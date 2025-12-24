// ============================================================
// COLLAPSED - Emptyset-inspired architectural chaos
// ============================================================
// Voice Roles:
// - Foundation: resonantBass (deep sub anchoring)
// - Pulse: concreteImpact (architectural hits)
// - Movement: metalResonance (chaotic metallic textures)
// - Color: structuralStress (creaking tension)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Sub bass emerges, first impacts
// - Development (0:20-0:50): Metal chaos builds, rapid impacts
// - Peak (0:50-1:15): Maximum density, overlapping chaos
// - Breakdown (1:15-1:35): Strip to bass, sparse metal
// - Resolution (1:35-2:00): Final impacts, fade

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Foundation: Deep resonant sub
SynthDef(\resonantBass, {
	arg out = 0, amp = 0.3, freq = 40, resonance = 0.9, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);
	sig = RLPF.ar(sig, freq * 4, 1 - resonance);
	sig = (sig * 2).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Pulse: Heavy architectural impact
SynthDef(\concreteImpact, {
	arg out = 0, amp = 0.25, freq = 60, dur = 1.5;
	var sig, env, noise, tone;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);
	tone = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.001, 0.3));
	tone = tone + (SinOsc.ar(freq * 0.5) * EnvGen.kr(Env.perc(0.001, 0.5)) * 0.5);
	noise = BPF.ar(WhiteNoise.ar, freq * 3, 0.5) * EnvGen.kr(Env.perc(0.001, 0.05));
	sig = tone + (noise * 0.3);
	sig = sig.tanh * 1.5;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Movement: Metallic resonant body
SynthDef(\metalResonance, {
	arg out = 0, amp = 0.2, freq = 200, decay = 2, brightness = 0.5;
	var sig, env, exciter;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -6), doneAction: 2);
	exciter = Impulse.ar(0) + (WhiteNoise.ar * 0.1);
	sig = Mix.fill(6, { |i|
		var ratio = [1, 2.756, 5.404, 8.933, 13.344, 18.637][i];
		var decayTime = decay / (i + 1);
		Ringz.ar(exciter, freq * ratio * (1 + (brightness * 0.2)), decayTime) * (1 / (i + 1))
	});
	sig = HPF.ar(sig, 60);
	sig = sig.tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Color: Structural stress/creaking
