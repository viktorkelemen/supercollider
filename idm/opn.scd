// ============================================================
// ONEOHTRIX POINT NEVER STYLE - Sample manipulation, MIDI nostalgia
// ============================================================
// Inspired by "R Plus Seven", "Garden of Delete", "Age Of":
// - FM synthesis and DX7 textures
// - Sample collage and manipulation
// - MIDI-era nostalgia
// - Hyperreal digital aesthetics
// - Uncanny valley synthesis

// --------------------------------------------------
// FM BELL - Classic FM bell tone
// --------------------------------------------------
SynthDef(\fmBell, {
	arg out = 0, amp = 0.15, freq = 440, ratio = 3.5, modIndex = 5, dur = 3;
	var sig, env, mod;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

	// FM synthesis
	mod = SinOsc.ar(freq * ratio) * modIndex * freq;
	sig = SinOsc.ar(freq + mod);

	// Bell-like decay on modulation
	sig = sig * EnvGen.kr(Env.perc(0.01, dur * 0.5, 1, -4));
	sig = sig + (SinOsc.ar(freq) * EnvGen.kr(Env.perc(0.01, dur, 0.5, -4)));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DX KEYS - FM electric piano texture
// --------------------------------------------------
SynthDef(\dxKeys, {
	arg out = 0, amp = 0.15, freq = 440, dur = 2;
	var sig, env, mod1, mod2;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Two modulator FM
	mod1 = SinOsc.ar(freq * 14) * 0.5 * freq * EnvGen.kr(Env.perc(0.01, 0.1));
	mod2 = SinOsc.ar(freq * 1) * 2 * freq * EnvGen.kr(Env.perc(0.01, dur * 0.3));

	sig = SinOsc.ar(freq + mod1 + mod2);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SYNTH CHOIR - Synthetic vocal texture
// --------------------------------------------------
SynthDef(\synthChoir, {
	arg out = 0, amp = 0.12, freq = 220, formant = 800, dur = 4;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.2, dur - 0.4, 0.2), doneAction: 2);

	// Formant-like synthesis
	sig = Saw.ar(freq) * 0.5;
	sig = BPF.ar(sig, formant, 0.1) * 4;
	sig = sig + BPF.ar(sig, formant * 1.5, 0.1) * 2;
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Chorus
	sig = sig + DelayL.ar(sig, 0.03, SinOsc.kr(2).range(0.01, 0.02)) * 0.5;

	sig = LPF.ar(sig, 4000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// PLUCK SYNTH - Digital pluck
// --------------------------------------------------
SynthDef(\pluckSynth, {
	arg out = 0, amp = 0.15, freq = 440, dur = 1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);

	sig = Pluck.ar(
		WhiteNoise.ar,
		Impulse.kr(0),
		1/freq,
		1/freq,
		dur * 2,
		0.5
	);

	// Add brightness
	sig = sig + (SinOsc.ar(freq * 2) * EnvGen.kr(Env.perc(0.001, 0.05)) * 0.2);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GLASSY PAD - Transparent digital pad
// --------------------------------------------------
SynthDef(\glassyPad, {
	arg out = 0, amp = 0.1, freq = 220, dur = 6;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.3);
	sig = sig + (SinOsc.ar(freq * 4.02) * 0.2);
	sig = sig + (SinOsc.ar(freq * 8.03) * 0.1);

	// Glassy shimmer
	sig = sig + (SinOsc.ar(freq * 16, SinOsc.kr(3) * pi) * 0.05);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// STUTTER SAMPLE - Rapid stutter effect
// --------------------------------------------------
SynthDef(\stutterSample, {
	arg out = 0, amp = 0.12, freq = 800, stutterRate = 20, dur = 0.5;
	var sig, env, stutter;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);

	// Base tone
	sig = SinOsc.ar(freq) + (Saw.ar(freq * 0.5) * 0.3);

	// Stutter gate
	stutter = LFPulse.ar(stutterRate, 0, 0.5);
	sig = sig * stutter;

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// MIDI BRASS - Cheesy synth brass
// --------------------------------------------------
SynthDef(\midiBrass, {
	arg out = 0, amp = 0.12, freq = 220, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.adsr(0.1, 0.2, 0.7, 0.3), Impulse.kr(0), timeScale: dur, doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Saw.ar(freq * 1.005) * 0.3);
	sig = sig + (Pulse.ar(freq * 0.5, 0.5) * 0.2);

	sig = RLPF.ar(sig, 1500 + (env * 2000), 0.3);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"OPN SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: R PLUS SEVEN
// MIDI nostalgia, FM bells
// --------------------------------------------------
(
// FM bell arpeggios
~bellRoutine = Routine({
	var notes = [60, 64, 67, 72, 76, 79, 84].midicps;
	inf.do {
		Synth(\fmBell, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.14),
			\ratio, [2, 3, 3.5, 4].choose,
			\modIndex, rrand(3, 8),
			\dur, rrand(2, 5)
		]);
		rrand(0.2, 0.8).wait;
	};
}).play;

// Glassy pad bed
~padRoutine = Routine({
	var notes = [48, 55, 60, 67].midicps;
	inf.do {
		Synth(\glassyPad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(6, 12)
		]);
		rrand(8, 15).wait;
	};
}).play;

// Synth choir accents
~choirRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\synthChoir, [
				\freq, [220, 277, 330, 440].choose,
				\amp, rrand(0.06, 0.1),
				\formant, rrand(600, 1200),
				\dur, rrand(3, 6)
			]);
		};
		rrand(5, 12).wait;
	};
}).play;

"R PLUS SEVEN - MIDI nostalgia".postln;
)

// Stop
// ~bellRoutine.stop; ~padRoutine.stop; ~choirRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: GARDEN OF DELETE
// Aggressive, stuttered
// --------------------------------------------------
(
// Stutter patterns
~stutterRoutine = Routine({
	inf.do {
		Synth(\stutterSample, [
			\freq, rrand(400, 1200),
			\amp, rrand(0.08, 0.14),
			\stutterRate, rrand(15, 40),
			\dur, rrand(0.3, 0.8)
		]);
		rrand(0.2, 0.8).wait;
	};
}).play;

// FM chaos
~fmRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\fmBell, [
				\freq, rrand(200, 1000),
				\amp, rrand(0.06, 0.12),
				\ratio, rrand(2, 8),
				\modIndex, rrand(5, 15),
				\dur, rrand(0.5, 2)
			]);
		};
		rrand(0.3, 1).wait;
	};
}).play;

