// ============================================================
// KELLY MORAN STYLE - Prepared piano meets modular
// ============================================================
// Inspired by "Ultraviolet":
// - Prepared piano timbres
// - Modular synthesis textures
// - Polyrhythmic patterns
// - Bright, crystalline quality
// - Melodic but experimental

// --------------------------------------------------
// PREPARED PIANO - Muted, metallic piano
// --------------------------------------------------
(
SynthDef(\preparedPiano, {
	arg out = 0, amp = 0.2, freq = 440, decay = 2, mute = 0.5, pan = 0;
	var sig, env, strike, body;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);

	// Strike transient
	strike = BPF.ar(WhiteNoise.ar, freq * 4, 0.1) * EnvGen.kr(Env.perc(0.001, 0.02));

	// Body - mixture of harmonics with inharmonicity
	body = SinOsc.ar(freq) * 0.4;
	body = body + (SinOsc.ar(freq * 2.01) * 0.2);
	body = body + (SinOsc.ar(freq * 3.02) * 0.15);
	body = body + (SinOsc.ar(freq * 4.05) * 0.1);
	body = body + (SinOsc.ar(freq * 5.1) * 0.05);

	// Muting effect (preparation)
	body = LPF.ar(body, 1000 + (2000 * (1 - mute)));
	body = body * (1 - (mute * 0.3));

	// Metallic resonance from preparation
	body = body + (Ringz.ar(strike, freq * rrand(2.5, 3.5), 0.1) * mute * 0.3);

	sig = (strike * 0.3) + body;
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// MODULAR ARPEGGIO - Bright, sequenced tones
// --------------------------------------------------
(
SynthDef(\modularArp, {
	arg out = 0, amp = 0.15, freq = 440, dur = 0.2, brightness = 0.6;
	var sig, env, fenv;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.01, dur * 0.5, 1, -4));

	// Saw + pulse mix
	sig = LFSaw.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq, LFNoise2.kr(0.5).range(0.3, 0.7)) * 0.3);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Filter with envelope
	sig = LPF.ar(sig, freq * (2 + (brightness * 8 * fenv)));
	sig = HPF.ar(sig, 80);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// CRYSTAL PAD - Bright, shimmering texture
// --------------------------------------------------
(
SynthDef(\crystalPad, {
	arg out = 0, amp = 0.1, freq = 220;
	var sig;

	sig = Mix.fill(6, { |i|
		var partial = [1, 2, 3, 4, 5, 6][i];
		var detune = LFNoise2.kr(0.03).range(0.998, 1.002);
		var vibrato = SinOsc.kr(rrand(4, 6)).range(0.998, 1.002);
		SinOsc.ar(freq * partial * detune * vibrato) * (1 / partial.sqrt);
	});

	// Shimmer
	sig = sig + (SinOsc.ar(freq * 8 * LFNoise2.kr(0.1).range(0.99, 1.01)) * 0.05);

	sig = LPF.ar(sig, 6000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: ULTRAVIOLET
// Prepared piano with modular textures
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 261.6;  // C

~pad = Synth(\crystalPad, [\freq, ~root / 2, \amp, 0.05]);

// Prepared piano melodic pattern
~pianoRoutine = Routine({
	var melody = [0, 4, 7, 4, 2, 5, 4, 0];
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree] / 12));

		Synth(\preparedPiano, [
			\freq, freq,
			\amp, rrand(0.12, 0.18),
			\decay, rrand(1, 2.5),
			\mute, rrand(0.3, 0.7),
			\pan, rrand(-0.3, 0.3)
		]);

		[0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.5].at(i % 8).wait;
		i = i + 1;
	};
}).play;

// Modular arpeggio layer
~arpRoutine = Routine({
	var pattern = [0, 2, 4, 7, 9, 7, 4, 2];
	var i = 0;
	inf.do {
		var degree = pattern[i % pattern.size];
		var freq = ~root * 2 * (2 ** (~scale[degree] / 12));

		Synth(\modularArp, [
			\freq, freq,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(0.1, 0.2),
			\brightness, rrand(0.4, 0.8)
		]);

		0.125.wait;
		i = i + 1;
	};
}).play;

"ULTRAVIOLET - Prepared piano + modular".postln;
)

