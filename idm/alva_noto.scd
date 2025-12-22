// ============================================================
// ALVA NOTO STYLE - Micro-sound, sine waves, digital precision
// ============================================================
// Inspired by "Xerrox" series:
// - Pure sine wave aesthetics
// - Precise digital clicks
// - Minimal, grid-based structures
// - Micro-tonal explorations
// - Clean, clinical soundscapes

// --------------------------------------------------
// PURE SINE - Clean sine tone
// --------------------------------------------------
(
SynthDef(\pureSine, {
	arg out = 0, amp = 0.2, freq = 440, dur = 1, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01, 1, \sin), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// DIGITAL CLICK - Precise, clean click
// --------------------------------------------------
(
SynthDef(\digitalClick, {
	arg out = 0, amp = 0.15, freq = 4000, dur = 0.002, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.0001, dur, 1, -8), doneAction: 2);

	// Pure click - single cycle
	sig = SinOsc.ar(freq) * 0.7;
	sig = sig + (WhiteNoise.ar * 0.3);

	sig = HPF.ar(sig, 500);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// GRID PULSE - Precise rhythmic pulse
// --------------------------------------------------
(
SynthDef(\gridPulse, {
	arg out = 0, amp = 0.1, freq = 200, rate = 8, dur = 2;
	var sig, env, trig;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);
	trig = Impulse.ar(rate);

	sig = SinOsc.ar(freq) * Decay.ar(trig, 1/rate * 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SINE CLUSTER - Multiple pure tones
// --------------------------------------------------
(
SynthDef(\sineCluster, {
	arg out = 0, amp = 0.1, freq = 440, spread = 10, numTones = 5;
	var sig;

	sig = Mix.fill(numTones, { |i|
		var offset = (i - (numTones / 2)) * spread;
		SinOsc.ar(freq + offset) * (1 / numTones);
	});

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// MICRO TEXTURE - Dense, quiet micro-sounds
// --------------------------------------------------
(
SynthDef(\microTexture, {
	arg out = 0, amp = 0.05, density = 50;
	var sig, clicks;

	// Sparse random clicks
	clicks = Dust.ar(density) * 0.5;

	// Add subtle digital noise
	sig = clicks + (LFNoise0.ar(density * 100) * 0.1);

	sig = HPF.ar(sig, 1000);
	sig = LPF.ar(sig, 12000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: XERROX MINIMAL
// Clean, grid-based minimalism
// --------------------------------------------------
(
~micro = Synth(\microTexture, [\amp, 0.03, \density, 40]);

// Regular click grid
~clickRoutine = Routine({
	var tempo = 0.25;
	inf.do { |i|
		if ((i % 4 == 0) || (i % 4 == 3)) {
			Synth(\digitalClick, [
				\amp, rrand(0.08, 0.15),
				\freq, [3000, 4000, 5000].choose,
				\pan, rrand(-0.3, 0.3)
			]);
		};
		tempo.wait;
	};
}).play;

// Pure sine tones
~sineRoutine = Routine({
	var freqs = [440, 550, 660, 880];
	var i = 0;
	inf.do {
		Synth(\pureSine, [
			\freq, freqs[i % 4],
			\amp, rrand(0.1, 0.18),
			\dur, rrand(0.5, 2),
			\pan, [-0.5, 0, 0.5].choose
		]);
		i = i + 1;
		1.wait;
	};
}).play;

"XERROX MINIMAL - Digital precision".postln;
)

// Stop
// ~micro.free; ~clickRoutine.stop; ~sineRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: MICRO GRID
// Focus on tiny sounds
// --------------------------------------------------
(
~micro = Synth(\microTexture, [\amp, 0.05, \density, 80]);

// Dense click patterns
~clickRoutine = Routine({
	inf.do {
		// Burst of clicks
		rrand(3, 10).do {
			Synth(\digitalClick, [
				\amp, rrand(0.05, 0.12),
				\freq, rrand(2000, 8000),
				\dur, rrand(0.001, 0.005),
				\pan, rrand(-0.8, 0.8)
			]);
			rrand(0.01, 0.05).wait;
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Sparse sine
~sineRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\pureSine, [
				\freq, rrand(200, 1000),
				\amp, rrand(0.06, 0.12),
				\dur, rrand(0.5, 3),
				\pan, rrand(-0.4, 0.4)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Grid pulses
~pulseRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\gridPulse, [
				\freq, [200, 300, 400, 600].choose,
				\amp, rrand(0.04, 0.08),
				\rate, [8, 12, 16, 24].choose,
				\dur, rrand(1, 4)
			]);
		};
		rrand(3, 10).wait;
	};
}).play;

"MICRO GRID - Tiny precision".postln;
)

// Stop
// ~micro.free; ~clickRoutine.stop; ~sineRoutine.stop; ~pulseRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: SINE MEDITATION
// Focus on pure tones
// --------------------------------------------------
(
// Sine cluster drone
~cluster = Synth(\sineCluster, [\freq, 220, \amp, 0.06, \spread, 5, \numTones, 7]);

// Sparse clicks
~clickRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\digitalClick, [
				\amp, rrand(0.04, 0.08),
				\freq, rrand(3000, 6000),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		rrand(0.5, 3).wait;
	};
}).play;

// Additional sine tones
~sineRoutine = Routine({
	var harmonics = [1, 2, 3, 4, 5, 6];
	var root = 220;
	inf.do {
		Synth(\pureSine, [
			\freq, root * harmonics.choose,
			\amp, rrand(0.04, 0.1),
			\dur, rrand(2, 8),
			\pan, rrand(-0.3, 0.3)
		]);
		rrand(3, 10).wait;
	};
}).play;

// Shift cluster frequency occasionally
~shiftRoutine = Routine({
	var freqs = [110, 165, 220, 330, 440];
	inf.do {
		~cluster.set(\freq, freqs.choose);
		rrand(15, 40).wait;
	};
}).play;

"SINE MEDITATION - Pure frequencies".postln;
)

// Stop
// ~cluster.free; ~clickRoutine.stop; ~sineRoutine.stop; ~shiftRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: DIGITAL STATIC
// Rhythmic noise exploration
// --------------------------------------------------
(
SynthDef(\staticBurst, {
	arg out = 0, amp = 0.1, dur = 0.1;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);
	sig = LFNoise0.ar(20000) * 0.5;
	sig = sig + (Dust.ar(1000) * 0.5);
	sig = HPF.ar(sig, 2000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

~micro = Synth(\microTexture, [\amp, 0.04, \density, 60]);

// Static bursts
~staticRoutine = Routine({
	var tempo = 0.2;
	var pattern = [1, 0, 1, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\staticBurst, [
				\amp, rrand(0.06, 0.12),
				\dur, rrand(0.05, 0.15)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Precise clicks on grid
~clickRoutine = Routine({
	var tempo = 0.2;
	var pattern = [0, 1, 0, 0, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\digitalClick, [
				\amp, rrand(0.1, 0.16),
				\freq, [4000, 5000, 6000].choose
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Sub sine
~sineRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\pureSine, [
				\freq, [55, 82.4, 110].choose,
				\amp, rrand(0.12, 0.2),
				\dur, rrand(1, 3)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"DIGITAL STATIC - Rhythmic noise".postln;
)

// Stop
// ~micro.free; ~staticRoutine.stop; ~clickRoutine.stop; ~sineRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: UNITXT
// Dense, complex, rapid
// --------------------------------------------------
(
~micro = Synth(\microTexture, [\amp, 0.04, \density, 100]);

// Rapid click patterns
~clickRoutine = Routine({
	inf.do {
		// Random density bursts
		var density = rrand(5, 20);
		density.do {
			Synth(\digitalClick, [
				\amp, rrand(0.04, 0.12),
				\freq, rrand(2000, 10000),
				\dur, rrand(0.001, 0.01),
				\pan, rrand(-0.9, 0.9)
			]);
			rrand(0.01, 0.08).wait;
		};
		rrand(0.1, 0.8).wait;
	};
}).play;

// Fast sine flashes
~sineRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\pureSine, [
				\freq, rrand(200, 2000),
				\amp, rrand(0.06, 0.15),
				\dur, rrand(0.05, 0.3),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(0.05, 0.3).wait;
	};
}).play;

// Grid pulses
~pulseRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\gridPulse, [
				\freq, rrand(100, 600),
				\amp, rrand(0.04, 0.08),
				\rate, [16, 24, 32].choose,
				\dur, rrand(0.5, 2)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

"UNITXT - Dense micro-sound".postln;
)

// Stop
// ~micro.free; ~clickRoutine.stop; ~sineRoutine.stop; ~pulseRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
