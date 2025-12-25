// ============================================================
// RUSSELL HASWELL STYLE - Harsh noise, computer music extremes
// ============================================================
// Inspired by "Second Live Salvage", "Factual":
// - Extreme dynamic range
// - Digital noise and feedback
// - Harsh, confrontational textures
// - Computer music precision meets noise
// - Sudden violent bursts

// --------------------------------------------------
// HARSH BURST - Violent noise burst
// --------------------------------------------------
SynthDef(\harshBurst, {
	arg out = 0, amp = 0.2, dur = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);

	sig = WhiteNoise.ar * 0.5;
	sig = sig + (ClipNoise.ar * 0.3);
	sig = sig + (Dust.ar(2000) * 0.2);

	// Hard clip for harshness
	sig = (sig * 4).clip(-1, 1);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DIGITAL SCREAM - High frequency harsh tone
// --------------------------------------------------
SynthDef(\digitalScream, {
	arg out = 0, amp = 0.15, freq = 8000, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (Saw.ar(freq * 1.01) * 0.3);

	// Distortion
	sig = (sig * 5).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// FEEDBACK SIM - Simulated feedback
// --------------------------------------------------
SynthDef(\feedbackSim, {
	arg out = 0, amp = 0.12, freq = 2000, dur = 2;
	var sig, env, fb;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1), doneAction: 2);

	sig = SinOsc.ar(freq + (SinOsc.kr(8).range(-50, 50)));

	// Feedback simulation
	fb = CombL.ar(sig, 0.1, freq.reciprocal * 2, 0.5);
	sig = sig + (fb * 0.5);

	sig = (sig * 3).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// STATIC WALL - Dense noise wall
// --------------------------------------------------
SynthDef(\staticWall, {
	arg out = 0, amp = 0.1;
	var sig;

	sig = WhiteNoise.ar * 0.4;
	sig = sig + (BrownNoise.ar * 0.3);
	sig = sig + (Dust.ar(500) * 0.3);

	sig = HPF.ar(sig, 100);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// PULSE VIOLENCE - Violent rhythmic pulse
// --------------------------------------------------
SynthDef(\pulseViolence, {
	arg out = 0, amp = 0.2, freq = 100, rate = 10, dur = 1;
	var sig, env, trig;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);
	trig = Impulse.ar(rate);

	sig = SinOsc.ar(freq) * Decay.ar(trig, 1/rate * 0.8);
	sig = sig + (WhiteNoise.ar * Decay.ar(trig, 0.01) * 0.5);

	sig = (sig * 3).clip(-1, 1);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CRUNCH - Bit-crushed texture
// --------------------------------------------------
SynthDef(\crunch, {
	arg out = 0, amp = 0.15, freq = 400, crush = 4, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	sig = Saw.ar(freq) * 0.5;
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.3);

	// Bit crushing
	sig = (sig * crush).round / crush;

	sig = (sig * 2).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Haswell SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: LIVE SALVAGE
// Harsh, confrontational
// --------------------------------------------------
(
// Harsh bursts
~harshRoutine = Routine({
	inf.do {
		Synth(\harshBurst, [
			\amp, rrand(0.1, 0.25),
			\dur, rrand(0.1, 0.5)
		]);
		rrand(0.1, 1).wait;
	};
}).play;

// Digital screams
~screamRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\digitalScream, [
				\freq, rrand(4000, 12000),
				\amp, rrand(0.08, 0.15),
				\dur, rrand(0.2, 0.8)
			]);
		};
		rrand(0.3, 1.5).wait;
	};
}).play;

// Crunch
~crunchRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\crunch, [
				\freq, rrand(100, 600),
				\amp, rrand(0.1, 0.16),
				\crush, rrand(2, 8),
				\dur, rrand(0.2, 0.6)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"LIVE SALVAGE - Harsh confrontation".postln;
)

// Stop
// ~harshRoutine.stop; ~screamRoutine.stop; ~crunchRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: FEEDBACK STUDY
// Extended feedback exploration
// --------------------------------------------------
(
// Feedback drones
~feedbackRoutine = Routine({
	inf.do {
		Synth(\feedbackSim, [
			\freq, rrand(1000, 5000),
			\amp, rrand(0.08, 0.14),
			\dur, rrand(2, 6)
		]);
		rrand(1, 4).wait;
	};
}).play;

// Punctuating bursts
~punctuateRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\harshBurst, [
				\amp, rrand(0.08, 0.15),
				\dur, rrand(0.05, 0.2)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// High screams
~highScream = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\digitalScream, [
				\freq, rrand(8000, 15000),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.3, 1)
			]);
		};
		rrand(2, 5).wait;
	};
}).play;

