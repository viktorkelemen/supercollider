// ============================================================
// VLADISLAV DELAY STYLE - Murky dub, degraded textures
// ============================================================
// Inspired by Sasu Ripatti's approach:
// - Semi-random layering, sounds dissolving and reforming
// - Heavy delay/feedback processing
// - Sparse, stuttering rhythms
// - Deep dubby basslines
// - Textural depth, organic yet digital
// - Long-form evolution

// --------------------------------------------------
// MURKY DELAY - Heavily processed delay line
// --------------------------------------------------
(
SynthDef(\murkyDelay, {
	arg out = 0, in, amp = 0.5, delayTime = 0.3, feedback = 0.7,
		filterFreq = 800, wobble = 0.02, decay = 8;
	var sig, delayed, local;

	// Feedback delay network
	local = LocalIn.ar(2);

	// Input + feedback
	sig = In.ar(in, 2) + (local * feedback);

	// Wobbling delay time (tape-like)
	delayed = DelayC.ar(sig, 2,
		delayTime + LFNoise2.kr(0.3).range(-wobble, wobble)
	);

	// Degrade the signal
	delayed = LPF.ar(delayed, filterFreq * LFNoise2.kr(0.1).range(0.5, 1.5));
	delayed = HPF.ar(delayed, 40);

	// Subtle saturation
	delayed = (delayed * 1.3).tanh;

	// Bit crushing for grit
	delayed = delayed.round(0.01);

	LocalOut.ar(delayed);

	sig = delayed * amp;
	sig = sig * EnvGen.kr(Env.linen(0.1, decay, 2), doneAction: 2);
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// DEGRADED LOOP - Self-destructing pattern
// --------------------------------------------------
(
SynthDef(\degradedLoop, {
	arg out = 0, amp = 0.3, freq = 110, loopTime = 0.5, decay = 12,
		degradeRate = 0.1, filterMod = 0.5;
	var sig, loop, env, degrade;

	env = EnvGen.kr(Env.linen(1, decay, 3), doneAction: 2);

	// Sound source - could be anything
	sig = Pulse.ar(freq, LFNoise2.kr(0.2).range(0.3, 0.7)) * 0.3;
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.4);
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 3, 0.1) * 0.2);

	// Initial hit
	sig = sig * EnvGen.kr(Env.perc(0.01, 0.2));

	// Feedback loop that degrades
	loop = CombC.ar(sig, 2, loopTime, decay * (1 - degradeRate));

	// Progressive filtering - gets murkier over time
	degrade = Line.kr(1, 0.2, decay);
	loop = LPF.ar(loop, 3000 * degrade + 200);
	loop = LPF.ar(loop, 2000 * degrade + 150);

	// Add noise as it decays
	loop = loop + (PinkNoise.ar * (1 - degrade) * 0.05);

	// Wow and flutter
	loop = DelayC.ar(loop, 0.1, LFNoise2.kr(0.5).range(0.01, 0.03));

	sig = loop * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SPARSE KICK - Deep, murky thud
// --------------------------------------------------
(
SynthDef(\sparseKick, {
	arg out = 0, amp = 0.5, freq = 45, decay = 0.8;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -8), doneAction: 2);

	// Sub thud
	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.1, 1, -4)).range(1, 2));
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.3);

	// Muffled click
	click = BPF.ar(WhiteNoise.ar, 200, 0.3) * EnvGen.kr(Env.perc(0.001, 0.02));

	sig = (sig + click) * env * amp;
	sig = LPF.ar(sig, 200);
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// GLITCH STUTTER - Fragmented micro-rhythm
// --------------------------------------------------
(
SynthDef(\glitchStutter, {
	arg out = 0, amp = 0.15, freq = 800, density = 8, dur = 0.5;
	var sig, env, stutter;

	env = EnvGen.kr(Env.linen(0.01, dur, 0.1), doneAction: 2);

	// Burst of micro-sounds
	stutter = Dust.ar(density);
	sig = Ringz.ar(stutter, freq * LFNoise0.kr(20).range(0.5, 2), 0.01);
	sig = sig + (BPF.ar(WhiteNoise.ar * stutter, freq, 0.05) * 0.5);

	// Random panning per grain
	sig = Pan2.ar(sig, LFNoise0.kr(density * 2).range(-0.8, 0.8));

	sig = LPF.ar(sig, 4000);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// SUBMERGED BASS - Deep rolling dub bass
// --------------------------------------------------
(
SynthDef(\submergedBass, {
	arg out = 0, amp = 0.4, freq = 55, dur = 2, slide = 0;
	var sig, env, fenv;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.3, 0.2, 1, \sin), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.01, 0.3, 1, -4));

	// Sliding frequency
	freq = freq * (1 + (slide * Line.kr(0, 1, dur)));

	// Warm sub
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (LFTri.ar(freq) * 0.2);
	sig = sig + (SinOsc.ar(freq * 2) * fenv * 0.15);

	// Subtle movement
	sig = sig * (1 + (LFNoise2.kr(0.3) * 0.1));

	sig = LPF.ar(sig, 200 + (fenv * 400));
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// TEXTURE CLOUD - Amorphous noise texture
// --------------------------------------------------
(
SynthDef(\textureCloud, {
	arg out = 0, amp = 0.1, dur = 8, freqLo = 200, freqHi = 2000;
	var sig, env, bands;

	env = EnvGen.kr(Env.linen(2, dur - 4, 2, 1, \sin), doneAction: 2);

	// Multiple filtered noise bands
	bands = 6;
	sig = Mix.fill(bands, { |i|
		var freq, bw, localAmp;
		freq = LFNoise2.kr(0.1 + (i * 0.02)).range(freqLo, freqHi);
		bw = LFNoise2.kr(0.05).range(0.02, 0.1);
		localAmp = LFNoise2.kr(0.08).range(0.2, 1);
		BPF.ar(PinkNoise.ar, freq, bw) * localAmp;
	});

	// Spatial movement
	sig = sig * LFNoise2.kr(0.1).range(0.5, 1);
	sig = Pan2.ar(sig, LFNoise2.kr(0.05).range(-0.6, 0.6));

	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// VINYL CRACKLE - Lo-fi surface noise
// --------------------------------------------------
(
SynthDef(\vinylCrackle, {
	arg out = 0, amp = 0.03, density = 5;
	var sig, crackle, hiss;

	// Crackle
	crackle = Dust2.ar(density) * 0.5;
	crackle = crackle + (Dust.ar(density * 3) * 0.3);
	crackle = HPF.ar(crackle, 300);
	crackle = LPF.ar(crackle, 8000);

	// Hiss
	hiss = HPF.ar(PinkNoise.ar, 2000) * 0.2;

	sig = (crackle + hiss) * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: SPARSE DUB
// Minimal, murky, slow
// --------------------------------------------------
(
// Add crackle layer
~crackle = Synth(\vinylCrackle, [\amp, 0.025, \density, 4]);

// Sparse kick pattern
~kickRoutine = Routine({
	var intervals = [2, 1.5, 2.5, 1, 3, 2];  // Irregular spacing
	inf.do { |i|
		if (0.7.coin) {  // Not always
			Synth(\sparseKick, [
				\amp, rrand(0.3, 0.5),
				\freq, [40, 45, 50].choose,
				\decay, rrand(0.5, 1.2)
			]);
		};
		intervals.choose.wait;
	};
}).play;

// Degraded loops - occasional
~loopRoutine = Routine({
	var notes = [55, 73.4, 82.4, 110];  // A1, D2, E2, A2
	inf.do {
		if (0.3.coin) {
			Synth(\degradedLoop, [
				\freq, notes.choose,
				\amp, rrand(0.15, 0.25),
				\loopTime, [0.25, 0.33, 0.5, 0.66].choose,
				\decay, rrand(6, 15),
				\degradeRate, rrand(0.05, 0.15)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Rolling bass - very sparse
~bassRoutine = Routine({
	var notes = [41.2, 49, 55, 61.7];  // E1, G1, A1, B1
	inf.do {
		if (0.4.coin) {
			Synth(\submergedBass, [
				\freq, notes.choose,
				\amp, rrand(0.25, 0.4),
				\dur, rrand(1.5, 4),
				\slide, rrand(-0.1, 0.1)
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

"SPARSE DUB - Murky and minimal".postln;
)

// Stop sparse dub
// ~crackle.free; ~kickRoutine.stop; ~loopRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: GLITCH AMBIENT
// Fragmented, dissolving
// --------------------------------------------------
(
~crackle = Synth(\vinylCrackle, [\amp, 0.02, \density, 3]);

// Texture clouds - continuous
~cloudRoutine = Routine({
	inf.do {
		Synth(\textureCloud, [
			\amp, rrand(0.06, 0.12),
			\dur, rrand(10, 25),
			\freqLo, rrand(150, 400),
			\freqHi, rrand(1500, 4000)
		]);
		rrand(8, 20).wait;
	};
}).play;

// Glitch stutters - irregular bursts
~glitchRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\glitchStutter, [
				\freq, rrand(400, 2000),
				\amp, rrand(0.08, 0.15),
				\density, rrand(5, 20),
				\dur, rrand(0.2, 1.0)
			]);
		};
		rrand(1, 6).wait;
	};
}).play;

// Occasional deep bass
~bassRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\submergedBass, [
				\freq, [36.7, 41.2, 49].choose,
				\amp, rrand(0.2, 0.35),
				\dur, rrand(2, 5)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

// Rare degraded loops
~loopRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\degradedLoop, [
				\freq, rrand(80, 200),
				\amp, rrand(0.1, 0.18),
				\loopTime, rrand(0.15, 0.4),
				\decay, rrand(8, 20)
			]);
		};
		rrand(10, 30).wait;
	};
}).play;

"GLITCH AMBIENT - Dissolving textures".postln;
)

// Stop glitch ambient
// ~crackle.free; ~cloudRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: RHYTHMIC MURK
// More structured but still abstract
// --------------------------------------------------
(
SynthDef(\murkyHat, {
	arg out = 0, amp = 0.1, decay = 0.08;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);
	sig = HPF.ar(WhiteNoise.ar, 6000);
	sig = LPF.ar(sig, 10000);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.3, 0.3)));
}).add;

SynthDef(\murkyRim, {
	arg out = 0, amp = 0.12, freq = 400;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.05, 1, -8), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, 0.03) * 0.5;
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 2, 0.1) * 0.3);
	sig = HPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.5, 0.5)));
}).add;
)

(
var tempo = 0.4;  // Slow tempo (150 BPM equivalent in feel)

~crackle = Synth(\vinylCrackle, [\amp, 0.02]);

// Kick - on downbeats mostly
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 16] == 1) {
			if (0.85.coin) {  // Some variation
				Synth(\sparseKick, [
					\amp, rrand(0.35, 0.5),
					\decay, rrand(0.6, 1.0)
				]);
			};
		};
		i = i + 1;
		(tempo / 4).wait;
	};
}).play;

