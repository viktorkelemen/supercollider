#!/Library/Developer/CommandLineTools/usr/bin/python3
"""
Audio to MIDI converter
Extracts melody from audio and creates a MIDI file

Best for: Monophonic melodies, vocal lines, bass lines, lead synths
Not suitable for: Drums, complex polyphonic content, chords

Usage: python3 audio_to_midi.py <audio_file> [output.mid]

Requires: aubio (CLI), midiutil (Python)
"""

import subprocess
import sys
import os
from midiutil import MIDIFile

def hz_to_midi(freq):
    """Convert frequency in Hz to MIDI note number"""
    if freq <= 0:
        return None
    import math
    return int(round(69 + 12 * math.log2(freq / 440.0)))

def midi_to_note_name(midi_num):
    """Convert MIDI number to note name"""
    notes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    octave = (midi_num // 12) - 1
    note = notes[midi_num % 12]
    return f"{note}{octave}"

def extract_pitch(audio_file, hop_size=256):
    """Extract pitch using aubiopitch"""
    result = subprocess.run(
        ['aubiopitch', '-i', audio_file, '-H', str(hop_size), '-p', 'yinfft'],
        capture_output=True, text=True
    )

    pitches = []
    for line in result.stdout.strip().split('\n'):
        if line:
            parts = line.split()
            if len(parts) >= 2:
                time = float(parts[0])
                freq = float(parts[1])
                pitches.append((time, freq))

    return pitches

def extract_onsets(audio_file):
    """Extract note onsets using aubioonset"""
    result = subprocess.run(
        ['aubioonset', '-i', audio_file],
        capture_output=True, text=True
    )

    onsets = []
    for line in result.stdout.strip().split('\n'):
        if line:
            onsets.append(float(line))

    return onsets

def estimate_tempo(audio_file):
    """Estimate tempo using aubio"""
    result = subprocess.run(
        ['aubio', 'tempo', '-i', audio_file],
        capture_output=True, text=True
    )

    # Get average tempo from output
    tempos = []
    for line in result.stdout.strip().split('\n'):
        if line:
            try:
                tempos.append(float(line))
            except:
                pass

    if tempos:
        return sum(tempos) / len(tempos)
    return 120.0  # Default

def pitches_to_notes(pitches, onsets, min_duration=0.05, confidence_threshold=0.0):
    """Convert pitch data to discrete notes based on onsets"""
    if not onsets:
        # If no onsets detected, create notes from pitch changes
        return pitches_to_notes_simple(pitches, min_duration)

    notes = []

    for i, onset_time in enumerate(onsets):
        # Find end time (next onset or end of track)
        if i + 1 < len(onsets):
            end_time = onsets[i + 1]
        else:
            # Use last pitch time + small buffer
            end_time = pitches[-1][0] + 0.1 if pitches else onset_time + 0.5

        # Get average pitch during this note
        note_pitches = [p[1] for p in pitches if onset_time <= p[0] < end_time and p[1] > 0]

        if note_pitches:
            avg_freq = sum(note_pitches) / len(note_pitches)
            midi_note = hz_to_midi(avg_freq)
            duration = end_time - onset_time

            if midi_note and duration >= min_duration:
                notes.append({
                    'time': onset_time,
                    'duration': duration,
                    'pitch': midi_note,
                    'freq': avg_freq,
                    'velocity': 100
                })

    return notes

def pitches_to_notes_simple(pitches, min_duration=0.05):
    """Simple pitch to notes without onset detection"""
    notes = []
    current_note = None
    current_start = None

    for time, freq in pitches:
        midi_note = hz_to_midi(freq) if freq > 0 else None

        if midi_note != current_note:
            # Save previous note
            if current_note is not None and current_start is not None:
                duration = time - current_start
                if duration >= min_duration:
                    notes.append({
                        'time': current_start,
                        'duration': duration,
                        'pitch': current_note,
                        'velocity': 100
                    })

            current_note = midi_note
            current_start = time

    # Save last note
    if current_note is not None and current_start is not None:
        duration = pitches[-1][0] - current_start + 0.1
        if duration >= min_duration:
            notes.append({
                'time': current_start,
                'duration': duration,
                'pitch': current_note,
                'velocity': 100
            })

    return notes

def quantize_notes(notes, bpm, quantize_grid=16):
    """Quantize note times to grid (e.g., 16th notes)"""
    beat_duration = 60.0 / bpm
    grid_duration = beat_duration / (quantize_grid / 4)

    for note in notes:
        # Quantize start time
        grid_units = round(note['time'] / grid_duration)
        note['time'] = grid_units * grid_duration

        # Quantize duration
        dur_units = max(1, round(note['duration'] / grid_duration))
        note['duration'] = dur_units * grid_duration

    return notes

def create_midi(notes, output_file, bpm=120):
    """Create MIDI file from notes"""
    midi = MIDIFile(1)  # One track
    track = 0
    channel = 0
    time_offset = 0

    midi.addTempo(track, 0, bpm)
    midi.addProgramChange(track, channel, 0, 0)  # Piano

    # Convert seconds to beats
    for note in notes:
        beat_time = (note['time'] * bpm) / 60.0
        beat_duration = (note['duration'] * bpm) / 60.0

        midi.addNote(
            track,
            channel,
            note['pitch'],
            beat_time,
            beat_duration,
            note['velocity']
        )

    with open(output_file, 'wb') as f:
        midi.writeFile(f)

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 audio_to_midi.py <audio_file> [output.mid] [--quantize]")
        print("")
        print("Options:")
        print("  --quantize    Quantize notes to 16th note grid")
        print("  --no-onsets   Don't use onset detection (for drones/pads)")
        sys.exit(1)

    audio_file = sys.argv[1]

    # Parse output file
    output_file = None
    for arg in sys.argv[2:]:
        if arg.endswith('.mid') or arg.endswith('.midi'):
            output_file = arg
            break

    if not output_file:
        base = os.path.splitext(audio_file)[0]
        output_file = f"{base}.mid"

    quantize = '--quantize' in sys.argv
    use_onsets = '--no-onsets' not in sys.argv

    print(f"Processing: {audio_file}")
    print(f"Output: {output_file}")
    print("")

    # Extract pitch
    print("Extracting pitch...")
    pitches = extract_pitch(audio_file)
    print(f"  Found {len(pitches)} pitch samples")

    # Extract onsets
    onsets = []
    if use_onsets:
        print("Detecting onsets...")
        onsets = extract_onsets(audio_file)
        print(f"  Found {len(onsets)} onsets")

    # Estimate tempo
    print("Estimating tempo...")
    bpm = estimate_tempo(audio_file)
    print(f"  Estimated BPM: {bpm:.1f}")

    # Convert to notes
    print("Converting to notes...")
    notes = pitches_to_notes(pitches, onsets)
    print(f"  Created {len(notes)} notes")

    if not notes:
        print("Error: No notes detected. The audio might be:")
        print("  - Too quiet or noisy")
        print("  - Polyphonic (chords) - this tool works best with monophonic melodies")
        print("  - Percussive/non-pitched")
        sys.exit(1)

    # Quantize if requested
    if quantize:
        print("Quantizing to 16th notes...")
        notes = quantize_notes(notes, bpm)

    # Show detected notes
    print("")
    print("Detected notes:")
    print("-" * 50)
    for i, note in enumerate(notes[:20]):  # Show first 20
        note_name = midi_to_note_name(note['pitch'])
        print(f"  {note['time']:6.2f}s  {note_name:4s} (MIDI {note['pitch']:3d})  dur: {note['duration']:.2f}s")

    if len(notes) > 20:
        print(f"  ... and {len(notes) - 20} more notes")

    # Create MIDI
    print("")
    print(f"Writing MIDI file: {output_file}")
    create_midi(notes, output_file, bpm)
    print("Done!")

    # Summary
    print("")
    print("=" * 50)
    print("Summary:")
    print(f"  Notes: {len(notes)}")
    print(f"  BPM: {bpm:.1f}")
    print(f"  Duration: {notes[-1]['time'] + notes[-1]['duration']:.1f}s")

    # Pitch range
    pitches_midi = [n['pitch'] for n in notes]
    print(f"  Range: {midi_to_note_name(min(pitches_midi))} - {midi_to_note_name(max(pitches_midi))}")

if __name__ == '__main__':
    main()
