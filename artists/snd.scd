// ============================================================
// SND STYLE - Ultra-reduced, grid-focused minimalism
// ============================================================
// Mark Fell & Mat Steel duo project:
// - Extreme reduction to essential elements
// - Rigid grid structures with micro-variations
// - Pure sine waves and simple waveforms
// - Rhythmic patterns from number sequences
// - Anti-expressive, systematic approach

// --------------------------------------------------
// GRID SINE - Quantized sine pulse
// --------------------------------------------------
SynthDef(\gridSine, {
	arg out = 0, amp = 0.2, freq = 440, dur = 0.1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GRID CLICK - Pure digital click
// --------------------------------------------------
SynthDef(\gridClick, {
	arg out = 0, amp = 0.15, freq = 8000;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.0001, 0.002, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GRID TONE - Sustained grid element
// --------------------------------------------------
SynthDef(\gridTone, {
	arg out = 0, amp = 0.12, freq = 220, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.001, dur - 0.002, 0.001), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SEQUENCE PULSE - Rhythmic pulse train
// --------------------------------------------------
SynthDef(\seqPulse, {
	arg out = 0, amp = 0.1, freq = 200, rate = 8, dur = 2;
	var sig, env, trig;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);
	trig = Impulse.ar(rate);

	sig = SinOsc.ar(freq) * Decay.ar(trig, 0.02);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SUB PULSE - Low frequency element
// --------------------------------------------------
SynthDef(\subPulse, {
	arg out = 0, amp = 0.25, freq = 55, dur = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// RATIO TONE - Two-frequency ratio element
// --------------------------------------------------
SynthDef(\ratioTone, {
	arg out = 0, amp = 0.12, freq = 440, ratio = 1.5, dur = 0.2;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * ratio) * 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"SND SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: TENDER LOVE
// Classic SND grid minimalism
// --------------------------------------------------
(
var tempo = 0.125; // 8th notes at 120bpm

// Main grid pattern (Euclidean-inspired)
~gridRoutine = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0];
	var freqs = [440, 550, 660, 880];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [
				\freq, freqs[(i / 4).floor % freqs.size],
				\amp, 0.15,
				\dur, 0.08
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Click on different pattern
~clickRoutine = Routine({
	var pattern = [0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClick, [\amp, 0.1, \freq, 6000]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Sub pulse every 8 steps
~subRoutine = Routine({
	var i = 0;
	inf.do {
		if ((i % 8) == 0) {
			Synth(\subPulse, [\freq, 55, \amp, 0.2, \dur, 0.2]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"TENDER LOVE - Grid minimalism".postln;
)

// Stop
// ~gridRoutine.stop; ~clickRoutine.stop; ~subRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: STDIO
// Dense interlocking patterns
// --------------------------------------------------
(
var tempo = 0.1;

// Pattern A
~patternA = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var freq = 660;
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [\freq, freq, \amp, 0.12, \dur, 0.05]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern B (offset)
~patternB = Routine({
	var pattern = [0, 1, 0, 0, 1, 0, 1, 0];
	var freq = 880;
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [\freq, freq, \amp, 0.1, \dur, 0.05]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern C (clicks)
~patternC = Routine({
	var pattern = [0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClick, [\amp, 0.08, \freq, 5000]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Sub pattern
~subPattern = Routine({
	var pattern = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\subPulse, [\freq, 55, \amp, 0.18, \dur, 0.15]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"STDIO - Interlocking patterns".postln;
)

// Stop
// ~patternA.stop; ~patternB.stop; ~patternC.stop; ~subPattern.stop;

// --------------------------------------------------
// EXPERIMENT 3: MAKESND
// Number sequence based
// --------------------------------------------------
(
var tempo = 0.08;

// Fibonacci-inspired pattern
~fibRoutine = Routine({
	var fib = [1, 1, 2, 3, 5, 8, 13];
	var fibIndex = 0;
	var count = 0;
	var freqs = [330, 440, 550, 660, 880, 1100];
	inf.do {
		if (count == 0) {
			Synth(\gridSine, [
				\freq, freqs[fibIndex % freqs.size],
				\amp, 0.14,
				\dur, 0.06
			]);
			count = fib[fibIndex % fib.size];
			fibIndex = fibIndex + 1;
		};
		count = count - 1;
		tempo.wait;
	};
}).play;

// Prime number clicks
~primeRoutine = Routine({
	var primes = [2, 3, 5, 7, 11, 13];
	var primeIndex = 0;
	var count = 0;
	inf.do {
		if (count == 0) {
			Synth(\gridClick, [\amp, 0.1, \freq, 7000]);
			count = primes[primeIndex % primes.size];
			primeIndex = primeIndex + 1;
		};
		count = count - 1;
		tempo.wait;
	};
}).play;

"MAKESND - Number sequences".postln;
)

// Stop
// ~fibRoutine.stop; ~primeRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: ATAVISM
// Ratio-based harmonics
// --------------------------------------------------
(
var tempo = 0.15;

// Ratio sequence
~ratioRoutine = Routine({
	var ratios = [1, 1.5, 2, 2.5, 3, 4];
	var baseFreq = 220;
	var pattern = [1, 0, 1, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\ratioTone, [
				\freq, baseFreq,
				\ratio, ratios[i % ratios.size],
				\amp, 0.1,
				\dur, 0.12
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Steady pulse
~pulseRoutine = Routine({
	var i = 0;
	inf.do {
		if ((i % 4) == 0) {
			Synth(\subPulse, [\freq, 110, \amp, 0.15, \dur, 0.1]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Click accents
~accentRoutine = Routine({
	var pattern = [0, 0, 0, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClick, [\amp, 0.12, \freq, 4500]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"ATAVISM - Ratio harmonics".postln;
)

// Stop
// ~ratioRoutine.stop; ~pulseRoutine.stop; ~accentRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: RESIZE
// Variable grid density
// --------------------------------------------------
(
// Changing tempo grid
~variableGrid = Routine({
	var tempos = [0.2, 0.15, 0.1, 0.08, 0.1, 0.15];
	var tempoIndex = 0;
	var stepCount = 0;
	var freq = 550;
	inf.do {
		Synth(\gridSine, [\freq, freq, \amp, 0.12, \dur, 0.04]);
		stepCount = stepCount + 1;
		if (stepCount >= 16) {
			stepCount = 0;
			tempoIndex = (tempoIndex + 1) % tempos.size;
		};
		tempos[tempoIndex].wait;
	};
}).play;

// Fixed click reference
~fixedClick = Routine({
	inf.do {
		Synth(\gridClick, [\amp, 0.08, \freq, 6000]);
		0.5.wait;
	};
}).play;

"RESIZE - Variable density".postln;
)

// Stop
// ~variableGrid.stop; ~fixedClick.stop;

// --------------------------------------------------
// EXPERIMENT 6: RAW
// Stripped to essentials
// --------------------------------------------------
(
var tempo = 0.125;

// Single sine pattern
~sinePattern = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [\freq, 440, \amp, 0.18, \dur, 0.06]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Single click pattern
~clickPattern = Routine({
	var pattern = [0, 0, 1, 0, 0, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClick, [\amp, 0.12, \freq, 5500]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"RAW - Essential elements".postln;
)

// Stop
// ~sinePattern.stop; ~clickPattern.stop;

// --------------------------------------------------
// EXPERIMENT 7: 3PAIRS
// Three frequency pairs
// --------------------------------------------------
(
var tempo = 0.1;

// Pair 1: 220/330
~pair1 = Routine({
	var pattern = [1, 0, 0, 1, 0, 0];
	var freqs = [220, 330];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [
				\freq, freqs[i % 2],
				\amp, 0.1,
				\dur, 0.08
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pair 2: 440/660
~pair2 = Routine({
	var pattern = [0, 1, 0, 0, 1, 0];
	var freqs = [440, 660];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [
				\freq, freqs[i % 2],
				\amp, 0.08,
				\dur, 0.08
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Pair 3: 880/1320
~pair3 = Routine({
	var pattern = [0, 0, 1, 0, 0, 1];
	var freqs = [880, 1320];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [
				\freq, freqs[i % 2],
				\amp, 0.06,
				\dur, 0.08
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"3PAIRS - Frequency pairs".postln;
)

// Stop
// ~pair1.stop; ~pair2.stop; ~pair3.stop;

// --------------------------------------------------
// EXPERIMENT 8: TRADEMARKED
// Commercial SND sound
// --------------------------------------------------
(
var tempo = 0.0625; // Fast 16ths

// Dense sine grid
~denseGrid = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0];
	var freqs = [440, 550, 660, 550, 880, 660, 550, 440];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridSine, [
				\freq, freqs[i % freqs.size],
				\amp, 0.1,
				\dur, 0.03
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Accented clicks
~accentClicks = Routine({
	var pattern = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClick, [\amp, 0.15, \freq, 5000]);
			Synth(\subPulse, [\freq, 55, \amp, 0.2, \dur, 0.15]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"TRADEMARKED - Dense grid".postln;
)

// Stop
// ~denseGrid.stop; ~accentClicks.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
