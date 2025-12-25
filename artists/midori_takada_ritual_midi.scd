// ============================================================
// MIDORI TAKADA - RITUAL EXTENDED - MIDI FILE EXPORT
// Generates separate MIDI files for each voice
// ============================================================
// Requires wslib quark: Quarks.install("wslib");

(
var pattern, accents, phraseLen, stepDur;
var totalDuration, introEnd, developEnd, peakEnd, breakdownEnd;
var numPhrases, getTimbre, getDensity;
var freqToMidi;
var mMarimba, mGong, mWoodBlock, mFills, mSparkle, mAll;
var basePath;

// Output path base
basePath = "~/Music/midori_takada_ritual".standardizePath;

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

// ---- Create MIDI files ----
// Separate file for each voice
mMarimba = SimpleMIDIFile(basePath ++ "_marimba.mid");
mGong = SimpleMIDIFile(basePath ++ "_gong.mid");
mWoodBlock = SimpleMIDIFile(basePath ++ "_woodblock.mid");
mFills = SimpleMIDIFile(basePath ++ "_fills.mid");
mSparkle = SimpleMIDIFile(basePath ++ "_sparkle.mid");
mAll = SimpleMIDIFile(basePath ++ "_all.mid");

// Initialize all files
[mMarimba, mGong, mWoodBlock, mFills, mSparkle].do { |m|
	m.init1(1, 120, "4/4");
	m.timeMode = \seconds;
};
mAll.init1(5, 120, "4/4");
mAll.timeMode = \seconds;

numPhrases = (totalDuration / phraseLen).floor.asInteger;

// Opening gong
mGong.addNote(36, 100, 0.1, 8, 0);
mAll.addNote(36, 100, 0.1, 8, 1);

numPhrases.do { |phraseNum|
	var phraseStart, timbre, density, vel;
	phraseStart = phraseNum * phraseLen;
	timbre = getTimbre.value(phraseStart);
	density = getDensity.value(phraseStart);

	// Gong scheduling
	if (phraseStart < introEnd) {
		if ((phraseNum % 12 == 0) and: (phraseNum > 0)) {
			mGong.addNote(36, 80, phraseStart, 6, 0);
			mAll.addNote(36, 80, phraseStart, 6, 1);
		};
	};
	if ((phraseStart >= introEnd) and: (phraseStart < developEnd)) {
		if (phraseNum % 10 == 0) {
			mGong.addNote(36, 90, phraseStart, 5, 0);
			mAll.addNote(36, 90, phraseStart, 5, 1);
		};
	};
	if ((phraseStart >= developEnd) and: (phraseStart < peakEnd)) {
		if (phraseNum % 7 == 0) {
			mGong.addNote(36, 100, phraseStart, 4, 0);
			mAll.addNote(36, 100, phraseStart, 4, 1);
		};
	};
	if ((phraseStart >= peakEnd) and: (phraseStart < breakdownEnd)) {
		if (phraseNum % 15 == 0) {
			mGong.addNote(36, 80, phraseStart, 6, 0);
			mAll.addNote(36, 80, phraseStart, 6, 1);
		};
	};

	// Marimba pattern
	8.do { |step|
		var noteTime, freq, midi, isAccent, dur;
		noteTime = phraseStart + (step * stepDur);
		freq = pattern[step];
		midi = freqToMidi.value(freq);
		isAccent = accents[step] == 1;

		if (isAccent or: (density > 0.5.rand)) {
			vel = if(isAccent, (100 * density).asInteger, (70 * density).asInteger);
			dur = if(isAccent, 1.0, 0.5);
			mMarimba.addNote(midi, vel.clip(40, 127), noteTime, dur, 0);
			mAll.addNote(midi, vel.clip(40, 127), noteTime, dur, 0);
		};
	};

	// Wood blocks
	if ((phraseStart >= introEnd) and: (phraseStart < breakdownEnd)) {
		if ((phraseNum % 2 == 0) and: (density > 0.6)) {
			mWoodBlock.addNote(76, (60 * density).asInteger, phraseStart, 0.1, 0);
			mAll.addNote(76, (60 * density).asInteger, phraseStart, 0.1, 2);
		};
		if ((phraseNum % 3 == 0) and: (density > 0.7)) {
			mWoodBlock.addNote(77, (50 * density).asInteger, phraseStart + (3 * stepDur), 0.1, 0);
			mAll.addNote(77, (50 * density).asInteger, phraseStart + (3 * stepDur), 0.1, 2);
		};
	};

	// Movement layer (high fills)
	if ((phraseStart >= 35) and: (phraseStart < peakEnd)) {
		if (density > 0.7) {
			var midi = freqToMidi.value(pattern.choose * 2);
			mFills.addNote(midi, (80 * density).asInteger, phraseStart + (5 * stepDur), 0.4, 0);
			mAll.addNote(midi, (80 * density).asInteger, phraseStart + (5 * stepDur), 0.4, 3);
		};
		if ((phraseNum % 2 == 0) and: (density > 0.8)) {
			var midi = freqToMidi.value(pattern.choose * 2);
			mFills.addNote(midi, (70 * density).asInteger, phraseStart + (2 * stepDur), 0.35, 0);
			mAll.addNote(midi, (70 * density).asInteger, phraseStart + (2 * stepDur), 0.35, 3);
		};
	};

	// Sparkle layer
	if ((phraseStart >= developEnd) and: (phraseStart < peakEnd)) {
		if (phraseNum % 2 == 1) {
			var midi = freqToMidi.value(pattern.choose * 4);
			mSparkle.addNote(midi, 50, phraseStart + (4 * stepDur), 0.25, 0);
			mAll.addNote(midi, 50, phraseStart + (4 * stepDur), 0.25, 4);
		};
		if (phraseNum % 3 == 0) {
			var midi = freqToMidi.value(pattern.choose * 4);
			mSparkle.addNote(midi, 45, phraseStart + (7 * stepDur), 0.2, 0);
			mAll.addNote(midi, 45, phraseStart + (7 * stepDur), 0.2, 4);
		};
	};
};

// Final gong
mGong.addNote(36, 100, totalDuration - 5, 10, 0);
mAll.addNote(36, 100, totalDuration - 5, 10, 1);

// Write all files
mMarimba.write;
mGong.write;
mWoodBlock.write;
mFills.write;
mSparkle.write;
mAll.write;

"MIDI files written to ~/Music/".postln;
"  - midori_takada_ritual_marimba.mid".postln;
"  - midori_takada_ritual_gong.mid".postln;
"  - midori_takada_ritual_woodblock.mid".postln;
"  - midori_takada_ritual_fills.mid".postln;
"  - midori_takada_ritual_sparkle.mid".postln;
"  - midori_takada_ritual_all.mid (all voices)".postln;
)
