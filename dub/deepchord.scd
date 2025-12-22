// ============================================================
// DEEPCHORD STYLE - Aquatic dub techno, tape saturation
// ============================================================
// Inspired by "Hash-Bar Loops":
// - Aquatic, submerged textures
// - Tape saturation and warmth
// - Loop-based composition
// - Deep reverb spaces
// - Subtle, evolving repetition

// --------------------------------------------------
// TAPE SATURATION - Warm, saturated processing
// --------------------------------------------------
(
SynthDef(\tapeSat, {
	arg out = 0, in, amp = 0.8, saturation = 0.3, warmth = 0.5;
	var sig;

	sig = In.ar(in, 2);

	// Tape saturation
	sig = (sig * (1 + saturation)).tanh;

	// Warmth - subtle low boost, high cut
	sig = LPF.ar(sig, 8000 - (warmth * 4000));
	sig = sig + (LPF.ar(sig, 200) * warmth * 0.3);

	// Subtle wow
	sig = DelayC.ar(sig, 0.05, SinOsc.kr(0.3).range(0.001, 0.003));

	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// AQUATIC PAD - Deep, underwater texture
// --------------------------------------------------
(
SynthDef(\aquaticPad, {
	arg out = 0, amp = 0.15, freq = 110, depth = 0.7, dur = 10;
	var sig, env, voices;

	env = EnvGen.kr(Env.linen(2, dur - 4, 2, 1, \sin), doneAction: 2);

	// Multiple detuned voices
	voices = Mix.fill(6, { |i|
		var detune = LFNoise2.kr(0.03 + (i * 0.01)).range(0.995, 1.005);
		var voice = SinOsc.ar(freq * (i + 1) * detune);
		voice * (1 / (i + 1).sqrt) * LFNoise2.kr(0.05).range(0.5, 1);
	});

	sig = voices;

	// Underwater filtering
	sig = LPF.ar(sig, 2000 - (depth * 1500));
	sig = LPF.ar(sig, 3000 - (depth * 2000));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DEEP CHORD - Rich harmonic stab
// --------------------------------------------------
(
SynthDef(\deepChord, {
	arg out = 0, amp = 0.2, freq = 220, spread = 0.01, dur = 3;
	var sig, env, fenv;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.3, 0.2, 1, \sin), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.05, dur * 0.4, 1, -3));

	// Rich chord
	sig = Mix([
		SinOsc.ar(freq * LFNoise2.kr(0.05).range(1-spread, 1+spread)) * 0.4,
		SinOsc.ar(freq * 1.5 * LFNoise2.kr(0.04).range(1-spread, 1+spread)) * 0.25,
		SinOsc.ar(freq * 2 * LFNoise2.kr(0.03).range(1-spread, 1+spread)) * 0.2,
		LFTri.ar(freq * 0.5) * 0.15
	]);

	// Filter with envelope
	sig = LPF.ar(sig, 800 + (fenv * 1500));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// LOOP FRAGMENT - Short repeating element
// --------------------------------------------------
(
SynthDef(\loopFragment, {
	arg out = 0, amp = 0.12, freq = 300, loopTime = 0.25, decay = 4;
	var sig, loop, env;

	env = EnvGen.kr(Env.linen(0.5, decay - 1, 0.5, 1, \sin), doneAction: 2);

	// Initial sound
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq, 0.3) * 0.2);
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 2, 0.1) * 0.1);

	// Short initial hit
	sig = sig * EnvGen.kr(Env.perc(0.005, loopTime * 0.5));

	// Create loop
	loop = CombL.ar(sig, 1, loopTime, decay);
	loop = LPF.ar(loop, 2000);

	sig = loop * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DUBBED KICK - Warm, processed kick
// --------------------------------------------------
(
SynthDef(\dubbedKick, {
	arg out = 0, amp = 0.5, freq = 50, decay = 0.5;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -6), doneAction: 2);

	// Warm sine
	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.08, 1, -4)).range(1, 1.5));
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.4);

	// Soft click
	click = LPF.ar(WhiteNoise.ar, 600) * EnvGen.kr(Env.perc(0.001, 0.025));

	sig = sig + (click * 0.25);
	sig = (sig * 1.2).tanh;  // Saturation
	sig = LPF.ar(sig, 200);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// AQUATIC REVERB - Deep space
// --------------------------------------------------
(
SynthDef(\aquaticReverb, {
	arg out = 0, in, amp = 0.3, decay = 4, damping = 0.5;
	var sig, verb;

	sig = In.ar(in, 2);

	// Simple reverb approximation with allpass chain
	verb = sig;
	6.do({ |i|
		verb = AllpassC.ar(verb, 0.1, rrand(0.01, 0.08), decay * (1 - (damping * i / 6)));
	});

	verb = LPF.ar(verb, 4000);
	verb = verb * amp;
	Out.ar(out, verb);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: HASH-BAR LOOPS
// Loop-focused, deep space
// --------------------------------------------------
(
~pad = Synth(\aquaticPad, [\freq, 55, \amp, 0.1, \depth, 0.6, \dur, 60]);

// Loop fragments
~loopRoutine = Routine({
	var freqs = [110, 146.8, 164.8, 196, 220, 261.6];
	var loopTimes = [0.125, 0.167, 0.2, 0.25, 0.333];
	inf.do {
		if (0.35.coin) {
			Synth(\loopFragment, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.12),
				\loopTime, loopTimes.choose,
				\decay, rrand(3, 8)
			]);
		};
		rrand(2, 8).wait;
	};
}).play;

// Sparse kicks
~kickRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\dubbedKick, [
				\amp, rrand(0.35, 0.5),
				\decay, rrand(0.4, 0.7)
			]);
		};
		rrand(1, 3).wait;
	};
}).play;

