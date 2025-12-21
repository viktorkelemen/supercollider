// ============================================================
// CATERINA BARBIERI STYLE - Sequencer-based minimalism
// ============================================================
// Inspired by "Ecstatic Computation":
// - Buchla-style stepped sequences
// - Harmonic series explorations
// - Polyrhythmic clock divisions
// - Slow transformations of repeating patterns
// - Psychoacoustic phenomena through repetition

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
// Define the scale - just intonation ratios
~ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];
~root = 110;

// Sequence patterns
~patterns = [
	[0, 2, 4, 7, 4, 2, 0, 4],
	[0, 0, 4, 4, 2, 2, 7, 7],
	[7, 4, 2, 0, 7, 4, 2, 0],
	[0, 4, 7, 4, 0, 2, 4, 2]
];

~currentPattern = 0;
~step = 0;
~patternLength = 8;

// Harmonic drone
~drone = Synth(\harmonicDrone, [\root, ~root / 2, \amp, 0.08, \numPartials, 6]);

// Melodic voice
~voice = Synth(\steppedOsc, [
	\freq, ~root,
	\amp, 0.2,
	\glide, 0.03,
	\brightness, 0.4
]);

// Sequencer routine
~seqRoutine = Routine({
	var tempo = 0.15; // 100ms per step
	inf.do { |i|
		var pattern = ~patterns[~currentPattern];
		var degree = pattern[~step % ~patternLength];
		var freq = ~root * ~ratios[degree];

		~voice.set(\freq, freq);

		// Occasionally change pattern
		if ((i % 64 == 0) && (0.3.coin)) {
			~currentPattern = (~currentPattern + 1) % ~patterns.size;
			"Pattern change -> %".format(~currentPattern).postln;
		};

		~step = ~step + 1;
		tempo.wait;
	};
}).play;

"ECSTATIC SEQUENCE - Stepped minimalism".postln;
)

// Stop experiment 1
// ~seqRoutine.stop; ~voice.free; ~drone.free;

// --------------------------------------------------
// EXPERIMENT 2: POLYRHYTHMIC VOICES
// Multiple voices at different clock divisions
// --------------------------------------------------
(
~root = 110;
~ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];

// Different patterns for each voice
~pattern1 = [0, 4, 7, 4];  // 4 steps
~pattern2 = [0, 2, 4, 5, 7, 5];  // 6 steps
~pattern3 = [7, 7, 4, 4, 2, 0, 2, 4];  // 8 steps

// Create voices
~voice1 = Synth(\steppedOsc, [\freq, ~root, \amp, 0.15, \glide, 0.02, \brightness, 0.3]);
~voice2 = Synth(\steppedOsc, [\freq, ~root * 2, \amp, 0.12, \glide, 0.03, \brightness, 0.5]);
~voice3 = Synth(\steppedOsc, [\freq, ~root / 2, \amp, 0.18, \glide, 0.01, \brightness, 0.2]);

// Drone
~drone = Synth(\harmonicDrone, [\root, ~root / 2, \amp, 0.06]);

~step1 = 0; ~step2 = 0; ~step3 = 0;

// Voice 1 - fastest
~routine1 = Routine({
	var tempo = 0.12;
	inf.do {
		var deg = ~pattern1[~step1 % ~pattern1.size];
		~voice1.set(\freq, ~root * ~ratios[deg]);
		~step1 = ~step1 + 1;
		tempo.wait;
	};
}).play;

// Voice 2 - medium
~routine2 = Routine({
	var tempo = 0.18;
	inf.do {
		var deg = ~pattern2[~step2 % ~pattern2.size];
		~voice2.set(\freq, ~root * 2 * ~ratios[deg]);
		~step2 = ~step2 + 1;
		tempo.wait;
	};
}).play;

// Voice 3 - slowest
~routine3 = Routine({
	var tempo = 0.24;
	inf.do {
		var deg = ~pattern3[~step3 % ~pattern3.size];
		~voice3.set(\freq, ~root / 2 * ~ratios[deg % ~ratios.size]);
		~step3 = ~step3 + 1;
		tempo.wait;
	};
}).play;

