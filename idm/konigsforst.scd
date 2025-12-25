// ============================================================
// KONIGSFORST - Gas-inspired deep forest ambient
// ============================================================
// Voice Roles:
// - Foundation: forestHaze (layered sine drones)
// - Texture: windTexture, natureCrackle (forest floor)
// - Movement: orchestralLoop (string-like swells)
// - Color: choirFragment (ghostly vocal wisps)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:25): Wind emerges, first haze layer
// - Development (0:25-0:55): Orchestra enters, textures build
// - Peak (0:55-1:20): Dense layering, choir fragments
// - Descent (1:20-1:40): Layers thin, space opens
// - Resolution (1:40-2:00): Final haze, fade to silence

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Foundation: Dense ambient haze
SynthDef(\forestHaze, {
	arg out = 0, amp = 0.1, freq = 200, dur = 20;
	var sig, env;
	env = EnvGen.kr(Env.linen(3, dur - 6, 3), doneAction: 2);
	sig = Mix.fill(6, { |i|
		var f = freq * (i + 1) * LFNoise1.kr(0.05).range(0.99, 1.01);
		var level = 1 / (i + 1);
		SinOsc.ar(f) * level
	}) / 3;
	sig = LPF.ar(sig, 800 + (LFNoise1.kr(0.1) * 300));
	sig = FreeVerb.ar(sig, 0.9, 0.95, 0.5);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Texture: Forest wind
SynthDef(\windTexture, {
	arg out = 0, amp = 0.06, dur = 30;
	var sig, env;
	env = EnvGen.kr(Env.linen(4, dur - 8, 4), doneAction: 2);
	sig = PinkNoise.ar;
	sig = BPF.ar(sig, LFNoise1.kr(0.1).range(200, 600), 0.5);
	sig = sig + BPF.ar(PinkNoise.ar, LFNoise1.kr(0.15).range(800, 1500), 0.3) * 0.3;
	sig = sig * amp * env;
	Out.ar(out, sig ! 2);
}).add;

// Texture: Forest floor crackle
SynthDef(\natureCrackle, {
	arg out = 0, amp = 0.04, density = 20, dur = 30;
	var sig, env;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);
	sig = Dust.ar(density) * 0.3;
	sig = sig + (Crackle.ar(1.7) * 0.1);
	sig = LPF.ar(sig, 3000);
	sig = HPF.ar(sig, 200);
	sig = FreeVerb.ar(sig, 0.6, 0.8, 0.3);
	sig = sig * amp * env;
	Out.ar(out, sig ! 2);
}).add;

// Movement: Orchestral strings swell
SynthDef(\orchestralLoop, {
	arg out = 0, amp = 0.1, freq = 220, dur = 8;
	var sig, env;
	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);
	sig = Saw.ar(freq) * 0.3;
	sig = sig + (Saw.ar(freq * 1.002) * 0.25);
	sig = sig + (Saw.ar(freq * 2.003) * 0.15);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.2);
	sig = LPF.ar(sig, 1500);
	sig = RLPF.ar(sig, 600 + (LFNoise1.kr(0.2) * 200), 0.5);
	sig = FreeVerb.ar(sig, 0.8, 0.9, 0.4);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Color: Ghostly choir fragment
SynthDef(\choirFragment, {
	arg out = 0, amp = 0.08, freq = 330, dur = 6;
	var sig, env;
	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);
	sig = Saw.ar(freq) * 0.3;
	sig = BPF.ar(sig, 700, 0.1) * 3;
	sig = sig + BPF.ar(Saw.ar(freq), 1200, 0.1) * 2;
	sig = LPF.ar(sig, 2000);
	sig = FreeVerb.ar(sig, 0.9, 0.95, 0.5);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// COMPOSITION - 2 MINUTE ARC
// --------------------------------------------------
// Intro:      0:00 - 0:25 (25s)
// Development: 0:25 - 0:55 (30s)
// Peak:       0:55 - 1:20 (25s)
// Descent:    1:20 - 1:40 (20s)
// Resolution: 1:40 - 2:00 (20s)

Routine({
	0.5.wait;
	"KONIGSFORST - Gas forest ambient (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:25) - Wind emerges
	// ==========================================
	// Wind texture layers
	s.sendBundle(0, [\s_new, \windTexture, -1, 0, 0, \amp, 0.03, \dur, 40]);
	s.sendBundle(5, [\s_new, \windTexture, -1, 0, 0, \amp, 0.04, \dur, 35]);

	// Nature crackle
	s.sendBundle(3, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.02, \density, 15, \dur, 45]);
	s.sendBundle(12, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.03, \density, 20, \dur, 40]);

	// First haze - low, sparse
	s.sendBundle(8, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.06, \dur, 25]);
	s.sendBundle(18, [\s_new, \forestHaze, -1, 0, 0, \freq, 130, \amp, 0.07, \dur, 22]);

	// ==========================================
	// DEVELOPMENT (0:25 - 0:55) - Orchestra enters
	// ==========================================
	// Haze continues
	s.sendBundle(25, [\s_new, \forestHaze, -1, 0, 0, \freq, 165, \amp, 0.08, \dur, 28]);
	s.sendBundle(38, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.09, \dur, 25]);

	// Orchestra enters
	s.sendBundle(28, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 130.81, \amp, 0.05, \dur, 12]); // C3
	s.sendBundle(36, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 146.83, \amp, 0.06, \dur, 14]); // D3
	s.sendBundle(45, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 164.81, \amp, 0.07, \dur, 12]); // E3

	// More wind/crackle
	s.sendBundle(30, [\s_new, \windTexture, -1, 0, 0, \amp, 0.05, \dur, 40]);
	s.sendBundle(35, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.035, \density, 22, \dur, 45]);

	// ==========================================
	// PEAK (0:55 - 1:20) - Dense layering
	// ==========================================
	// Dense haze layers
	s.sendBundle(55, [\s_new, \forestHaze, -1, 0, 0, \freq, 130, \amp, 0.1, \dur, 22]);
	s.sendBundle(58, [\s_new, \forestHaze, -1, 0, 0, \freq, 196, \amp, 0.08, \dur, 20]);
	s.sendBundle(65, [\s_new, \forestHaze, -1, 0, 0, \freq, 165, \amp, 0.1, \dur, 18]);
	s.sendBundle(72, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.09, \dur, 20]);

	// Orchestral swells
	s.sendBundle(55, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 130.81, \amp, 0.08, \dur, 14]); // C3
	s.sendBundle(60, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 196.00, \amp, 0.07, \dur, 12]); // G3
	s.sendBundle(68, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 146.83, \amp, 0.08, \dur, 16]); // D3
	s.sendBundle(75, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 164.81, \amp, 0.07, \dur, 14]); // E3

	// Choir fragments emerge
	s.sendBundle(58, [\s_new, \choirFragment, -1, 0, 0, \freq, 330, \amp, 0.05, \dur, 8]);
	s.sendBundle(68, [\s_new, \choirFragment, -1, 0, 0, \freq, 392, \amp, 0.06, \dur, 7]);
	s.sendBundle(76, [\s_new, \choirFragment, -1, 0, 0, \freq, 277, \amp, 0.05, \dur, 9]);

	// Peak textures
	s.sendBundle(55, [\s_new, \windTexture, -1, 0, 0, \amp, 0.055, \dur, 35]);
	s.sendBundle(60, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.04, \density, 25, \dur, 35]);

	// ==========================================
	// DESCENT (1:20 - 1:40) - Layers thin
	// ==========================================
	// Fewer haze layers
	s.sendBundle(80, [\s_new, \forestHaze, -1, 0, 0, \freq, 130, \amp, 0.08, \dur, 25]);
	s.sendBundle(90, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.07, \dur, 22]);

	// Sparse orchestra
	s.sendBundle(85, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 130.81, \amp, 0.05, \dur, 14]); // C3
	s.sendBundle(95, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 164.81, \amp, 0.04, \dur, 12]); // E3

	// Final choir wisp
	s.sendBundle(88, [\s_new, \choirFragment, -1, 0, 0, \freq, 330, \amp, 0.04, \dur, 10]);

	// Reduced textures
	s.sendBundle(82, [\s_new, \windTexture, -1, 0, 0, \amp, 0.04, \dur, 30]);
	s.sendBundle(85, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.025, \density, 18, \dur, 30]);

	// ==========================================
	// RESOLUTION (1:40 - 2:00) - Fade to silence
	// ==========================================
	// Final haze - long fade
	s.sendBundle(100, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.06, \dur, 25]);
	s.sendBundle(108, [\s_new, \forestHaze, -1, 0, 0, \freq, 130, \amp, 0.04, \dur, 20]);

	// Distant orchestra
	s.sendBundle(105, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 130.81, \amp, 0.03, \dur, 16]); // C3

	// Final wind whisper
	s.sendBundle(100, [\s_new, \windTexture, -1, 0, 0, \amp, 0.03, \dur, 25]);
	s.sendBundle(110, [\s_new, \natureCrackle, -1, 0, 0, \amp, 0.015, \density, 10, \dur, 18]);

	"Scheduled (2 min).".postln;
}).play;
)
