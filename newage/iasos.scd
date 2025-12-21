// ============================================================
// IASOS STYLE - Paradise music, crystalline synthesis
// ============================================================
// Inspired by "Inter-Dimensional Music":
// - Bright, crystalline timbres
// - Celestial, uplifting quality
// - Rich harmonic content
// - New age spirituality
// - Lush, layered textures

// --------------------------------------------------
// CRYSTAL BELL - Bright, resonant bell tone
// --------------------------------------------------
(
SynthDef(\crystalBell, {
	arg out = 0, amp = 0.15, freq = 880, decay = 4, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);

	// Bell harmonics
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 2.0) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3.0) * 0.15);
	sig = sig + (SinOsc.ar(freq * 4.2) * 0.1);
	sig = sig + (SinOsc.ar(freq * 5.4) * 0.06);
	sig = sig + (SinOsc.ar(freq * 6.8) * 0.03);

	// Shimmer
	sig = sig * (1 + (SinOsc.kr(rrand(4, 7)) * 0.1));

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// CELESTIAL PAD - Lush, heavenly texture
// --------------------------------------------------
(
SynthDef(\celestialPad, {
	arg out = 0, amp = 0.12, freq = 220;
	var sig, chorus;

	// Multiple detuned voices
	sig = Mix.fill(8, { |i|
		var detune = LFNoise2.kr(0.02 + (i * 0.01)).range(0.995, 1.005);
		var vibrato = SinOsc.kr(rrand(4, 6) + (i * 0.3)).range(0.998, 1.002);
		var partial = [1, 2, 3, 4, 5, 6, 7, 8][i];
		SinOsc.ar(freq * partial * detune * vibrato) * (1 / partial.sqrt);
	});

	// Chorus effect
	chorus = sig;
	chorus = chorus + DelayC.ar(sig, 0.05, SinOsc.kr(0.5).range(0.01, 0.02)) * 0.3;
	chorus = chorus + DelayC.ar(sig, 0.05, SinOsc.kr(0.7).range(0.015, 0.025)) * 0.25;

	sig = (sig + chorus) * 0.5;

	sig = LPF.ar(sig, 8000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// ANGELIC VOICE - Choir-like synthesis
// --------------------------------------------------
(
SynthDef(\angelicVoice, {
	arg out = 0, amp = 0.1, freq = 440, dur = 5;
	var sig, env, formants;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1, 1, \sin), doneAction: 2);

	// Source
	sig = Saw.ar(freq * LFNoise2.kr(0.05).range(0.99, 1.01)) * 0.3;
	sig = sig + (Saw.ar(freq * 2.01) * 0.15);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Aah formants
	formants = BPF.ar(sig, 700, 0.15) * 0.5;
	formants = formants + BPF.ar(sig, 1200, 0.1) * 0.35;
	formants = formants + BPF.ar(sig, 2500, 0.08) * 0.25;

	sig = formants;

	// Breathiness
	sig = sig + (HPF.ar(PinkNoise.ar, 3000) * 0.02);

	sig = LPF.ar(sig, 6000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// HARP GLISS - Glissando arpeggio
// --------------------------------------------------
(
SynthDef(\harpGliss, {
	arg out = 0, amp = 0.08, baseFreq = 220, numNotes = 12, rate = 10;
	var sig, env, trig;

	env = EnvGen.kr(Env.linen(0.5, numNotes / rate, 1), doneAction: 2);

	sig = Mix.fill(numNotes, { |i|
		var freq = baseFreq * (2 ** (i / 6));  // Whole tone scale up
		var delay = i / rate;
		var noteEnv = EnvGen.kr(Env.perc(0.01, 2, 1, -4), Impulse.kr(0).delay(delay));

		SinOsc.ar(freq) * noteEnv * (1 - (i / numNotes * 0.3));
	}) / numNotes.sqrt;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: INTER-DIMENSIONAL
// Full celestial experience
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];  // Major
~root = 220;

~pad = Synth(\celestialPad, [\freq, ~root / 2, \amp, 0.08]);

// Crystal bell melody
~bellRoutine = Routine({
	var melody = [0, 4, 7, 11, 7, 4, 2, 4];
	var i = 0;
	inf.do {
		var degree = melody[i % 8];
		var freq = ~root * 2 * (2 ** (~scale[degree] / 12));

		Synth(\crystalBell, [
			\freq, freq,
			\amp, rrand(0.1, 0.15),
			\decay, rrand(3, 6),
			\pan, rrand(-0.5, 0.5)
		]);

		[0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 1].at(i % 8).wait;
		i = i + 1;
	};
}).play;

// Angelic voices
~voiceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			var freq = ~root * [1, 1.5, 2].choose * (2 ** (~scale.choose / 12));
			Synth(\angelicVoice, [
				\freq, freq,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(4, 10)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Occasional glisses
~glissRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\harpGliss, [
				\baseFreq, ~root * [1, 2, 4].choose,
				\amp, rrand(0.04, 0.08),
				\numNotes, rrand(8, 16),
				\rate, rrand(8, 15)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

"INTER-DIMENSIONAL - Celestial paradise".postln;
)

// Stop
// ~pad.free; ~bellRoutine.stop; ~voiceRoutine.stop; ~glissRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: ELYSIAN FIELDS
// Slower, more meditative
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];  // Pentatonic
~root = 165;

~pad = Synth(\celestialPad, [\freq, ~root / 2, \amp, 0.1]);

// Sparse bells
~bellRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			var freq = ~root * [1, 2, 4].choose * (2 ** (~scale.choose / 12));
			Synth(\crystalBell, [
				\freq, freq,
				\amp, rrand(0.1, 0.15),
				\decay, rrand(4, 8),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(1.5, 5).wait;
	};
}).play;

// Long voice drones
~voiceRoutine = Routine({
	inf.do {
		Synth(\angelicVoice, [
			\freq, ~root * [0.5, 1, 1.5].choose * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.06, 0.1),
			\dur, rrand(8, 20)
		]);
		rrand(10, 25).wait;
	};
}).play;

"ELYSIAN FIELDS - Meditative bliss".postln;
)

// Stop
// ~pad.free; ~bellRoutine.stop; ~voiceRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: ANGEL PLAY
// More active, playful
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 329.6;  // E

~pad = Synth(\celestialPad, [\freq, ~root / 2, \amp, 0.06]);

// Fast bell patterns
~bellRoutine = Routine({
	var pattern = [0, 2, 4, 7, 9, 7, 4, 2, 0, 4, 7, 11];
	var tempo = 0.2;
	var i = 0;
	inf.do {
		var degree = pattern[i % pattern.size];
		var freq = ~root * (2 ** (~scale[degree] / 12));

		Synth(\crystalBell, [
			\freq, freq,
			\amp, rrand(0.08, 0.12),
			\decay, rrand(1.5, 3),
			\pan, rrand(-0.4, 0.4)
		]);

		i = i + 1;
		tempo.wait;
	};
}).play;

// High bell accents
~highBellRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\crystalBell, [
				\freq, ~root * 4 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.05, 0.09),
				\decay, rrand(2, 4)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Frequent glisses
~glissRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\harpGliss, [
				\baseFreq, ~root * [1, 2].choose,
				\amp, rrand(0.04, 0.07),
				\numNotes, rrand(6, 12),
				\rate, rrand(12, 20)
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

"ANGEL PLAY - Bright and active".postln;
)

// Stop
// ~pad.free; ~bellRoutine.stop; ~highBellRoutine.stop; ~glissRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: REALMS OF LIGHT
// Maximum density
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 220;

// Multiple pads
~pad1 = Synth(\celestialPad, [\freq, ~root / 2, \amp, 0.05]);
~pad2 = Synth(\celestialPad, [\freq, ~root, \amp, 0.04]);

// Dense bells
~bellRoutine = Routine({
	inf.do {
		Synth(\crystalBell, [
			\freq, ~root * [1, 2, 4].choose * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.06, 0.1),
			\decay, rrand(2, 5),
			\pan, rrand(-0.7, 0.7)
		]);
		rrand(0.2, 0.8).wait;
	};
}).play;

// Multiple voices
~voiceRoutine = Routine({
	inf.do {
		Synth(\angelicVoice, [
			\freq, ~root * [0.5, 1, 1.5, 2].choose * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.04, 0.08),
			\dur, rrand(4, 10)
		]);
		rrand(2, 6).wait;
	};
}).play;

// Frequent glisses
~glissRoutine = Routine({
	inf.do {
		Synth(\harpGliss, [
			\baseFreq, ~root * [0.5, 1, 2, 4].choose,
			\amp, rrand(0.03, 0.06),
			\numNotes, rrand(8, 20),
			\rate, rrand(10, 25)
		]);
		rrand(2, 6).wait;
	};
}).play;

"REALMS OF LIGHT - Maximum celestial density".postln;
)

// Stop
// ~pad1.free; ~pad2.free; ~bellRoutine.stop; ~voiceRoutine.stop; ~glissRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: DEEP SPACE
// Lower register, cosmic
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];
~root = 110;

~pad = Synth(\celestialPad, [\freq, ~root / 4, \amp, 0.08]);

// Low bells
~bellRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\crystalBell, [
				\freq, ~root * [0.5, 1, 2].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.1, 0.15),
				\decay, rrand(5, 10),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Deep voices
~voiceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\angelicVoice, [
				\freq, ~root * [0.5, 1].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(8, 20)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

// Slow glisses
~glissRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\harpGliss, [
				\baseFreq, ~root * [0.5, 1].choose,
				\amp, rrand(0.04, 0.08),
				\numNotes, rrand(10, 18),
				\rate, rrand(4, 8)
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

"DEEP SPACE - Cosmic meditation".postln;
)

// Stop
// ~pad.free; ~bellRoutine.stop; ~voiceRoutine.stop; ~glissRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
