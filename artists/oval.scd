// ============================================================
// OVAL STYLE - Pioneering glitch, CD-skip aesthetics
// ============================================================
// Inspired by "Systemisch" and "94diskont":
// - CD-skip stutters and loops
// - Granular deconstruction of source material
// - Warm, melodic fragments emerging from glitch
// - Looping micro-segments
// - Digital artifacts as musical material

// --------------------------------------------------
// SKIP LOOP - CD-skip stutter effect
// --------------------------------------------------
SynthDef(\skipLoop, {
	arg out = 0, amp = 0.2, freq = 440, skipRate = 8, dur = 2;
	var sig, env, skip;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);

	// Create a warm tone that gets "skipped"
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.25);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.15);

	// Simulate CD skip - hard gating
	skip = LFPulse.ar(skipRate, 0, 0.5);
	sig = sig * skip;

	// Soft filter for warmth
	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GRANULAR FRAGMENT - Short granular burst
// --------------------------------------------------
SynthDef(\granularFragment, {
	arg out = 0, amp = 0.15, freq = 800, grainDur = 0.02, density = 40, dur = 0.5;
	var sig, env, trig;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	trig = Dust.ar(density);

	// Granular sine clusters
	sig = GrainSin.ar(2, trig, grainDur, freq, LFNoise1.kr(2).range(-0.5, 0.5));

	sig = LPF.ar(sig, 4000);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

// --------------------------------------------------
// WARM FRAGMENT - Melodic fragment with filtering
// --------------------------------------------------
SynthDef(\warmFragment, {
	arg out = 0, amp = 0.2, freq = 440, dur = 1, pan = 0, cutoff = 2000;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

	// Rich harmonic content
	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	// Warm filtering
	sig = RLPF.ar(sig, cutoff, 0.5);
	sig = LPF.ar(sig, 5000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// --------------------------------------------------
// STUTTER TONE - Rapid repetition of short segment
// --------------------------------------------------
SynthDef(\stutterTone, {
	arg out = 0, amp = 0.15, freq = 660, stutterRate = 20, dur = 1;
	var sig, env, stutter;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);

	sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 1.5) * 0.3);

	// Stutter gate
	stutter = LFPulse.ar(stutterRate, 0, 0.3);
	sig = sig * stutter;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GLITCH TEXTURE - Background glitch layer
// --------------------------------------------------
SynthDef(\glitchTexture, {
	arg out = 0, amp = 0.05, density = 20;
	var sig, clicks, tones;

	// Random clicks
	clicks = Dust.ar(density) * 0.3;

	// Short sine bursts
	tones = SinOsc.ar(TRand.ar(200, 2000, Dust.ar(density * 0.5))) *
	        Decay.ar(Dust.ar(density * 0.5), 0.02) * 0.2;

	sig = clicks + tones;
	sig = LPF.ar(sig, 6000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// LOOP GRAIN - Simulated loop point grain
// --------------------------------------------------
SynthDef(\loopGrain, {
	arg out = 0, amp = 0.12, freq = 550, loopRate = 4, dur = 2;
	var sig, env, loop, grain;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);

	// Base tone
	sig = SinOsc.ar(freq) * 0.5 + (Saw.ar(freq) * 0.2);
	sig = LPF.ar(sig, 2500);

	// Loop point - creates that CD repeat sound
	loop = LFPulse.kr(loopRate).lag(0.001);
	grain = EnvGen.ar(Env.perc(0.001, 0.05), loop);

	sig = sig * grain;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// MELODIC GLITCH - Pitched glitch with melody
// --------------------------------------------------
SynthDef(\melodicGlitch, {
	arg out = 0, amp = 0.15, freq = 440, glitchRate = 12, dur = 0.5, pan = 0;
	var sig, env, glitch;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);

	// Melodic content
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);

	// Glitch modulation
	glitch = LFNoise0.ar(glitchRate).range(0.3, 1);
	sig = sig * glitch;

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

"Oval SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: SYSTEMISCH
// Classic Oval CD-skip texture
// --------------------------------------------------
(
~glitch = Synth(\glitchTexture, [\amp, 0.04, \density, 15]);

// Skipping melodic loops
~skipRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72].midicps;
	inf.do {
		Synth(\skipLoop, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.18),
			\skipRate, [4, 6, 8, 12].choose,
			\dur, rrand(1, 3)
		]);
		rrand(0.5, 2).wait;
	};
}).play;

// Warm fragments
~fragmentRoutine = Routine({
	var notes = [48, 55, 60, 64, 67].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\warmFragment, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.15),
				\dur, rrand(0.3, 1.5),
				\cutoff, rrand(800, 2500),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

"SYSTEMISCH - CD-skip aesthetics".postln;
)

// Stop
// ~glitch.free; ~skipRoutine.stop; ~fragmentRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: 94DISKONT
// Dense granular deconstruction
// --------------------------------------------------
(
~glitch = Synth(\glitchTexture, [\amp, 0.05, \density, 25]);

// Granular bursts
~grainRoutine = Routine({
	inf.do {
		Synth(\granularFragment, [
			\freq, rrand(300, 1500),
			\amp, rrand(0.08, 0.15),
			\grainDur, rrand(0.01, 0.05),
			\density, rrand(20, 80),
			\dur, rrand(0.2, 0.8)
		]);
		rrand(0.1, 0.6).wait;
	};
}).play;

// Stutter tones
~stutterRoutine = Routine({
	var notes = [55, 60, 62, 67, 72].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\stutterTone, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\stutterRate, rrand(15, 40),
				\dur, rrand(0.5, 2)
			]);
		};
		rrand(0.8, 3).wait;
	};
}).play;

"94DISKONT - Granular density".postln;
)

