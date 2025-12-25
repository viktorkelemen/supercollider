// ============================================================
// GAS STYLE - Forest ambient, buried loops, hypnotic haze
// ============================================================
// Inspired by "Pop", "Königsforst", "Narkopop":
// - Looped orchestral fragments
// - Dense fog-like textures
// - 4/4 kick buried in haze
// - Nature sounds and forest atmosphere
// - Hypnotic, trance-inducing repetition

// --------------------------------------------------
// FOREST HAZE - Dense ambient texture
// --------------------------------------------------
SynthDef(\forestHaze, {
	arg out = 0, amp = 0.1, freq = 200, dur = 20;
	var sig, env;

	env = EnvGen.kr(Env.linen(3, dur - 6, 3), doneAction: 2);

	// Multiple layered tones
	sig = Mix.fill(6, { |i|
		var f = freq * (i + 1) * LFNoise1.kr(0.05).range(0.99, 1.01);
		var level = 1 / (i + 1);
		SinOsc.ar(f) * level
	}) / 3;

	// Heavy filtering and reverb
	sig = LPF.ar(sig, 800 + (LFNoise1.kr(0.1) * 300));
	sig = FreeVerb.ar(sig, 0.9, 0.95, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BURIED KICK - Muffled 4/4 kick
// --------------------------------------------------
SynthDef(\buriedKick, {
	arg out = 0, amp = 0.2, freq = 50;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, 0.3, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.1, 1, -4)).range(1, 2));
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.3);

	// Heavy muffling
	sig = LPF.ar(sig, 150);
	sig = FreeVerb.ar(sig, 0.6, 0.7, 0.3);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// ORCHESTRAL LOOP - Strings-like pad
// --------------------------------------------------
SynthDef(\orchestralLoop, {
	arg out = 0, amp = 0.1, freq = 220, dur = 8;
	var sig, env;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);

	// String-like harmonics
	sig = Saw.ar(freq) * 0.3;
	sig = sig + (Saw.ar(freq * 1.002) * 0.25);
	sig = sig + (Saw.ar(freq * 2.003) * 0.15);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.2);

	// Warm filtering
	sig = LPF.ar(sig, 1500);
	sig = RLPF.ar(sig, 600 + (LFNoise1.kr(0.2) * 200), 0.5);

	// Dense reverb
	sig = FreeVerb.ar(sig, 0.8, 0.9, 0.4);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// WIND TEXTURE - Forest wind
// --------------------------------------------------
SynthDef(\windTexture, {
	arg out = 0, amp = 0.06;
	var sig;

	sig = PinkNoise.ar;
	sig = BPF.ar(sig, LFNoise1.kr(0.1).range(200, 600), 0.5);
	sig = sig + BPF.ar(PinkNoise.ar, LFNoise1.kr(0.15).range(800, 1500), 0.3) * 0.3;

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CHOIR FRAGMENT - Buried vocal texture
// --------------------------------------------------
SynthDef(\choirFragment, {
	arg out = 0, amp = 0.08, freq = 330, dur = 6;
	var sig, env;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);

	// Formant-like synthesis
	sig = Saw.ar(freq) * 0.3;
	sig = BPF.ar(sig, 700, 0.1) * 3;
	sig = sig + BPF.ar(Saw.ar(freq), 1200, 0.1) * 2;

	// Heavy processing
	sig = LPF.ar(sig, 2000);
	sig = FreeVerb.ar(sig, 0.9, 0.95, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// NATURE CRACKLE - Forest floor texture
// --------------------------------------------------
SynthDef(\natureCrackle, {
	arg out = 0, amp = 0.04, density = 20;
	var sig;

	sig = Dust.ar(density) * 0.3;
	sig = sig + (Crackle.ar(1.7) * 0.1);
	sig = LPF.ar(sig, 3000);
	sig = HPF.ar(sig, 200);

	// Reverb for space
	sig = FreeVerb.ar(sig, 0.6, 0.8, 0.3);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HORN DRONE - Buried brass texture
// --------------------------------------------------
SynthDef(\hornDrone, {
	arg out = 0, amp = 0.08, freq = 110, dur = 10;
	var sig, env;

	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Saw.ar(freq * 1.003) * 0.3);
	sig = RLPF.ar(sig, 400, 0.4);

	sig = LPF.ar(sig, 1000);
	sig = FreeVerb.ar(sig, 0.85, 0.9, 0.4);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Gas SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: POP
// Classic Gas - 4/4 buried in haze
// --------------------------------------------------
(
~wind = Synth(\windTexture, [\amp, 0.04]);
~crackle = Synth(\natureCrackle, [\amp, 0.03, \density, 15]);

// Buried kick at ~120bpm
~kickRoutine = Routine({
	inf.do {
		Synth(\buriedKick, [\amp, rrand(0.15, 0.22), \freq, 50]);
		0.5.wait;
	};
}).play;

// Orchestral loops
~orchestraRoutine = Routine({
	var notes = [55, 60, 62, 67].midicps;
	inf.do {
		Synth(\orchestralLoop, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(8, 16)
		]);
		rrand(4, 10).wait;
	};
}).play;

// Forest haze
~hazeRoutine = Routine({
	inf.do {
		Synth(\forestHaze, [
			\freq, [110, 165, 220].choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(15, 30)
		]);
		rrand(12, 25).wait;
	};
}).play;

"POP - 4/4 in haze".postln;
)

// Stop
// ~wind.free; ~crackle.free; ~kickRoutine.stop; ~orchestraRoutine.stop; ~hazeRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: KÖNIGSFORST
// Dense forest atmosphere
// --------------------------------------------------
(
~wind = Synth(\windTexture, [\amp, 0.06]);
~crackle = Synth(\natureCrackle, [\amp, 0.04, \density, 25]);

// No kick - pure ambient
~hazeRoutine = Routine({
	var freqs = [110, 130, 165, 196];
	inf.do {
		Synth(\forestHaze, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(20, 40)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Orchestral swells
~orchestraRoutine = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		Synth(\orchestralLoop, [
			\freq, notes.choose,
			\amp, rrand(0.05, 0.09),
			\dur, rrand(10, 20)
		]);
		rrand(8, 15).wait;
	};
}).play;

// Choir fragments
~choirRoutine = Routine({
	var notes = [220, 277, 330, 392].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\choirFragment, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(5, 10)
			]);
		};
		rrand(8, 18).wait;
	};
}).play;

"KÖNIGSFORST - Forest atmosphere".postln;
)

// Stop
// ~wind.free; ~crackle.free; ~hazeRoutine.stop; ~orchestraRoutine.stop; ~choirRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: NARKOPOP
// Modern Gas - clearer elements
// --------------------------------------------------
(
~crackle = Synth(\natureCrackle, [\amp, 0.02, \density, 10]);

// Slower kick
~kickRoutine = Routine({
	inf.do {
		Synth(\buriedKick, [\amp, rrand(0.12, 0.18), \freq, 45]);
		0.6.wait;
	};
}).play;

// Cleaner orchestral
~orchestraRoutine = Routine({
	var notes = [60, 64, 67, 72].midicps;
	inf.do {
		Synth(\orchestralLoop, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(6, 12)
		]);
		rrand(4, 8).wait;
	};
}).play;

// Horn drones
~hornRoutine = Routine({
	var notes = [55, 65.4, 82.4].midicps;
	inf.do {
		if (0.35.coin) {
			Synth(\hornDrone, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(10, 18)
			]);
		};
		rrand(12, 25).wait;
	};
}).play;

// Lighter haze
~lightHaze = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\forestHaze, [
				\freq, [165, 220, 330].choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(10, 20)
			]);
		};
		rrand(8, 15).wait;
	};
}).play;

