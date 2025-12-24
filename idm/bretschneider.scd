// ============================================================
// FRANK BRETSCHNEIDER STYLE - Visual-audio sync, precision
// ============================================================
// Inspired by Raster-Noton aesthetic:
// - Precise digital pulses
// - Visual rhythm patterns
// - Minimal, geometric structures
// - Sine wave purity
// - Grid-locked timing

// --------------------------------------------------
// VISUAL PULSE - Short, precise pulse
// --------------------------------------------------
SynthDef(\visualPulse, {
	arg out = 0, amp = 0.15, freq = 1000, dur = 0.02;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// LINE TONE - Sustained line element
// --------------------------------------------------
SynthDef(\lineTone, {
	arg out = 0, amp = 0.1, freq = 440, dur = 1;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.005, dur - 0.01, 0.005), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SCAN LINE - Moving frequency sweep
// --------------------------------------------------
SynthDef(\scanLine, {
	arg out = 0, amp = 0.1, freqStart = 100, freqEnd = 2000, dur = 2;
	var sig, env, freq;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);
	freq = Line.kr(freqStart, freqEnd, dur);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GRID CLICK - Precise click
// --------------------------------------------------
SynthDef(\gridClickB, {
	arg out = 0, amp = 0.12, freq = 5000;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.0001, 0.003, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BLOCK TONE - Rectangular wave burst
// --------------------------------------------------
SynthDef(\blockTone, {
	arg out = 0, amp = 0.1, freq = 300, dur = 0.2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.001, dur - 0.002, 0.001), doneAction: 2);

	sig = Pulse.ar(freq, 0.5);
	sig = LPF.ar(sig, 2000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DIGITAL STATIC - Precise noise burst
// --------------------------------------------------
SynthDef(\digitalStatic, {
	arg out = 0, amp = 0.08, dur = 0.1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

	sig = LFNoise0.ar(20000) * 0.5;
	sig = sig + (Dust.ar(1000) * 0.3);
	sig = HPF.ar(sig, 2000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Bretschneider SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: RHYTHM
// Visual rhythm patterns
// --------------------------------------------------
(
var tempo = 0.1;

// Main pulse pattern
~pulseRoutine = Routine({
	var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0];
	var freqs = [800, 1000, 1200, 1000];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [
				\freq, freqs[(i / 4).floor % freqs.size],
				\amp, 0.12,
				\dur, 0.015
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Click pattern
~clickRoutine = Routine({
	var pattern = [0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClickB, [\amp, 0.1, \freq, 6000]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Low tone accents
~toneRoutine = Routine({
	var pattern = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\lineTone, [\freq, 220, \amp, 0.08, \dur, 0.3]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"RHYTHM - Visual patterns".postln;
)

// Stop
// ~pulseRoutine.stop; ~clickRoutine.stop; ~toneRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: CURVE
// Frequency sweeps and lines
// --------------------------------------------------
(
var tempo = 0.5;

// Scan lines
~scanRoutine = Routine({
	inf.do {
		var direction = [1, -1].choose;
		if (direction == 1) {
			Synth(\scanLine, [\freqStart, 200, \freqEnd, 1500, \amp, 0.08, \dur, 1.5]);
		} {
			Synth(\scanLine, [\freqStart, 1500, \freqEnd, 200, \amp, 0.08, \dur, 1.5]);
		};
		rrand(2, 4).wait;
	};
}).play;

// Pulse accents
~pulseRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [\freq, [600, 800, 1000].choose, \amp, 0.1]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Static punctuation
~staticRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\digitalStatic, [\amp, 0.06, \dur, rrand(0.05, 0.15)]);
		};
		rrand(1, 3).wait;
	};
}).play;

"CURVE - Frequency lines".postln;
)

// Stop
// ~scanRoutine.stop; ~pulseRoutine.stop; ~staticRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: BLOCKS
// Rectangular forms
// --------------------------------------------------
(
var tempo = 0.2;

// Block tone pattern
~blockRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 0, 0, 1];
	var freqs = [200, 250, 300, 400];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\blockTone, [
				\freq, freqs[i % freqs.size],
				\amp, 0.08,
				\dur, rrand(0.1, 0.25)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// High pulse counter
~highPulse = Routine({
	var pattern = [0, 1, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [\freq, 1500, \amp, 0.08, \dur, 0.01]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Click grid
~clickGrid = Routine({
	var pattern = [0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\gridClickB, [\amp, 0.08, \freq, 4500]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"BLOCKS - Rectangular forms".postln;
)

// Stop
// ~blockRoutine.stop; ~highPulse.stop; ~clickGrid.stop;

// --------------------------------------------------
// EXPERIMENT 4: LOOP
// Repeating geometric patterns
// --------------------------------------------------
(
var tempo = 0.0625; // Fast 16ths

// Main loop
~loopRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [\freq, 800, \amp, 0.1, \dur, 0.01]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Counter loop
~counterLoop = Routine({
	var pattern = [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [\freq, 1200, \amp, 0.08, \dur, 0.01]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Accent loop
~accentLoop = Routine({
	var pattern = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\lineTone, [\freq, 220, \amp, 0.1, \dur, 0.2]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"LOOP - Geometric repetition".postln;
)

// Stop
// ~loopRoutine.stop; ~counterLoop.stop; ~accentLoop.stop;

// --------------------------------------------------
// EXPERIMENT 5: EXP
// Exponential patterns
// --------------------------------------------------
(
// Accelerating pulses
~expRoutine = Routine({
	inf.do {
		var numPulses = rrand(5, 12);
		var startTempo = 0.3;
		numPulses.do { |i|
			var tempo = startTempo * (0.85 ** i);
			Synth(\visualPulse, [
				\freq, 800 + (i * 100),
				\amp, 0.1,
				\dur, 0.015
			]);
			tempo.wait;
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Decelerating pulses
~decRoutine = Routine({
	inf.do {
		var numPulses = rrand(5, 10);
		var startTempo = 0.05;
		numPulses.do { |i|
			var tempo = startTempo * (1.3 ** i);
			Synth(\visualPulse, [
				\freq, 1500 - (i * 80),
				\amp, 0.08,
				\dur, 0.01
			]);
			tempo.wait;
		};
		rrand(1, 3).wait;
	};
}).play;

"EXP - Exponential patterns".postln;
)

// Stop
// ~expRoutine.stop; ~decRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 6: SUPER.TRIGGER
// Dense trigger patterns
// --------------------------------------------------
(
var tempo = 0.05;

// Dense pulse grid
~denseGrid = Routine({
	var pattern = [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\visualPulse, [
				\freq, 600 + ((i % 8) * 100),
				\amp, 0.06,
				\dur, 0.008
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Static bursts
~staticBurst = Routine({
	inf.do {
		if (0.1.coin) {
			Synth(\digitalStatic, [\amp, 0.05, \dur, rrand(0.02, 0.08)]);
		};
		tempo.wait;
	};
}).play;

// Tone anchors
~toneAnchor = Routine({
	var i = 0;
	inf.do {
		if ((i % 32) == 0) {
			Synth(\lineTone, [\freq, [110, 220, 330].choose, \amp, 0.08, \dur, 0.4]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"SUPER.TRIGGER - Dense triggers".postln;
)

// Stop
// ~denseGrid.stop; ~staticBurst.stop; ~toneAnchor.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
