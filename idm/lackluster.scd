// ============================================================
// LACKLUSTER STYLE - Warm melodic IDM, Merck Records aesthetic
// ============================================================
// Inspired by "Showcase", "Container", "Wrapping":
// - Warm, melodic electronica
// - Glitchy but accessible textures
// - Hip-hop influenced downtempo beats
// - Nostalgic, melancholic atmosphere
// - Digital warmth with vinyl crackle

// --------------------------------------------------
// WARM KEYS - Rhodes-like warm keys
// --------------------------------------------------
SynthDef(\warmKeys, {
	arg out = 0, amp = 0.12, freq = 440, dur = 1.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Electric piano-like tone
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3 * EnvGen.kr(Env.perc(0.01, dur * 0.3)));
	sig = sig + (SinOsc.ar(freq * 3) * 0.1 * EnvGen.kr(Env.perc(0.01, dur * 0.2)));
	sig = sig + (SinOsc.ar(freq * 4) * 0.05 * EnvGen.kr(Env.perc(0.01, dur * 0.1)));

	// Slight chorus for warmth
	sig = sig + DelayL.ar(sig, 0.03, SinOsc.kr(2).range(0.008, 0.012)) * 0.3;

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(0.5).range(-0.3, 0.3)));
}).add;

// --------------------------------------------------
// SOFT PAD - Warm analog-style pad
// --------------------------------------------------
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

// --------------------------------------------------
// GLITCH CLICK - Warm glitch element
// --------------------------------------------------
SynthDef(\glitchClick, {
	arg out = 0, amp = 0.1, freq = 2000, dur = 0.02;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (Dust.ar(500) * 0.3);

	sig = HPF.ar(sig, 500);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.7, 0.7)));
}).add;

// --------------------------------------------------
// DOWNTEMPO KICK - Soft hip-hop kick
// --------------------------------------------------
SynthDef(\lofiKick, {
	arg out = 0, amp = 0.2;
	var sig, env, pitchEnv;

	env = EnvGen.kr(Env.perc(0.01, 0.35, 1, -5), doneAction: 2);
	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.12, 1, -4));

	sig = SinOsc.ar(45 + (pitchEnv * 60));
	sig = sig + (SinOsc.ar(90) * 0.3);

	// Lo-fi warmth
	sig = LPF.ar(sig, 300);
	sig = (sig * 1.2).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// LOFI SNARE - Muffled snare
// --------------------------------------------------
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

// --------------------------------------------------
// LOFI HAT - Soft hi-hat
// --------------------------------------------------
SynthDef(\lofiHat, {
	arg out = 0, amp = 0.08, dur = 0.06;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig, 7000, 0.5);
	sig = LPF.ar(sig, 9000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// VINYL CRACKLE - Warm vinyl texture
// --------------------------------------------------
SynthDef(\vinylCrackle, {
	arg out = 0, amp = 0.04;
	var sig;

	sig = Dust.ar(25) * 0.4;
	sig = sig + (Crackle.ar(1.7) * 0.15);
	sig = sig + (HPF.ar(PinkNoise.ar * 0.2, 6000));

	sig = LPF.ar(sig, 8000);
	sig = HPF.ar(sig, 100);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// MELODY BELL - Soft melodic bell
// --------------------------------------------------
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
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(0.3).range(-0.4, 0.4)));
}).add;

// --------------------------------------------------
// BASS PULSE - Warm sub bass
// --------------------------------------------------
SynthDef(\bassPulse, {
	arg out = 0, amp = 0.15, freq = 55, dur = 0.4;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (Saw.ar(freq) * 0.2);
	sig = sig + (SinOsc.ar(freq * 2) * 0.15);

	sig = LPF.ar(sig, 500);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// GLITCH STUTTER - Rapid stutter texture
// --------------------------------------------------
SynthDef(\glitchStutter, {
	arg out = 0, amp = 0.08, freq = 600, rate = 25, dur = 0.3;
	var sig, env, stutter;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 1.5) * 0.3);

	stutter = LFPulse.ar(rate, 0, 0.4);
	sig = sig * stutter;

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Lackluster SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: SHOWCASE
// Classic Lackluster warmth
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.03]);

// Warm keys melody
~keysRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72, 74].midicps;
	inf.do {
		if (0.7.coin) {
			Synth(\warmKeys, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\dur, rrand(0.8, 2)
			]);
		};
		rrand(0.3, 0.8).wait;
	};
}).play;

// Soft pad
~padRoutine = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		Synth(\softPad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(6, 12)
		]);
		rrand(5, 10).wait;
	};
}).play;

