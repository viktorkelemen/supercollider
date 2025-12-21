// ============================================================
// AUTECHRE STYLE - Generative systems, complex rhythms
// ============================================================
// Inspired by "Confield", "Elseq":
// - Algorithmic, self-modifying patterns
// - Non-repetitive structures
// - Complex, shifting time signatures
// - Granular-like textures
// - Abstract, machine-like timbres

// --------------------------------------------------
// FRACTAL RHYTHM - Self-similar pattern generator
// --------------------------------------------------
(
SynthDef(\fractalHit, {
	arg out = 0, amp = 0.2, freq = 200, decay = 0.1, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);

	// Metallic, abstract timbre
	sig = Ringz.ar(Impulse.ar(0), freq, decay) * 0.5;
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.3);
	sig = sig + (Pulse.ar(freq, Rand(0.2, 0.8)) * 0.2);

	sig = HPF.ar(sig, 80);
	sig = LPF.ar(sig, freq * 5);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// GLITCH GRAIN - Micro-sound element
// --------------------------------------------------
(
SynthDef(\glitchGrain, {
	arg out = 0, amp = 0.15, freq = 1000, dur = 0.02, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (Pulse.ar(freq * Rand(0.5, 2), Rand(0.1, 0.9)) * 0.3);
	sig = sig + (WhiteNoise.ar * 0.2);

	sig = HPF.ar(sig, 200);
	sig = LPF.ar(sig, freq * 3);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// ALGORITHMIC BASS - Shifting, unstable
// --------------------------------------------------
(
SynthDef(\algoBass, {
	arg out = 0, amp = 0.35, freq = 55, dur = 0.3, glide = 0.02;
	var sig, env, fenv, mod;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.01, dur * 0.3, 1, -6));

	freq = Lag.kr(freq, glide);

	// Unstable modulation
	mod = LFNoise2.kr(10).range(0.98, 1.02);

	sig = SinOsc.ar(freq * mod) * 0.5;
	sig = sig + (LFTri.ar(freq * 0.5 * mod) * 0.3);
	sig = sig + (Pulse.ar(freq * mod, 0.3) * 0.2 * fenv);

	sig = LPF.ar(sig, freq * (2 + (fenv * 4)));
	sig = (sig * 1.3).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// TEXTURE SWARM - Complex evolving texture
// --------------------------------------------------
(
SynthDef(\textureSwarm, {
	arg out = 0, amp = 0.1, centerFreq = 500, spread = 200, density = 20;
	var sig, freqs;

	// Swarm of sine tones
	sig = Mix.fill(12, { |i|
		var freq = centerFreq + (LFNoise2.kr(0.1 + (i * 0.05)) * spread);
		var localAmp = LFNoise2.kr(0.2 + (i * 0.03)).range(0.2, 1);
		SinOsc.ar(freq) * localAmp;
	}) / 12;

	// Add grain layer
	sig = sig + (Dust.ar(density) * 0.1);
	sig = sig + (Crackle.ar(1.5) * 0.05);

	sig = LPF.ar(sig, centerFreq * 3);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: CONFIELD RHYTHMS
// Complex, shifting patterns
// --------------------------------------------------
(
~patterns = [
	[1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0],
	[1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0],
	[0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0],
	[1, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0]
];

~currentPattern = 0;
~step = 0;
~tempo = 0.08;  // Fast

~swarm = Synth(\textureSwarm, [\centerFreq, 400, \amp, 0.05, \density, 15]);

// Main rhythm
~rhythmRoutine = Routine({
	inf.do { |i|
		var pattern = ~patterns[~currentPattern];
		var hit = pattern[~step % pattern.size];

		if (hit == 1) {
			// Vary the hit
			Synth(\fractalHit, [
				\freq, [100, 150, 200, 300, 400].choose,
				\amp, rrand(0.1, 0.25),
				\decay, rrand(0.05, 0.2),
				\pan, rrand(-0.6, 0.6)
			]);
		};

		// Occasional pattern shift
		if ((i % 32 == 0) && (0.4.coin)) {
			~currentPattern = (~currentPattern + 1) % ~patterns.size;
			~tempo = rrand(0.06, 0.12);  // Tempo also shifts
			"Pattern: %, Tempo: %".format(~currentPattern, ~tempo.round(0.001)).postln;
		};

		~step = ~step + 1;
		~tempo.wait;
	};
}).play;

// Glitch layer
~glitchRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\glitchGrain, [
				\freq, rrand(500, 4000),
				\amp, rrand(0.05, 0.12),
				\dur, rrand(0.01, 0.08),
				\pan, rrand(-0.8, 0.8)
			]);
		};
		rrand(0.02, 0.15).wait;
	};
}).play;

// Bass events
~bassRoutine = Routine({
	var notes = [55, 61.7, 73.4, 82.4];
	inf.do {
		if (0.25.coin) {
			Synth(\algoBass, [
				\freq, notes.choose,
				\amp, rrand(0.2, 0.35),
				\dur, rrand(0.1, 0.4)
			]);
		};
		rrand(0.3, 1.5).wait;
	};
}).play;

"CONFIELD RHYTHMS - Shifting complexity".postln;
)

// Stop
// ~swarm.free; ~rhythmRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: ELSEQ TEXTURES
// More ambient, textural
// --------------------------------------------------
(
~swarm = Synth(\textureSwarm, [\centerFreq, 600, \amp, 0.08, \density, 25, \spread, 400]);

// Sparse rhythmic elements
~rhythmRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\fractalHit, [
				\freq, rrand(150, 600),
				\amp, rrand(0.08, 0.18),
				\decay, rrand(0.08, 0.3),
				\pan, rrand(-0.7, 0.7)
			]);
		};
		rrand(0.1, 0.8).wait;
	};
}).play;

