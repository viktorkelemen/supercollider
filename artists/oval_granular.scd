// ============================================================
// OVAL STYLE - Glitch, skipping CD aesthetics
// ============================================================
// Inspired by "94diskont":
// - Damaged CD sound
// - Repetitive micro-loops
// - Gentle melodic underpinning
// - Stutter and skip as composition
// - Warmth beneath the glitch

// --------------------------------------------------
// CD SKIP - Repeating micro-sample
// --------------------------------------------------
(
SynthDef(\cdSkipOval, {
	arg out = 0, amp = 0.15, freq = 400, skipRate = 8, dur = 2;
	var sig, env, skip, source;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);

	// Warm melodic source
	source = SinOsc.ar(freq) * 0.5;
	source = source + (SinOsc.ar(freq * 2.01) * 0.2);
	source = source + (LFTri.ar(freq) * 0.2);
	source = source + (SinOsc.ar(freq * 0.5) * 0.1);

	// Skip/stutter effect
	skip = LFPulse.kr(skipRate, 0, LFNoise2.kr(0.5).range(0.3, 0.7));
	sig = source * skip;

	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// GLITCH LOOP - Short repeating fragment
// --------------------------------------------------
(
SynthDef(\glitchLoop, {
	arg out = 0, amp = 0.12, freq = 300, loopTime = 0.1, decay = 3;
	var sig, loop, env;

	env = EnvGen.kr(Env.linen(0.1, decay - 0.2, 0.1), doneAction: 2);

	// Source
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq, 0.3) * 0.15);
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 2, 0.1) * 0.1);

	// Short initial trigger
	sig = sig * EnvGen.kr(Env.perc(0.001, loopTime * 0.5));

	// Create micro-loop
	loop = CombL.ar(sig, 1, loopTime, decay);

	sig = loop * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// WARM PAD - Underlying harmonic bed
// --------------------------------------------------
(
SynthDef(\warmPad, {
	arg out = 0, amp = 0.1, freq = 110;
	var sig;

	sig = Mix.fill(5, { |i|
		var partial = i + 1;
		var detune = LFNoise2.kr(0.02).range(0.998, 1.002);
		SinOsc.ar(freq * partial * detune) * (1 / partial);
	});

	sig = LPF.ar(sig, 2000);
	sig = sig * LFNoise2.kr(0.03).range(0.8, 1);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DIGITAL CRACKLE - CD error noise
// --------------------------------------------------
(
SynthDef(\digitalCrackle, {
	arg out = 0, amp = 0.04, density = 10;
	var sig;

	sig = Dust2.ar(density) * 0.4;
	sig = sig + (Dust.ar(density * 2) * 0.3);

	// Brief resonance on some clicks
	sig = sig + (Ringz.ar(Dust.ar(density / 3), LFNoise0.kr(1).range(800, 2000), 0.02) * 0.3);

	sig = HPF.ar(sig, 400);
	sig = LPF.ar(sig, 8000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: DISKONT
// Classic Oval glitch
// --------------------------------------------------
(
~pad = Synth(\warmPad, [\freq, 110, \amp, 0.06]);
~crackle = Synth(\digitalCrackle, [\amp, 0.025, \density, 8]);

// CD skips
~skipRoutine = Routine({
	var freqs = [220, 261.6, 293.7, 329.6, 392];
	inf.do {
		Synth(\cdSkipOval, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.15),
			\skipRate, rrand(4, 16),
			\dur, rrand(0.5, 3)
		]);
		rrand(0.3, 2).wait;
	};
}).play;

// Glitch loops
~loopRoutine = Routine({
	var freqs = [200, 300, 400, 500, 600];
	inf.do {
		if (0.4.coin) {
			Synth(\glitchLoop, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.12),
				\loopTime, rrand(0.05, 0.2),
				\decay, rrand(1, 4)
			]);
		};
		rrand(1, 5).wait;
	};
}).play;

"DISKONT - CD glitch aesthetic".postln;
)

// Stop
// ~pad.free; ~crackle.free; ~skipRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: SYSTEMISCH
// More rhythmic, structured
// --------------------------------------------------
(
var tempo = 0.25;

~pad = Synth(\warmPad, [\freq, 82.4, \amp, 0.05]);
~crackle = Synth(\digitalCrackle, [\amp, 0.02, \density, 6]);

// Rhythmic skips
~skipRoutine = Routine({
	var pattern = [1, 0, 1, 1, 0, 1, 0, 1];
	var freqs = [261.6, 293.7, 329.6, 392];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\cdSkipOval, [
				\freq, freqs.choose,
				\amp, rrand(0.1, 0.16),
				\skipRate, [8, 12, 16].choose,
				\dur, tempo * rrand(1, 3)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Occasional loops
~loopRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\glitchLoop, [
				\freq, rrand(200, 500),
				\amp, rrand(0.05, 0.1),
				\loopTime, tempo * [0.5, 0.25, 0.125].choose,
				\decay, rrand(1.5, 3)
			]);
		};
		(tempo * rrand(4, 12)).wait;
	};
}).play;

"SYSTEMISCH - Rhythmic glitch".postln;
)

// Stop
// ~pad.free; ~crackle.free; ~skipRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: DOK
// Softer, more ambient
// --------------------------------------------------
(
~pad = Synth(\warmPad, [\freq, 55, \amp, 0.08]);
~crackle = Synth(\digitalCrackle, [\amp, 0.015, \density, 4]);

// Gentle skips
~skipRoutine = Routine({
	var freqs = [164.8, 196, 220, 261.6];
	inf.do {
		if (0.5.coin) {
			Synth(\cdSkipOval, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.1),
				\skipRate, rrand(3, 8),
				\dur, rrand(1, 5)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Longer loops
~loopRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\glitchLoop, [
				\freq, rrand(150, 350),
				\amp, rrand(0.04, 0.08),
				\loopTime, rrand(0.15, 0.4),
				\decay, rrand(3, 8)
			]);
		};
		rrand(5, 15).wait;
	};
}).play;

"DOK - Ambient glitch".postln;
)

// Stop
// ~pad.free; ~crackle.free; ~skipRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: TEXTURA
// Dense, layered
// --------------------------------------------------
(
~pad = Synth(\warmPad, [\freq, 73.4, \amp, 0.06]);
~crackle = Synth(\digitalCrackle, [\amp, 0.03, \density, 15]);

// Many overlapping skips
~skipRoutine = Routine({
	inf.do {
		Synth(\cdSkipOval, [
			\freq, rrand(200, 600),
			\amp, rrand(0.05, 0.1),
			\skipRate, rrand(6, 20),
			\dur, rrand(0.3, 2)
		]);
		rrand(0.1, 0.8).wait;
	};
}).play;

// Dense loops
~loopRoutine = Routine({
	inf.do {
		Synth(\glitchLoop, [
			\freq, rrand(200, 800),
			\amp, rrand(0.03, 0.08),
			\loopTime, rrand(0.03, 0.15),
			\decay, rrand(1, 3)
		]);
		rrand(0.5, 2).wait;
	};
}).play;

"TEXTURA - Dense layers".postln;
)

// Stop
// ~pad.free; ~crackle.free; ~skipRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: CAMOFLEUR
// Melodic emphasis
// --------------------------------------------------
(
SynthDef(\ovalMelody, {
	arg out = 0, amp = 0.12, freq = 440, dur = 1;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.05, dur, 1, -3), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);
	sig = LPF.ar(sig, 2500);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

~pad = Synth(\warmPad, [\freq, 110, \amp, 0.07]);
~crackle = Synth(\digitalCrackle, [\amp, 0.02, \density, 6]);

// Melodic phrases with glitch
~melodyRoutine = Routine({
	var scale = [0, 2, 4, 5, 7, 9, 11];
	var root = 220;
	inf.do {
		var degree = scale.choose;
		var freq = root * (2 ** (degree / 12));

		// Sometimes clean, sometimes glitched
		if (0.6.coin) {
			Synth(\ovalMelody, [
				\freq, freq,
				\amp, rrand(0.08, 0.12),
				\dur, rrand(0.3, 1)
			]);
		} {
			Synth(\cdSkipOval, [
				\freq, freq,
				\amp, rrand(0.08, 0.12),
				\skipRate, rrand(6, 12),
				\dur, rrand(0.5, 2)
			]);
		};

		rrand(0.25, 0.75).wait;
	};
}).play;

// Subtle loops
~loopRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\glitchLoop, [
				\freq, rrand(200, 400),
				\amp, rrand(0.03, 0.06),
				\loopTime, rrand(0.1, 0.25),
				\decay, rrand(2, 5)
			]);
		};
		rrand(3, 10).wait;
	};
}).play;

"CAMOFLEUR - Melodic glitch".postln;
)

// Stop
// ~pad.free; ~crackle.free; ~melodyRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
