// ============================================================
// TIM HECKER STYLE - Noise into beauty, spectral processing
// ============================================================
// Inspired by "Ravedeath, 1972":
// - Organ/harmonic textures
// - Distortion as compositional element
// - Dense, cathedral-like reverb
// - Noise transformed into harmony
// - Slow, massive gestures

// --------------------------------------------------
// ORGAN DRONE - Distorted organ-like texture
// --------------------------------------------------
(
SynthDef(\organDrone, {
	arg out = 0, amp = 0.2, freq = 110, distortion = 0.3, brightness = 0.5;
	var sig, harmonics;

	// Organ-like harmonic content
	harmonics = Mix.fill(8, { |i|
		var partial = [1, 2, 3, 4, 5, 6, 8, 10][i];
		var detune = LFNoise2.kr(0.03 + (i * 0.01)).range(0.998, 1.002);
		var drawbar = [1, 0.8, 0.6, 0.4, 0.3, 0.2, 0.15, 0.1][i];

		SinOsc.ar(freq * partial * detune) * drawbar;
	});

	sig = harmonics;

	// Distortion
	sig = (sig * (1 + (distortion * 3))).tanh;
	sig = sig + (sig.clip2(0.3) * distortion);

	// More distortion stages
	sig = (sig * 1.5).fold(-1, 1) * 0.7;

	// Filter based on brightness
	sig = LPF.ar(sig, 1000 + (brightness * 5000));

	// Subtle modulation
	sig = sig * (1 + (LFNoise2.kr(0.05) * 0.1));

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SPECTRAL WASH - Noise transformed to harmony
// --------------------------------------------------
(
SynthDef(\spectralWash, {
	arg out = 0, amp = 0.1, freq = 220, resonance = 0.1, dur = 10;
	var sig, noise, filtered, env;

	env = EnvGen.kr(Env.linen(3, dur - 6, 3, 1, \sin), doneAction: 2);

	// Start with noise
	noise = PinkNoise.ar;

	// Multiple resonant filters create harmonic content
	filtered = Mix.fill(6, { |i|
		var partial = [1, 2, 3, 4, 5, 6][i];
		var rq = resonance / (i + 1).sqrt;
		BPF.ar(noise, freq * partial * LFNoise2.kr(0.02).range(0.99, 1.01), rq);
	});

	sig = filtered;

	// Gentle saturation
	sig = (sig * 2).tanh * 0.5;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// MASSIVE REVERB - Cathedral-like space
// --------------------------------------------------
(
SynthDef(\massiveReverb, {
	arg out = 0, in, amp = 0.5, decay = 8, damping = 0.3;
	var sig, verb;

	sig = In.ar(in, 2);

	// Long allpass chain
	verb = sig;
	8.do({ |i|
		verb = AllpassC.ar(verb, 0.2, rrand(0.02, 0.15), decay * (1 - (damping * i / 8)));
	});

	// Additional smearing
	verb = verb + CombL.ar(verb, 0.5, 0.3, decay * 0.5) * 0.3;

	verb = LPF.ar(verb, 3000);
	verb = HPF.ar(verb, 60);

	verb = verb * amp;
	Out.ar(out, verb);
}).add;
)

// --------------------------------------------------
// NOISE BURST - Textural impact
// --------------------------------------------------
(
SynthDef(\noiseBurst, {
	arg out = 0, amp = 0.2, freq = 500, dur = 2, distortion = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.1, dur, 1, -3), doneAction: 2);

	// Filtered noise
	sig = BPF.ar(WhiteNoise.ar, freq, 0.2);
	sig = sig + BPF.ar(PinkNoise.ar, freq * 2, 0.15) * 0.5;

	// Heavy distortion
	sig = (sig * (2 + (distortion * 4))).tanh;
	sig = sig.fold(-0.8, 0.8);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: RAVEDEATH
// Distorted organ, massive space
// --------------------------------------------------
(
~organ = Synth(\organDrone, [
	\freq, 55,
	\amp, 0.15,
	\distortion, 0.4,
	\brightness, 0.4
]);

// Occasional spectral washes
~washRoutine = Routine({
	var freqs = [110, 146.8, 164.8, 220];
	inf.do {
		Synth(\spectralWash, [
			\freq, freqs.choose,
			\amp, rrand(0.06, 0.12),
			\resonance, rrand(0.05, 0.15),
			\dur, rrand(8, 20)
		]);
		rrand(10, 30).wait;
	};
}).play;

// Noise bursts
~burstRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\noiseBurst, [
				\freq, rrand(200, 800),
				\amp, rrand(0.08, 0.18),
				\dur, rrand(1, 5),
				\distortion, rrand(0.3, 0.8)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

// Shift organ slowly
~shiftRoutine = Routine({
	var freqs = [41.2, 55, 73.4, 82.4];
	inf.do {
		~organ.set(\freq, freqs.choose);
		~organ.set(\distortion, rrand(0.2, 0.6));
		rrand(20, 60).wait;
	};
}).play;

"RAVEDEATH - Distorted cathedral".postln;
)

// Stop
// ~organ.free; ~washRoutine.stop; ~burstRoutine.stop; ~shiftRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: VIRGINS
// Softer, more melodic
// --------------------------------------------------
(
~organ = Synth(\organDrone, [
	\freq, 110,
	\amp, 0.12,
	\distortion, 0.2,
	\brightness, 0.6
]);

// Melodic spectral tones
~melodyRoutine = Routine({
	var scale = [0, 2, 4, 5, 7, 9, 11, 12];
	var root = 220;
	inf.do {
		var degree = scale.choose;
		var freq = root * (2 ** (degree / 12));

		Synth(\spectralWash, [
			\freq, freq,
			\amp, rrand(0.05, 0.1),
			\resonance, rrand(0.08, 0.12),
			\dur, rrand(6, 15)
		]);

		rrand(4, 12).wait;
	};
}).play;

// Rare, soft bursts
~burstRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\noiseBurst, [
				\freq, rrand(300, 600),
				\amp, rrand(0.04, 0.1),
				\dur, rrand(2, 6),
				\distortion, rrand(0.1, 0.3)
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

"VIRGINS - Softer noise".postln;
)

// Stop
// ~organ.free; ~melodyRoutine.stop; ~burstRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: KONOYO
// Darker, more sparse
// --------------------------------------------------
(
~organ = Synth(\organDrone, [
	\freq, 36.7,
	\amp, 0.12,
	\distortion, 0.5,
	\brightness, 0.25
]);

// Very sparse washes
~washRoutine = Routine({
	inf.do {
		Synth(\spectralWash, [
			\freq, rrand(60, 200),
			\amp, rrand(0.04, 0.1),
			\resonance, rrand(0.03, 0.08),
			\dur, rrand(15, 40)
		]);
		rrand(25, 60).wait;
	};
}).play;

// Dark bursts
~burstRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\noiseBurst, [
				\freq, rrand(80, 300),
				\amp, rrand(0.06, 0.15),
				\dur, rrand(3, 10),
				\distortion, rrand(0.4, 0.8)
			]);
		};
		rrand(15, 45).wait;
	};
}).play;

"KONOYO - Dark and sparse".postln;
)

// Stop
// ~organ.free; ~washRoutine.stop; ~burstRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: LOVE STREAMS
// Maximum distortion
// --------------------------------------------------
(
~organ = Synth(\organDrone, [
	\freq, 55,
	\amp, 0.18,
	\distortion, 0.7,
	\brightness, 0.5
]);

// Constant spectral wash
~wash = Synth(\spectralWash, [
	\freq, 110,
	\amp, 0.08,
	\resonance, 0.1,
	\dur, 600
]);

// Frequent bursts
~burstRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\noiseBurst, [
				\freq, rrand(150, 600),
				\amp, rrand(0.1, 0.2),
				\dur, rrand(1, 4),
				\distortion, rrand(0.5, 0.9)
			]);
		};
		rrand(3, 10).wait;
	};
}).play;

