// ============================================================
// FENNESZ STYLE - Granular textures, ambient guitar, warm noise
// ============================================================
// Inspired by "Endless Summer", "Venice", "Bécs":
// - Dense granular clouds
// - Shimmering harmonics
// - Warm, organic noise
// - Processed guitar textures
// - Glitchy digital artifacts
// - Cascading ambient washes

// --------------------------------------------------
// GRANULAR CLOUD - Dense texture cloud
// --------------------------------------------------
SynthDef(\granularCloud, {
	arg out = 0, amp = 0.1, freq = 400, density = 40, spread = 200;
	var sig, grains;
	grains = Mix.fill(8, { |i|
		var grainFreq = freq + LFNoise1.kr(0.5 + (i * 0.1)).range(spread.neg, spread);
		var grainAmp = LFNoise1.kr(1 + (i * 0.2)).range(0.3, 1);
		SinOsc.ar(grainFreq) * Dust.kr(density / 8) * grainAmp;
	});
	sig = grains;
	sig = LPF.ar(sig, 6000);
	sig = sig + (CombL.ar(sig, 0.2, 0.15, 2) * 0.3);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SHIMMER PAD - Bright harmonic shimmer
// --------------------------------------------------
SynthDef(\shimmerPad, {
	arg out = 0, amp = 0.1, freq = 220, shimmerRate = 3;
	var sig, shimmer;
	sig = Mix([
		SinOsc.ar(freq) * 0.5,
		SinOsc.ar(freq * 2.01) * 0.3,
		SinOsc.ar(freq * 3.99) * 0.15,
		SinOsc.ar(freq * 5.02) * 0.1
	]);
	shimmer = SinOsc.ar(freq * 8 + (SinOsc.kr(shimmerRate) * 20)) * 0.1;
	sig = sig + shimmer;
	sig = sig + (DelayC.ar(sig, 0.5, SinOsc.kr(0.1).range(0.01, 0.03)) * 0.4);
	sig = LPF.ar(sig, 8000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// WARM NOISE - Filtered organic noise
// --------------------------------------------------
SynthDef(\warmNoise, {
	arg out = 0, amp = 0.08, cutoff = 2000, res = 0.3;
	var sig;
	sig = PinkNoise.ar;
	sig = RLPF.ar(sig, cutoff + (LFNoise1.kr(0.3) * 500), res);
	sig = sig + (BPF.ar(PinkNoise.ar, cutoff * 0.5, 0.5) * 0.3);
	sig = sig.tanh;
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GLITCH GRAIN - Sporadic glitchy particles
// --------------------------------------------------
SynthDef(\glitchGrain, {
	arg out = 0, amp = 0.1, density = 5, freqLo = 1000, freqHi = 8000;
	var sig, trig;
	trig = Dust.kr(density);
	sig = SinOsc.ar(TRand.kr(freqLo, freqHi, trig)) * Decay.kr(trig, 0.02);
	sig = sig + (WhiteNoise.ar * Decay.kr(trig, 0.005) * 0.3);
	sig = sig * amp;
	Out.ar(out, Pan2.ar(sig, TRand.kr(-0.8, 0.8, trig)));
}).add;

// --------------------------------------------------
// DRONE WASH - Evolving ambient drone
// --------------------------------------------------
SynthDef(\droneWash, {
	arg out = 0, amp = 0.1, freq = 110;
	var sig, mod;
	mod = LFNoise1.kr(0.1).range(0.99, 1.01);
	sig = Mix([
		Saw.ar(freq * mod) * 0.3,
		Pulse.ar(freq * 0.5 * mod, LFNoise1.kr(0.2).range(0.3, 0.7)) * 0.2,
		SinOsc.ar(freq * 2 * mod) * 0.2
	]);
	sig = LPF.ar(sig, 1500 + (LFNoise1.kr(0.2) * 500));
	sig = sig + (CombC.ar(sig, 0.5, 0.25, 3) * 0.3);
	sig = sig + (FreeVerb.ar(sig, 0.7, 0.9, 0.3) * 0.5);
	sig = sig.tanh;
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GUITAR TEXTURE - Processed guitar-like tone
// --------------------------------------------------
SynthDef(\guitarTexture, {
	arg out = 0, amp = 0.15, freq = 330, dur = 3, drive = 2;
	var sig, env, pluck;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	pluck = Pluck.ar(PinkNoise.ar, Impulse.kr(0), 1/freq, 1/freq, dur * 2, 0.5);
	sig = pluck + (SinOsc.ar(freq) * 0.3);
	sig = (sig * drive).tanh;
	sig = LPF.ar(sig, 3000 + (env * 2000));
	sig = sig + (CombL.ar(sig, 0.3, 0.2, 2) * 0.4);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CRACKLE BED - Warm vinyl-like crackle
// --------------------------------------------------
SynthDef(\crackleBed, {
	arg out = 0, amp = 0.04, density = 30;
	var sig;
	sig = Dust.ar(density) * 0.5;
	sig = sig + (Crackle.ar(1.8) * 0.05);
	sig = LPF.ar(sig, 4000);
	sig = HPF.ar(sig, 100);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CASCADE - Shimmering harmonic cascade
// --------------------------------------------------
SynthDef(\cascade, {
	arg out = 0, amp = 0.08, baseFreq = 440, dur = 5;
	var sig, env;
	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);
	sig = Mix.fill(6, { |i|
		var freq = baseFreq * (i + 1) * LFNoise1.kr(0.2).range(0.99, 1.01);
		var ampMod = LFNoise1.kr(0.5 + (i * 0.1)).range(0.2, 1);
		SinOsc.ar(freq) * ampMod * (1 / (i + 1));
	});
	sig = sig + (DelayC.ar(sig, 0.5, LFNoise1.kr(0.1).range(0.02, 0.05)) * 0.5);
	sig = LPF.ar(sig, 6000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Fennesz SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: ENDLESS SUMMER
// Warm, hazy, nostalgic
// --------------------------------------------------
(
~crackle = Synth(\crackleBed, [\amp, 0.03, \density, 25]);
~warmNoise = Synth(\warmNoise, [\amp, 0.05, \cutoff, 1500]);

~shimmerRoutine = Routine({
	var freqs = [220, 277, 330, 440];
	inf.do {
		Synth(\shimmerPad, [\freq, freqs.choose, \amp, rrand(0.06, 0.1), \shimmerRate, rrand(2, 5)]);
		rrand(4, 10).wait;
	};
}).play;

~cascadeRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\cascade, [\baseFreq, [220, 330, 440, 550].choose, \amp, rrand(0.05, 0.08), \dur, rrand(4, 8)]);
		};
		rrand(5, 12).wait;
	};
}).play;

~guitarRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\guitarTexture, [\freq, rrand(200, 500), \amp, rrand(0.08, 0.14), \dur, rrand(2, 5)]);
		};
		rrand(4, 10).wait;
	};
}).play;

"ENDLESS SUMMER - Warm haze".postln;
)

// Stop
// ~crackle.free; ~warmNoise.free; ~shimmerRoutine.stop; ~cascadeRoutine.stop; ~guitarRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: VENICE
// Dense, layered, submerged
// --------------------------------------------------
(
~drone = Synth(\droneWash, [\amp, 0.08, \freq, 82.4]);
~crackle = Synth(\crackleBed, [\amp, 0.02, \density, 15]);

~granularRoutine = Routine({
	inf.do {
		Synth(\granularCloud, [
			\freq, [200, 300, 400, 500].choose,
			\amp, rrand(0.06, 0.1),
			\density, rrand(30, 60),
			\spread, rrand(100, 300)
		]);
		rrand(6, 15).wait;
	};
}).play;

~glitchRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\glitchGrain, [\density, rrand(3, 8), \amp, rrand(0.04, 0.08)]);
		};
		rrand(3, 8).wait;
	};
}).play;

~shimmerRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\shimmerPad, [\freq, [110, 165, 220].choose, \amp, rrand(0.05, 0.08)]);
		};
		rrand(8, 20).wait;
	};
}).play;