// Brass stabs
~brassRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\midiBrass, [
				\freq, rrand(100, 400),
				\amp, rrand(0.08, 0.12),
				\dur, rrand(0.5, 1.5)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

"GARDEN OF DELETE - Aggressive".postln;
)

// Stop
// ~stutterRoutine.stop; ~fmRoutine.stop; ~brassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: REPLICA
// Looped fragments
// --------------------------------------------------
(
// Repeating pluck pattern
~pluckRoutine = Routine({
	var pattern = [60, 64, 67, 64, 60, 62, 65, 62].midicps;
	var i = 0;
	inf.do {
		Synth(\pluckSynth, [
			\freq, pattern[i % pattern.size],
			\amp, rrand(0.1, 0.16),
			\dur, rrand(0.8, 1.5)
		]);
		i = i + 1;
		0.25.wait;
	};
}).play;

// DX keys
~keysRoutine = Routine({
	var notes = [48, 55, 60, 67].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\dxKeys, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.15),
				\dur, rrand(1, 3)
			]);
		};
		rrand(1, 3).wait;
	};
}).play;

// Subtle choir
~subtleChoir = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\synthChoir, [
				\freq, [165, 220, 277].choose,
				\amp, rrand(0.04, 0.08),
				\formant, rrand(500, 900),
				\dur, rrand(4, 8)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

"REPLICA - Looped fragments".postln;
)

