// ============================================================
// MARK FELL STYLE - Algorithmic patterns, non-Western rhythms
// ============================================================
// Inspired by "Multistability":
// - Non-Western rhythmic structures
// - Perceptual instability
// - Minimal timbre, maximum rhythm
// - Phase-based patterns
// - Irrational time divisions

// --------------------------------------------------
// FELL CLICK - Clean, precise rhythmic element
// --------------------------------------------------
(
SynthDef(\fellClick, {
	arg out = 0, amp = 0.2, freq = 1000, decay = 0.015, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);

	// Clean click with slight resonance
	sig = SinOsc.ar(freq) * 0.7;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 2, decay) * 0.3);

	sig = HPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// FELL TONE - Simple sine with precise envelope
// --------------------------------------------------
(
SynthDef(\fellTone, {
	arg out = 0, amp = 0.15, freq = 440, dur = 0.1, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// FELL BASS - Sub with click
// --------------------------------------------------
(
SynthDef(\fellBass, {
	arg out = 0, amp = 0.35, freq = 55, dur = 0.2;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);

	// Clean sub
	sig = SinOsc.ar(freq);

	// Subtle click
	click = HPF.ar(WhiteNoise.ar, 2000) * EnvGen.kr(Env.perc(0.001, 0.01));

	sig = sig + (click * 0.15);
	sig = LPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: IRRATIONAL PATTERNS
// Non-integer rhythm relationships
// --------------------------------------------------
(
// Three interlocking patterns with irrational relationships
var baseTime = 0.2;

// Pattern 1 - base
~pattern1 = Routine({
	var intervals = [1, 1, 1, 1];  // Regular
	var i = 0;
	inf.do {
		Synth(\fellClick, [
			\freq, 800,
			\amp, 0.15,
			\decay, 0.02,
			\pan, -0.4
		]);
		(baseTime * intervals[i % 4]).wait;
		i = i + 1;
	};
}).play;

// Pattern 2 - phi ratio (golden)
~pattern2 = Routine({
	var phi = 1.618;
	inf.do {
		Synth(\fellClick, [
			\freq, 1200,
			\amp, 0.12,
			\decay, 0.015,
			\pan, 0.4
		]);
		(baseTime * phi).wait;
	};
}).play;

// Pattern 3 - sqrt(2) ratio
~pattern3 = Routine({
	var ratio = 2.sqrt;
	inf.do {
		Synth(\fellTone, [
			\freq, 600,
			\amp, 0.1,
			\dur, 0.08,
			\pan, 0
		]);
		(baseTime * ratio).wait;
	};
}).play;

// Bass - even slower
~bassRoutine = Routine({
	var ratio = 3.sqrt;
	inf.do {
		Synth(\fellBass, [
			\freq, [55, 55, 73.4, 55].choose,
			\amp, rrand(0.25, 0.35),
			\dur, 0.15
		]);
		(baseTime * ratio * 2).wait;
	};
}).play;

"IRRATIONAL PATTERNS - Non-integer rhythms".postln;
)

// Stop
// ~pattern1.stop; ~pattern2.stop; ~pattern3.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: PERCEPTUAL FLIP
// Patterns that flip between interpretations
// --------------------------------------------------
(
var tempo = 0.12;

// Two patterns that create ambiguous groupings
~patternA = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1];  // 12-step
	var i = 0;
	inf.do {
		if (pattern[i % 12] == 1) {
			Synth(\fellClick, [
				\freq, 900,
				\amp, 0.16,
				\decay, 0.02,
				\pan, -0.3
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

~patternB = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0];  // Different 12-step
	var i = 0;
	inf.do {
		if (pattern[i % 12] == 1) {
			Synth(\fellClick, [
				\freq, 1400,
				\amp, 0.12,
				\decay, 0.015,
				\pan, 0.3
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Tone pattern - 7 steps against 12
~tonePattern = Routine({
	var pattern = [1, 0, 1, 0, 1, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 7] == 1) {
			Synth(\fellTone, [
				\freq, [440, 550, 660].choose,
				\amp, 0.1,
				\dur, 0.06
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Bass - 5 steps
~bassRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 5] == 1) {
			Synth(\fellBass, [
				\freq, [55, 73.4].choose,
				\amp, 0.3,
				\dur, 0.12
			]);
		};
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

"PERCEPTUAL FLIP - Ambiguous groupings".postln;
)

// Stop
// ~patternA.stop; ~patternB.stop; ~tonePattern.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: GAMELAN INFLUENCE
// Non-Western tuning, interlocking
// --------------------------------------------------
(
// Pelog-like scale ratios
var pelog = [1, 1.067, 1.183, 1.333, 1.5, 1.783, 2];
var root = 220;

var tempo = 0.18;

// Interlocking pattern 1
~gangsa1 = Routine({
	var pattern = [0, 2, 0, 3, 0, 4];  // 6-step
	var i = 0;
	inf.do {
		var degree = pattern[i % 6];
		Synth(\fellTone, [
			\freq, root * pelog[degree],
			\amp, 0.12,
			\dur, 0.1,
			\pan, -0.3
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Interlocking pattern 2 (fills gaps)
~gangsa2 = Routine({
	var pattern = [1, 0, 2, 0, 3, 0];  // 6-step, offset
	var i = 0;
	(tempo / 2).wait;  // Offset start
	inf.do {
		var degree = pattern[i % 6];
		if (degree > 0) {
			Synth(\fellTone, [
				\freq, root * pelog[degree],
				\amp, 0.1,
				\dur, 0.08,
				\pan, 0.3
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Lower octave - slower
~jegogan = Routine({
	var degrees = [0, 3, 4, 0, 2, 4];
	var i = 0;
	inf.do {
		Synth(\fellTone, [
			\freq, (root / 2) * pelog[degrees[i % 6]],
			\amp, 0.14,
			\dur, 0.2,
			\pan, 0
		]);
		i = i + 1;
		(tempo * 3).wait;
	};
}).play;

// Gong substitute
~bassRoutine = Routine({
	inf.do {
		Synth(\fellBass, [
			\freq, root / 4,
			\amp, 0.3,
			\dur, 0.3
		]);
		(tempo * 12).wait;
	};
}).play;

"GAMELAN INFLUENCE - Interlocking patterns".postln;
)

// Stop
// ~gangsa1.stop; ~gangsa2.stop; ~jegogan.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: EUCLIDEAN POLYRHYTHM
// Multiple Euclidean rhythms
// --------------------------------------------------
(
// Euclidean rhythm generator (simplified)
~euclidean = { |hits, steps|
	var pattern = Array.fill(steps, { 0 });
	var bucket = 0;
	steps.do { |i|
		bucket = bucket + hits;
		if (bucket >= steps) {
			bucket = bucket - steps;
			pattern[i] = 1;
		};
	};
	pattern;
};

var tempo = 0.1;

var e_3_8 = ~euclidean.(3, 8);   // Cuban tresillo
var e_5_8 = ~euclidean.(5, 8);   // Cinquillo
var e_5_12 = ~euclidean.(5, 12); // Similar to West African

// Pattern 1 - E(3,8)
~pattern1 = Routine({
	var i = 0;
	inf.do {
		if (e_3_8[i % 8] == 1) {
			Synth(\fellClick, [
				\freq, 700,
				\amp, 0.15,
				\decay, 0.025,
				\pan, -0.4
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern 2 - E(5,8)
~pattern2 = Routine({
	var i = 0;
	inf.do {
		if (e_5_8[i % 8] == 1) {
			Synth(\fellClick, [
				\freq, 1100,
				\amp, 0.12,
				\decay, 0.02,
				\pan, 0.4
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern 3 - E(5,12)
~pattern3 = Routine({
	var i = 0;
	inf.do {
		if (e_5_12[i % 12] == 1) {
			Synth(\fellTone, [
				\freq, 440,
				\amp, 0.1,
				\dur, 0.06,
				\pan, 0
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Bass - E(2,8)
~bassRoutine = Routine({
	var e_2_8 = ~euclidean.(2, 8);
	var i = 0;
	inf.do {
		if (e_2_8[i % 8] == 1) {
			Synth(\fellBass, [
				\freq, 55,
				\amp, 0.3,
				\dur, 0.1
			]);
		};
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

"EUCLIDEAN POLYRHYTHM - Mathematical patterns".postln;
)

// Stop
// ~pattern1.stop; ~pattern2.stop; ~pattern3.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: PHASE MUSIC
// Patterns that slowly drift against each other
// --------------------------------------------------
(
var baseTempo = 0.15;

// Pattern 1 - base
~phase1 = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 0];
	var tempo = baseTempo;
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\fellClick, [
				\freq, 800,
				\amp, 0.14,
				\pan, -0.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern 2 - slightly faster (will phase)
~phase2 = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 0];  // Same pattern
	var tempo = baseTempo * 0.99;  // 1% faster
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\fellClick, [
				\freq, 1200,
				\amp, 0.11,
				\pan, 0.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern 3 - even faster
~phase3 = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 0];
	var tempo = baseTempo * 0.97;  // 3% faster
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\fellTone, [
				\freq, 600,
				\amp, 0.08,
				\dur, 0.05
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Stable bass anchor
~bassRoutine = Routine({
	inf.do {
		Synth(\fellBass, [
			\freq, 55,
			\amp, 0.28,
			\dur, 0.12
		]);
		(baseTempo * 8).wait;
	};
}).play;

"PHASE MUSIC - Gradual drift".postln;
)

// Stop
// ~phase1.stop; ~phase2.stop; ~phase3.stop; ~bassRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
