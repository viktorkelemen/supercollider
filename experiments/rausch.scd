// ============================================================
// RAUSCH - Gas-inspired intoxicated swirl
// ============================================================
// Voice Roles:
// - Foundation: buriedKick (hypnotic 4/4 pulse)
// - Texture: forestHaze (swirling frequency cycle)
// - Movement: orchestralLoop (ascending note sequence)
// - Color: choirFragment (ghostly vocal wisps)
// - Atmosphere: windTexture (continuous forest air)
//
// Energy Arc (2 minutes):
// - Intro (0:00-0:20): Wind emerges, first haze, kick enters
// - Build (0:20-0:50): Orchestra evolves, haze cycles
// - Peak (0:50-1:20): Dense layering, choir fragments, full swirl
// - Sustain (1:20-1:40): Maintain intensity, subtle variations
// - Resolution (1:40-2:00): Gradual thinning, final haze

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------

// Foundation: Buried hypnotic kick
SynthDef(\buriedKick, {
	arg out = 0, amp = 0.2, freq = 50;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, 0.3, 1, -6), doneAction: 2);
	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.1, 1, -4)).range(1, 2));
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.3);
	sig = LPF.ar(sig, 150);
	sig = FreeVerb.ar(sig, 0.6, 0.7, 0.3);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// Texture: Dense swirling haze
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