"VENICE - Submerged layers".postln;
)

// Stop
// ~drone.free; ~crackle.free; ~granularRoutine.stop; ~glitchRoutine.stop; ~shimmerRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: GUITAR DREAMS
// Processed strings, warm distortion
// --------------------------------------------------
(
~warmNoise = Synth(\warmNoise, [\amp, 0.04, \cutoff, 1200, \res, 0.4]);
~crackle = Synth(\crackleBed, [\amp, 0.03, \density, 20]);

~guitarRoutine = Routine({
	var notes = [165, 196, 220, 247, 294, 330];
	inf.do {
		Synth(\guitarTexture, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.18),
			\dur, rrand(3, 7),
			\drive, rrand(1.5, 3)
		]);
		rrand(2, 6).wait;
	};
}).play;

~cascadeRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\cascade, [\baseFreq, [165, 220, 330].choose, \amp, rrand(0.04, 0.07), \dur, rrand(5, 10)]);
		};
		rrand(6, 15).wait;
	};
}).play;

"GUITAR DREAMS - Warm strings".postln;
)

// Stop
// ~warmNoise.free; ~crackle.free; ~guitarRoutine.stop; ~cascadeRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: GLITCH GARDEN
// Digital artifacts in organic bed
// --------------------------------------------------
(
~warmNoise = Synth(\warmNoise, [\amp, 0.06, \cutoff, 2500]);
~crackle = Synth(\crackleBed, [\amp, 0.04, \density, 35]);

~glitchRoutine = Routine({
	inf.do {
		Synth(\glitchGrain, [
			\density, rrand(5, 15),
			\amp, rrand(0.06, 0.12),
			\freqLo, rrand(500, 2000),
			\freqHi, rrand(4000, 12000)
		]);
		rrand(1, 4).wait;
	};
}).play;

~granularRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\granularCloud, [\freq, rrand(300, 800), \amp, rrand(0.05, 0.09), \density, rrand(40, 80)]);
		};
		rrand(4, 10).wait;
	};
}).play;

~shimmerRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\shimmerPad, [\freq, rrand(300, 600), \amp, rrand(0.04, 0.07)]);
		};
		rrand(6, 15).wait;
	};
}).play;

"GLITCH GARDEN - Digital organic".postln;
)

// Stop
// ~warmNoise.free; ~crackle.free; ~glitchRoutine.stop; ~granularRoutine.stop; ~shimmerRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: DEEP TEXTURE
// Slow, dense, immersive
// --------------------------------------------------
(
~drone = Synth(\droneWash, [\amp, 0.1, \freq, 55]);
~warmNoise = Synth(\warmNoise, [\amp, 0.05, \cutoff, 1000, \res, 0.5]);
~crackle = Synth(\crackleBed, [\amp, 0.02, \density, 10]);

~granularRoutine = Routine({
	inf.do {
		Synth(\granularCloud, [
			\freq, [110, 165, 220].choose,
			\amp, rrand(0.05, 0.08),
			\density, rrand(20, 40),
			\spread, rrand(50, 150)
		]);
		rrand(10, 25).wait;
	};
}).play;

~cascadeRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\cascade, [\baseFreq, [55, 82.4, 110].choose, \amp, rrand(0.04, 0.06), \dur, rrand(8, 15)]);
		};
		rrand(12, 30).wait;
	};
}).play;

"DEEP TEXTURE - Immersive depths".postln;
)

// Stop
// ~drone.free; ~warmNoise.free; ~crackle.free; ~granularRoutine.stop; ~cascadeRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
