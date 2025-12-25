// ============================================================
// GUITAR DREAMS - Fennesz-inspired processed guitar composition
// ============================================================
// Voice Roles:
// - Foundation: warmNoise (filtered pink noise bed)
// - Color: crackleBed (vinyl texture)
// - Focus: guitarTexture (plucked strings with saturation)
// - Movement: cascade (harmonic overtones)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Noise bed + crackle, first guitar hint
// - Development (0:20-0:50): Guitar phrases build, cascades enter
// - Peak (0:50-1:15): Dense overlapping guitars, rich harmonics
// - Breakdown (1:15-1:35): Single guitar, sparse
// - Resolution (1:35-2:00): Final cascade, fade to crackle

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Foundation: Warm filtered noise bed
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

// Focus: Processed guitar-like plucked tone
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

// Movement: Harmonic cascade
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
	var noise, crackle;

	0.5.wait;
	"GUITAR DREAMS - Fennesz composition (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Warm bed emerges
	// ==========================================
	noise = Synth(\warmNoise, [\amp, 0.03, \cutoff, 1000]);
	crackle = Synth(\crackleBed, [\amp, 0.02, \density, 15]);

	// First guitar hint
	s.sendBundle(10, [\s_new, \guitarTexture, -1, 0, 0, \freq, 165, \amp, 0.08, \dur, 6, \drive, 1.5]);
	s.sendBundle(16, [\n_set, noise.nodeID, \amp, 0.04]);

	// ==========================================
	// DEVELOPMENT (0:20 - 0:50) - Guitars build
	// ==========================================
	s.sendBundle(20, [\n_set, noise.nodeID, \cutoff, 1400]);
	s.sendBundle(20, [\s_new, \guitarTexture, -1, 0, 0, \freq, 196, \amp, 0.12, \dur, 5, \drive, 1.8]);
	s.sendBundle(26, [\s_new, \guitarTexture, -1, 0, 0, \freq, 247, \amp, 0.1, \dur, 6, \drive, 2]);
	s.sendBundle(28, [\s_new, \cascade, -1, 0, 0, \baseFreq, 165, \amp, 0.04, \dur, 10]);
	s.sendBundle(34, [\s_new, \guitarTexture, -1, 0, 0, \freq, 220, \amp, 0.13, \dur, 5, \drive, 1.6]);
	s.sendBundle(40, [\s_new, \guitarTexture, -1, 0, 0, \freq, 165, \amp, 0.11, \dur, 7, \drive, 2]);
	s.sendBundle(42, [\s_new, \cascade, -1, 0, 0, \baseFreq, 220, \amp, 0.05, \dur, 12]);

	// ==========================================
	// PEAK (0:50 - 1:15) - Dense, layered
	// ==========================================
	s.sendBundle(50, [\n_set, noise.nodeID, \amp, 0.05]);
	s.sendBundle(50, [\s_new, \guitarTexture, -1, 0, 0, \freq, 294, \amp, 0.14, \dur, 6, \drive, 2.2]);
	s.sendBundle(52, [\s_new, \guitarTexture, -1, 0, 0, \freq, 196, \amp, 0.12, \dur, 8, \drive, 1.8]);
	s.sendBundle(56, [\s_new, \cascade, -1, 0, 0, \baseFreq, 165, \amp, 0.06, \dur, 10]);
	s.sendBundle(58, [\s_new, \guitarTexture, -1, 0, 0, \freq, 330, \amp, 0.15, \dur, 5, \drive, 2]);
	s.sendBundle(62, [\s_new, \guitarTexture, -1, 0, 0, \freq, 247, \amp, 0.13, \dur, 7, \drive, 1.5]);
	s.sendBundle(64, [\s_new, \cascade, -1, 0, 0, \baseFreq, 330, \amp, 0.05, \dur, 8]);
	s.sendBundle(68, [\s_new, \guitarTexture, -1, 0, 0, \freq, 220, \amp, 0.14, \dur, 6, \drive, 2.2]);

	// ==========================================
	// BREAKDOWN (1:15 - 1:35) - Strip back
	// ==========================================
	s.sendBundle(75, [\n_set, noise.nodeID, \amp, 0.03]);
	s.sendBundle(78, [\s_new, \guitarTexture, -1, 0, 0, \freq, 165, \amp, 0.1, \dur, 10, \drive, 1.5]);
	s.sendBundle(88, [\s_new, \guitarTexture, -1, 0, 0, \freq, 196, \amp, 0.08, \dur, 8, \drive, 1.3]);

	// ==========================================
	// RESOLUTION (1:35 - 2:00) - Fade
	// ==========================================
	s.sendBundle(95, [\n_set, noise.nodeID, \amp, 0.02]);
	s.sendBundle(96, [\s_new, \cascade, -1, 0, 0, \baseFreq, 110, \amp, 0.04, \dur, 15]);
	s.sendBundle(102, [\s_new, \guitarTexture, -1, 0, 0, \freq, 110, \amp, 0.06, \dur, 12, \drive, 1.2]);
	s.sendBundle(110, [\n_set, noise.nodeID, \amp, 0.01]);

	// Release
	s.sendBundle(118, [\n_set, noise.nodeID, \gate, 0]);
	s.sendBundle(118, [\n_set, crackle.nodeID, \gate, 0]);

	"Scheduled (2 min).".postln;
}).play;
)
