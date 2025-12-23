// ============================================================
// MIDORI TAKADA - RITUAL EXTENDED - MIDI FILE EXPORT
// Generates a MIDI file of the piece
// ============================================================
// Requires SimpleMIDIFile quark:
//   Quarks.install("SimpleMIDIFile");

(
var m, pattern, accents, phraseLen, stepDur;
var totalDuration, introEnd, developEnd, peakEnd, breakdownEnd;
var numPhrases, getTimbre, getDensity;
var freqToMidi;

// Output path
~midiPath = "~/Music/midori_takada_ritual.mid".standardizePath;

// Helper: freq to MIDI note
freqToMidi = { |freq| (12 * (freq / 440).log2 + 69).round.asInteger };

// ---- Parameters ----
totalDuration = 180;
phraseLen = 1.2;
stepDur = 0.15;
pattern = [220, 220, 262, 220, 294, 262, 330, 294];
accents = [1, 0, 0, 1, 0, 0, 1, 0];

introEnd = 20;
developEnd = 50;
peakEnd = 120;
breakdownEnd = 150;

// ---- Timbre/Density functions ----
getTimbre = { |time|
	var progress;
	case
		{ time < introEnd } { 0.1 + ((time / introEnd) * 0.1) }
		{ time < developEnd } {
			progress = (time - introEnd) / (developEnd - introEnd);
			0.2 + (progress * 0.65)
		}
		{ time < peakEnd } {
			progress = (time - developEnd) / (peakEnd - developEnd);
			0.85 + ((progress * 2 * pi).sin * 0.15)
		}
		{ time < breakdownEnd } {
			progress = (time - peakEnd) / (breakdownEnd - peakEnd);
			0.9 - (progress * 0.6)
		}
		{
			progress = (time - breakdownEnd) / (totalDuration - breakdownEnd);
			0.3 - (progress * 0.2)
		}
};

getDensity = { |time|
	var progress;
	case
		{ time < introEnd } { 0.4 }
		{ time < developEnd } {
			progress = (time - introEnd) / (developEnd - introEnd);
			0.4 + (progress * 0.55)
		}
		{ time < peakEnd } { 1.0 }
		{ time < breakdownEnd } {
			progress = (time - peakEnd) / (breakdownEnd - peakEnd);
			0.95 - (progress * 0.55)
		}
		{ 0.35 }
};

// ---- Create MIDI file ----
m = SimpleMIDIFile(~midiPath);
m.init1(1, 120, "4/4");  // 1 track, 120 BPM, 4/4 time

// MIDI channels:
// 0 = Marimba (pulse)
// 1 = Gong
// 2 = Wood blocks
// 3 = High fills
// 4 = Sparkle

numPhrases = (totalDuration / phraseLen).floor.asInteger;

// Opening gong
m.addNote(36, 100, 0, 4, 1);  // Low C, vel 100, time 0, dur 4 beats, channel 1

numPhrases.do { |phraseNum|
	var phraseStart, timbre, density, time, vel;
	phraseStart = phraseNum * phraseLen;
	timbre = getTimbre.value(phraseStart);
	density = getDensity.value(phraseStart);

	// Convert time to beats (at 120 BPM, 1 sec = 2 beats)
	phraseStart = phraseStart * 2;

	// Gong scheduling
	if (phraseStart < (introEnd * 2)) {
		if ((phraseNum % 12 == 0) and: (phraseNum > 0)) {
			m.addNote(36, 80, phraseStart, 4, 1);
		};
	};
	if ((phraseStart >= (introEnd * 2)) and: (phraseStart < (developEnd * 2))) {
		if (phraseNum % 10 == 0) {
			m.addNote(36, 90, phraseStart, 3.5, 1);
		};
	};
	if ((phraseStart >= (developEnd * 2)) and: (phraseStart < (peakEnd * 2))) {
		if (phraseNum % 7 == 0) {
			m.addNote(36, 100, phraseStart, 3, 1);
		};
	};
	if ((phraseStart >= (peakEnd * 2)) and: (phraseStart < (breakdownEnd * 2))) {
		if (phraseNum % 15 == 0) {
			m.addNote(36, 80, phraseStart, 4, 1);
		};
	};

	// Marimba pattern
	8.do { |step|
		var noteTime, freq, midi, isAccent, dur;
		noteTime = phraseStart + (step * stepDur * 2);
		freq = pattern[step];
		midi = freqToMidi.value(freq);
		isAccent = accents[step] == 1;

		if (isAccent or: (density > 0.5.rand)) {
			vel = if(isAccent, (100 * density).asInteger, (70 * density).asInteger);
			dur = if(isAccent, 0.5, 0.25);
			m.addNote(midi, vel.clip(40, 127), noteTime, dur, 0);
		};
	};

	// Wood blocks
	if ((phraseStart >= (introEnd * 2)) and: (phraseStart < (breakdownEnd * 2))) {
		if ((phraseNum % 2 == 0) and: (density > 0.6)) {
			m.addNote(76, (60 * density).asInteger, phraseStart, 0.1, 2);  // High E
		};
		if ((phraseNum % 3 == 0) and: (density > 0.7)) {
			m.addNote(77, (50 * density).asInteger, phraseStart + (3 * stepDur * 2), 0.1, 2);
		};
	};

	// Movement layer (high fills)
	if ((phraseStart >= (35 * 2)) and: (phraseStart < (peakEnd * 2))) {
		if (density > 0.7) {
			m.addNote(freqToMidi.value(pattern.choose * 2), (80 * density).asInteger,
				phraseStart + (5 * stepDur * 2), 0.3, 3);
		};
		if ((phraseNum % 2 == 0) and: (density > 0.8)) {
			m.addNote(freqToMidi.value(pattern.choose * 2), (70 * density).asInteger,
				phraseStart + (2 * stepDur * 2), 0.25, 3);
		};
	};

	// Sparkle layer
	if ((phraseStart >= (developEnd * 2)) and: (phraseStart < (peakEnd * 2))) {
		if (phraseNum % 2 == 1) {
			m.addNote(freqToMidi.value(pattern.choose * 4), 50,
				phraseStart + (4 * stepDur * 2), 0.15, 4);
		};
		if (phraseNum % 3 == 0) {
			m.addNote(freqToMidi.value(pattern.choose * 4), 45,
				phraseStart + (7 * stepDur * 2), 0.12, 4);
		};
	};
};

// Final gong
m.addNote(36, 100, (totalDuration - 5) * 2, 6, 1);

// Write file
m.write;

"MIDI file written to: %".format(~midiPath).postln;
"Channels: 0=Marimba, 1=Gong, 2=WoodBlock, 3=Fills, 4=Sparkle".postln;
)