// Hats - irregular
~hatRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\murkyHat, [
				\amp, rrand(0.04, 0.1),
				\decay, rrand(0.03, 0.12)
			]);
		};
		(tempo / rrand(2, 8)).wait;
	};
}).play;

// Rim shots - sparse
~rimRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\murkyRim, [
				\amp, rrand(0.06, 0.12),
				\freq, rrand(300, 600)
			]);
		};
		(tempo / 2).wait;
	};
}).play;

// Bass - follows kick loosely
~bassRoutine = Routine({
	var notes = [41.2, 41.2, 49, 55];
	inf.do {
		if (0.5.coin) {
			Synth(\submergedBass, [
				\freq, notes.choose,
				\amp, rrand(0.25, 0.4),
				\dur, rrand(0.8, 2.5)
			]);
		};
		(tempo * rrand(2, 4)).wait;
	};
}).play;

// Degraded loops - occasional texture
~loopRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\degradedLoop, [
				\freq, rrand(100, 300),
				\amp, rrand(0.12, 0.2),
				\loopTime, tempo * [0.5, 1, 0.75, 0.25].choose,
				\decay, rrand(6, 12)
			]);
		};
		(tempo * rrand(4, 12)).wait;
	};
}).play;

"RHYTHMIC MURK - Structured abstraction".postln;
)

