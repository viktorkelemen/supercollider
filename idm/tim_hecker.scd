// ============================================================
// TIM HECKER STYLE - Dense harmonic clouds, distortion as texture
// ============================================================
// Inspired by "Ravedeath 1972", "Virgins", "Konoyo":
// - Organ/pipe textures
// - Extreme harmonic density
// - Distortion and saturation as compositional element
// - Cathedral acoustics
// - Overwhelming yet controlled chaos

// --------------------------------------------------
// ORGAN CLUSTER - Dense organ-like harmonics
// --------------------------------------------------
SynthDef(\organCluster, {
	arg out = 0, amp = 0.15, freq = 110, spread = 10, dur = 8;
	var sig, env;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);

	// Organ-like additive synthesis
	sig = Mix.fill(12, { |i|
		var harmonic = i + 1;
		var detune = LFNoise1.kr(0.1).range(1 - (spread/1000), 1 + (spread/1000));
		var level = 1 / harmonic.sqrt;
		SinOsc.ar(freq * harmonic * detune) * level
	}) / 4;

	// Warm saturation
	sig = (sig * 2).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DISTORTED WASH - Heavy distortion texture
// --------------------------------------------------
SynthDef(\distortedWash, {
	arg out = 0, amp = 0.12, freq = 220, drive = 4, dur = 5;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);

	// Base tones
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (Saw.ar(freq * 0.5) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);

	// Heavy distortion
	sig = (sig * drive).tanh;
	sig = (sig * drive * 0.5).fold(-1, 1);
	sig = (sig + (sig * drive * 0.3).clip(-1, 1)) / 2;

	sig = LPF.ar(sig, 4000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CATHEDRAL REVERB - Long decay space
// --------------------------------------------------
SynthDef(\cathedralVerb, {
	arg out = 0, amp = 0.1, freq = 330, dur = 10;
	var sig, env, verb;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);
	sig = sig + (SinOsc.ar(freq * 3) * 0.15);

	// Dense reverb
	verb = Mix.fill(8, { |i|
		var delay = 0.05 + (i * 0.03);
		CombL.ar(sig, 0.5, delay, 5 + (i * 0.5))
	}) / 8;

	sig = sig * 0.3 + (verb * 0.7);
	sig = FreeVerb.ar(sig, 0.95, 0.98, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HARMONIC SWARM - Buzzing harmonic mass
// --------------------------------------------------
SynthDef(\harmonicSwarm, {
	arg out = 0, amp = 0.1, freq = 110, numVoices = 16, spread = 30;
	var sig;

	sig = Mix.fill(numVoices, { |i|
		var detune = LFNoise1.kr(rrand(0.1, 0.5)).range(1 - (spread/500), 1 + (spread/500));
		var phase = Rand(0, 2pi);
		SinOsc.ar(freq * detune, phase) / numVoices
	});

	// Slight saturation
	sig = (sig * 1.5).tanh;

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// NOISE BURST - Saturated noise element
// --------------------------------------------------
SynthDef(\noiseBurst, {
	arg out = 0, amp = 0.1, freq = 1000, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

	sig = BPF.ar(WhiteNoise.ar, freq, 0.3);
	sig = sig + BPF.ar(PinkNoise.ar, freq * 0.5, 0.5) * 0.5;

	// Saturation
	sig = (sig * 3).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// PIPE ORGAN - Simulated pipe resonance
// --------------------------------------------------
SynthDef(\pipeOrgan, {
	arg out = 0, amp = 0.12, freq = 65.4, dur = 6;
	var sig, env, air;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);

	// Pipe harmonics
	sig = Mix.fill(8, { |i|
		var harmonic = [1, 2, 3, 4, 5, 6, 8, 10][i];
		var level = [1, 0.8, 0.6, 0.5, 0.3, 0.2, 0.15, 0.1][i];
		SinOsc.ar(freq * harmonic) * level
	}) / 3;

	// Air noise component
	air = BPF.ar(PinkNoise.ar, freq * 4, 0.5) * 0.05;
	sig = sig + air;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// CRUSHING TEXTURE - Extreme bit reduction feel
// --------------------------------------------------
SynthDef(\crushingTexture, {
	arg out = 0, amp = 0.1, freq = 200, crush = 8, dur = 4;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	// Bit crushing simulation
	sig = (sig * crush).round / crush;
	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Tim Hecker SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: RAVEDEATH
// Overwhelming organ density
// --------------------------------------------------
(
// Organ cluster layers
~organRoutine = Routine({
	var freqs = [55, 65.4, 82.4, 110, 130.8].midicps;
	inf.do {
		Synth(\organCluster, [
			\freq, freqs.choose,
			\amp, rrand(0.1, 0.18),
			\spread, rrand(5, 20),
			\dur, rrand(8, 15)
		]);
		rrand(4, 10).wait;
	};
}).play;

// Harmonic swarm
~swarm = Synth(\harmonicSwarm, [\freq, 110, \amp, 0.08, \spread, 25]);

// Distorted washes
~distortionRoutine = Routine({
	var freqs = [110, 165, 220].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\distortedWash, [
				\freq, freqs.choose,
				\amp, rrand(0.08, 0.14),
				\drive, rrand(3, 6),
				\dur, rrand(4, 8)
			]);
		};
		rrand(5, 12).wait;
	};
}).play;

"RAVEDEATH - Organ density".postln;
)

// Stop
// ~organRoutine.stop; ~swarm.free; ~distortionRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: VIRGINS
// Sparse but massive
// --------------------------------------------------
(
// Single massive organ
~organRoutine = Routine({
	var freqs = [55, 82.4, 110];
	inf.do {
		Synth(\organCluster, [
			\freq, freqs.choose,
			\amp, rrand(0.12, 0.2),
			\spread, rrand(8, 15),
			\dur, rrand(12, 25)
		]);
		rrand(15, 30).wait;
	};
}).play;

// Cathedral reverb hits
~cathedralRoutine = Routine({
	var freqs = [220, 330, 440, 550].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\cathedralVerb, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(8, 15)
			]);
		};
		rrand(10, 25).wait;
	};
}).play;

// Rare noise bursts
~noiseRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\noiseBurst, [
				\freq, rrand(500, 2000),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.5, 1.5)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

"VIRGINS - Sparse massive".postln;
)

// Stop
// ~organRoutine.stop; ~cathedralRoutine.stop; ~noiseRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: KONOYO
// Gagaku-inspired textures
// --------------------------------------------------
(
// Pipe organ voices (sho-like)
~pipeRoutine = Routine({
	var freqs = [65.4, 73.4, 82.4, 98, 110, 123.5].midicps;
	inf.do {
		Synth(\pipeOrgan, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(5, 10)
		]);
		rrand(2, 5).wait;
	};
}).play;

// Dense harmony
~harmonyRoutine = Routine({
	var chords = [
		[65.4, 82.4, 98],
		[73.4, 98, 123.5],
		[82.4, 110, 130.8]
	];
	inf.do {
		var chord = chords.choose;
		chord.do { |freq|
			Synth(\organCluster, [
				\freq, freq,
				\amp, rrand(0.06, 0.1),
				\spread, rrand(3, 8),
				\dur, rrand(8, 15)
			]);
		};
		rrand(10, 20).wait;
	};
}).play;

"KONOYO - Gagaku textures".postln;
)

// Stop
// ~pipeRoutine.stop; ~harmonyRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: HARMONY IN ULTRAVIOLET
// Bright crushing distortion
// --------------------------------------------------
(
// High frequency clusters
~highCluster = Routine({
	var freqs = [440, 550, 660, 880, 1100].midicps;
	inf.do {
		Synth(\organCluster, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.14),
			\spread, rrand(15, 30),
			\dur, rrand(5, 10)
		]);
		rrand(3, 7).wait;
	};
}).play;

// Crushing textures
~crushRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\crushingTexture, [
				\freq, rrand(200, 500),
				\amp, rrand(0.08, 0.12),
				\crush, rrand(4, 12),
				\dur, rrand(3, 6)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Distortion layer
~distortRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\distortedWash, [
				\freq, rrand(300, 800),
				\amp, rrand(0.08, 0.14),
				\drive, rrand(4, 8),
				\dur, rrand(3, 6)
			]);
		};
		rrand(5, 12).wait;
	};
}).play;

