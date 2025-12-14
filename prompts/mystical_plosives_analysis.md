# Analysis: mystical_plosives.wav

## Sound Classification

**Classifier result**: Pads/Textures (score: 70)
**Duration**: 16.5 seconds
**Sample rate**: 48kHz stereo

---

## Sound Profile

### Spectral Characteristics
- **Frequency range**: ~90Hz (F#2) to ~830Hz (G#5) fundamental, harmonics extend to ~8kHz
- **Spectral density**: Dense, layered, multiple voices
- **Brightness**: Moderate-bright (centroid ~3000-4000 Hz)
- **Spectral balance**: Balanced with strong mid presence
- **Harmonic vs noise content**: Mostly tonal (spectral flatness ~0.03-0.17)

### Tonal Content
- **Key**: C# minor / G# mixolydian feel
- **Primary pitch classes**: G#, C#, E, D#, B (in order of prevalence)
- **Chord implied**: C#m7 or E6/9 voicing
- **Interval content**: Minor thirds, perfect fourths, fifths
- **Detuning**: Slight natural detuning from multiple voices
- **Voice count**: 3-5 simultaneous voices (polyphonic)

### Detected Pitches (most common)
| Note | Count | Frequency |
|------|-------|-----------|
| C#4  | 391   | 277 Hz    |
| G#3  | 326   | 208 Hz    |
| G#4  | 286   | 415 Hz    |
| E4   | 275   | 330 Hz    |
| D#4  | 274   | 311 Hz    |
| C#3  | 255   | 139 Hz    |

---

## Temporal Evolution

### Overall Shape
- **Duration**: 16.5 seconds (continuous texture)
- **Amplitude contour**: Fade in over ~0.5s, then sustained with subtle breathing
- **Dynamic range**: ~10dB variation (RMS -28dB to -17dB)
- **Character**: Evolving pad with movement

### Spectral Movement
- **Filter movement**: Subtle modulation, not dramatic sweeps
- **Centroid variation**: 3000-4300 Hz range
- **Evolution**: Gradual timbral shifts, voices entering/exiting

---

## MIDI Export

A MIDI file was generated: `mystical_plosives.mid`
- **Notes extracted**: 115 notes
- **Range**: F#2 (MIDI 42) to G#5 (MIDI 80)
- **Estimated BPM**: 120 (default - this is a pad, not rhythmic)

Note: MIDI extraction on polyphonic content captures pitch jumps between voices rather than true polyphony.

---

## SuperCollider Recreation Approach

### Recommended Technique
- Multiple detuned oscillators in C#m voicing
- Slow filter modulation
- Layered voices with different octaves
- Rich reverb

### Suggested Voicing
```supercollider
// C#m7 voicing across octaves
// G#2 (103.83), C#3 (138.59), E3 (164.81), G#3 (207.65), B3 (246.94), C#4 (277.18), D#4 (311.13), E4 (329.63), G#4 (415.30)
```

### Suggested SynthDef
```supercollider
SynthDef(\mysticalPad, {
    arg out = 0, amp = 0.3, gate = 1,
        root = 138.59, // C#3
        cutoff = 3500, filterLFO = 0.08, filterDepth = 800;
    var sig, env, filt, voices;

    // Multiple voices in C#m voicing with detuning
    voices = [
        // Root layer
        Saw.ar(root * [1, 1.002, 0.998]),
        // Fifth (G#)
        Saw.ar(root * 1.498 * [1, 1.003, 0.997]),
        // Octave + third (E)
        Saw.ar(root * 2.378 * [1, 1.001, 0.999]) * 0.7,
        // High fifth (G#)
        Saw.ar(root * 2.996 * [1, 1.002]) * 0.5,
    ];

    sig = Mix(voices.flatten) * 0.08;

    // Slow filter movement
    filt = SinOsc.kr(filterLFO, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, filt, 0.4);

    // Stereo spread
    sig = Splay.ar(sig, spread: 0.7);

    // Envelope
    env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);

    // Reverb
    sig = sig + FreeVerb2.ar(sig[0], sig[1], mix: 0.5, room: 0.85, damp: 0.4);

    Out.ar(out, sig * env * amp);
}).add;
```

---

## LLM Prompt for Recreation

```
Recreate this pad sound in SuperCollider:

SPECTRAL CHARACTER:
- Frequency range: 100Hz - 800Hz fundamental, harmonics to 8kHz
- Tonal vs noise: Mostly tonal, warm character
- Brightness: Moderate-bright (centroid ~3500 Hz)
- Density: Dense, layered, 4-5 voices

TONAL CONTENT:
- Key: C# minor
- Primary notes: G#, C#, E, D#, B
- Chord: C#m7 or suspended voicing
- Detuning: Subtle (~2-3 cents between voices)
- Voice count: 4-5 simultaneous layers

EVOLUTION:
- Duration: Continuous pad (16+ seconds)
- Filter movement: Slow LFO (~0.08 Hz), ~800Hz depth
- Amplitude shape: Sustained with subtle breathing
- Modulation rates: Very slow (10-15 second cycles)

STEREO & SPACE:
- Width: Wide stereo spread
- Reverb: Medium-large hall, ~3-4 second decay
- Movement: Subtle stereo drift

Create a SynthDef with multiple detuned saw voices in a C#m7 voicing,
slow filter modulation, wide stereo spread via Splay, and built-in reverb.
Sound should be warm, evolving, and work as an atmospheric texture.
```
