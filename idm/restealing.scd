// ============================================================
// RESTEALING - Lackluster-inspired melancholic ambient
// ============================================================
// Voice Roles:
// - Foundation: softPad (long evolving pad)
// - Color: vinylCrackle (warm texture)
// - Focus: mutedKeys (sparse muted piano), melodyBell (rare accents)
// - Pulse: lofiKick, lofiSnare (very sparse)
// - Movement: glitchClick (rare digital artifacts)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Vinyl + pad emerges, first key
// - Development (0:20-0:50): Keys build, bells enter, sparse beat
// - Peak (0:50-1:15): Layered keys, more bells, beat present
// - Breakdown (1:15-1:35): Strip to pad + single keys
// - Resolution (1:35-2:00): Final bell, fade to crackle

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Color: Vinyl crackle texture
SynthDef(\vinylCrackle, {
	arg out = 0, amp = 0.04, gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.asr(0.5, 1, 2), gate, doneAction: 2);
	sig = Dust.ar(25) * 0.4;
	sig = sig + (Crackle.ar(1.7) * 0.15);
	sig = sig + (HPF.ar(PinkNoise.ar * 0.2, 6000));
	sig = LPF.ar(sig, 8000);
	sig = HPF.ar(sig, 100);
	sig = sig * amp * env;
	Out.ar(out, sig ! 2);
}).add;

// Foundation: Soft analog-style pad
SynthDef(\softPad, {
	arg out = 0, amp = 0.1, freq = 220, dur = 6;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.8, dur - 1.6, 0.8), doneAction: 2);
	sig = Saw.ar(freq) * 0.25;
	sig = sig + (Saw.ar(freq * 1.002) * 0.2);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.2);
	sig = sig + (Pulse.ar(freq * 2, 0.3) * 0.1);
	sig = LPF.ar(sig, 2000);
	sig = FreeVerb.ar(sig, 0.5, 0.7, 0.3);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Focus: Muted keys - soft and mellow
