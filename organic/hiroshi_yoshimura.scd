// ============================================================
// HIROSHI YOSHIMURA STYLE - Environmental music, gentle synthesis
// ============================================================
// Inspired by "Music for Nine Post Cards":
// - Gentle, unobtrusive synthesis
// - Environmental / furniture music
// - Simple, pure tones
// - Pentatonic harmony
// - Peaceful, meditative quality

// --------------------------------------------------
// GENTLE TONE - Pure, soft sine-based voice
// --------------------------------------------------
(
SynthDef(\gentleTone, {
	arg out = 0, amp = 0.12, freq = 440, dur = 2, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3, 1, \sin), doneAction: 2);

	// Pure, simple tone
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.15);

	// Gentle high-frequency content
	sig = sig + (SinOsc.ar(freq * 3) * 0.05);

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// AMBIENT WASH - Soft background texture
// --------------------------------------------------
(
SynthDef(\ambientWash, {
	arg out = 0, amp = 0.05, freq = 220;
	var sig;

	sig = Mix.fill(4, { |i|
		var partial = [1, 2, 3, 4][i];
		var detune = LFNoise2.kr(0.01).range(0.998, 1.002);
		SinOsc.ar(freq * partial * detune) * (1 / (partial * 2));
	});

	// Very slow modulation
	sig = sig * LFNoise2.kr(0.02).range(0.8, 1);

	sig = LPF.ar(sig, 2000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// WATER DROP - Delicate pluck-like sound
// --------------------------------------------------
(
SynthDef(\waterDrop, {
	arg out = 0, amp = 0.1, freq = 880, decay = 1.5, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -5), doneAction: 2);

	// Bell-like quality
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.2) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3.5) * 0.1);

	sig = LPF.ar(sig, 4000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: NINE POST CARDS
// Classic Yoshimura style
// --------------------------------------------------
(
// Pentatonic scale (just intonation)
~scale = [1, 9/8, 5/4, 3/2, 5/3];  // Major pentatonic ratios
~root = 220;

// Gentle background wash
~wash = Synth(\ambientWash, [\freq, ~root / 2, \amp, 0.04]);

// Melodic routine
~melodyRoutine = Routine({
	inf.do {
		var degree = ~scale.choose;
		var octave = [1, 2].wchoose([0.6, 0.4]);
		var freq = ~root * degree * octave;

		Synth(\gentleTone, [
			\freq, freq,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(1.5, 4),
			\pan, rrand(-0.4, 0.4)
		]);

		rrand(2, 6).wait;
	};
}).play;

// Occasional water drops
~dropRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			var freq = ~root * ~scale.choose * [2, 4].choose;
			Synth(\waterDrop, [
				\freq, freq,
				\amp, rrand(0.04, 0.08),
				\decay, rrand(1, 2.5),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

"NINE POST CARDS - Environmental music".postln;
)

// Stop
// ~wash.free; ~melodyRoutine.stop; ~dropRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: GREEN
// Lower register, more sustained
// --------------------------------------------------
(
~scale = [1, 9/8, 5/4, 3/2, 5/3];
~root = 110;

~wash = Synth(\ambientWash, [\freq, ~root / 2, \amp, 0.05]);

// Slower, longer tones
~toneRoutine = Routine({
	inf.do {
		var freq = ~root * ~scale.choose * [0.5, 1, 1].choose;

		Synth(\gentleTone, [
			\freq, freq,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(3, 8),
			\pan, rrand(-0.3, 0.3)
		]);

		rrand(4, 10).wait;
	};
}).play;

// Rare drops
~dropRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\waterDrop, [
				\freq, ~root * ~scale.choose * 2,
				\amp, rrand(0.03, 0.06),
				\decay, rrand(1.5, 3)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

"GREEN - Lower sustains".postln;
)

// Stop
// ~wash.free; ~toneRoutine.stop; ~dropRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: PIER AND LOFT
// Slightly more active
// --------------------------------------------------
(
~scale = [1, 9/8, 5/4, 3/2, 5/3, 2];
~root = 220;

~wash = Synth(\ambientWash, [\freq, ~root / 2, \amp, 0.035]);

// Two voice interplay
~voice1 = Routine({
	inf.do {
		var freq = ~root * ~scale.choose;
		Synth(\gentleTone, [
			\freq, freq,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(1, 3),
			\pan, -0.3
		]);
		rrand(1.5, 4).wait;
	};
}).play;

~voice2 = Routine({
	1.5.wait;  // Offset
	inf.do {
		var freq = ~root * ~scale.choose * 2;
		Synth(\gentleTone, [
			\freq, freq,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(1, 2.5),
			\pan, 0.3
		]);
		rrand(2, 5).wait;
	};
}).play;

// More frequent drops
~dropRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\waterDrop, [
				\freq, ~root * ~scale.choose * [2, 4].choose,
				\amp, rrand(0.04, 0.08),
				\decay, rrand(0.8, 2)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"PIER AND LOFT - Two voices".postln;
)

// Stop
// ~wash.free; ~voice1.stop; ~voice2.stop; ~dropRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: FLORA
// Higher register, bright
// --------------------------------------------------
(
~scale = [1, 9/8, 5/4, 3/2, 5/3];
~root = 440;

~wash = Synth(\ambientWash, [\freq, 220, \amp, 0.03]);

// Bright, gentle tones
~toneRoutine = Routine({
	inf.do {
		var freq = ~root * ~scale.choose * [0.5, 1, 2].wchoose([0.2, 0.5, 0.3]);

		Synth(\gentleTone, [
			\freq, freq,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(1, 3),
			\pan, rrand(-0.5, 0.5)
		]);

		rrand(1.5, 4).wait;
	};
}).play;

// Frequent drops
~dropRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\waterDrop, [
				\freq, ~root * ~scale.choose * [1, 2].choose,
				\amp, rrand(0.05, 0.1),
				\decay, rrand(0.8, 1.8),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(1.5, 5).wait;
	};
}).play;

"FLORA - Bright register".postln;
)

// Stop
// ~wash.free; ~toneRoutine.stop; ~dropRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: SOUNDSCAPE
// Very sparse, maximum space
// --------------------------------------------------
(
~scale = [1, 9/8, 5/4, 3/2, 5/3];
~root = 165;

~wash = Synth(\ambientWash, [\freq, ~root / 2, \amp, 0.025]);

// Very sparse tones
~toneRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			var freq = ~root * ~scale.choose * [0.5, 1, 2].choose;

			Synth(\gentleTone, [
				\freq, freq,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(3, 8),
				\pan, rrand(-0.3, 0.3)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

// Rare drops
~dropRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\waterDrop, [
				\freq, ~root * ~scale.choose * 2,
				\amp, rrand(0.03, 0.06),
				\decay, rrand(2, 4)
			]);
		};
		rrand(10, 30).wait;
	};
}).play;

"SOUNDSCAPE - Maximum space".postln;
)

// Stop
// ~wash.free; ~toneRoutine.stop; ~dropRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