// Stop rhythmic murk
// ~crackle.free; ~kickRoutine.stop; ~hatRoutine.stop; ~rimRoutine.stop; ~bassRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: ENTAIN STYLE
// Named after the album - deep, submerged
// --------------------------------------------------
(
SynthDef(\deepPad, {
	arg out = 0, amp = 0.15, freq = 55, dur = 10;
	var sig, env;

	env = EnvGen.kr(Env.linen(3, dur - 6, 3, 1, \sin), doneAction: 2);

	// Deep, simple tone
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3.02) * 0.1);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.15);

	// Slow filter movement
	sig = LPF.ar(sig, LFNoise2.kr(0.05).range(200, 600));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\subClick, {
	arg out = 0, amp = 0.2, freq = 60;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.15, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.05)).range(1, 1.5));
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 4, 0.02) * 0.3);
	sig = LPF.ar(sig, 300);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

(
~crackle = Synth(\vinylCrackle, [\amp, 0.015, \density, 2]);

// Deep evolving pad
~padRoutine = Routine({
	var notes = [36.7, 41.2, 49, 55];  // D1, E1, G1, A1
	inf.do {
		Synth(\deepPad, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.18),
			\dur, rrand(12, 25)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Sub clicks - very sparse
~clickRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\subClick, [
				\freq, [50, 60, 70].choose,
				\amp, rrand(0.12, 0.22)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Texture clouds
~cloudRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\textureCloud, [
				\amp, rrand(0.04, 0.08),
				\dur, rrand(15, 30),
				\freqLo, 100,
				\freqHi, 1000
			]);
		};
		rrand(12, 30).wait;
	};
}).play;

