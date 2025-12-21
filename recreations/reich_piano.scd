// ============================================================
// STEVE REICH STYLE - Phasing and minimalist piano patterns
// ============================================================
// Inspired by:
// - Piano Phase (1967) - two pianos, gradual phase shifting
// - Six Pianos (1973) - interlocking patterns, additive process
// - Music for 18 Musicians - pulses and breathing

// --------------------------------------------------
// PIANO SYNTH - Simple percussive piano tone
// --------------------------------------------------
(
SynthDef(\reichPiano, {
	arg out = 0, freq = 440, amp = 0.3, dur = 0.3, pan = 0, brightness = 1;
	var sig, env, harmonics;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);

	// Piano-like tone: fundamental + harmonics with quick decay
	harmonics = [1, 2, 3, 4, 5, 6, 7, 8];
	sig = Mix.fill(harmonics.size, { |i|
		var partial = harmonics[i];
		var partialAmp = 1 / (partial ** 1.5);  // Natural harmonic decay
		var partialEnv = EnvGen.kr(Env.perc(0.005, dur / (partial.sqrt), 1, -8));
		SinOsc.ar(freq * partial) * partialAmp * partialEnv;
	});

	// Slight attack transient
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 4, 0.3) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.15);

	// Brightness control
	sig = LPF.ar(sig, freq * brightness * 8);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// MALLET SYNTH - Vibraphone-like for variety