// Stop
// ~pluckRoutine.stop; ~keysRoutine.stop; ~subtleChoir.stop;

// --------------------------------------------------
// EXPERIMENT 4: AGE OF
// Orchestral digital
// --------------------------------------------------
(
// Choir layers
~choirLayers = Routine({
	var notes = [48, 55, 60, 64, 67, 72].midicps;
	inf.do {
		2.do {
			Synth(\synthChoir, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\formant, rrand(600, 1000),
				\dur, rrand(4, 8)
			]);
		};
		rrand(3, 6).wait;
	};
}).play;

// Brass fanfares
~fanfareRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			var notes = [[55, 60, 64], [60, 64, 67], [55, 59, 62]].choose;
			notes.do { |note|
				Synth(\midiBrass, [
					\freq, note.midicps,
					\amp, rrand(0.06, 0.1),
					\dur, rrand(1.5, 3)
				]);
			};
		};
		rrand(5, 12).wait;
	};
}).play;

// Bell accents
~bellAccent = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\fmBell, [
				\freq, [440, 550, 660, 880].choose,
				\amp, rrand(0.06, 0.1),
				\ratio, [3, 4, 5].choose,
				\modIndex, rrand(3, 6),
				\dur, rrand(2, 4)
			]);
		};
		rrand(2, 5).wait;
	};
}).play;

"AGE OF - Orchestral digital".postln;
)

// Stop
// ~choirLayers.stop; ~fanfareRoutine.stop; ~bellAccent.stop;

// --------------------------------------------------
// EXPERIMENT 5: NOBODY HERE
// Sparse, melancholic
// --------------------------------------------------
(
// Sparse keys
~sparseKeys = Routine({
	var notes = [60, 64, 67, 69, 72].midicps;
	inf.do {
		Synth(\dxKeys, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.16),
			\dur, rrand(2, 4)
		]);
		rrand(3, 8).wait;
	};
}).play;

// Glassy pad
~glassyRoutine = Routine({
	var notes = [48, 55, 60].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\glassyPad, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(8, 15)
			]);
		};
		rrand(10, 20).wait;
	};
}).play;

// Rare bell
~rareBell = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\fmBell, [
				\freq, [440, 550, 660].choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(4, 8)
			]);
		};
		rrand(10, 25).wait;
	};
}).play;

"NOBODY HERE - Sparse melancholy".postln;
)

// Stop
// ~sparseKeys.stop; ~glassyRoutine.stop; ~rareBell.stop;

// --------------------------------------------------
// EXPERIMENT 6: PROBLEM AREAS
// Hyperactive collage
// --------------------------------------------------
(
// Rapid everything
~rapidBells = Routine({
	inf.do {
		Synth(\fmBell, [
			\freq, rrand(200, 1500),
			\amp, rrand(0.04, 0.08),
			\ratio, rrand(1, 6),
			\modIndex, rrand(2, 10),
			\dur, rrand(0.2, 1)
		]);
		rrand(0.05, 0.3).wait;
	};
}).play;

~rapidPlucks = Routine({
	inf.do {
		if (0.6.coin) {
			Synth(\pluckSynth, [
				\freq, rrand(200, 1200),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.3, 1)
			]);
		};
		rrand(0.1, 0.4).wait;
	};
}).play;

~rapidStutter = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\stutterSample, [
				\freq, rrand(300, 1000),
				\amp, rrand(0.05, 0.09),
				\stutterRate, rrand(20, 50),
				\dur, rrand(0.1, 0.4)
			]);
		};
		rrand(0.2, 0.6).wait;
	};
}).play;

"PROBLEM AREAS - Hyperactive".postln;
)

// Stop
// ~rapidBells.stop; ~rapidPlucks.stop; ~rapidStutter.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