// Very rare degraded loops
~loopRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\degradedLoop, [
				\freq, rrand(60, 120),
				\amp, rrand(0.08, 0.15),
				\loopTime, rrand(0.4, 0.8),
				\decay, rrand(15, 30)
			]);
		};
		rrand(20, 50).wait;
	};
}).play;

"ENTAIN STYLE - Deep and submerged".postln;
)

// Stop Entain style
// ~crackle.free; ~padRoutine.stop; ~clickRoutine.stop; ~cloudRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: MULTILA STYLE
// Named after the album - rhythmic but abstract
// --------------------------------------------------
(
SynthDef(\stutterTone, {
	arg out = 0, amp = 0.2, freq = 200, rate = 8, dur = 2;
	var sig, env, stutter;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1, 1, \sin), doneAction: 2);

	// Tone
	sig = LFTri.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 1.5) * 0.2);
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.1);

	// Amplitude stutter
	stutter = LFPulse.kr(rate, 0, LFNoise2.kr(0.5).range(0.2, 0.8));
	sig = sig * stutter;

	sig = LPF.ar(sig, freq * 3);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.3).range(-0.5, 0.5)));
}).add;
)

(
var tempo = 0.35;

~crackle = Synth(\vinylCrackle, [\amp, 0.02]);

// Kicks - slightly swung
~kickRoutine = Routine({
	inf.do {
		if (0.6.coin) {
			Synth(\sparseKick, [
				\amp, rrand(0.3, 0.45),
				\freq, rrand(42, 50),
				\decay, rrand(0.5, 0.9)
			]);
		};
		(tempo * [1, 1.5, 0.5, 2].choose).wait;
	};
}).play;

// Stutter tones - rhythmic element
~stutterRoutine = Routine({
	var notes = [110, 146.8, 164.8, 196, 220];
	inf.do {
		if (0.4.coin) {
			Synth(\stutterTone, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.18),
				\rate, rrand(4, 16),
				\dur, rrand(0.5, 2.5)
			]);
		};
		(tempo * rrand(1, 4)).wait;
	};
}).play;

// Glitch bursts
~glitchRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\glitchStutter, [
				\freq, rrand(300, 1500),
				\amp, rrand(0.08, 0.14),
				\density, rrand(8, 25),
				\dur, rrand(0.1, 0.5)
			]);
		};
		(tempo * rrand(0.5, 3)).wait;
	};
}).play;

// Bass - follows
~bassRoutine = Routine({
	var notes = [41.2, 49, 55];
	inf.do {
		if (0.45.coin) {
			Synth(\submergedBass, [
				\freq, notes.choose,
				\amp, rrand(0.2, 0.35),
				\dur, rrand(1, 3)
			]);
		};
		(tempo * rrand(2, 5)).wait;
	};
}).play;

// Degraded loops
~loopRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\degradedLoop, [
				\freq, rrand(80, 180),
				\amp, rrand(0.1, 0.2),
				\loopTime, tempo * [0.5, 0.75, 1, 1.5].choose,
				\decay, rrand(5, 12)
			]);
		};
		(tempo * rrand(6, 16)).wait;
	};
}).play;

"MULTILA STYLE - Rhythmic abstraction".postln;
)

// Stop Multila style
// ~crackle.free; ~kickRoutine.stop; ~stutterRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
