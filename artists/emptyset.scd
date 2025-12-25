// ============================================================
// EMPTYSET STYLE - Architectural bass, resonant spaces
// ============================================================
// Inspired by "Medium", "Recur", "Blossoms":
// - Resonant feedback systems
// - Architectural acoustics simulation
// - Heavy sub-bass with harmonic distortion
// - Metal/concrete material textures
// - Physical modeling concepts

// --------------------------------------------------
// RESONANT BASS - Deep resonant sub
// --------------------------------------------------
SynthDef(\resonantBass, {
	arg out = 0, amp = 0.3, freq = 40, resonance = 0.9, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Fundamental with harmonics
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);

	// Resonant filter for metallic quality
	sig = RLPF.ar(sig, freq * 4, 1 - resonance);

	// Soft clip for warmth
	sig = (sig * 2).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// METAL RESONANCE - Metallic resonant body
// --------------------------------------------------
SynthDef(\metalResonance, {
	arg out = 0, amp = 0.2, freq = 200, decay = 2, brightness = 0.5;
	var sig, env, exciter;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -6), doneAction: 2);

	// Exciter
	exciter = Impulse.ar(0) + (WhiteNoise.ar * 0.1);

	// Bank of resonant filters (modal synthesis)
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

// --------------------------------------------------
// CONCRETE IMPACT - Heavy architectural impact
// --------------------------------------------------
SynthDef(\concreteImpact, {
	arg out = 0, amp = 0.25, freq = 60, dur = 1.5;
	var sig, env, noise, tone;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	// Low thud
	tone = SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.001, 0.3));
	tone = tone + (SinOsc.ar(freq * 0.5) * EnvGen.kr(Env.perc(0.001, 0.5)) * 0.5);

	// Noise burst for attack texture
	noise = BPF.ar(WhiteNoise.ar, freq * 3, 0.5) * EnvGen.kr(Env.perc(0.001, 0.05));

	sig = tone + (noise * 0.3);
	sig = sig.tanh * 1.5;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// FEEDBACK DRONE - Simulated feedback
// --------------------------------------------------
SynthDef(\feedbackDrone, {
	arg out = 0, amp = 0.15, freq = 100, feedback = 0.7, dur = 5;
	var sig, env, fb;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);

	// Base oscillator
	sig = SinOsc.ar(freq);

	// Feedback simulation with delay
	fb = CombL.ar(sig, 0.1, freq.reciprocal, feedback * 3);
	sig = sig + (fb * feedback);

	// Resonant filtering
	sig = RLPF.ar(sig, freq * 2, 0.3);
	sig = sig.tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SPACE IMPULSE - Room impulse response simulation
// --------------------------------------------------
SynthDef(\spaceImpulse, {
	arg out = 0, amp = 0.2, decay = 3, brightness = 0.3;
	var sig, env, impulse;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	// Initial impulse
	impulse = Impulse.ar(0);

	// Multiple delayed reflections
	sig = Mix.fill(8, { |i|
		var delay = 0.01 + (i * 0.015);
		var level = 1 / (i + 1).sqrt;
		DelayL.ar(impulse, 0.2, delay) * level
	});

	// Room coloration
	sig = BPF.ar(sig, 400 + (brightness * 2000), 0.8);
	sig = sig + (LPF.ar(sig, 200) * 0.5);

	// Reverb tail
	sig = FreeVerb.ar(sig, 0.8, 0.9, 0.3);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HARMONIC DISTORTION - Bass with rich harmonics
// --------------------------------------------------
SynthDef(\harmonicDistortion, {
	arg out = 0, amp = 0.2, freq = 50, drive = 2, dur = 1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq);

	// Waveshaping for harmonics
	sig = (sig * drive).tanh;
	sig = (sig * drive * 0.5).fold(-1, 1);

	// Subtle high harmonics
	sig = sig + (SinOsc.ar(freq * 5) * 0.05);

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// STRUCTURAL STRESS - Creaking/stress sounds
// --------------------------------------------------
SynthDef(\structuralStress, {
	arg out = 0, amp = 0.12, freq = 300, dur = 0.5;
	var sig, env, mod;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Modulated tone for stress/strain sound
	mod = LFNoise1.kr(20).range(0.95, 1.05);
	sig = SinOsc.ar(freq * mod);
	sig = sig + (SinOsc.ar(freq * 1.01) * 0.5);
	sig = sig + (SinOsc.ar(freq * 0.99) * 0.5);

	sig = RLPF.ar(sig, freq * 3, 0.4);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Emptyset SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: MEDIUM
// Deep architectural bass
// --------------------------------------------------
(
// Resonant bass hits
~bassRoutine = Routine({
	var freqs = [30, 35, 40, 45, 50];
	inf.do {
		Synth(\resonantBass, [
			\freq, freqs.choose,
			\amp, rrand(0.2, 0.35),
			\resonance, rrand(0.7, 0.95),
			\dur, rrand(1.5, 3)
		]);
		rrand(2, 5).wait;
	};
}).play;

// Concrete impacts
~impactRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\concreteImpact, [
				\freq, [40, 50, 60, 80].choose,
				\amp, rrand(0.15, 0.25),
				\dur, rrand(1, 2)
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

// Space impulses
~spaceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\spaceImpulse, [
				\amp, rrand(0.1, 0.18),
				\decay, rrand(2, 5),
				\brightness, rrand(0.2, 0.6)
			]);
		};
		rrand(5, 15).wait;
	};
}).play;

"MEDIUM - Architectural bass".postln;
)

// Stop
// ~bassRoutine.stop; ~impactRoutine.stop; ~spaceRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: RECUR
// Repetitive metallic patterns
// --------------------------------------------------
(
var tempo = 0.5;

// Metal resonance pattern
~metalRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var freqs = [150, 200, 250, 180];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\metalResonance, [
				\freq, freqs[i % freqs.size],
				\amp, rrand(0.12, 0.2),
				\decay, rrand(1, 2.5),
				\brightness, rrand(0.3, 0.7)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Bass pulse
~bassRoutine = Routine({
	var pattern = [1, 0, 0, 0, 0, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\resonantBass, [
				\freq, [40, 50].choose,
				\amp, 0.25,
				\dur, 1.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"RECUR - Metallic patterns".postln;
)

// Stop
// ~metalRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: BLOSSOMS
// Feedback and distortion
// --------------------------------------------------
(
// Feedback drones
~feedbackRoutine = Routine({
	inf.do {
		Synth(\feedbackDrone, [
			\freq, [60, 80, 100, 120].choose,
			\amp, rrand(0.1, 0.18),
			\feedback, rrand(0.5, 0.85),
			\dur, rrand(4, 10)
		]);
		rrand(6, 15).wait;
	};
}).play;

// Harmonic distortion hits
~distortionRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\harmonicDistortion, [
				\freq, [40, 50, 60, 80].choose,
				\amp, rrand(0.15, 0.25),
				\drive, rrand(1.5, 3),
				\dur, rrand(0.8, 2)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Structural stress
~stressRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\structuralStress, [
				\freq, rrand(200, 500),
				\amp, rrand(0.08, 0.14),
				\dur, rrand(0.3, 0.8)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

"BLOSSOMS - Feedback layers".postln;
)

// Stop
// ~feedbackRoutine.stop; ~distortionRoutine.stop; ~stressRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: COLLAPSED
// Dense, chaotic
// --------------------------------------------------
(
// Rapid impacts
~rapidImpacts = Routine({
	inf.do {
		// Burst of impacts
		rrand(2, 5).do {
			Synth(\concreteImpact, [
				\freq, rrand(40, 100),
				\amp, rrand(0.1, 0.2),
				\dur, rrand(0.5, 1.2)
			]);
			rrand(0.1, 0.4).wait;
		};
		rrand(1, 4).wait;
	};
}).play;

// Metal resonance chaos
~metalChaos = Routine({
	inf.do {
		Synth(\metalResonance, [
			\freq, rrand(100, 400),
			\amp, rrand(0.1, 0.18),
			\decay, rrand(0.5, 1.5),
			\brightness, rrand(0.4, 0.9)
		]);
		rrand(0.2, 0.8).wait;
	};
}).play;

// Sub bass anchoring
~subBass = Routine({
	inf.do {
		Synth(\resonantBass, [
			\freq, [30, 35, 40].choose,
			\amp, 0.3,
			\dur, rrand(2, 4)
		]);
		rrand(3, 6).wait;
	};
}).play;

"COLLAPSED - Dense chaos".postln;
)

// Stop
// ~rapidImpacts.stop; ~metalChaos.stop; ~subBass.stop;

// --------------------------------------------------
// EXPERIMENT 5: BORDERS
// Sparse, monumental
// --------------------------------------------------
(
// Monumental bass
~monumentalBass = Routine({
	inf.do {
		Synth(\resonantBass, [
			\freq, [25, 30, 35].choose,
			\amp, rrand(0.3, 0.4),
			\resonance, rrand(0.85, 0.95),
			\dur, rrand(4, 8)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Rare space impulses
~rareSpace = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\spaceImpulse, [
				\amp, rrand(0.15, 0.25),
				\decay, rrand(4, 8),
				\brightness, rrand(0.1, 0.4)
			]);
		};
		rrand(15, 30).wait;
	};
}).play;

// Very sparse metal
~sparseMetal = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\metalResonance, [
				\freq, [100, 150, 200].choose,
				\amp, rrand(0.12, 0.18),
				\decay, rrand(3, 5),
				\brightness, 0.3
			]);
		};
		rrand(20, 40).wait;
	};
}).play;

"BORDERS - Monumental space".postln;
)

// Stop
// ~monumentalBass.stop; ~rareSpace.stop; ~sparseMetal.stop;

// --------------------------------------------------
// EXPERIMENT 6: SKIN
// Organic textures
// --------------------------------------------------
(
// Structural stress as organic sound
~organicRoutine = Routine({
	inf.do {
		Synth(\structuralStress, [
			\freq, rrand(150, 400),
			\amp, rrand(0.08, 0.15),
			\dur, rrand(0.2, 0.6)
		]);
		rrand(0.3, 1.5).wait;
	};
}).play;

// Warm feedback
~warmFeedback = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\feedbackDrone, [
				\freq, rrand(80, 150),
				\amp, rrand(0.08, 0.14),
				\feedback, rrand(0.4, 0.7),
				\dur, rrand(3, 7)
			]);
		};
		rrand(5, 12).wait;
	};
}).play;

// Subtle bass
~subtleBass = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\harmonicDistortion, [
				\freq, [50, 60, 75].choose,
				\amp, rrand(0.1, 0.18),
				\drive, rrand(1, 2),
				\dur, rrand(1, 2.5)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

"SKIN - Organic textures".postln;
)

// Stop
// ~organicRoutine.stop; ~warmFeedback.stop; ~subtleBass.stop;

// --------------------------------------------------
// EXPERIMENT 7: SIGNAL
// Rhythmic industrial
// --------------------------------------------------
(
var tempo = 0.25;

// Industrial rhythm
~rhythm = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\concreteImpact, [
				\freq, [50, 60, 70].choose,
				\amp, rrand(0.15, 0.25),
				\dur, 0.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Accented metal
~accent = Routine({
	var pattern = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\metalResonance, [
				\freq, [200, 250, 300].choose,
				\amp, 0.15,
				\decay, 1.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"SIGNAL - Industrial rhythm".postln;
)

// Stop
// ~rhythm.stop; ~accent.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