"NARKOPOP - Modern Gas".postln;
)

// Stop
// ~crackle.free; ~kickRoutine.stop; ~orchestraRoutine.stop; ~hornRoutine.stop; ~lightHaze.stop;

// --------------------------------------------------
// EXPERIMENT 4: ZAUBERBERG
// Early Gas - darker
// --------------------------------------------------
(
~wind = Synth(\windTexture, [\amp, 0.05]);
~crackle = Synth(\natureCrackle, [\amp, 0.03, \density, 20]);

// Low haze
~lowHaze = Routine({
	var freqs = [55, 65.4, 82.4];
	inf.do {
		Synth(\forestHaze, [
			\freq, freqs.choose,
			\amp, rrand(0.1, 0.14),
			\dur, rrand(25, 45)
		]);
		rrand(20, 35).wait;
	};
}).play;

// Deep orchestra
~deepOrchestra = Routine({
	var notes = [36, 43, 48, 55].midicps;
	inf.do {
		Synth(\orchestralLoop, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(12, 20)
		]);
		rrand(8, 15).wait;
	};
}).play;

// Sparse kick
~sparseKick = Routine({
	inf.do {
		if (0.7.coin) {
			Synth(\buriedKick, [\amp, rrand(0.1, 0.16), \freq, 40]);
		};
		0.5.wait;
	};
}).play;