// Organ shifts
~shiftRoutine = Routine({
	var freqs = [41.2, 55, 55, 73.4];
	inf.do {
		~organ.set(\freq, freqs.choose);
		~organ.set(\distortion, rrand(0.5, 0.9));
		rrand(10, 30).wait;
	};
}).play;

"LOVE STREAMS - Maximum density".postln;
)

// Stop
// ~organ.free; ~wash.free; ~burstRoutine.stop; ~shiftRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: AMBIENT DESTRUCTION
// Noise as primary element
// --------------------------------------------------
(
// Continuous noise wash
~noise = Synth(\spectralWash, [
	\freq, 150,
	\amp, 0.12,
	\resonance, 0.15,
	\dur, 600
]);

// Quiet organ underneath
~organ = Synth(\organDrone, [
	\freq, 55,
	\amp, 0.06,
	\distortion, 0.3,
	\brightness, 0.3
]);

// Frequent harsh bursts
~burstRoutine = Routine({
	inf.do {
		Synth(\noiseBurst, [
			\freq, rrand(100, 500),
			\amp, rrand(0.08, 0.2),
			\dur, rrand(0.5, 3),
			\distortion, rrand(0.4, 0.9)
		]);
		rrand(1, 6).wait;
	};
}).play;

// Additional spectral layers
~layerRoutine = Routine({
	inf.do {
		Synth(\spectralWash, [
			\freq, rrand(80, 400),
			\amp, rrand(0.04, 0.1),
			\resonance, rrand(0.05, 0.12),
			\dur, rrand(5, 15)
		]);
		rrand(4, 12).wait;
	};
}).play;

"AMBIENT DESTRUCTION - Noise dominant".postln;
)

// Stop
// ~noise.free; ~organ.free; ~burstRoutine.stop; ~layerRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