"HARMONY IN ULTRAVIOLET - Bright crushing".postln;
)

// Stop
// ~highCluster.stop; ~crushRoutine.stop; ~distortRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: HATRED OF MUSIC
// Minimal, dark
// --------------------------------------------------
(
// Single low organ
~lowOrgan = Synth(\organCluster, [\freq, 55, \amp, 0.12, \spread, 5, \dur, 1000]);

// Rare cathedral hits
~cathedralRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\cathedralVerb, [
				\freq, [110, 165, 220].choose,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(10, 20)
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

// Sparse distortion
~sparseDistort = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\distortedWash, [
				\freq, [55, 82.4, 110].choose,
				\amp, rrand(0.08, 0.12),
				\drive, rrand(2, 4),
				\dur, rrand(5, 10)
			]);
		};
		rrand(20, 45).wait;
	};
}).play;

"HATRED OF MUSIC - Minimal dark".postln;
)

// Stop
// ~lowOrgan.free; ~cathedralRoutine.stop; ~sparseDistort.stop;

// --------------------------------------------------
// EXPERIMENT 6: MUSIC FOR TUNDRA
// Cold, crystalline
// --------------------------------------------------
(
// High swarm
~highSwarm = Synth(\harmonicSwarm, [\freq, 880, \amp, 0.06, \numVoices, 12, \spread, 20]);

// Crystalline clusters
~crystalRoutine = Routine({
	var freqs = [880, 1100, 1320, 1760].midicps;
	inf.do {
		Synth(\organCluster, [
			\freq, freqs.choose,
			\amp, rrand(0.05, 0.09),
			\spread, rrand(10, 25),
			\dur, rrand(4, 8)
		]);
		rrand(3, 7).wait;
	};
}).play;

// Low anchor
~lowAnchor = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\pipeOrgan, [
				\freq, [55, 82.4].choose,
				\amp, rrand(0.1, 0.15),
				\dur, rrand(8, 15)
			]);
		};
		rrand(12, 25).wait;
	};
}).play;

