// ============================================================
// CATERINA BARBIERI STYLE - Sequencer-based minimalism
// ============================================================
// Inspired by "Ecstatic Computation":
// - Buchla-style stepped sequences
// - Harmonic series explorations
// - Polyrhythmic clock divisions
// - Slow transformations of repeating patterns
// - Psychoacoustic phenomena through repetition
//
// NOTE: Drone synths (\harmonicDrone, \harmonicVoice) have no doneAction
// and must be manually freed. This is intentional for sustained drones.

// --------------------------------------------------
// STEPPED OSCILLATOR - Core melodic voice
// --------------------------------------------------
(
SynthDef(\steppedOsc, {
	arg out = 0, amp = 0.2, freq = 200, gate = 1,
		glide = 0.02, brightness = 0.5, waveFold = 0;
	var sig, env, fenv;

	env = EnvGen.kr(Env.asr(0.01, 1, 0.05), gate, doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.01, 0.1, 1, -4));

	// Portamento
	freq = Lag.kr(freq, glide);

	// Complex waveform - mix of saw and pulse
	sig = LFSaw.ar(freq) * 0.5;
	sig = sig + (Pulse.ar(freq, LFNoise2.kr(0.1).range(0.3, 0.7)) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	// Wave folding for harmonic richness
	sig = (sig * (1 + (waveFold * 2))).fold(-1, 1);

	// Lowpass with envelope
	sig = LPF.ar(sig, freq * (2 + (brightness * 8)) + (fenv * freq * 3));
	sig = HPF.ar(sig, 60);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// HARMONIC DRONE - Sustaining harmonic foundation
// --------------------------------------------------
(
SynthDef(\harmonicDrone, {
	arg out = 0, amp = 0.15, root = 55, numPartials = 8;
	var sig;

	sig = Mix.fill(numPartials, { |i|
		var partial = i + 1;
		var freq = root * partial;
		var detune = LFNoise2.kr(0.02 + (i * 0.01)).range(0.998, 1.002);
		var vibrato = SinOsc.kr(0.1 + (i * 0.02)).range(0.999, 1.001);
		var partialAmp = 1 / partial.sqrt;

		SinOsc.ar(freq * detune * vibrato) * partialAmp *
		LFNoise2.kr(0.05 + (i * 0.02)).range(0.5, 1);
	});

	sig = sig * LFNoise2.kr(0.02).range(0.8, 1);
	sig = LPF.ar(sig, 4000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SEQUENCER CLOCK - Multiple clock divisions
// --------------------------------------------------
(
SynthDef(\seqClock, {
	arg out = 0, bpm = 120, division = 1;
	var trig;
	trig = Impulse.kr(bpm / 60 * division);
	Out.kr(out, trig);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: ECSTATIC SEQUENCE
// Single voice with shifting intervals
// --------------------------------------------------
(
~exp1 = ();  // Namespace for experiment 1

// Define the scale - just intonation ratios
~exp1.ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];
~exp1.root = 110;

// Sequence patterns
~exp1.patterns = [
	[0, 2, 4, 7, 4, 2, 0, 4],
	[0, 0, 4, 4, 2, 2, 7, 7],
	[7, 4, 2, 0, 7, 4, 2, 0],
	[0, 4, 7, 4, 0, 2, 4, 2]
];

~exp1.currentPattern = 0;
~exp1.step = 0;
~exp1.patternLength = 8;

// Harmonic drone
~exp1.drone = Synth(\harmonicDrone, [\root, ~exp1.root / 2, \amp, 0.08, \numPartials, 6]);

// Melodic voice
~exp1.voice = Synth(\steppedOsc, [
	\freq, ~exp1.root,
	\amp, 0.2,
	\glide, 0.03,
	\brightness, 0.4
]);

// Sequencer routine
~exp1.routine = Routine({
	var tempo = 0.15; // 100ms per step
	inf.do { |i|
		var pattern = ~exp1.patterns[~exp1.currentPattern];
		var degree = pattern.wrapAt(~exp1.step);
		var freq = ~exp1.root * ~exp1.ratios.wrapAt(degree);

		~exp1.voice.set(\freq, freq);

		// Occasionally change pattern
		if ((i % 64 == 0) && (0.3.coin)) {
			~exp1.currentPattern = (~exp1.currentPattern + 1) % ~exp1.patterns.size;
			"Pattern change -> %".format(~exp1.currentPattern).postln;
		};

		~exp1.step = ~exp1.step + 1;
		tempo.wait;
	};
}).play;

"ECSTATIC SEQUENCE - Stepped minimalism".postln;
)

// Stop experiment 1
// ~exp1.routine.stop; ~exp1.voice.free; ~exp1.drone.free;

// --------------------------------------------------
// EXPERIMENT 2: POLYRHYTHMIC VOICES
// Multiple voices at different clock divisions
// --------------------------------------------------
(
~exp2 = ();  // Namespace for experiment 2
~exp2.root = 110;
~exp2.ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];

// Different patterns for each voice
~exp2.pattern1 = [0, 4, 7, 4];  // 4 steps
~exp2.pattern2 = [0, 2, 4, 5, 7, 5];  // 6 steps
~exp2.pattern3 = [7, 7, 4, 4, 2, 0, 2, 4];  // 8 steps

// Create voices
~exp2.voice1 = Synth(\steppedOsc, [\freq, ~exp2.root, \amp, 0.15, \glide, 0.02, \brightness, 0.3]);
~exp2.voice2 = Synth(\steppedOsc, [\freq, ~exp2.root * 2, \amp, 0.12, \glide, 0.03, \brightness, 0.5]);
~exp2.voice3 = Synth(\steppedOsc, [\freq, ~exp2.root / 2, \amp, 0.18, \glide, 0.01, \brightness, 0.2]);

// Drone
~exp2.drone = Synth(\harmonicDrone, [\root, ~exp2.root / 2, \amp, 0.06]);

~exp2.step1 = 0; ~exp2.step2 = 0; ~exp2.step3 = 0;

// Voice 1 - fastest
~exp2.routine1 = Routine({
	var tempo = 0.12;
	inf.do {
		var deg = ~exp2.pattern1.wrapAt(~exp2.step1);
		~exp2.voice1.set(\freq, ~exp2.root * ~exp2.ratios.wrapAt(deg));
		~exp2.step1 = ~exp2.step1 + 1;
		tempo.wait;
	};
}).play;

// Voice 2 - medium
~exp2.routine2 = Routine({
	var tempo = 0.18;
	inf.do {
		var deg = ~exp2.pattern2.wrapAt(~exp2.step2);
		~exp2.voice2.set(\freq, ~exp2.root * 2 * ~exp2.ratios.wrapAt(deg));
		~exp2.step2 = ~exp2.step2 + 1;
		tempo.wait;
	};
}).play;

// Voice 3 - slowest
~exp2.routine3 = Routine({
	var tempo = 0.24;
	inf.do {
		var deg = ~exp2.pattern3.wrapAt(~exp2.step3);
		~exp2.voice3.set(\freq, ~exp2.root / 2 * ~exp2.ratios.wrapAt(deg));
		~exp2.step3 = ~exp2.step3 + 1;
		tempo.wait;
	};
}).play;

"POLYRHYTHMIC VOICES - Phase relationships".postln;
)

// Stop experiment 2
// ~exp2.routine1.stop; ~exp2.routine2.stop; ~exp2.routine3.stop;
// ~exp2.voice1.free; ~exp2.voice2.free; ~exp2.voice3.free; ~exp2.drone.free;

// --------------------------------------------------
// EXPERIMENT 3: HARMONIC SWEEP
// Sequence through the harmonic series
// --------------------------------------------------
(
SynthDef(\harmonicVoice, {
	arg out = 0, amp = 0.2, root = 55, partial = 1, brightness = 0.5;
	var sig, env, freq;

	freq = root * partial;

	// Pure sine with subtle overtone
	sig = SinOsc.ar(freq) * 0.7;
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);

	// Gentle amplitude variation
	sig = sig * LFNoise2.kr(0.1).range(0.8, 1);

	sig = LPF.ar(sig, freq * (2 + (brightness * 4)));
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

~exp3 = ();  // Namespace for experiment 3
~exp3.root = 55;
~exp3.maxPartial = 16;
~exp3.currentPartial = 1;

~exp3.voice = Synth(\harmonicVoice, [\root, ~exp3.root, \partial, 1, \amp, 0.2]);

// Slow sweep through harmonics
~exp3.routine = Routine({
	var tempo = 0.8;
	inf.do { |i|
		// Move up and down through harmonics
		if (i % (~exp3.maxPartial * 2) < ~exp3.maxPartial) {
			~exp3.currentPartial = (i % ~exp3.maxPartial) + 1;
		} {
			~exp3.currentPartial = ~exp3.maxPartial - (i % ~exp3.maxPartial);
		};

		~exp3.voice.set(\partial, ~exp3.currentPartial.clip(1, ~exp3.maxPartial));
		"Partial: %".format(~exp3.currentPartial).postln;

		tempo.wait;
	};
}).play;

"HARMONIC SWEEP - Ascending and descending partials".postln;
)

// Stop experiment 3
// ~exp3.routine.stop; ~exp3.voice.free;

// --------------------------------------------------
// EXPERIMENT 4: PATTERN MORPHING
// Gradual transformation of sequences
// --------------------------------------------------
(
~exp4 = ();  // Namespace for experiment 4
~exp4.root = 110;
~exp4.ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];

// Two patterns to morph between
~exp4.patternA = [0, 2, 4, 5, 7, 5, 4, 2];
~exp4.patternB = [7, 5, 4, 2, 0, 2, 4, 5];

~exp4.morphAmount = 0;  // 0 = pattern A, 1 = pattern B

~exp4.voice = Synth(\steppedOsc, [
	\freq, ~exp4.root,
	\amp, 0.22,
	\glide, 0.04,
	\brightness, 0.35,
	\waveFold, 0.2
]);

~exp4.drone = Synth(\harmonicDrone, [\root, ~exp4.root / 2, \amp, 0.07]);

~exp4.step = 0;

~exp4.routine = Routine({
	var tempo = 0.14;
	inf.do { |i|
		var idx = ~exp4.step % ~exp4.patternA.size;
		var degreeA = ~exp4.patternA.wrapAt(idx);
		var degreeB = ~exp4.patternB.wrapAt(idx);
		var degree, freq;

		// Probabilistic morphing
		if (rrand(0.0, 1.0) < ~exp4.morphAmount) {
			degree = degreeB;
		} {
			degree = degreeA;
		};

		freq = ~exp4.root * ~exp4.ratios.wrapAt(degree);
		~exp4.voice.set(\freq, freq);

		// Slowly increase morph amount
		if (i % 32 == 0) {
			~exp4.morphAmount = (~exp4.morphAmount + 0.1).clip(0, 1);
			if (~exp4.morphAmount >= 1) { ~exp4.morphAmount = 0 };
			"Morph: %".format(~exp4.morphAmount.round(0.01)).postln;
		};

		~exp4.step = ~exp4.step + 1;
		tempo.wait;
	};
}).play;

"PATTERN MORPHING - Gradual transformation".postln;
)

// Stop experiment 4
// ~exp4.routine.stop; ~exp4.voice.free; ~exp4.drone.free;

// --------------------------------------------------
// EXPERIMENT 5: SPECTRAL ACCUMULATION
// Notes slowly add to create dense chords
// --------------------------------------------------
(
SynthDef(\spectralTone, {
	arg out = 0, amp = 0.1, freq = 200, gate = 1;
	var sig, env;

	env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3.02) * 0.15);

	// Gentle beating
	sig = sig * (1 + (SinOsc.kr(0.1) * 0.1));

	sig = sig * env * amp;
	Out.ar(out, Splay.ar(sig, 0.4));  // Stereo spread
}).add;

~exp5 = ();  // Namespace for experiment 5
~exp5.root = 55;
~exp5.ratios = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
~exp5.voices = [];
~exp5.maxVoices = 8;

// Gradually add voices
~exp5.routine = Routine({
	inf.do { |i|
		var partial = ~exp5.ratios.choose;
		var freq = ~exp5.root * partial;
		var newVoice;

		// Remove oldest if at max - schedule release and defer removal
		if (~exp5.voices.size >= ~exp5.maxVoices) {
			var oldVoice = ~exp5.voices[0];
			oldVoice.set(\gate, 0);
			~exp5.voices.removeAt(0);
		};

		newVoice = Synth(\spectralTone, [
			\freq, freq,
			\amp, 0.1 / ~exp5.voices.size.max(1).sqrt
		]);
		~exp5.voices = ~exp5.voices.add(newVoice);

		"Added partial %, total voices: %".format(partial, ~exp5.voices.size).postln;

		rrand(3, 8).wait;
	};
}).play;

"SPECTRAL ACCUMULATION - Building harmonic density".postln;
)

// Stop experiment 5
// ~exp5.routine.stop; ~exp5.voices.do(_.set(\gate, 0));

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