// Dense glitch layer
~glitchRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			3.do {
				Synth(\glitchGrain, [
					\freq, rrand(800, 6000),
					\amp, rrand(0.03, 0.08),
					\dur, rrand(0.005, 0.03),
					\pan, rrand(-0.9, 0.9)
				]);
				rrand(0.01, 0.05).wait;
			};
		};
		rrand(0.2, 1.0).wait;
	};
}).play;

// Very sparse bass
~bassRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\algoBass, [
				\freq, rrand(40, 80),
				\amp, rrand(0.2, 0.35),
				\dur, rrand(0.2, 0.6)
			]);
		};
		rrand(1, 5).wait;
	};
}).play;

"ELSEQ TEXTURES - Granular complexity".postln;
)

// Stop
// ~swarm.free; ~rhythmRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: GENERATIVE MACHINE
// Self-modifying system
// --------------------------------------------------
(
~params = (
	tempo: 0.1,
	density: 0.4,
	freqRange: [100, 500],
	ampRange: [0.1, 0.2]
);

~swarm = Synth(\textureSwarm, [\centerFreq, 350, \amp, 0.04]);

// Main routine with parameter evolution
~mainRoutine = Routine({
	inf.do { |i|
		// Generate hit based on current params
		if (rrand(0, 1) < ~params.density) {
			Synth(\fractalHit, [
				\freq, rrand(~params.freqRange[0], ~params.freqRange[1]),
				\amp, rrand(~params.ampRange[0], ~params.ampRange[1]),
				\decay, rrand(0.05, 0.25),
				\pan, rrand(-0.6, 0.6)
			]);
		};

		// Evolve parameters every so often
		if (i % 16 == 0) {
			~params.tempo = rrand(0.05, 0.15);
			~params.density = rrand(0.2, 0.7);
			~params.freqRange = [rrand(80, 200), rrand(300, 800)];
			~params.ampRange = [rrand(0.05, 0.12), rrand(0.15, 0.25)];

			// Update swarm
			~swarm.set(\centerFreq, rrand(200, 800));
		};

		~params.tempo.wait;
	};
}).play;

// Glitch accents
~glitchRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			rrand(1, 5).do {
				Synth(\glitchGrain, [
					\freq, rrand(500, 8000),
					\amp, rrand(0.04, 0.1),
					\dur, rrand(0.005, 0.04),
					\pan, rrand(-0.9, 0.9)
				]);
				rrand(0.01, 0.04).wait;
			};
		};
		rrand(0.2, 1.5).wait;
	};
}).play;