"MUSIC FOR TUNDRA - Cold crystalline".postln;
)

// Stop
// ~highSwarm.free; ~crystalRoutine.stop; ~lowAnchor.stop;

// --------------------------------------------------
// EXPERIMENT 7: DROPPED PIANOS
// Acoustic destruction
// --------------------------------------------------
(
// Crushed piano-like
~pianoRoutine = Routine({
	var freqs = [65.4, 73.4, 82.4, 87.3, 98, 110, 123.5].midicps;
	inf.do {
		// Chord clusters
		rrand(2, 4).do {
			Synth(\crushingTexture, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.1),
				\crush, rrand(6, 12),
				\dur, rrand(2, 5)
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

// Distorted resonance
~resonanceRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\distortedWash, [
				\freq, rrand(80, 200),
				\amp, rrand(0.08, 0.14),
				\drive, rrand(3, 5),
				\dur, rrand(4, 8)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

// Cathedral space
~spaceRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\cathedralVerb, [
				\freq, rrand(150, 400),
				\amp, rrand(0.04, 0.07),
				\dur, rrand(8, 15)
			]);
		};
		rrand(10, 20).wait;
	};
}).play;

"DROPPED PIANOS - Acoustic destruction".postln;
)

// Stop
// ~pianoRoutine.stop; ~resonanceRoutine.stop; ~spaceRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