// --------------------------------------------------
(
SynthDef(\reichMallet, {
	arg out = 0, freq = 440, amp = 0.25, dur = 1, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);

	// Vibraphone-like: fundamental + slight inharmonics
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + SinOsc.ar(freq * 2.001) * 0.25;
	sig = sig + SinOsc.ar(freq * 3.997) * 0.1;
	sig = sig + SinOsc.ar(freq * 5.003) * 0.05;

	// Gentle tremolo (like vibraphone motor)
	sig = sig * (1 + (SinOsc.kr(5) * 0.05));

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: PIANO PHASE
// Two identical patterns, one gradually speeds up
// --------------------------------------------------
(
// The classic Piano Phase pattern (12 notes)
~pianoPhasePattern = [64, 66, 71, 73, 74, 66, 64, 73, 71, 66, 74, 73];  // E4 F#4 B4 C#5 D5...

~phaseVoice = { |pattern, tempo, pan = 0, amp = 0.2|
	Routine({
		var index = 0;
		inf.do {
			var note = pattern[index % pattern.size];
			Synth(\reichPiano, [
				\freq, note.midicps,
				\amp, amp,
				\dur, 0.2,
				\pan, pan,
				\brightness, 1.5
			]);
			index = index + 1;
			(60 / tempo / 2).wait;  // Eighth notes
		};
	});
};

// Voice 1: Fixed tempo
~voice1 = ~phaseVoice.value(~pianoPhasePattern, 120, -0.5, 0.18);

// Voice 2: Slightly faster (phases ahead)
~voice2 = ~phaseVoice.value(~pianoPhasePattern, 120.15, 0.5, 0.18);

~voice1.play;
~voice2.play;

"PIANO PHASE - Listen for the patterns to gradually shift".postln;
)

// Stop phase experiment
// ~voice1.stop; ~voice2.stop;

// --------------------------------------------------
// EXPERIMENT 2: CLAPPING MUSIC STYLE
// Pattern with rests, one voice shifts by one beat
// --------------------------------------------------
(
// 1 = clap, 0 = rest (the original Clapping Music pattern)
~clapPattern = [1, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0];

~clapVoice = { |pattern, offset = 0, pan = 0, amp = 0.15|
	Routine({
		var index = 0;
		var tempo = 160;
		inf.do {
			var pos = (index + offset) % pattern.size;
			if (pattern[pos] == 1) {
				Synth(\reichPiano, [
					\freq, 72.midicps,  // C5
					\amp, amp,
					\dur, 0.08,
					\pan, pan,
					\brightness, 2
				]);
			};
			index = index + 1;
			(60 / tempo).wait;
		};
	});
};

~clap1 = ~clapVoice.value(~clapPattern, 0, -0.4, 0.15);
~clap2 = ~clapVoice.value(~clapPattern, 0, 0.4, 0.15);

~clap1.play;
~clap2.play;

// Shift voice 2 every 12 bars
~shiftRoutine = Routine({
	var currentOffset = 0;
	12.do { |bar|
		(60 / 160 * 12 * 4).wait;  // Wait 4 bars
		currentOffset = (currentOffset + 1) % 12;
		~clap2.stop;
		~clap2 = ~clapVoice.value(~clapPattern, currentOffset, 0.4, 0.15);
		~clap2.play;
		("Shift " ++ (currentOffset + 1) ++ "/12").postln;
	};
	"Pattern complete - back to unison".postln;
}).play;

"CLAPPING MUSIC - Pattern shifts every 4 bars".postln;
)

// Stop clapping experiment
// ~clap1.stop; ~clap2.stop; ~shiftRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: SIX PIANOS STYLE
// Interlocking resultant patterns
// --------------------------------------------------
(
// Base pattern - simple ascending figure
~sixPianoPatterns = [
	[60, 64, 67],           // Voice 1: C E G (arpeggiated)
	[nil, 62, 65, 69],      // Voice 2: rest, D F A
	[60, nil, 67, nil, 72], // Voice 3: C rest G rest C
	[nil, nil, 64, 67],     // Voice 4: rests then E G
	[55, 60, nil, 67],      // Voice 5: G C rest G
	[nil, 62, nil, 69]      // Voice 6: rest D rest A
];

~sixPianoVoice = { |pattern, pan = 0, amp = 0.12, tempo = 140|
	Routine({
		var index = 0;
		inf.do {
			var note = pattern[index % pattern.size];
			if (note.notNil) {
				Synth(\reichPiano, [
					\freq, note.midicps,
					\amp, amp * rrand(0.9, 1.1),  // Slight human variation
					\dur, 0.15,
					\pan, pan,
					\brightness, 1.2
				]);
			};
			index = index + 1;
			(60 / tempo).wait;
		};
	});
};

// Start all six voices with spread panning
~sixVoices = ~sixPianoPatterns.collect { |pattern, i|
	var pan = i.linlin(0, 5, -0.7, 0.7);
	~sixPianoVoice.value(pattern, pan, 0.1, 140);
};

~sixVoices.do(_.play);

"SIX PIANOS - Interlocking resultant patterns".postln;
)

// Stop six pianos
// ~sixVoices.do(_.stop);

// --------------------------------------------------
// EXPERIMENT 4: ADDITIVE PROCESS
// Pattern builds up note by note (like Drumming)
// --------------------------------------------------
(
~additivePattern = [60, 64, 67, 72, 76, 79, 72, 67];  // C major arpeggio extended
~activeNotes = 1;  // Start with just first note

~additiveVoice = { |pan = 0|
	Routine({
		var index = 0;
		var tempo = 180;
		inf.do {
			var noteIndex = index % ~activeNotes.min(~additivePattern.size);
			var note = ~additivePattern[noteIndex];
			Synth(\reichMallet, [
				\freq, note.midicps,
				\amp, 0.15,
				\dur, 0.4,
				\pan, pan
			]);
			index = index + 1;
			(60 / tempo).wait;
		};
	});
};

~addVoice1 = ~additiveVoice.value(-0.3);
~addVoice2 = ~additiveVoice.value(0.3);

~addVoice1.play;
~addVoice2.play;

// Gradually add notes
~buildRoutine = Routine({
	~additivePattern.size.do { |i|
		~activeNotes = i + 1;
		("Notes active: " ++ ~activeNotes).postln;
		4.wait;  // Add a note every 4 seconds
	};
	"Full pattern reached".postln;
}).play;

"ADDITIVE PROCESS - Pattern builds note by note".postln;
)

// Stop additive
// ~addVoice1.stop; ~addVoice2.stop; ~buildRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: PULSE / BREATHING (Music for 18)
// Sustained chords with pulsing
// --------------------------------------------------
(
SynthDef(\reichPulse, {
	arg out = 0, freq = 440, amp = 0.2, dur = 4, pulseRate = 3, pan = 0;
	var sig, env, pulse;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5, 1, \sin), doneAction: 2);

	// Organ-like sustained tone
	sig = Mix([
		SinOsc.ar(freq) * 0.5,
		SinOsc.ar(freq * 2) * 0.25,
		SinOsc.ar(freq * 3) * 0.12,
		SinOsc.ar(freq * 4) * 0.08
	]);

	// Pulsing amplitude
	pulse = SinOsc.kr(pulseRate).range(0.3, 1);

	sig = sig * env * pulse * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

(
~pulseChords = [
	[48, 55, 60, 64, 67],  // C chord
	[50, 57, 62, 65, 69],  // D minor
	[48, 55, 60, 64, 67],  // C chord
	[45, 52, 57, 60, 64],  // A minor
];

~pulseRoutine = Routine({
	inf.do { |chordIndex|
		var chord = ~pulseChords[chordIndex % ~pulseChords.size];
		var dur = rrand(6.0, 10.0);
		var pulseRate = rrand(2.5, 4.0);

		chord.do { |note, i|
			var pan = i.linlin(0, chord.size - 1, -0.5, 0.5);
			Synth(\reichPulse, [
				\freq, note.midicps,
				\amp, 0.08,
				\dur, dur,
				\pulseRate, pulseRate + rrand(-0.1, 0.1),
				\pan, pan
			]);
		};

		(dur * 0.8).wait;  // Overlap slightly
	};
}).play;

"PULSE BREATHING - Sustained chords with rhythmic pulsing".postln;
)

// Stop pulse
// ~pulseRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 6: GENERATIVE REICH
// Combines phasing with pattern generation
// --------------------------------------------------
(
// Pentatonic scale for Reich-like tonality
~scale = [0, 2, 4, 7, 9];  // Pentatonic
~baseNote = 60;  // C4

~generatePattern = { |length = 8|
	Array.fill(length, {
		~baseNote + ~scale.choose + ([0, 12].choose);  // Random octave
	});
};

~generativeVoice = { |seedPattern, tempoOffset = 0, pan = 0, amp = 0.15|
	var pattern = seedPattern;
	Routine({
		var index = 0;
		var baseTempo = 144;
		inf.do {
			var note = pattern[index % pattern.size];
			Synth(\reichPiano, [
				\freq, note.midicps,
				\amp, amp,
				\dur, 0.18,
				\pan, pan,
				\brightness, 1.3
			]);
			index = index + 1;
			(60 / (baseTempo + tempoOffset)).wait;
		};
	});
};

// Generate a pattern and phase it
~seedPattern = ~generatePattern.value(12);
("Pattern: " ++ ~seedPattern).postln;

~genVoice1 = ~generativeVoice.value(~seedPattern, 0, -0.4, 0.14);
~genVoice2 = ~generativeVoice.value(~seedPattern, 0.2, 0, 0.14);
~genVoice3 = ~generativeVoice.value(~seedPattern, 0.4, 0.4, 0.14);

~genVoice1.play;
~genVoice2.play;
~genVoice3.play;

"GENERATIVE REICH - Random pattern with 3-voice phasing".postln;
)

// Regenerate pattern
// ~genVoice1.stop; ~genVoice2.stop; ~genVoice3.stop;
// Run the block again for new pattern

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
