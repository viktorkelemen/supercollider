// ============================================================
// VENICE - Fennesz-inspired ambient composition
// ============================================================
// Voice Roles:
// - Foundation: droneWash (low evolving drone)
// - Color: warmNoise, crackleBed, granularCloud
// - Focus: shimmerPad, cascade (harmonic content)
// - Movement: glitchGrain (sporadic texture)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Drone + crackle only, submerged
// - Development (0:20-0:50): Add granular clouds, glitch enters
// - Peak (0:50-1:15): Dense layers, shimmer + cascade
// - Breakdown (1:15-1:35): Strip to drone + sparse grains
// - Resolution (1:35-2:00): Fade, final shimmer, silence

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Foundation: Evolving ambient drone
SynthDef(\droneWash, {
	arg out = 0, amp = 0.1, freq = 110, gate = 1;
	var sig, mod, env;
	env = EnvGen.kr(Env.asr(4, 1, 6), gate, doneAction: 2);
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
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Color: Warm filtered noise bed
SynthDef(\warmNoise, {
	arg out = 0, amp = 0.08, cutoff = 2000, gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.asr(3, 1, 4), gate, doneAction: 2);
	sig = PinkNoise.ar;
	sig = RLPF.ar(sig, cutoff + (LFNoise1.kr(0.3) * 500), 0.3);
	sig = sig + (BPF.ar(PinkNoise.ar, cutoff * 0.5, 0.5) * 0.3);
	sig = sig.tanh * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Color: Vinyl-like crackle
SynthDef(\crackleBed, {
	arg out = 0, amp = 0.04, density = 30, gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);
	sig = Dust.ar(density) * 0.5;
	sig = sig + (Crackle.ar(1.8) * 0.05);
	sig = LPF.ar(sig, 4000);
	sig = HPF.ar(sig, 100);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Color: Dense granular texture cloud
SynthDef(\granularCloud, {
	arg out = 0, amp = 0.1, freq = 400, density = 40, spread = 200, dur = 10;
	var sig, grains, env;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);
	grains = Mix.fill(8, { |i|
		var grainFreq = freq + LFNoise1.kr(0.5 + (i * 0.1)).range(spread.neg, spread);
		var grainAmp = LFNoise1.kr(1 + (i * 0.2)).range(0.3, 1);
		SinOsc.ar(grainFreq) * Dust.kr(density / 8) * grainAmp;
	});
	sig = grains;
	sig = LPF.ar(sig, 6000);
	sig = sig + (CombL.ar(sig, 0.2, 0.15, 2) * 0.3);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Movement: Sporadic glitch particles
SynthDef(\glitchGrain, {
	arg out = 0, amp = 0.1, density = 5, freqLo = 1000, freqHi = 8000, gate = 1;
	var sig, trig, env;
	env = EnvGen.kr(Env.asr(1, 1, 2), gate, doneAction: 2);
	trig = Dust.kr(density);
	sig = SinOsc.ar(TRand.kr(freqLo, freqHi, trig)) * Decay.kr(trig, 0.02);
	sig = sig + (WhiteNoise.ar * Decay.kr(trig, 0.005) * 0.3);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, TRand.kr(-0.8, 0.8, trig)));
}).add;

// Focus: Shimmering harmonic pad
SynthDef(\shimmerPad, {
	arg out = 0, amp = 0.1, freq = 220, dur = 8;
	var sig, shimmer, env;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);
	sig = Mix([
		SinOsc.ar(freq) * 0.5,
		SinOsc.ar(freq * 2.01) * 0.3,
		SinOsc.ar(freq * 3.99) * 0.15,
		SinOsc.ar(freq * 5.02) * 0.1
	]);
	shimmer = SinOsc.ar(freq * 8 + (SinOsc.kr(3) * 20)) * 0.1;
	sig = sig + shimmer;
	sig = sig + (DelayC.ar(sig, 0.5, SinOsc.kr(0.1).range(0.01, 0.03)) * 0.4);
	sig = LPF.ar(sig, 8000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Focus: Harmonic cascade
SynthDef(\cascade, {
	arg out = 0, amp = 0.08, baseFreq = 440, dur = 8;
	var sig, env;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);
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

// --------------------------------------------------
// COMPOSITION - 2 MINUTE ARC
// --------------------------------------------------
// Intro:       0:00 - 0:20 (20s)
// Development: 0:20 - 0:50 (30s)
// Peak:        0:50 - 1:15 (25s)
// Breakdown:   1:15 - 1:35 (20s)
// Resolution:  1:35 - 2:00 (25s)

Routine({
	var drone, crackle;

	0.5.wait;
	"VENICE - Fennesz composition (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Submerged
	// ==========================================
	drone = Synth(\droneWash, [\freq, 82.4, \amp, 0.04]);
	crackle = Synth(\crackleBed, [\amp, 0.015, \density, 10]);

	// Drone swell
	s.sendBundle(8, [\n_set, drone.nodeID, \amp, 0.06]);
	s.sendBundle(16, [\n_set, drone.nodeID, \amp, 0.08]);

	// ==========================================
	// DEVELOPMENT (0:20 - 0:50) - Layers emerge
	// ==========================================
	s.sendBundle(20, [\s_new, \warmNoise, -1, 0, 0, \amp, 0.04, \cutoff, 1200]);
	s.sendBundle(22, [\s_new, \granularCloud, -1, 0, 0, \freq, 300, \amp, 0.06, \density, 40, \spread, 150, \dur, 10]);
	s.sendBundle(28, [\s_new, \glitchGrain, -1, 0, 0, \density, 3, \amp, 0.03]);
	s.sendBundle(32, [\s_new, \granularCloud, -1, 0, 0, \freq, 400, \amp, 0.05, \density, 45, \spread, 180, \dur, 12]);
	s.sendBundle(38, [\s_new, \shimmerPad, -1, 0, 0, \freq, 165, \amp, 0.05, \dur, 10]);
	s.sendBundle(44, [\s_new, \shimmerPad, -1, 0, 0, \freq, 110, \amp, 0.04, \dur, 8]);

	// ==========================================
	// PEAK (0:50 - 1:15) - Maximum density
	// ==========================================
	s.sendBundle(50, [\n_set, drone.nodeID, \amp, 0.1]);
	s.sendBundle(50, [\s_new, \granularCloud, -1, 0, 0, \freq, 500, \amp, 0.08, \density, 60, \spread, 250, \dur, 12]);
	s.sendBundle(52, [\s_new, \shimmerPad, -1, 0, 0, \freq, 220, \amp, 0.08, \dur, 12]);
	s.sendBundle(56, [\s_new, \granularCloud, -1, 0, 0, \freq, 300, \amp, 0.07, \density, 55, \spread, 200, \dur, 10]);
	s.sendBundle(58, [\s_new, \cascade, -1, 0, 0, \baseFreq, 110, \amp, 0.05, \dur, 10]);
	s.sendBundle(62, [\s_new, \shimmerPad, -1, 0, 0, \freq, 330, \amp, 0.06, \dur, 10]);
	s.sendBundle(66, [\s_new, \cascade, -1, 0, 0, \baseFreq, 165, \amp, 0.05, \dur, 8]);

	// ==========================================
	// BREAKDOWN (1:15 - 1:35) - Strip back
	// ==========================================
	s.sendBundle(75, [\n_set, drone.nodeID, \amp, 0.06]);
	s.sendBundle(78, [\s_new, \granularCloud, -1, 0, 0, \freq, 200, \amp, 0.04, \density, 25, \spread, 100, \dur, 15]);
	s.sendBundle(85, [\s_new, \shimmerPad, -1, 0, 0, \freq, 110, \amp, 0.04, \dur, 12]);

	// ==========================================
	// RESOLUTION (1:35 - 2:00) - Fade
	// ==========================================
	s.sendBundle(95, [\n_set, drone.nodeID, \amp, 0.04]);
	s.sendBundle(98, [\s_new, \shimmerPad, -1, 0, 0, \freq, 165, \amp, 0.03, \dur, 15]);
	s.sendBundle(105, [\s_new, \cascade, -1, 0, 0, \baseFreq, 82.4, \amp, 0.03, \dur, 12]);
	s.sendBundle(108, [\n_set, drone.nodeID, \amp, 0.02]);

	// Release
	s.sendBundle(115, [\n_set, drone.nodeID, \gate, 0]);
	s.sendBundle(115, [\n_set, crackle.nodeID, \gate, 0]);

	"Scheduled (2 min).".postln;
}).play;
)