"FEEDBACK STUDY - Extended feedback".postln;
)

// Stop
// ~feedbackRoutine.stop; ~punctuateRoutine.stop; ~highScream.stop;

// --------------------------------------------------
// EXPERIMENT 3: PULSE TERROR
// Violent rhythmic assault
// --------------------------------------------------
(
// Violent pulses
~pulseRoutine = Routine({
	inf.do {
		Synth(\pulseViolence, [
			\freq, rrand(50, 200),
			\amp, rrand(0.15, 0.25),
			\rate, rrand(5, 20),
			\dur, rrand(0.5, 2)
		]);
		rrand(0.3, 1.5).wait;
	};
}).play;

// Harsh punctuation
~punctRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\harshBurst, [
				\amp, rrand(0.1, 0.2),
				\dur, rrand(0.05, 0.15)
			]);
		};
		rrand(0.1, 0.5).wait;
	};
}).play;

// Crunch bass
~crunchBass = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\crunch, [
				\freq, rrand(40, 120),
				\amp, rrand(0.12, 0.18),
				\crush, rrand(3, 6),
				\dur, rrand(0.3, 0.8)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"PULSE TERROR - Violent rhythm".postln;
)

// Stop
// ~pulseRoutine.stop; ~punctRoutine.stop; ~crunchBass.stop;

// --------------------------------------------------
// EXPERIMENT 4: STATIC FIELD
// Dense noise exploration
// --------------------------------------------------
(
~wall = Synth(\staticWall, [\amp, 0.08]);

// Varying bursts
~burstRoutine = Routine({
	inf.do {
		Synth(\harshBurst, [
			\amp, rrand(0.05, 0.15),
			\dur, rrand(0.1, 0.4)
		]);
		rrand(0.3, 1.5).wait;
	};
}).play;

// Feedback punctuation
~feedbackPunct = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\feedbackSim, [
				\freq, rrand(2000, 8000),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.5, 1.5)
			]);
		};
		rrand(2, 5).wait;
	};
}).play;

"STATIC FIELD - Dense noise".postln;
)

// Stop
// ~wall.free; ~burstRoutine.stop; ~feedbackPunct.stop;

// --------------------------------------------------
// EXPERIMENT 5: FACTUAL
// Precision meets chaos
// --------------------------------------------------
(
var tempo = 0.15;

// Precise crunch pattern
~preciseRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\crunch, [
				\freq, [100, 150, 200, 300].choose,
				\amp, 0.12,
				\crush, [3, 4, 5].choose,
				\dur, 0.1
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Chaotic bursts
~chaoticBurst = Routine({
	inf.do {
		if (0.2.coin) {
			rrand(2, 5).do {
				Synth(\harshBurst, [
					\amp, rrand(0.06, 0.12),
					\dur, rrand(0.02, 0.1)
				]);
				rrand(0.02, 0.1).wait;
			};
		};
		rrand(1, 4).wait;
	};
}).play;

// Scream accents
~screamAccent = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\digitalScream, [
				\freq, rrand(6000, 12000),
				\amp, rrand(0.08, 0.14),
				\dur, rrand(0.2, 0.5)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"FACTUAL - Precision chaos".postln;
)

// Stop
// ~preciseRoutine.stop; ~chaoticBurst.stop; ~screamAccent.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