// Occasional chords
~chordRoutine = Routine({
	var notes = [82.4, 110, 130.8, 146.8];
	inf.do {
		if (0.2.coin) {
			Synth(\deepChord, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.15),
				\dur, rrand(3, 8)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

"HASH-BAR LOOPS - Deep and looped".postln;
)

// Stop
// ~pad.free; ~loopRoutine.stop; ~kickRoutine.stop; ~chordRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: AQUATIC DRIFT
// Slow, underwater movement
// --------------------------------------------------
(
// Layered pads
~pad1 = Synth(\aquaticPad, [\freq, 55, \amp, 0.08, \depth, 0.7, \dur, 120]);
~pad2 = Synth(\aquaticPad, [\freq, 82.4, \amp, 0.06, \depth, 0.65, \dur, 120]);

// Very sparse elements
~chordRoutine = Routine({
	var notes = [110, 130.8, 164.8];
	inf.do {
		Synth(\deepChord, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.12),
			\dur, rrand(5, 15),
			\spread, rrand(0.005, 0.02)
		]);
		rrand(10, 25).wait;
	};
}).play;

// Rare loops
~loopRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\loopFragment, [
				\freq, rrand(150, 400),
				\amp, rrand(0.04, 0.08),
				\loopTime, rrand(0.2, 0.5),
				\decay, rrand(6, 15)
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

"AQUATIC DRIFT - Submerged motion".postln;
)

// Stop
// ~pad1.free; ~pad2.free; ~chordRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: TAPE LOOP DUB
// Warmer, more rhythmic
// --------------------------------------------------
(
var tempo = 0.5;

~pad = Synth(\aquaticPad, [\freq, 55, \amp, 0.06, \depth, 0.5, \dur, 120]);

// Rhythmic kicks
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\dubbedKick, [
				\amp, rrand(0.4, 0.55),
				\decay, rrand(0.4, 0.6)
			]);
		};
		i = i + 1;
		(tempo / 2).wait;
	};
}).play;

// Regular chord stabs
~chordRoutine = Routine({
	var notes = [82.4, 110, 130.8];
	var i = 0;
	inf.do {
		if ((i % 8) == 0 || (i % 8) == 5) {
			Synth(\deepChord, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(2, 4)
			]);
		};
		i = i + 1;
		(tempo / 2).wait;
	};
}).play;

// Loop texture
~loopRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\loopFragment, [
				\freq, rrand(200, 500),
				\amp, rrand(0.05, 0.1),
				\loopTime, tempo * [0.25, 0.5, 0.75, 1].choose,
				\decay, rrand(3, 6)
			]);
		};
		(tempo * rrand(4, 12)).wait;
	};
}).play;

"TAPE LOOP DUB - Warm and rhythmic".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~chordRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: DEEP SEA ECHOES
// Maximum depth, minimal elements
// --------------------------------------------------
(
~pad = Synth(\aquaticPad, [\freq, 36.7, \amp, 0.1, \depth, 0.85, \dur, 180]);

// Very rare, deep kicks
~kickRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\dubbedKick, [
				\amp, rrand(0.3, 0.45),
				\freq, [40, 45, 50].choose,
				\decay, rrand(0.6, 1.0)
			]);
		};
		rrand(3, 10).wait;
	};
}).play;

// Long decaying loops
~loopRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\loopFragment, [
				\freq, rrand(80, 200),
				\amp, rrand(0.04, 0.08),
				\loopTime, rrand(0.5, 1.5),
				\decay, rrand(10, 25)
			]);
		};
		rrand(20, 60).wait;
	};
}).play;

"DEEP SEA ECHOES - Abyssal zone".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: SURFACE REFLECTIONS
// Brighter, more active
// --------------------------------------------------
(
~pad = Synth(\aquaticPad, [\freq, 110, \amp, 0.08, \depth, 0.3, \dur, 120]);

// More active loops
~loopRoutine = Routine({
	var freqs = [220, 293.7, 329.6, 392, 440];
	inf.do {
		Synth(\loopFragment, [
			\freq, freqs.choose,
			\amp, rrand(0.06, 0.12),
			\loopTime, rrand(0.1, 0.3),
			\decay, rrand(2, 5)
		]);
		rrand(1, 4).wait;
	};
}).play;

// Brighter chords
~chordRoutine = Routine({
	var notes = [164.8, 196, 220, 261.6];
	inf.do {
		if (0.4.coin) {
			Synth(\deepChord, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\dur, rrand(2, 5),
				\spread, 0.015
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

// Light kick
~kickRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\dubbedKick, [
				\amp, rrand(0.3, 0.4),
				\freq, 55,
				\decay, 0.35
			]);
		};
		rrand(0.75, 2).wait;
	};
}).play;

"SURFACE REFLECTIONS - Sunlit waters".postln;
)

// Stop
// ~pad.free; ~loopRoutine.stop; ~chordRoutine.stop; ~kickRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