// Downtempo beat
~beatRoutine = Routine({
	var tempo = 0.22;
	var kickPat = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\lofiKick, [\amp, rrand(0.14, 0.2)]) };
		if (snarePat[i % 16] == 1) { Synth(\lofiSnare, [\amp, rrand(0.08, 0.12)]) };
		if (hatPat[i % 16] == 1) { Synth(\lofiHat, [\amp, rrand(0.04, 0.07)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Glitch accents
~glitchRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\glitchClick, [
				\freq, rrand(1500, 4000),
				\amp, rrand(0.04, 0.08),
				\dur, rrand(0.01, 0.03)
			]);
		};
		rrand(0.2, 0.8).wait;
	};
}).play;

"SHOWCASE - Classic warmth".postln;
)

// Stop
// ~vinyl.free; ~keysRoutine.stop; ~padRoutine.stop; ~beatRoutine.stop; ~glitchRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: CONTAINER
// More melodic focus
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.025]);

// Bell melody
~bellRoutine = Routine({
	var notes = [67, 69, 72, 74, 76, 79].midicps;
	var i = 0;
	inf.do {
		Synth(\melodyBell, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.06, 0.1),
			\dur, rrand(1.5, 3)
		]);
		i = i + ([1, 1, 2, -1].choose);
		if (i < 0) { i = 0 };
		if (i > 5) { i = 5 };
		rrand(0.4, 1).wait;
	};
}).play;

// Keys accompaniment
~keysRoutine = Routine({
	var chords = [
		[48, 55, 60].midicps,
		[50, 57, 62].midicps,
		[52, 59, 64].midicps,
		[48, 55, 60].midicps
	];
	var i = 0;
	inf.do {
		chords[i % chords.size].do { |freq|
			Synth(\warmKeys, [
				\freq, freq,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(1.5, 3)
			]);
		};
		i = i + 1;
		rrand(2, 4).wait;
	};
}).play;

// Bass
~bassRoutine = Routine({
	var notes = [36, 38, 40, 36].midicps;
	var i = 0;
	inf.do {
		Synth(\bassPulse, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.1, 0.15),
			\dur, rrand(0.3, 0.5)
		]);
		i = i + 1;
		rrand(0.8, 1.5).wait;
	};
}).play;

// Gentle beat
~beatRoutine = Routine({
	var tempo = 0.25;
	var kickPat = [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0];
	var hatPat = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\lofiKick, [\amp, 0.15]) };
		if (hatPat[i % 16] == 1) { Synth(\lofiHat, [\amp, rrand(0.04, 0.06)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"CONTAINER - Melodic focus".postln;
)

// Stop
// ~vinyl.free; ~bellRoutine.stop; ~keysRoutine.stop; ~bassRoutine.stop; ~beatRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: WRAPPING
// Glitchier textures
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.035]);

// Glitch patterns
~glitchRoutine = Routine({
	inf.do {
		// Burst of glitches
		rrand(3, 8).do {
			Synth(\glitchClick, [
				\freq, rrand(1000, 5000),
				\amp, rrand(0.05, 0.1),
				\dur, rrand(0.008, 0.025)
			]);
			rrand(0.02, 0.1).wait;
		};
		rrand(0.3, 1).wait;
	};
}).play;

// Stutter elements
~stutterRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\glitchStutter, [
				\freq, rrand(400, 1200),
				\amp, rrand(0.05, 0.09),
				\rate, rrand(15, 40),
				\dur, rrand(0.15, 0.4)
			]);
		};
		rrand(0.5, 1.5).wait;
	};
}).play;

// Warm keys
~keysRoutine = Routine({
	var notes = [60, 64, 67, 72, 74].midicps;
	inf.do {
		if (0.6.coin) {
			Synth(\warmKeys, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.13),
				\dur, rrand(0.6, 1.5)
			]);
		};
		rrand(0.3, 0.8).wait;
	};
}).play;

// Skippy beat
~beatRoutine = Routine({
	var tempo = 0.18;
	var kickPat = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1];
	var hatPat = [1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\lofiKick, [\amp, rrand(0.12, 0.18)]) };
		if (snarePat[i % 16] == 1) { Synth(\lofiSnare, [\amp, rrand(0.08, 0.11)]) };
		if (hatPat[i % 16] == 1) { Synth(\lofiHat, [\amp, rrand(0.03, 0.06)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"WRAPPING - Glitchy textures".postln;
)

// Stop
// ~vinyl.free; ~glitchRoutine.stop; ~stutterRoutine.stop; ~keysRoutine.stop; ~beatRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: RESTEALING
// Melancholic, sparse
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.03]);

// Sparse keys
~sparseKeys = Routine({
	var notes = [60, 62, 64, 67, 69].midicps;
	inf.do {
		Synth(\warmKeys, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.15),
			\dur, rrand(1.5, 3)
		]);
		rrand(2, 5).wait;
	};
}).play;