// Atmosphere: Forest wind
SynthDef(\windTexture, {
	arg out = 0, amp = 0.06, dur = 30;
	var sig, env;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);
	sig = PinkNoise.ar;
	sig = BPF.ar(sig, LFNoise1.kr(0.1).range(200, 600), 0.5);
	sig = sig + BPF.ar(PinkNoise.ar, LFNoise1.kr(0.15).range(800, 1500), 0.3) * 0.3;
	sig = sig * amp * env;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// COMPOSITION - 2 MINUTE ARC
// --------------------------------------------------
// Intro:      0:00 - 0:20 (20s)
// Build:      0:20 - 0:50 (30s)
// Peak:       0:50 - 1:20 (30s)
// Sustain:    1:20 - 1:40 (20s)
// Resolution: 1:40 - 2:00 (20s)

// Swirling frequency sequence (cycles through)
var hazeFreqs = [110, 123.5, 146.8, 165, 196, 220];
// Ascending orchestra notes (G3 to C5)
var orchestraNotes = [196.00, 220.00, 246.94, 261.63, 293.66, 329.63, 349.23];

Routine({
	0.5.wait;
	"RAUSCH - Intoxicated swirl (2 min)".postln;

	// ==========================================
	// INTRO (0:00 - 0:20) - Wind, haze, kick enters
	// ==========================================
	// Wind texture
	s.sendBundle(0, [\s_new, \windTexture, -1, 0, 0, \amp, 0.03, \dur, 50]);
	s.sendBundle(8, [\s_new, \windTexture, -1, 0, 0, \amp, 0.04, \dur, 45]);

	// First haze layers
	s.sendBundle(2, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.05, \dur, 18]);
	s.sendBundle(10, [\s_new, \forestHaze, -1, 0, 0, \freq, 123.5, \amp, 0.06, \dur, 16]);

	// Kick enters gradually (starts at 8s)
	24.do { |i|
		s.sendBundle(8 + (i * 0.5), [\s_new, \buriedKick, -1, 0, 0, \amp, 0.08 + (i * 0.003), \freq, 50]);
	};

	// ==========================================
	// BUILD (0:20 - 0:50) - Orchestra evolves
	// ==========================================
	// Swirling haze - cycling frequencies
	s.sendBundle(20, [\s_new, \forestHaze, -1, 0, 0, \freq, 146.8, \amp, 0.07, \dur, 15]);
	s.sendBundle(28, [\s_new, \forestHaze, -1, 0, 0, \freq, 165, \amp, 0.07, \dur, 14]);
	s.sendBundle(36, [\s_new, \forestHaze, -1, 0, 0, \freq, 196, \amp, 0.08, \dur, 15]);
	s.sendBundle(44, [\s_new, \forestHaze, -1, 0, 0, \freq, 220, \amp, 0.08, \dur, 14]);

	// Orchestra enters and evolves
	s.sendBundle(22, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 196.00, \amp, 0.05, \dur, 10]);
	s.sendBundle(28, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 220.00, \amp, 0.06, \dur, 9]);
	s.sendBundle(34, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 246.94, \amp, 0.06, \dur, 10]);
	s.sendBundle(40, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 261.63, \amp, 0.07, \dur, 9]);
	s.sendBundle(46, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 293.66, \amp, 0.07, \dur, 10]);

	// Continuous kick (120bpm)
	60.do { |i|
		s.sendBundle(20 + (i * 0.5), [\s_new, \buriedKick, -1, 0, 0, \amp, 0.12, \freq, 50]);
	};

	// First choir wisp
	s.sendBundle(38, [\s_new, \choirFragment, -1, 0, 0, \freq, 330, \amp, 0.04, \dur, 7]);

	// ==========================================
	// PEAK (0:50 - 1:20) - Dense, full swirl
	// ==========================================
	// Dense overlapping haze
	s.sendBundle(50, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.09, \dur, 16]);
	s.sendBundle(54, [\s_new, \forestHaze, -1, 0, 0, \freq, 165, \amp, 0.08, \dur, 14]);
	s.sendBundle(58, [\s_new, \forestHaze, -1, 0, 0, \freq, 220, \amp, 0.09, \dur, 15]);
	s.sendBundle(64, [\s_new, \forestHaze, -1, 0, 0, \freq, 146.8, \amp, 0.08, \dur, 14]);
	s.sendBundle(70, [\s_new, \forestHaze, -1, 0, 0, \freq, 196, \amp, 0.09, \dur, 15]);
	s.sendBundle(76, [\s_new, \forestHaze, -1, 0, 0, \freq, 123.5, \amp, 0.08, \dur, 14]);

	// Evolving orchestra continues
	s.sendBundle(50, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 329.63, \amp, 0.08, \dur, 9]);
	s.sendBundle(56, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 349.23, \amp, 0.08, \dur, 10]);
	s.sendBundle(62, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 293.66, \amp, 0.08, \dur, 9]);
	s.sendBundle(68, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 261.63, \amp, 0.08, \dur, 10]);
	s.sendBundle(74, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 329.63, \amp, 0.07, \dur, 9]);

	// Choir fragments
	s.sendBundle(55, [\s_new, \choirFragment, -1, 0, 0, \freq, 392, \amp, 0.05, \dur, 8]);
	s.sendBundle(66, [\s_new, \choirFragment, -1, 0, 0, \freq, 350, \amp, 0.05, \dur, 7]);
	s.sendBundle(78, [\s_new, \choirFragment, -1, 0, 0, \freq, 440, \amp, 0.04, \dur, 8]);

	// Peak kick continues
	60.do { |i|
		s.sendBundle(50 + (i * 0.5), [\s_new, \buriedKick, -1, 0, 0, \amp, 0.14, \freq, 50]);
	};

	// Extra wind layer
	s.sendBundle(50, [\s_new, \windTexture, -1, 0, 0, \amp, 0.05, \dur, 40]);

	// ==========================================
	// SUSTAIN (1:20 - 1:40) - Maintain intensity
	// ==========================================
	// Haze continues
	s.sendBundle(80, [\s_new, \forestHaze, -1, 0, 0, \freq, 165, \amp, 0.08, \dur, 18]);
	s.sendBundle(88, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.07, \dur, 16]);

	// Orchestra
	s.sendBundle(82, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 246.94, \amp, 0.07, \dur, 10]);
	s.sendBundle(90, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 220.00, \amp, 0.06, \dur, 12]);

	// Kick continues
	40.do { |i|
		s.sendBundle(80 + (i * 0.5), [\s_new, \buriedKick, -1, 0, 0, \amp, 0.12, \freq, 50]);
	};

	// Choir wisp
	s.sendBundle(86, [\s_new, \choirFragment, -1, 0, 0, \freq, 370, \amp, 0.04, \dur, 8]);

	// ==========================================
	// RESOLUTION (1:40 - 2:00) - Gradual fade
	// ==========================================
	// Final haze layers
	s.sendBundle(100, [\s_new, \forestHaze, -1, 0, 0, \freq, 110, \amp, 0.06, \dur, 22]);
	s.sendBundle(108, [\s_new, \forestHaze, -1, 0, 0, \freq, 146.8, \amp, 0.04, \dur, 18]);

	// Final orchestra - descending
	s.sendBundle(102, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 196.00, \amp, 0.05, \dur, 14]);
	s.sendBundle(112, [\s_new, \orchestralLoop, -1, 0, 0, \freq, 174.61, \amp, 0.03, \dur, 12]);

	// Kick fades out
	30.do { |i|
		var amp = 0.12 - (i * 0.003);
		s.sendBundle(100 + (i * 0.5), [\s_new, \buriedKick, -1, 0, 0, \amp, amp.max(0.04), \freq, 50]);
	};

	// Final wind whisper
	s.sendBundle(100, [\s_new, \windTexture, -1, 0, 0, \amp, 0.03, \dur, 25]);

	// Last choir whisper
	s.sendBundle(105, [\s_new, \choirFragment, -1, 0, 0, \freq, 300, \amp, 0.03, \dur, 10]);

	"Scheduled (2 min).".postln;
}).play;
)
