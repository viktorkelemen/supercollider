// ============================================================
// SUZANNE CIANI STYLE - Buchla pioneer, expressive sequencing
// ============================================================
// Inspired by "Seven Waves" and Buchla concerts:
// - Expressive voltage control
// - Wave sequencing
// - Spatial movement (quadraphonic concepts)
// - Organic, flowing modulation
// - Complex function generators

// --------------------------------------------------
// BUCHLA VOICE - Complex oscillator with waveshaping
// --------------------------------------------------
(
SynthDef(\buchlaVoice, {
	arg out = 0, amp = 0.2, freq = 220, timbre = 0.5,
		symmetry = 0.5, foldAmount = 0, gate = 1;
	var sig, env, shape;

	env = EnvGen.kr(Env.asr(0.05, 1, 0.1), gate, doneAction: 2);

	// Variable waveshape - sine to triangle to more complex
	sig = SinOsc.ar(freq) * (1 - timbre);
	sig = sig + (LFTri.ar(freq) * timbre * 0.5);
	sig = sig + (VarSaw.ar(freq, 0, symmetry) * timbre * 0.5);

	// Wavefolder
	sig = (sig * (1 + (foldAmount * 4))).fold(-1, 1);

	// Lowpass gate simulation
	sig = LPF.ar(sig, freq * (2 + (env * 8)));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// WAVE SEQUENCER - Stepped modulation source
// --------------------------------------------------
(
SynthDef(\waveSequence, {
	arg out = 0, amp = 0.15, baseFreq = 110, numSteps = 8, rate = 4;
	var sig, step, freq, trig;

	trig = Impulse.kr(rate);
	step = Stepper.kr(trig, 0, 0, numSteps - 1);

	// Different frequency for each step
	freq = Select.kr(step, [1, 1.125, 1.25, 1.33, 1.5, 1.67, 1.875, 2] * baseFreq);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3) * 0.15);

	// Envelope per step
	sig = sig * EnvGen.kr(Env.perc(0.01, 1/rate * 0.8), trig);

	sig = LPF.ar(sig, freq * 4);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SPATIAL PAD - Quadraphonic-inspired movement
// --------------------------------------------------
(
SynthDef(\spatialPad, {
	arg out = 0, amp = 0.12, freq = 110, moveRate = 0.1;
	var sig, pan, voices;

	// Multiple voices with different movements
	voices = Mix.fill(4, { |i|
		var detune = LFNoise2.kr(0.02 + (i * 0.01)).range(0.99, 1.01);
		var voice = SinOsc.ar(freq * (i + 1) * detune);
		voice = voice * (1 / (i + 1));
		voice * LFNoise2.kr(0.05 + (i * 0.02)).range(0.5, 1);
	});

	sig = voices;

	// Circular panning
	pan = SinOsc.kr(moveRate + LFNoise2.kr(0.02).range(-0.02, 0.02));

	sig = LPF.ar(sig, LFNoise2.kr(0.05).range(800, 3000));
	sig = sig * amp;

	// Stereo with movement
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// FUNCTION GENERATOR - Complex envelope shapes
// --------------------------------------------------
(
SynthDef(\functionGen, {
	arg out = 0, amp = 0.2, freq = 440, attack = 0.1,
		decay = 0.3, sustain = 0.5, release = 1, curve = -4;
	var sig, env, fenv;

	env = EnvGen.kr(
		Env.adsr(attack, decay, sustain, release, 1, curve),
		doneAction: 2
	);
	fenv = EnvGen.kr(Env.perc(attack * 0.5, decay + release, 1, curve));

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.25);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.2);

	// Filter follows function
	sig = LPF.ar(sig, freq * (2 + (fenv * 6)));

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.2).range(-0.4, 0.4)));
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: SEVEN WAVES SEQUENCE
// Flowing wave-like sequences
// --------------------------------------------------
(
~root = 110;

// Spatial foundation
~pad = Synth(\spatialPad, [\freq, ~root / 2, \amp, 0.08, \moveRate, 0.07]);

// Wave sequence
~seq = Synth(\waveSequence, [
	\baseFreq, ~root,
	\amp, 0.12,
	\numSteps, 8,
	\rate, 3
]);

// Melodic voice
~voice = Synth(\buchlaVoice, [
	\freq, ~root,
	\amp, 0.15,
	\timbre, 0.4,
	\symmetry, 0.5
]);

// Melody evolution
~melodyRoutine = Routine({
	var ratios = [1, 1.125, 1.25, 1.33, 1.5, 1.67, 1.875, 2];
	inf.do {
		var ratio = ratios.choose;
		~voice.set(\freq, ~root * ratio);

		// Evolve timbre
		~voice.set(
			\timbre, rrand(0.2, 0.8),
			\symmetry, rrand(0.3, 0.7),
			\foldAmount, rrand(0, 0.3)
		);

		rrand(0.5, 2).wait;
	};
}).play;

"SEVEN WAVES - Flowing sequences".postln;
)

// Stop
// ~melodyRoutine.stop; ~voice.free; ~seq.free; ~pad.free;

// --------------------------------------------------
// EXPERIMENT 2: BUCHLA CONCERT
// Expressive, gestural performance
// --------------------------------------------------
(
~root = 165;

~pad = Synth(\spatialPad, [\freq, ~root / 3, \amp, 0.06, \moveRate, 0.05]);

// Gestural routine - like live performance
~gestureRoutine = Routine({
	var phrases = [
		[[1, 1.25, 1.5, 1.25], [0.2, 0.2, 0.3, 0.3]],  // Rising
		[[2, 1.67, 1.5, 1.33], [0.15, 0.2, 0.2, 0.45]],  // Falling
		[[1, 1.5, 1.33, 1.67], [0.25, 0.25, 0.25, 0.25]],  // Jumping
		[[1.25, 1.25, 1.5, 2], [0.1, 0.1, 0.2, 0.6]]  // Held
	];

	inf.do {
		var phrase = phrases.choose;
		var ratios = phrase[0];
		var durations = phrase[1];

		ratios.do({ |ratio, i|
			Synth(\functionGen, [
				\freq, ~root * ratio,
				\amp, rrand(0.12, 0.2),
				\attack, rrand(0.02, 0.15),
				\decay, rrand(0.1, 0.4),
				\sustain, rrand(0.3, 0.7),
				\release, durations[i] * 2,
				\curve, rrand(-6, -2)
			]);
			durations[i].wait;
		});

		rrand(0.5, 2).wait;  // Pause between phrases
	};
}).play;

"BUCHLA CONCERT - Expressive gestures".postln;
)

// Stop
// ~gestureRoutine.stop; ~pad.free;

// --------------------------------------------------
// EXPERIMENT 3: QUADRAPHONIC MEDITATION
// Spatial movement emphasis
// --------------------------------------------------
(
~root = 82.4;

// Multiple spatial pads at different rates
~pads = [];
~pads = ~pads.add(Synth(\spatialPad, [\freq, ~root, \amp, 0.06, \moveRate, 0.05]));
~pads = ~pads.add(Synth(\spatialPad, [\freq, ~root * 1.5, \amp, 0.05, \moveRate, 0.08]));
~pads = ~pads.add(Synth(\spatialPad, [\freq, ~root * 2, \amp, 0.04, \moveRate, 0.12]));

// Occasional melodic events
~eventRoutine = Routine({
	var ratios = [1, 1.25, 1.33, 1.5, 2];
	inf.do {
		if (0.4.coin) {
			Synth(\functionGen, [
				\freq, ~root * 2 * ratios.choose,
				\amp, rrand(0.08, 0.15),
				\attack, rrand(0.5, 2),
				\decay, rrand(0.5, 1),
				\sustain, 0.6,
				\release, rrand(2, 5)
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

"QUADRAPHONIC MEDITATION - Spatial awareness".postln;
)

// Stop
// ~eventRoutine.stop; ~pads.do(_.free);

// --------------------------------------------------
// EXPERIMENT 4: VOLTAGE OCEAN
// Continuous modulation, wave-like
// --------------------------------------------------
(
SynthDef(\voltageWave, {
	arg out = 0, amp = 0.12, freq = 55, waveSpeed = 0.1;
	var sig, wave1, wave2, wave3;

	// Multiple slow waves
	wave1 = SinOsc.kr(waveSpeed).range(0.5, 1);
	wave2 = SinOsc.kr(waveSpeed * 1.3).range(0.8, 1.2);
	wave3 = SinOsc.kr(waveSpeed * 0.7).range(-0.3, 0.3);

	// Frequency modulated by waves
	sig = SinOsc.ar(freq * wave2) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2 * wave2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3 * wave2) * 0.15);

	// Amplitude waves
	sig = sig * wave1;

	// Filter waves
	sig = LPF.ar(sig, (freq * 4) + (wave3 * freq * 2));

	sig = sig * amp;
	Out.ar(out, Pan2.ar(sig, SinOsc.kr(waveSpeed * 0.5)));
}).add;

~wave1 = Synth(\voltageWave, [\freq, 55, \amp, 0.1, \waveSpeed, 0.08]);
~wave2 = Synth(\voltageWave, [\freq, 82.4, \amp, 0.08, \waveSpeed, 0.11]);
~wave3 = Synth(\voltageWave, [\freq, 110, \amp, 0.06, \waveSpeed, 0.14]);

// Melodic overlay
~overlayRoutine = Routine({
	var ratios = [1, 1.5, 2, 2.5, 3, 4];
	inf.do {
		if (0.3.coin) {
			Synth(\functionGen, [
				\freq, 110 * ratios.choose,
				\amp, rrand(0.06, 0.12),
				\attack, rrand(0.2, 1),
				\decay, 0.5,
				\sustain, 0.4,
				\release, rrand(1, 3)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"VOLTAGE OCEAN - Continuous modulation".postln;
)

// Stop
// ~overlayRoutine.stop; ~wave1.free; ~wave2.free; ~wave3.free;

// --------------------------------------------------
// EXPERIMENT 5: COMPLEX SEQUENCE
// Interlocking sequencers
// --------------------------------------------------
(
~root = 110;

~pad = Synth(\spatialPad, [\freq, ~root / 2, \amp, 0.05, \moveRate, 0.06]);

// Sequence 1 - 8 steps
~seq1 = Synth(\waveSequence, [
	\baseFreq, ~root,
	\amp, 0.1,
	\numSteps, 8,
	\rate, 4
]);

// Sequence 2 - 6 steps (polyrhythm)
~seq2 = Synth(\waveSequence, [
	\baseFreq, ~root * 1.5,
	\amp, 0.08,
	\numSteps, 6,
	\rate, 4
]);

// Sequence 3 - 5 steps
~seq3 = Synth(\waveSequence, [
	\baseFreq, ~root * 2,
	\amp, 0.06,
	\numSteps, 5,
	\rate, 4
]);

// Occasional rate changes
~rateRoutine = Routine({
	var rates = [3, 4, 5, 6];
	inf.do {
		var rate = rates.choose;
		[~seq1, ~seq2, ~seq3].choose.set(\rate, rate);
		rrand(8, 20).wait;
	};
}).play;

"COMPLEX SEQUENCE - Interlocking patterns".postln;
)

// Stop
// ~rateRoutine.stop; ~seq1.free; ~seq2.free; ~seq3.free; ~pad.free;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