// Bass events
~bassRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\algoBass, [
				\freq, [36.7, 41.2, 49, 55, 61.7].choose,
				\amp, rrand(0.2, 0.35),
				\dur, rrand(0.15, 0.4)
			]);
		};
		rrand(0.5, 2.5).wait;
	};
}).play;

"GENERATIVE MACHINE - Self-modifying patterns".postln;
)

// Stop
// ~swarm.free; ~mainRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: BROKEN BEAT
// Fragmented, unpredictable
// --------------------------------------------------
(
SynthDef(\brokenKick, {
	arg out = 0, amp = 0.45, freq = 50, decay = 0.15;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);
	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.03)).range(1, 1.8));
	sig = (sig * 1.5).tanh;
	sig = LPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

~swarm = Synth(\textureSwarm, [\centerFreq, 300, \amp, 0.03, \density, 10]);

// Unpredictable kick pattern
~kickRoutine = Routine({
	inf.do {
		if (rrand(0, 1) < 0.4) {
			Synth(\brokenKick, [
				\amp, rrand(0.35, 0.5),
				\decay, rrand(0.1, 0.25)
			]);
		};
		[0.1, 0.1, 0.15, 0.2, 0.25, 0.1, 0.15].choose.wait;
	};
}).play;

// Metallic hits
~hitRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\fractalHit, [
				\freq, rrand(150, 400),
				\amp, rrand(0.1, 0.2),
				\decay, rrand(0.08, 0.2),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		[0.1, 0.15, 0.1, 0.2, 0.1, 0.25].choose.wait;
	};
}).play;

// Bass
~bassRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\algoBass, [
				\freq, [41.2, 49, 55, 61.7].choose,
				\amp, rrand(0.25, 0.4),
				\dur, rrand(0.1, 0.3)
			]);
		};
		rrand(0.2, 0.8).wait;
	};
}).play;

// Glitch spray
~glitchRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			rrand(2, 8).do {
				Synth(\glitchGrain, [
					\freq, rrand(1000, 5000),
					\amp, rrand(0.03, 0.08),
					\dur, rrand(0.005, 0.02),
					\pan, rrand(-0.9, 0.9)
				]);
				rrand(0.01, 0.03).wait;
			};
		};
		rrand(0.3, 1.2).wait;
	};
}).play;

"BROKEN BEAT - Fractured rhythms".postln;
)

// Stop
// ~swarm.free; ~kickRoutine.stop; ~hitRoutine.stop; ~bassRoutine.stop; ~glitchRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: AMBIENT ALGORITHM
// Slow, contemplative version
// --------------------------------------------------
(
~swarm = Synth(\textureSwarm, [\centerFreq, 500, \amp, 0.08, \density, 30, \spread, 300]);

// Very sparse events
~eventRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\fractalHit, [
				\freq, rrand(100, 400),
				\amp, rrand(0.06, 0.14),
				\decay, rrand(0.2, 0.8),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(0.5, 3).wait;
	};
}).play;

// Soft glitches
~glitchRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\glitchGrain, [
				\freq, rrand(400, 2000),
				\amp, rrand(0.02, 0.06),
				\dur, rrand(0.02, 0.1),
				\pan, rrand(-0.7, 0.7)
			]);
		};
		rrand(0.3, 1.5).wait;
	};
}).play;

// Rare bass tones
~bassRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\algoBass, [
				\freq, rrand(40, 70),
				\amp, rrand(0.15, 0.25),
				\dur, rrand(0.5, 1.5)
			]);
		};
		rrand(3, 10).wait;
	};
}).play;

"AMBIENT ALGORITHM - Slow machine meditation".postln;
)

// Stop
// ~swarm.free; ~eventRoutine.stop; ~glitchRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
