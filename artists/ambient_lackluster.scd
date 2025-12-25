// ============================================================
// AMBIENT LACKLUSTER - Beatless warm ambient textures
// ============================================================
// Voice Roles:
// - Foundation: softPad (layered evolving pads)
// - Color: vinylCrackle (warm texture)
// - Focus: warmKeys (sparse floating notes), melodyBell (rare accents)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Vinyl + deep pad emerges
// - Development (0:20-0:50): Add mid pad, first keys
// - Peak (0:50-1:15): Layered pads, keys + bells
// - Breakdown (1:15-1:35): Thin to single pad + sparse keys
// - Resolution (1:35-2:00): Final bell, fade

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Color: Vinyl crackle texture
SynthDef(\vinylCrackle, {
	arg out = 0, amp = 0.04, gate = 1;
	var sig, env;
	env = EnvGen.kr(Env.asr(1, 1, 3), gate, doneAction: 2);
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
	env = EnvGen.kr(Env.linen(1.5, dur - 3, 1.5), doneAction: 2);
	sig = Saw.ar(freq) * 0.25;
	sig = sig + (Saw.ar(freq * 1.002) * 0.2);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.2);
	sig = sig + (Pulse.ar(freq * 2, 0.3) * 0.1);
	sig = LPF.ar(sig, 2000);
	sig = FreeVerb.ar(sig, 0.6, 0.8, 0.3);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Focus: Warm Rhodes-like keys
SynthDef(\warmKeys, {
	arg out = 0, amp = 0.12, freq = 440, dur = 1.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3 * EnvGen.kr(Env.perc(0.01, dur * 0.3)));
	sig = sig + (SinOsc.ar(freq * 3) * 0.1 * EnvGen.kr(Env.perc(0.01, dur * 0.2)));
	sig = sig + (SinOsc.ar(freq * 4) * 0.05 * EnvGen.kr(Env.perc(0.01, dur * 0.1)));
	sig = sig + DelayL.ar(sig, 0.03, SinOsc.kr(2).range(0.008, 0.012)) * 0.3;
	sig = LPF.ar(sig, 3000);
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
	"AMBIENT LACKLUSTER - Beatless ambient (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Vinyl + deep pad
	// ==========================================
	vinyl = Synth(\vinylCrackle, [\amp, 0.035]);

	// Deep foundation pad
	s.sendBundle(2, [\s_new, \softPad, -1, 0, 0, \freq, 55, \amp, 0.08, \dur, 18]);

	// First floating key
	s.sendBundle(12, [\s_new, \warmKeys, -1, 0, 0, \freq, 261.63, \amp, 0.07, \dur, 3.5]);

	// ==========================================
	// DEVELOPMENT (0:20 - 0:50) - Add layers
	// ==========================================
	// Deep pad continues
	s.sendBundle(20, [\s_new, \softPad, -1, 0, 0, \freq, 55, \amp, 0.09, \dur, 16]);

	// Mid pad enters
	s.sendBundle(22, [\s_new, \softPad, -1, 0, 0, \freq, 164.81, \amp, 0.06, \dur, 14]);

	// Upper pad layer
	s.sendBundle(30, [\s_new, \softPad, -1, 0, 0, \freq, 220.0, \amp, 0.05, \dur, 12]);

	// Floating keys
	s.sendBundle(24, [\s_new, \warmKeys, -1, 0, 0, \freq, 329.63, \amp, 0.08, \dur, 3]);
	s.sendBundle(32, [\s_new, \warmKeys, -1, 0, 0, \freq, 392.0, \amp, 0.07, \dur, 3.5]);
	s.sendBundle(40, [\s_new, \warmKeys, -1, 0, 0, \freq, 349.23, \amp, 0.08, \dur, 3]);
	s.sendBundle(47, [\s_new, \warmKeys, -1, 0, 0, \freq, 440.0, \amp, 0.07, \dur, 3]);

	// First bell
	s.sendBundle(36, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.04, \dur, 5]);
	s.sendBundle(45, [\s_new, \melodyBell, -1, 0, 0, \freq, 659.25, \amp, 0.04, \dur, 4.5]);

	// ==========================================
	// PEAK (0:50 - 1:15) - Full layers
	// ==========================================
	// Foundation
	s.sendBundle(50, [\s_new, \softPad, -1, 0, 0, \freq, 55, \amp, 0.1, \dur, 16]);

	// Fifth relationship
	s.sendBundle(52, [\s_new, \softPad, -1, 0, 0, \freq, 82.41, \amp, 0.07, \dur, 14]);

	// Mid layers
	s.sendBundle(54, [\s_new, \softPad, -1, 0, 0, \freq, 196.0, \amp, 0.06, \dur, 12]);
	s.sendBundle(60, [\s_new, \softPad, -1, 0, 0, \freq, 261.63, \amp, 0.05, \dur, 10]);

	// Keys more present
	s.sendBundle(52, [\s_new, \warmKeys, -1, 0, 0, \freq, 293.66, \amp, 0.08, \dur, 3.5]);
	s.sendBundle(58, [\s_new, \warmKeys, -1, 0, 0, \freq, 349.23, \amp, 0.08, \dur, 3]);
	s.sendBundle(64, [\s_new, \warmKeys, -1, 0, 0, \freq, 392.0, \amp, 0.09, \dur, 3.5]);
	s.sendBundle(70, [\s_new, \warmKeys, -1, 0, 0, \freq, 329.63, \amp, 0.08, \dur, 3]);

	// Bells
	s.sendBundle(55, [\s_new, \melodyBell, -1, 0, 0, \freq, 587.33, \amp, 0.05, \dur, 5]);
	s.sendBundle(63, [\s_new, \melodyBell, -1, 0, 0, \freq, 783.99, \amp, 0.05, \dur, 4.5]);
	s.sendBundle(72, [\s_new, \melodyBell, -1, 0, 0, \freq, 659.25, \amp, 0.04, \dur, 5]);

	// ==========================================
	// BREAKDOWN (1:15 - 1:35) - Thin out
	// ==========================================
	// Single deep pad
	s.sendBundle(75, [\s_new, \softPad, -1, 0, 0, \freq, 55, \amp, 0.08, \dur, 18]);

	// Sparse keys
	s.sendBundle(80, [\s_new, \warmKeys, -1, 0, 0, \freq, 261.63, \amp, 0.07, \dur, 4]);
	s.sendBundle(90, [\s_new, \warmKeys, -1, 0, 0, \freq, 329.63, \amp, 0.06, \dur, 3.5]);

	// Single bell
	s.sendBundle(85, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.04, \dur, 5]);

	// ==========================================
	// RESOLUTION (1:35 - 2:00) - Fade
	// ==========================================
	// Final pad - quieter
	s.sendBundle(95, [\s_new, \softPad, -1, 0, 0, \freq, 55, \amp, 0.06, \dur, 20]);

	// Faint upper pad
	s.sendBundle(100, [\s_new, \softPad, -1, 0, 0, \freq, 164.81, \amp, 0.03, \dur, 14]);

	// Final keys
	s.sendBundle(98, [\s_new, \warmKeys, -1, 0, 0, \freq, 261.63, \amp, 0.05, \dur, 4]);
	s.sendBundle(108, [\s_new, \warmKeys, -1, 0, 0, \freq, 293.66, \amp, 0.04, \dur, 4]);

	// Final bell
	s.sendBundle(104, [\s_new, \melodyBell, -1, 0, 0, \freq, 659.25, \amp, 0.03, \dur, 6]);
	s.sendBundle(114, [\s_new, \melodyBell, -1, 0, 0, \freq, 523.25, \amp, 0.02, \dur, 7]);

	// Release vinyl
	s.sendBundle(118, [\n_set, vinyl.nodeID, \gate, 0]);

	"Scheduled (2 min).".postln;
}).play;
)