// Stop
// ~glitch.free; ~grainRoutine.stop; ~stutterRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: DOK
// Slower, more melodic
// --------------------------------------------------
(
// Melodic glitch layer
~melodicRoutine = Routine({
	var scale = [60, 62, 64, 65, 67, 69, 71, 72].midicps;
	var i = 0;
	inf.do {
		Synth(\melodicGlitch, [
			\freq, scale[i % scale.size],
			\amp, rrand(0.1, 0.18),
			\glitchRate, [8, 10, 12, 16].choose,
			\dur, rrand(0.3, 0.8),
			\pan, rrand(-0.4, 0.4)
		]);
		i = i + 1;
		rrand(0.2, 0.5).wait;
	};
}).play;

// Loop grains
~loopRoutine = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		if (0.35.coin) {
			Synth(\loopGrain, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\loopRate, [2, 3, 4, 6].choose,
				\dur, rrand(2, 5)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Warm fragments
~warmRoutine = Routine({
	var notes = [36, 43, 48, 55].midicps;
	inf.do {
		if (0.25.coin) {
			Synth(\warmFragment, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(1, 3),
				\cutoff, rrand(600, 1800)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

"DOK - Melodic glitch".postln;
)

// Stop
// ~melodicRoutine.stop; ~loopRoutine.stop; ~warmRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: OVALPROCESS
// Process-based generative
// --------------------------------------------------
(
~glitch = Synth(\glitchTexture, [\amp, 0.03, \density, 10]);

// Process layers
~processRoutine = Routine({
	var notes = [48, 55, 60, 64, 67, 72, 76].midicps;
	inf.do {
		// Burst of activity
		var burstSize = rrand(3, 8);
		burstSize.do { |i|
			Synth(\skipLoop, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.12),
				\skipRate, rrand(4, 20),
				\dur, rrand(0.3, 1)
			]);
			rrand(0.05, 0.2).wait;
		};
		// Pause
		rrand(1, 4).wait;
	};
}).play;

// Sparse grains
~grainRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\granularFragment, [
				\freq, rrand(400, 1200),
				\amp, rrand(0.06, 0.12),
				\grainDur, rrand(0.02, 0.06),
				\density, rrand(30, 60),
				\dur, rrand(0.3, 0.6)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"OVALPROCESS - Generative".postln;
)

// Stop
// ~glitch.free; ~processRoutine.stop; ~grainRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: SZENARIO
// Ambient glitch
// --------------------------------------------------
(
// Long warm drones with glitch interruption
~droneRoutine = Routine({
	var notes = [48, 55, 60, 67].midicps;
	inf.do {
		Synth(\warmFragment, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(4, 10),
			\cutoff, rrand(400, 1200),
			\pan, rrand(-0.3, 0.3)
		]);
		rrand(3, 8).wait;
	};
}).play;

// Sparse skips
~skipRoutine = Routine({
	var notes = [60, 64, 67, 72].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\skipLoop, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\skipRate, [2, 3, 4].choose,
				\dur, rrand(1, 3)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Very sparse glitch texture
~glitch = Synth(\glitchTexture, [\amp, 0.02, \density, 5]);

"SZENARIO - Ambient glitch".postln;
)

// Stop
// ~droneRoutine.stop; ~skipRoutine.stop; ~glitch.free;

// --------------------------------------------------
// EXPERIMENT 6: COMMERS
// Dense commercial-era Oval
// --------------------------------------------------
(
~glitch = Synth(\glitchTexture, [\amp, 0.04, \density, 30]);

// Rapid melodic glitches
~melodicRoutine = Routine({
	var notes = [48, 52, 55, 57, 60, 62, 64, 67].midicps;
	inf.do {
		3.do {
			Synth(\melodicGlitch, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\glitchRate, rrand(10, 25),
				\dur, rrand(0.1, 0.4),
				\pan, rrand(-0.7, 0.7)
			]);
			rrand(0.05, 0.15).wait;
		};
		rrand(0.3, 1).wait;
	};
}).play;

// Stutter bursts
~stutterRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\stutterTone, [
				\freq, rrand(200, 800),
				\amp, rrand(0.06, 0.12),
				\stutterRate, rrand(20, 50),
				\dur, rrand(0.2, 0.8)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Loop points
~loopRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\loopGrain, [
				\freq, rrand(300, 900),
				\amp, rrand(0.06, 0.1),
				\loopRate, rrand(4, 12),
				\dur, rrand(1, 3)
			]);
		};
		rrand(2, 5).wait;
	};
}).play;

"COMMERS - Dense melodic".postln;
)

// Stop
// ~glitch.free; ~melodicRoutine.stop; ~stutterRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 7: O (MINIMALIST)
// Ultra-sparse, single elements
// --------------------------------------------------
(
// Single skip loops with long pauses
~skipRoutine = Routine({
	var notes = [55, 60, 67].midicps;
	inf.do {
		Synth(\skipLoop, [
			\freq, notes.choose,
			\amp, rrand(0.12, 0.2),
			\skipRate, [2, 4].choose,
			\dur, rrand(2, 5)
		]);
		rrand(8, 20).wait;
	};
}).play;

// Rare warm fragments
~warmRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\warmFragment, [
				\freq, [48, 55, 60].choose.midicps,
				\amp, rrand(0.1, 0.15),
				\dur, rrand(2, 5),
				\cutoff, rrand(500, 1500)
			]);
		};
		rrand(10, 25).wait;
	};
}).play;

"O - Minimalist glitch".postln;
)

// Stop
// ~skipRoutine.stop; ~warmRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