SynthDef(\mutedKeys, {
	arg out = 0, amp = 0.12, freq = 440, dur = 1.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.008, dur, 1, -5), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.15);
	sig = sig + (SinOsc.ar(freq * 3) * 0.05);
	sig = LPF.ar(sig, 1200 + (env * 800));
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Focus: Soft melodic bell
SynthDef(\melodyBell, {
	arg out = 0, amp = 0.1, freq = 880, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.3);
	sig = sig + (SinOsc.ar(freq * 3.98) * 0.15);
	sig = sig + (SinOsc.ar(freq * 5.03) * 0.08);
	sig = LPF.ar(sig, 5000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Pulse: Soft lo-fi kick
SynthDef(\lofiKick, {
	arg out = 0, amp = 0.2;
	var sig, env, pitchEnv;
	env = EnvGen.kr(Env.perc(0.01, 0.35, 1, -5), doneAction: 2);
	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.12, 1, -4));
	sig = SinOsc.ar(45 + (pitchEnv * 60));
	sig = sig + (SinOsc.ar(90) * 0.3);
	sig = LPF.ar(sig, 300);
	sig = (sig * 1.2).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Pulse: Muffled snare
SynthDef(\lofiSnare, {
	arg out = 0, amp = 0.12;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.18, 1, -5), doneAction: 2);
	sig = WhiteNoise.ar * 0.5;
	sig = sig + (SinOsc.ar(180) * EnvGen.kr(Env.perc(0.001, 0.04)) * 0.4);
	sig = BPF.ar(sig, 900, 0.7);
	sig = LPF.ar(sig, 4000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Movement: Warm glitch click
SynthDef(\glitchClick, {
	arg out = 0, amp = 0.1, freq = 2000, dur = 0.02;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (Dust.ar(500) * 0.3);
	sig = HPF.ar(sig, 500);
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
	var vinyl;

	0.5.wait;
	"RESTEALING - Lackluster composition (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Vinyl + pad emerges
	// ==========================================
	vinyl = Synth(\vinylCrackle, [\amp, 0.025]);

	// Pad fades in
	s.sendBundle(4, [\s_new, \softPad, -1, 0, 0, \freq, 130.81, \amp, 0.06, \dur, 14]);

	// First sparse key
	s.sendBundle(10, [\s_new, \mutedKeys, -1, 0, 0, \freq, 261.63, \amp, 0.1, \dur, 2.5]);
	s.sendBundle(16, [\s_new, \mutedKeys, -1, 0, 0, \freq, 293.66, \amp, 0.09, \dur, 2]);

	// ==========================================
	// DEVELOPMENT (0:20 - 0:50) - Keys build
	// ==========================================
	s.sendBundle(20, [\s_new, \softPad, -1, 0, 0, \freq, 146.83, \amp, 0.07, \dur, 12]);

	// More keys
	s.sendBundle(22, [\s_new, \mutedKeys, -1, 0, 0, \freq, 329.63, \amp, 0.11, \dur, 2.2]);
	s.sendBundle(27, [\s_new, \mutedKeys, -1, 0, 0, \freq, 261.63, \amp, 0.1, \dur, 2]);
	s.sendBundle(32, [\s_new, \mutedKeys, -1, 0, 0, \freq, 392.0, \amp, 0.11, \dur, 2.5]);
	s.sendBundle(37, [\s_new, \mutedKeys, -1, 0, 0, \freq, 349.23, \amp, 0.1, \dur, 2]);
	s.sendBundle(42, [\s_new, \mutedKeys, -1, 0, 0, \freq, 293.66, \amp, 0.11, \dur, 2.2]);
	s.sendBundle(47, [\s_new, \mutedKeys, -1, 0, 0, \freq, 440.0, \amp, 0.1, \dur, 2]);

	// First bells
	s.sendBundle(30, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.05, \dur, 3]);
	s.sendBundle(40, [\s_new, \melodyBell, -1, 0, 0, \freq, 587.33, \amp, 0.05, \dur, 3]);

	// Sparse beat enters
	s.sendBundle(24, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);
	s.sendBundle(28.8, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);
	s.sendBundle(33.6, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);
	s.sendBundle(38.4, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);
	s.sendBundle(43.2, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);
	s.sendBundle(48, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.12]);

	// Rare snare
	s.sendBundle(36, [\s_new, \lofiSnare, -1, 0, 0, \amp, 0.08]);
	s.sendBundle(45.6, [\s_new, \lofiSnare, -1, 0, 0, \amp, 0.08]);

	// Glitch accents
	s.sendBundle(25, [\s_new, \glitchClick, -1, 0, 0, \freq, 2800, \amp, 0.04, \dur, 0.02]);
	s.sendBundle(35, [\s_new, \glitchClick, -1, 0, 0, \freq, 3200, \amp, 0.05, \dur, 0.015]);
	s.sendBundle(44, [\s_new, \glitchClick, -1, 0, 0, \freq, 2500, \amp, 0.04, \dur, 0.02]);

	// ==========================================
	// PEAK (0:50 - 1:15) - Layered, fuller
	// ==========================================
	s.sendBundle(50, [\s_new, \softPad, -1, 0, 0, \freq, 130.81, \amp, 0.08, \dur, 14]);
	s.sendBundle(56, [\s_new, \softPad, -1, 0, 0, \freq, 196.0, \amp, 0.05, \dur, 10]);

	// Keys more frequent
	s.sendBundle(51, [\s_new, \mutedKeys, -1, 0, 0, \freq, 261.63, \amp, 0.12, \dur, 2]);
	s.sendBundle(54, [\s_new, \mutedKeys, -1, 0, 0, \freq, 329.63, \amp, 0.11, \dur, 2.2]);
	s.sendBundle(57, [\s_new, \mutedKeys, -1, 0, 0, \freq, 392.0, \amp, 0.12, \dur, 2]);
	s.sendBundle(60, [\s_new, \mutedKeys, -1, 0, 0, \freq, 440.0, \amp, 0.11, \dur, 2.5]);
	s.sendBundle(64, [\s_new, \mutedKeys, -1, 0, 0, \freq, 349.23, \amp, 0.12, \dur, 2]);
	s.sendBundle(67, [\s_new, \mutedKeys, -1, 0, 0, \freq, 293.66, \amp, 0.11, \dur, 2.2]);
	s.sendBundle(70, [\s_new, \mutedKeys, -1, 0, 0, \freq, 523.25, \amp, 0.1, \dur, 2.5]);

	// More bells
	s.sendBundle(52, [\s_new, \melodyBell, -1, 0, 0, \freq, 659.25, \amp, 0.06, \dur, 3]);
	s.sendBundle(59, [\s_new, \melodyBell, -1, 0, 0, \freq, 587.33, \amp, 0.06, \dur, 3.5]);
	s.sendBundle(66, [\s_new, \melodyBell, -1, 0, 0, \freq, 783.99, \amp, 0.05, \dur, 3]);

	// Beat continues
	s.sendBundle(50.4, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.13]);
	s.sendBundle(55.2, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.13]);
	s.sendBundle(60, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.13]);
	s.sendBundle(64.8, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.13]);
	s.sendBundle(69.6, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.13]);

	s.sendBundle(57.6, [\s_new, \lofiSnare, -1, 0, 0, \amp, 0.09]);
	s.sendBundle(67.2, [\s_new, \lofiSnare, -1, 0, 0, \amp, 0.09]);

	// Glitches
	s.sendBundle(53, [\s_new, \glitchClick, -1, 0, 0, \freq, 3000, \amp, 0.05, \dur, 0.02]);
	s.sendBundle(62, [\s_new, \glitchClick, -1, 0, 0, \freq, 2600, \amp, 0.04, \dur, 0.018]);
	s.sendBundle(71, [\s_new, \glitchClick, -1, 0, 0, \freq, 3400, \amp, 0.05, \dur, 0.02]);

	// ==========================================
	// BREAKDOWN (1:15 - 1:35) - Strip back
	// ==========================================
	s.sendBundle(75, [\s_new, \softPad, -1, 0, 0, \freq, 130.81, \amp, 0.06, \dur, 16]);

	// Very sparse keys
	s.sendBundle(78, [\s_new, \mutedKeys, -1, 0, 0, \freq, 261.63, \amp, 0.1, \dur, 3]);
	s.sendBundle(85, [\s_new, \mutedKeys, -1, 0, 0, \freq, 293.66, \amp, 0.09, \dur, 2.5]);

	// One bell
	s.sendBundle(82, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.04, \dur, 4]);

	// Minimal beat
	s.sendBundle(76.8, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.1]);
	s.sendBundle(86.4, [\s_new, \lofiKick, -1, 0, 0, \amp, 0.1]);

	// ==========================================
	// RESOLUTION (1:35 - 2:00) - Fade
	// ==========================================
	s.sendBundle(95, [\s_new, \softPad, -1, 0, 0, \freq, 130.81, \amp, 0.04, \dur, 18]);

	// Final keys
	s.sendBundle(98, [\s_new, \mutedKeys, -1, 0, 0, \freq, 261.63, \amp, 0.08, \dur, 3]);
	s.sendBundle(106, [\s_new, \mutedKeys, -1, 0, 0, \freq, 329.63, \amp, 0.06, \dur, 3]);

	// Final bell
	s.sendBundle(102, [\s_new, \melodyBell, -1, 0, 0, \freq, 659.25, \amp, 0.04, \dur, 5]);
	s.sendBundle(112, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.03, \dur, 6]);

	// Last glitch
	s.sendBundle(108, [\s_new, \glitchClick, -1, 0, 0, \freq, 2800, \amp, 0.03, \dur, 0.02]);

	// Release vinyl
	s.sendBundle(118, [\n_set, vinyl.nodeID, \gate, 0]);

	"Scheduled (2 min).".postln;
}).play;
)