// Stop
// ~pad.free; ~pianoRoutine.stop; ~arpRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: HELIX
// More aggressive, polyrhythmic
// --------------------------------------------------
(
~scale = [0, 2, 3, 5, 7, 8, 10];  // Harmonic minor
~root = 293.7;  // D

~pad = Synth(\crystalPad, [\freq, ~root / 2, \amp, 0.04]);

// Fast piano pattern (7 beats)
~piano1 = Routine({
	var pattern = [0, 3, 5, 7, 5, 3, 0];
	var tempo = 0.18;
	var i = 0;
	inf.do {
		Synth(\preparedPiano, [
			\freq, ~root * (2 ** (~scale[pattern[i % 7]] / 12)),
			\amp, rrand(0.1, 0.16),
			\decay, 1.2,
			\mute, 0.4
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Piano pattern (5 beats)
~piano2 = Routine({
	var pattern = [7, 5, 3, 0, 3];
	var tempo = 0.18;
	var i = 0;
	inf.do {
		Synth(\preparedPiano, [
			\freq, ~root * 2 * (2 ** (~scale[pattern[i % 5]] / 12)),
			\amp, rrand(0.08, 0.12),
			\decay, 0.8,
			\mute, 0.6,
			\pan, 0.4
		]);
		i = i + 1;
		(tempo * 7 / 5).wait;  // Cross-rhythm
	};
}).play;

// Fast arp
~arpRoutine = Routine({
	inf.do {
		if (0.6.coin) {
			Synth(\modularArp, [
				\freq, ~root * [1, 2, 4].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.05, 0.15)
			]);
		};
		rrand(0.05, 0.2).wait;
	};
}).play;

"HELIX - Polyrhythmic intensity".postln;
)

// Stop
// ~pad.free; ~piano1.stop; ~piano2.stop; ~arpRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: WATER MUSIC
// Softer, more ambient
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];  // Pentatonic
~root = 220;

~pad = Synth(\crystalPad, [\freq, ~root, \amp, 0.06]);

// Sparse piano
~pianoRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			var freq = ~root * [0.5, 1, 2].choose * (2 ** (~scale.choose / 12));
			Synth(\preparedPiano, [
				\freq, freq,
				\amp, rrand(0.1, 0.16),
				\decay, rrand(2, 4),
				\mute, rrand(0.2, 0.5),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Gentle arps
~arpRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			var freq = ~root * 2 * (2 ** (~scale.choose / 12));
			Synth(\modularArp, [
				\freq, freq,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(0.2, 0.5),
				\brightness, 0.4
			]);
		};
		rrand(0.3, 1.5).wait;
	};
}).play;

"WATER MUSIC - Ambient prepared piano".postln;
)

// Stop
// ~pad.free; ~pianoRoutine.stop; ~arpRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: BLOODROOT
// Dark, metallic
// --------------------------------------------------
(
~scale = [0, 1, 4, 5, 7, 8, 10];  // Phrygian-ish
~root = 196;  // G

~pad = Synth(\crystalPad, [\freq, ~root / 2, \amp, 0.04]);

// Heavy preparation
~pianoRoutine = Routine({
	var pattern = [0, 1, 4, 5, 4, 1, 0, 7];
	var tempo = 0.22;
	var i = 0;
	inf.do {
		Synth(\preparedPiano, [
			\freq, ~root * (2 ** (~scale[pattern[i % 8]] / 12)),
			\amp, rrand(0.14, 0.2),
			\decay, rrand(1, 2),
			\mute, rrand(0.5, 0.8),  // More muted
			\pan, rrand(-0.3, 0.3)
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Dark arps
~arpRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\modularArp, [
				\freq, ~root * [1, 2].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.1, 0.3),
				\brightness, rrand(0.2, 0.5)
			]);
		};
		rrand(0.1, 0.5).wait;
	};
}).play;

"BLOODROOT - Dark and metallic".postln;
)

// Stop
// ~pad.free; ~pianoRoutine.stop; ~arpRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: ANTHEM
// Maximum brightness, full texture
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 329.6;  // E

~pad = Synth(\crystalPad, [\freq, ~root, \amp, 0.07]);

// Fast piano pattern
~pianoRoutine = Routine({
	var pattern = [0, 4, 7, 11, 7, 4, 2, 4];
	var tempo = 0.12;
	var i = 0;
	inf.do {
		Synth(\preparedPiano, [
			\freq, ~root * (2 ** (~scale[pattern[i % 8]] / 12)),
			\amp, rrand(0.1, 0.16),
			\decay, 0.8,
			\mute, rrand(0.2, 0.4),
			\pan, rrand(-0.4, 0.4)
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Dense arpeggiation
~arpRoutine = Routine({
	var pattern = [0, 2, 4, 7, 9, 11, 9, 7, 4, 2];
	var tempo = 0.06;
	var i = 0;
	inf.do {
		Synth(\modularArp, [
			\freq, ~root * 2 * (2 ** (~scale[pattern[i % 10]] / 12)),
			\amp, rrand(0.05, 0.09),
			\dur, 0.08,
			\brightness, rrand(0.5, 0.9)
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// High octave accents
~highRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\preparedPiano, [
				\freq, ~root * 4 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\decay, 0.5,
				\mute, 0.2
			]);
		};
		rrand(0.2, 0.8).wait;
	};
}).play;

"ANTHEM - Maximum brightness".postln;
)

// Stop
// ~pad.free; ~pianoRoutine.stop; ~arpRoutine.stop; ~highRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