"ZAUBERBERG - Dark early Gas".postln;
)

// Stop
// ~wind.free; ~crackle.free; ~lowHaze.stop; ~deepOrchestra.stop; ~sparseKick.stop;

// --------------------------------------------------
// EXPERIMENT 5: RAUSCH
// Intoxicated swirl
// --------------------------------------------------
(
~wind = Synth(\windTexture, [\amp, 0.04]);

// Swirling haze
~swirlHaze = Routine({
	var freqs = [110, 123.5, 146.8, 165, 196, 220];
	var i = 0;
	inf.do {
		Synth(\forestHaze, [
			\freq, freqs[i % freqs.size],
			\amp, rrand(0.05, 0.08),
			\dur, rrand(12, 20)
		]);
		i = i + 1;
		rrand(6, 12).wait;
	};
}).play;

// Evolving orchestra
~evolvingOrchestra = Routine({
	var notes = [55, 60, 62, 64, 67, 69, 72].midicps;
	var i = 0;
	inf.do {
		Synth(\orchestralLoop, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.06, 0.1),
			\dur, rrand(6, 12)
		]);
		i = i + 1;
		rrand(3, 6).wait;
	};
}).play;

// Buried kick
~kickRoutine = Routine({
	inf.do {
		Synth(\buriedKick, [\amp, rrand(0.1, 0.16), \freq, 50]);
		0.5.wait;
	};
}).play;

// Choir wisps
~choirWisp = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\choirFragment, [
				\freq, rrand(250, 500),
				\amp, rrand(0.03, 0.06),
				\dur, rrand(4, 8)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

"RAUSCH - Intoxicated swirl".postln;
)

// Stop
// ~wind.free; ~swirlHaze.stop; ~evolvingOrchestra.stop; ~kickRoutine.stop; ~choirWisp.stop;

// --------------------------------------------------
// EXPERIMENT 6: NO BEAT
// Pure ambient Gas
// --------------------------------------------------
(
~wind = Synth(\windTexture, [\amp, 0.05]);
~crackle = Synth(\natureCrackle, [\amp, 0.03, \density, 12]);

// Multiple haze layers
~haze1 = Routine({
	inf.do {
		Synth(\forestHaze, [
			\freq, [82.4, 110, 130].choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(20, 40)
		]);
		rrand(15, 30).wait;
	};
}).play;

~haze2 = Routine({
	inf.do {
		Synth(\forestHaze, [
			\freq, [165, 196, 220].choose,
			\amp, rrand(0.04, 0.08),
			\dur, rrand(15, 30)
		]);
		rrand(12, 25).wait;
	};
}).play;

// Orchestral sustains
~sustainOrchestra = Routine({
	var notes = [48, 55, 60, 67].midicps;
	inf.do {
		2.do {
			Synth(\orchestralLoop, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(12, 20)
			]);
		};
		rrand(10, 20).wait;
	};
}).play;

// Horn layer
~hornLayer = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\hornDrone, [
				\freq, [65.4, 82.4, 110].choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(12, 20)
			]);
		};
		rrand(15, 30).wait;
	};
}).play;

"NO BEAT - Pure ambient".postln;
)

// Stop
// ~wind.free; ~crackle.free; ~haze1.stop; ~haze2.stop; ~sustainOrchestra.stop; ~hornLayer.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