"POLYRHYTHMIC VOICES - Phase relationships".postln;
)

// Stop experiment 2
// ~routine1.stop; ~routine2.stop; ~routine3.stop;
// ~voice1.free; ~voice2.free; ~voice3.free; ~drone.free;

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

~root = 55;
~maxPartial = 16;
~currentPartial = 1;

~voice = Synth(\harmonicVoice, [\root, ~root, \partial, 1, \amp, 0.2]);

// Slow sweep through harmonics
~sweepRoutine = Routine({
	var tempo = 0.8;
	inf.do { |i|
		// Move up and down through harmonics
		if (i % (~maxPartial * 2) < ~maxPartial) {
			~currentPartial = (i % ~maxPartial) + 1;
		} {
			~currentPartial = ~maxPartial - (i % ~maxPartial);
		};

		~voice.set(\partial, ~currentPartial);
		"Partial: %".format(~currentPartial).postln;

		tempo.wait;
	};
}).play;

"HARMONIC SWEEP - Ascending and descending partials".postln;
)

// Stop experiment 3
// ~sweepRoutine.stop; ~voice.free;

// --------------------------------------------------
// EXPERIMENT 4: PATTERN MORPHING
// Gradual transformation of sequences
// --------------------------------------------------
(
~root = 110;
~ratios = [1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2];

// Two patterns to morph between
~patternA = [0, 2, 4, 5, 7, 5, 4, 2];
~patternB = [7, 5, 4, 2, 0, 2, 4, 5];

~morphAmount = 0;  // 0 = pattern A, 1 = pattern B

~voice = Synth(\steppedOsc, [
	\freq, ~root,
	\amp, 0.22,
	\glide, 0.04,
	\brightness, 0.35,
	\waveFold, 0.2
]);

~drone = Synth(\harmonicDrone, [\root, ~root / 2, \amp, 0.07]);

~step = 0;

~morphRoutine = Routine({
	var tempo = 0.14;
	inf.do { |i|
		var idx = ~step % ~patternA.size;
		var degreeA = ~patternA[idx];
		var degreeB = ~patternB[idx];
		var degree, freq;

		// Probabilistic morphing
		if (rrand(0.0, 1.0) < ~morphAmount) {
			degree = degreeB;
		} {
			degree = degreeA;
		};

		freq = ~root * ~ratios[degree];
		~voice.set(\freq, freq);

		// Slowly increase morph amount
		if (i % 32 == 0) {
			~morphAmount = (~morphAmount + 0.1).clip(0, 1);
			if (~morphAmount >= 1) { ~morphAmount = 0 };
			"Morph: %".format(~morphAmount.round(0.01)).postln;
		};

		~step = ~step + 1;
		tempo.wait;
	};
}).play;

"PATTERN MORPHING - Gradual transformation".postln;
)

// Stop experiment 4
// ~morphRoutine.stop; ~voice.free; ~drone.free;

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
	Out.ar(out, sig ! 2);
}).add;

~root = 55;
~ratios = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
~voices = [];
~maxVoices = 8;

// Gradually add voices
~accumRoutine = Routine({
	inf.do { |i|
		var partial = ~ratios.choose;
		var freq = ~root * partial;
		var newVoice;

		// Remove oldest if at max
		if (~voices.size >= ~maxVoices) {
			~voices[0].set(\gate, 0);
			~voices.removeAt(0);
		};

		newVoice = Synth(\spectralTone, [
			\freq, freq,
			\amp, 0.1 / ~voices.size.max(1).sqrt
		]);
		~voices = ~voices.add(newVoice);

		"Added partial %, total voices: %".format(partial, ~voices.size).postln;

		rrand(3, 8).wait;
	};
}).play;

"SPECTRAL ACCUMULATION - Building harmonic density".postln;
)

// Stop experiment 5
// ~accumRoutine.stop; ~voices.do(_.set(\gate, 0));

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