// Long pad
~longPad = Routine({
	var notes = [48, 52, 55].midicps;
	inf.do {
		Synth(\softPad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(10, 18)
		]);
		rrand(12, 20).wait;
	};
}).play;

// Occasional bell
~occasionalBell = Routine({
	var notes = [72, 74, 76, 79].midicps;
	inf.do {
		if (0.25.coin) {
			Synth(\melodyBell, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(2, 4)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Very sparse beat
~sparseBeat = Routine({
	var tempo = 0.3;
	var kickPat = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\lofiKick, [\amp, 0.14]) };
		if ((i % 32 == 12).and(0.6.coin)) { Synth(\lofiSnare, [\amp, 0.08]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Rare glitch
~rareGlitch = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\glitchClick, [
				\freq, rrand(2000, 4000),
				\amp, rrand(0.04, 0.07)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"RESTEALING - Melancholic sparse".postln;
)

// Stop
// ~vinyl.free; ~sparseKeys.stop; ~longPad.stop; ~occasionalBell.stop; ~sparseBeat.stop; ~rareGlitch.stop;

// --------------------------------------------------
// EXPERIMENT 5: MERCK STYLE
// Label-defining sound
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.03]);

// Layered keys
~keysLayer1 = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		Synth(\warmKeys, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(1, 2)
		]);
		rrand(0.5, 1.5).wait;
	};
}).play;

~keysLayer2 = Routine({
	var notes = [60, 64, 67, 72].midicps;
	inf.do {
		if (0.6.coin) {
			Synth(\warmKeys, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.09),
				\dur, rrand(0.8, 1.8)
			]);
		};
		rrand(0.4, 1.2).wait;
	};
}).play;

// Bell accents
~bellAccents = Routine({
	var notes = [72, 76, 79, 84].midicps;
	inf.do {
		if (0.35.coin) {
			Synth(\melodyBell, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(1.5, 3)
			]);
		};
		rrand(1, 3).wait;
	};
}).play;

// Bass line
~bassLine = Routine({
	var notes = [36, 36, 38, 36, 41, 36, 38, 36].midicps;
	var i = 0;
	inf.do {
		Synth(\bassPulse, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.1, 0.14),
			\dur, rrand(0.25, 0.4)
		]);
		i = i + 1;
		0.4.wait;
	};
}).play;

// Classic beat
~classicBeat = Routine({
	var tempo = 0.2;
	var kickPat = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\lofiKick, [\amp, 0.16]) };
		if (snarePat[i % 16] == 1) { Synth(\lofiSnare, [\amp, 0.1]) };
		if (hatPat[i % 16] == 1) { Synth(\lofiHat, [\amp, rrand(0.04, 0.07)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Glitch sprinkles
~glitchSprinkle = Routine({
	inf.do {
		if (0.3.coin) {
			rrand(1, 3).do {
				Synth(\glitchClick, [
					\freq, rrand(1500, 4000),
					\amp, rrand(0.03, 0.06)
				]);
				rrand(0.02, 0.08).wait;
			};
		};
		rrand(0.5, 1.5).wait;
	};
}).play;

"MERCK STYLE - Label sound".postln;
)

// Stop
// ~vinyl.free; ~keysLayer1.stop; ~keysLayer2.stop; ~bellAccents.stop; ~bassLine.stop; ~classicBeat.stop; ~glitchSprinkle.stop;

// --------------------------------------------------
// EXPERIMENT 6: AMBIENT LACKLUSTER
// No beat, pure texture
// --------------------------------------------------
(
~vinyl = Synth(\vinylCrackle, [\amp, 0.04]);

// Pad layers
~padLayer1 = Routine({
	var notes = [36, 43, 48].midicps;
	inf.do {
		Synth(\softPad, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(12, 22)
		]);
		rrand(10, 18).wait;
	};
}).play;

~padLayer2 = Routine({
	var notes = [55, 60, 67].midicps;
	inf.do {
		Synth(\softPad, [
			\freq, notes.choose,
			\amp, rrand(0.05, 0.09),
			\dur, rrand(10, 18)
		]);
		rrand(8, 15).wait;
	};
}).play;

// Sparse keys
~sparseKeys = Routine({
	var notes = [60, 64, 67, 72, 74].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\warmKeys, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(2, 4)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Occasional bell
~bellLayer = Routine({
	var notes = [72, 76, 79, 84].midicps;
	inf.do {
		if (0.2.coin) {
			Synth(\melodyBell, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(3, 6)
			]);
		};
		rrand(8, 18).wait;
	};
}).play;

"AMBIENT LACKLUSTER - Pure texture".postln;
)

// Stop
// ~vinyl.free; ~padLayer1.stop; ~padLayer2.stop; ~sparseKeys.stop; ~bellLayer.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