SynthDef(\structuralStress, {
	arg out = 0, amp = 0.12, freq = 300, dur = 0.5;
	var sig, env, mod;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	mod = LFNoise1.kr(20).range(0.95, 1.05);
	sig = SinOsc.ar(freq * mod);
	sig = sig + (SinOsc.ar(freq * 1.01) * 0.5);
	sig = sig + (SinOsc.ar(freq * 0.99) * 0.5);
	sig = RLPF.ar(sig, freq * 3, 0.4);
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
	0.5.wait;
	"COLLAPSED - Emptyset composition (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Sub emerges
	// ==========================================
	// Foundation bass
	s.sendBundle(0, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.2, \resonance, 0.85, \dur, 4]);
	s.sendBundle(6, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.25, \resonance, 0.88, \dur, 3.5]);
	s.sendBundle(12, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.28, \resonance, 0.9, \dur, 4]);

	// First impacts
	s.sendBundle(8, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.12, \dur, 1.2]);
	s.sendBundle(14, [\s_new, \concreteImpact, -1, 0, 0, \freq, 60, \amp, 0.15, \dur, 1]);
	s.sendBundle(18, [\s_new, \concreteImpact, -1, 0, 0, \freq, 45, \amp, 0.14, \dur, 1.3]);

	// ==========================================
	// DEVELOPMENT (0:20 - 0:50) - Chaos builds
	// ==========================================
	// Bass continues
	s.sendBundle(20, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.3, \resonance, 0.88, \dur, 3]);
	s.sendBundle(26, [\s_new, \resonantBass, -1, 0, 0, \freq, 40, \amp, 0.28, \resonance, 0.85, \dur, 3.5]);
	s.sendBundle(32, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.32, \resonance, 0.9, \dur, 4]);
	s.sendBundle(40, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.3, \resonance, 0.88, \dur, 3]);
	s.sendBundle(46, [\s_new, \resonantBass, -1, 0, 0, \freq, 40, \amp, 0.28, \resonance, 0.85, \dur, 3]);

	// Impacts increase
	s.sendBundle(20, [\s_new, \concreteImpact, -1, 0, 0, \freq, 55, \amp, 0.16, \dur, 0.9]);
	s.sendBundle(22, [\s_new, \concreteImpact, -1, 0, 0, \freq, 70, \amp, 0.14, \dur, 0.7]);
	s.sendBundle(25, [\s_new, \concreteImpact, -1, 0, 0, \freq, 48, \amp, 0.18, \dur, 1]);
	s.sendBundle(28, [\s_new, \concreteImpact, -1, 0, 0, \freq, 65, \amp, 0.15, \dur, 0.8]);
	s.sendBundle(30, [\s_new, \concreteImpact, -1, 0, 0, \freq, 52, \amp, 0.17, \dur, 0.9]);
	s.sendBundle(33, [\s_new, \concreteImpact, -1, 0, 0, \freq, 80, \amp, 0.14, \dur, 0.6]);
	s.sendBundle(35, [\s_new, \concreteImpact, -1, 0, 0, \freq, 45, \amp, 0.19, \dur, 1.1]);
	s.sendBundle(38, [\s_new, \concreteImpact, -1, 0, 0, \freq, 58, \amp, 0.16, \dur, 0.8]);
	s.sendBundle(41, [\s_new, \concreteImpact, -1, 0, 0, \freq, 72, \amp, 0.15, \dur, 0.7]);
	s.sendBundle(44, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.18, \dur, 0.9]);
	s.sendBundle(47, [\s_new, \concreteImpact, -1, 0, 0, \freq, 62, \amp, 0.16, \dur, 0.8]);

	// Metal enters
	s.sendBundle(24, [\s_new, \metalResonance, -1, 0, 0, \freq, 180, \amp, 0.1, \decay, 1.2, \brightness, 0.5]);
	s.sendBundle(29, [\s_new, \metalResonance, -1, 0, 0, \freq, 220, \amp, 0.12, \decay, 1, \brightness, 0.6]);
	s.sendBundle(34, [\s_new, \metalResonance, -1, 0, 0, \freq, 160, \amp, 0.11, \decay, 1.3, \brightness, 0.55]);
	s.sendBundle(39, [\s_new, \metalResonance, -1, 0, 0, \freq, 250, \amp, 0.13, \decay, 0.9, \brightness, 0.65]);
	s.sendBundle(43, [\s_new, \metalResonance, -1, 0, 0, \freq, 190, \amp, 0.12, \decay, 1.1, \brightness, 0.5]);
	s.sendBundle(48, [\s_new, \metalResonance, -1, 0, 0, \freq, 280, \amp, 0.14, \decay, 1, \brightness, 0.7]);

	// ==========================================
	// PEAK (0:50 - 1:15) - Maximum density
	// ==========================================
	// Heavy bass
	s.sendBundle(50, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.35, \resonance, 0.92, \dur, 3]);
	s.sendBundle(54, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.32, \resonance, 0.9, \dur, 3]);
	s.sendBundle(58, [\s_new, \resonantBass, -1, 0, 0, \freq, 40, \amp, 0.33, \resonance, 0.88, \dur, 2.5]);
	s.sendBundle(62, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.35, \resonance, 0.92, \dur, 3]);
	s.sendBundle(66, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.32, \resonance, 0.9, \dur, 3]);
	s.sendBundle(70, [\s_new, \resonantBass, -1, 0, 0, \freq, 40, \amp, 0.3, \resonance, 0.88, \dur, 2.5]);

	// Rapid impacts
	s.sendBundle(50, [\s_new, \concreteImpact, -1, 0, 0, \freq, 60, \amp, 0.2, \dur, 0.7]);
	s.sendBundle(50.3, [\s_new, \concreteImpact, -1, 0, 0, \freq, 80, \amp, 0.16, \dur, 0.5]);
	s.sendBundle(50.6, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.22, \dur, 0.8]);
	s.sendBundle(52, [\s_new, \concreteImpact, -1, 0, 0, \freq, 70, \amp, 0.18, \dur, 0.6]);
	s.sendBundle(52.2, [\s_new, \concreteImpact, -1, 0, 0, \freq, 55, \amp, 0.2, \dur, 0.7]);
	s.sendBundle(54, [\s_new, \concreteImpact, -1, 0, 0, \freq, 65, \amp, 0.19, \dur, 0.6]);
	s.sendBundle(54.3, [\s_new, \concreteImpact, -1, 0, 0, \freq, 85, \amp, 0.15, \dur, 0.5]);
	s.sendBundle(54.5, [\s_new, \concreteImpact, -1, 0, 0, \freq, 45, \amp, 0.21, \dur, 0.9]);
	s.sendBundle(56, [\s_new, \concreteImpact, -1, 0, 0, \freq, 58, \amp, 0.18, \dur, 0.7]);
	s.sendBundle(56.4, [\s_new, \concreteImpact, -1, 0, 0, \freq, 75, \amp, 0.17, \dur, 0.6]);
	s.sendBundle(58, [\s_new, \concreteImpact, -1, 0, 0, \freq, 52, \amp, 0.2, \dur, 0.8]);
	s.sendBundle(58.2, [\s_new, \concreteImpact, -1, 0, 0, \freq, 68, \amp, 0.16, \dur, 0.6]);
	s.sendBundle(58.5, [\s_new, \concreteImpact, -1, 0, 0, \freq, 90, \amp, 0.14, \dur, 0.5]);
	s.sendBundle(60, [\s_new, \concreteImpact, -1, 0, 0, \freq, 48, \amp, 0.22, \dur, 0.9]);
	s.sendBundle(60.3, [\s_new, \concreteImpact, -1, 0, 0, \freq, 62, \amp, 0.18, \dur, 0.7]);
	s.sendBundle(62, [\s_new, \concreteImpact, -1, 0, 0, \freq, 55, \amp, 0.19, \dur, 0.7]);
	s.sendBundle(62.4, [\s_new, \concreteImpact, -1, 0, 0, \freq, 78, \amp, 0.16, \dur, 0.5]);
	s.sendBundle(64, [\s_new, \concreteImpact, -1, 0, 0, \freq, 42, \amp, 0.21, \dur, 1]);
	s.sendBundle(64.2, [\s_new, \concreteImpact, -1, 0, 0, \freq, 65, \amp, 0.17, \dur, 0.6]);
	s.sendBundle(66, [\s_new, \concreteImpact, -1, 0, 0, \freq, 58, \amp, 0.18, \dur, 0.7]);
	s.sendBundle(66.3, [\s_new, \concreteImpact, -1, 0, 0, \freq, 82, \amp, 0.15, \dur, 0.5]);
	s.sendBundle(68, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.2, \dur, 0.8]);
	s.sendBundle(68.4, [\s_new, \concreteImpact, -1, 0, 0, \freq, 72, \amp, 0.17, \dur, 0.6]);
	s.sendBundle(70, [\s_new, \concreteImpact, -1, 0, 0, \freq, 45, \amp, 0.19, \dur, 0.9]);
	s.sendBundle(70.2, [\s_new, \concreteImpact, -1, 0, 0, \freq, 60, \amp, 0.18, \dur, 0.7]);
	s.sendBundle(72, [\s_new, \concreteImpact, -1, 0, 0, \freq, 55, \amp, 0.17, \dur, 0.8]);

	// Metal chaos
	s.sendBundle(50, [\s_new, \metalResonance, -1, 0, 0, \freq, 200, \amp, 0.15, \decay, 0.8, \brightness, 0.6]);
	s.sendBundle(50.5, [\s_new, \metalResonance, -1, 0, 0, \freq, 280, \amp, 0.13, \decay, 0.7, \brightness, 0.7]);
	s.sendBundle(51.2, [\s_new, \metalResonance, -1, 0, 0, \freq, 150, \amp, 0.14, \decay, 1, \brightness, 0.5]);
	s.sendBundle(52, [\s_new, \metalResonance, -1, 0, 0, \freq, 320, \amp, 0.12, \decay, 0.6, \brightness, 0.75]);
	s.sendBundle(52.6, [\s_new, \metalResonance, -1, 0, 0, \freq, 180, \amp, 0.15, \decay, 0.9, \brightness, 0.55]);
	s.sendBundle(53.3, [\s_new, \metalResonance, -1, 0, 0, \freq, 240, \amp, 0.13, \decay, 0.8, \brightness, 0.65]);
	s.sendBundle(54, [\s_new, \metalResonance, -1, 0, 0, \freq, 300, \amp, 0.14, \decay, 0.7, \brightness, 0.7]);
	s.sendBundle(54.8, [\s_new, \metalResonance, -1, 0, 0, \freq, 160, \amp, 0.15, \decay, 1, \brightness, 0.5]);
	s.sendBundle(55.5, [\s_new, \metalResonance, -1, 0, 0, \freq, 220, \amp, 0.14, \decay, 0.85, \brightness, 0.6]);
	s.sendBundle(56.2, [\s_new, \metalResonance, -1, 0, 0, \freq, 350, \amp, 0.12, \decay, 0.6, \brightness, 0.8]);
	s.sendBundle(57, [\s_new, \metalResonance, -1, 0, 0, \freq, 190, \amp, 0.15, \decay, 0.9, \brightness, 0.55]);
	s.sendBundle(57.7, [\s_new, \metalResonance, -1, 0, 0, \freq, 260, \amp, 0.13, \decay, 0.8, \brightness, 0.65]);
	s.sendBundle(58.4, [\s_new, \metalResonance, -1, 0, 0, \freq, 140, \amp, 0.14, \decay, 1.1, \brightness, 0.5]);
	s.sendBundle(59.2, [\s_new, \metalResonance, -1, 0, 0, \freq, 290, \amp, 0.15, \decay, 0.7, \brightness, 0.7]);
	s.sendBundle(60, [\s_new, \metalResonance, -1, 0, 0, \freq, 210, \amp, 0.14, \decay, 0.85, \brightness, 0.6]);
	s.sendBundle(60.6, [\s_new, \metalResonance, -1, 0, 0, \freq, 330, \amp, 0.12, \decay, 0.65, \brightness, 0.75]);
	s.sendBundle(61.3, [\s_new, \metalResonance, -1, 0, 0, \freq, 170, \amp, 0.15, \decay, 0.95, \brightness, 0.55]);
	s.sendBundle(62, [\s_new, \metalResonance, -1, 0, 0, \freq, 250, \amp, 0.14, \decay, 0.8, \brightness, 0.65]);
	s.sendBundle(62.8, [\s_new, \metalResonance, -1, 0, 0, \freq, 310, \amp, 0.13, \decay, 0.7, \brightness, 0.7]);
	s.sendBundle(63.5, [\s_new, \metalResonance, -1, 0, 0, \freq, 185, \amp, 0.14, \decay, 0.9, \brightness, 0.55]);
	s.sendBundle(64.2, [\s_new, \metalResonance, -1, 0, 0, \freq, 270, \amp, 0.15, \decay, 0.75, \brightness, 0.65]);
	s.sendBundle(65, [\s_new, \metalResonance, -1, 0, 0, \freq, 155, \amp, 0.13, \decay, 1, \brightness, 0.5]);
	s.sendBundle(65.7, [\s_new, \metalResonance, -1, 0, 0, \freq, 230, \amp, 0.14, \decay, 0.85, \brightness, 0.6]);
	s.sendBundle(66.5, [\s_new, \metalResonance, -1, 0, 0, \freq, 340, \amp, 0.12, \decay, 0.6, \brightness, 0.75]);
	s.sendBundle(67.2, [\s_new, \metalResonance, -1, 0, 0, \freq, 195, \amp, 0.15, \decay, 0.9, \brightness, 0.55]);
	s.sendBundle(68, [\s_new, \metalResonance, -1, 0, 0, \freq, 275, \amp, 0.13, \decay, 0.8, \brightness, 0.65]);
	s.sendBundle(68.8, [\s_new, \metalResonance, -1, 0, 0, \freq, 165, \amp, 0.14, \decay, 0.95, \brightness, 0.5]);
	s.sendBundle(69.5, [\s_new, \metalResonance, -1, 0, 0, \freq, 245, \amp, 0.15, \decay, 0.8, \brightness, 0.6]);
	s.sendBundle(70.3, [\s_new, \metalResonance, -1, 0, 0, \freq, 305, \amp, 0.13, \decay, 0.7, \brightness, 0.7]);
	s.sendBundle(71, [\s_new, \metalResonance, -1, 0, 0, \freq, 175, \amp, 0.14, \decay, 0.9, \brightness, 0.55]);
	s.sendBundle(71.8, [\s_new, \metalResonance, -1, 0, 0, \freq, 255, \amp, 0.12, \decay, 0.85, \brightness, 0.6]);

	// Stress sounds in peak
	s.sendBundle(51, [\s_new, \structuralStress, -1, 0, 0, \freq, 300, \amp, 0.1, \dur, 0.4]);
	s.sendBundle(55, [\s_new, \structuralStress, -1, 0, 0, \freq, 380, \amp, 0.11, \dur, 0.5]);
	s.sendBundle(59, [\s_new, \structuralStress, -1, 0, 0, \freq, 260, \amp, 0.1, \dur, 0.45]);
	s.sendBundle(63, [\s_new, \structuralStress, -1, 0, 0, \freq, 420, \amp, 0.12, \dur, 0.55]);
	s.sendBundle(67, [\s_new, \structuralStress, -1, 0, 0, \freq, 320, \amp, 0.1, \dur, 0.4]);
	s.sendBundle(71, [\s_new, \structuralStress, -1, 0, 0, \freq, 350, \amp, 0.11, \dur, 0.5]);

	// ==========================================
	// BREAKDOWN (1:15 - 1:35) - Strip back
	// ==========================================
	// Reduced bass
	s.sendBundle(75, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.25, \resonance, 0.88, \dur, 4]);
	s.sendBundle(82, [\s_new, \resonantBass, -1, 0, 0, \freq, 35, \amp, 0.22, \resonance, 0.85, \dur, 3.5]);
	s.sendBundle(88, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.2, \resonance, 0.9, \dur, 4]);

	// Sparse impacts
	s.sendBundle(78, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.14, \dur, 1.2]);
	s.sendBundle(85, [\s_new, \concreteImpact, -1, 0, 0, \freq, 55, \amp, 0.12, \dur, 1]);
	s.sendBundle(92, [\s_new, \concreteImpact, -1, 0, 0, \freq, 48, \amp, 0.13, \dur, 1.3]);

	// Occasional metal
	s.sendBundle(80, [\s_new, \metalResonance, -1, 0, 0, \freq, 180, \amp, 0.08, \decay, 1.5, \brightness, 0.4]);
	s.sendBundle(90, [\s_new, \metalResonance, -1, 0, 0, \freq, 200, \amp, 0.07, \decay, 1.3, \brightness, 0.45]);

	// ==========================================
	// RESOLUTION (1:35 - 2:00) - Fade
	// ==========================================
	// Final bass
	s.sendBundle(95, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.18, \resonance, 0.9, \dur, 5]);
	s.sendBundle(102, [\s_new, \resonantBass, -1, 0, 0, \freq, 25, \amp, 0.15, \resonance, 0.92, \dur, 6]);
	s.sendBundle(110, [\s_new, \resonantBass, -1, 0, 0, \freq, 30, \amp, 0.1, \resonance, 0.88, \dur, 8]);

	// Final impacts
	s.sendBundle(98, [\s_new, \concreteImpact, -1, 0, 0, \freq, 45, \amp, 0.1, \dur, 1.5]);
	s.sendBundle(106, [\s_new, \concreteImpact, -1, 0, 0, \freq, 50, \amp, 0.08, \dur, 1.8]);
	s.sendBundle(114, [\s_new, \concreteImpact, -1, 0, 0, \freq, 40, \amp, 0.06, \dur, 2]);

	// Final metal whisper
	s.sendBundle(100, [\s_new, \metalResonance, -1, 0, 0, \freq, 150, \amp, 0.05, \decay, 2, \brightness, 0.3]);
	s.sendBundle(112, [\s_new, \metalResonance, -1, 0, 0, \freq, 160, \amp, 0.04, \decay, 2.5, \brightness, 0.25]);

	"Scheduled (2 min).".postln;
}).play;
)
