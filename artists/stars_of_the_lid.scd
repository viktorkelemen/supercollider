// ============================================================
// STARS OF THE LID STYLE - Glacial movements, orchestral drone
// ============================================================
// Inspired by "And Their Refinement of the Decline":
// - Extremely slow evolution
// - Orchestral string-like textures
// - Warm, enveloping harmonics
// - Near-static composition
// - Long sustains, subtle shifts

// --------------------------------------------------
// STRING DRONE - Warm, bowed string simulation
// --------------------------------------------------
(
SynthDef(\stringDrone, {
	arg out = 0, amp = 0.15, freq = 110, brightness = 0.4, vibRate = 5;
	var sig, bow, vibrato;

	// Subtle vibrato
	vibrato = SinOsc.kr(vibRate + LFNoise2.kr(0.1).range(-0.5, 0.5)).range(0.998, 1.002);

	// Bowed string simulation - saw wave filtered
	sig = LFSaw.ar(freq * vibrato) * 0.3;
	sig = sig + (LFSaw.ar(freq * 2.01 * vibrato) * 0.15);
	sig = sig + (LFSaw.ar(freq * 3.02 * vibrato) * 0.08);
	sig = sig + (SinOsc.ar(freq * vibrato) * 0.2);  // Add fundamental

	// Formant-like filtering for string character
	sig = BPF.ar(sig, freq * 2, 0.3) * 0.5;
	sig = sig + BPF.ar(sig, freq * 4, 0.2) * 0.3;
	sig = sig + LPF.ar(sig, freq * (3 + (brightness * 8)));

	// Very subtle amplitude variation (bow pressure)
	sig = sig * (1 + (LFNoise2.kr(0.05) * 0.1));

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// HARMONIC PAD - Pure, sustaining harmonics
// --------------------------------------------------
(
SynthDef(\harmonicPad, {
	arg out = 0, amp = 0.1, freq = 55, numPartials = 8;
	var sig;

	sig = Mix.fill(numPartials, { |i|
		var partial = i + 1;
		var detune = LFNoise2.kr(0.01 + (i * 0.005)).range(0.999, 1.001);
		var partialAmp = 1 / partial;

		SinOsc.ar(freq * partial * detune) * partialAmp *
		LFNoise2.kr(0.02 + (i * 0.01)).range(0.7, 1);
	});

	// Gentle low-pass
	sig = LPF.ar(sig, 3000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// GLACIAL SWELL - Extremely slow crescendo/decrescendo
// --------------------------------------------------
(
SynthDef(\glacialSwell, {
	arg out = 0, amp = 0.12, freq = 110, attack = 30, sustain = 60, release = 30;
	var sig, env, voices;

	env = EnvGen.kr(Env.linen(attack, sustain, release, 1, \sin), doneAction: 2);

	// Multiple string-like voices
	voices = Mix.fill(4, { |i|
		var detune = LFNoise2.kr(0.01).range(0.997, 1.003);
		var oct = [0.5, 1, 1, 2][i];
		var voice;

		voice = LFSaw.ar(freq * oct * detune) * 0.2;
		voice = voice + (SinOsc.ar(freq * oct * detune) * 0.15);
		voice = LPF.ar(voice, freq * oct * 4);
		voice * [0.3, 0.4, 0.4, 0.2][i];
	});

	sig = voices;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// BREATH - Subtle textural element
// --------------------------------------------------
(
SynthDef(\sotlBreath, {
	arg out = 0, amp = 0.03;
	var sig;

	// Very quiet, warm noise
	sig = PinkNoise.ar * 0.5;
	sig = sig + (BrownNoise.ar * 0.5);

	sig = LPF.ar(sig, 2000);
	sig = HPF.ar(sig, 100);

	// Slow amplitude variation
	sig = sig * LFNoise2.kr(0.03).range(0.5, 1);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: REFINEMENT
// Classic Stars of the Lid sound
// --------------------------------------------------
(
// Main string drones
~string1 = Synth(\stringDrone, [\freq, 55, \amp, 0.1, \brightness, 0.3]);
~string2 = Synth(\stringDrone, [\freq, 82.4, \amp, 0.08, \brightness, 0.35]);

// Harmonic foundation
~pad = Synth(\harmonicPad, [\freq, 55, \amp, 0.06, \numPartials, 6]);

// Breath texture
~breath = Synth(\sotlBreath, [\amp, 0.02]);

// Very slow swells
~swellRoutine = Routine({
	var notes = [55, 73.4, 82.4, 110];
	inf.do {
		Synth(\glacialSwell, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.12),
			\attack, rrand(20, 40),
			\sustain, rrand(30, 90),
			\release, rrand(20, 40)
		]);
		rrand(60, 180).wait;
	};
}).play;

// Very occasional shifts
~shiftRoutine = Routine({
	var chords = [
		[55, 82.4],
		[55, 73.4],
		[73.4, 110],
		[82.4, 110]
	];
	inf.do {
		var chord = chords.choose;
		~string1.set(\freq, chord[0]);
		~string2.set(\freq, chord[1]);
		~pad.set(\freq, chord[0] / 2);
		rrand(120, 300).wait;
	};
}).play;

"REFINEMENT - Glacial movements".postln;
)

// Stop
// ~string1.free; ~string2.free; ~pad.free; ~breath.free;
// ~swellRoutine.stop; ~shiftRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: DECLINE
// Even slower, more sparse
// --------------------------------------------------
(
// Single quiet drone
~string = Synth(\stringDrone, [\freq, 55, \amp, 0.08, \brightness, 0.25]);

// Deep harmonic pad
~pad = Synth(\harmonicPad, [\freq, 27.5, \amp, 0.05, \numPartials, 4]);

// Very quiet breath
~breath = Synth(\sotlBreath, [\amp, 0.015]);

// Extremely slow swells
~swellRoutine = Routine({
	inf.do {
		Synth(\glacialSwell, [
			\freq, [36.7, 55, 73.4].choose,
			\amp, rrand(0.04, 0.08),
			\attack, rrand(40, 80),
			\sustain, rrand(60, 120),
			\release, rrand(40, 80)
		]);
		rrand(180, 400).wait;
	};
}).play;

"DECLINE - Maximum slowness".postln;
)

// Stop
// ~string.free; ~pad.free; ~breath.free; ~swellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: AVEC LAUDENUM
// Slightly more active
// --------------------------------------------------
(
// Multiple string layers
~strings = [];
~strings = ~strings.add(Synth(\stringDrone, [\freq, 55, \amp, 0.08]));
~strings = ~strings.add(Synth(\stringDrone, [\freq, 73.4, \amp, 0.07]));
~strings = ~strings.add(Synth(\stringDrone, [\freq, 110, \amp, 0.06]));
~strings = ~strings.add(Synth(\stringDrone, [\freq, 146.8, \amp, 0.04]));

~pad = Synth(\harmonicPad, [\freq, 55, \amp, 0.05]);
~breath = Synth(\sotlBreath, [\amp, 0.02]);

// More frequent swells
~swellRoutine = Routine({
	var notes = [55, 73.4, 82.4, 110, 146.8];
	inf.do {
		Synth(\glacialSwell, [
			\freq, notes.choose,
			\amp, rrand(0.05, 0.1),
			\attack, rrand(15, 30),
			\sustain, rrand(20, 50),
			\release, rrand(15, 30)
		]);
		rrand(30, 90).wait;
	};
}).play;

// Chord changes
~chordRoutine = Routine({
	var progressions = [
		[55, 73.4, 110, 146.8],
		[55, 82.4, 110, 164.8],
		[73.4, 110, 146.8, 220],
		[41.2, 82.4, 110, 164.8]
	];
	inf.do {
		var chord = progressions.choose;
		~strings.do({ |synth, i|
			synth.set(\freq, chord[i]);
		});
		~pad.set(\freq, chord[0] / 2);
		rrand(60, 150).wait;
	};
}).play;

"AVEC LAUDENUM - Layered strings".postln;
)

// Stop
// ~strings.do(_.free); ~pad.free; ~breath.free;
// ~swellRoutine.stop; ~chordRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: THE LONELY PEOPLE
// Melancholic, slightly brighter
// --------------------------------------------------
(
~string1 = Synth(\stringDrone, [\freq, 110, \amp, 0.1, \brightness, 0.5]);
~string2 = Synth(\stringDrone, [\freq, 164.8, \amp, 0.07, \brightness, 0.45]);

~pad = Synth(\harmonicPad, [\freq, 55, \amp, 0.04]);
~breath = Synth(\sotlBreath, [\amp, 0.018]);

// Melodic swells
~swellRoutine = Routine({
	var notes = [110, 130.8, 146.8, 164.8, 196, 220];
	inf.do {
		Synth(\glacialSwell, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\attack, rrand(10, 25),
			\sustain, rrand(15, 40),
			\release, rrand(10, 25)
		]);
		rrand(20, 60).wait;
	};
}).play;

"THE LONELY PEOPLE - Melancholic drift".postln;
)

// Stop
// ~string1.free; ~string2.free; ~pad.free; ~breath.free; ~swellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: STATIC
// Near-motionless
// --------------------------------------------------
(
// Single held chord
~strings = [];
~strings = ~strings.add(Synth(\stringDrone, [\freq, 55, \amp, 0.06, \brightness, 0.2]));
~strings = ~strings.add(Synth(\stringDrone, [\freq, 82.4, \amp, 0.05, \brightness, 0.2]));

~pad = Synth(\harmonicPad, [\freq, 55, \amp, 0.04, \numPartials, 4]);
~breath = Synth(\sotlBreath, [\amp, 0.01]);

// Extremely rare swells
~swellRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\glacialSwell, [
				\freq, [55, 82.4].choose,
				\amp, rrand(0.03, 0.06),
				\attack, rrand(60, 120),
				\sustain, rrand(60, 180),
				\release, rrand(60, 120)
			]);
		};
		rrand(300, 600).wait;
	};
}).play;

"STATIC - Near motionless".postln;
)

// Stop
// ~strings.do(_.free); ~pad.free; ~breath.free; ~swellRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
