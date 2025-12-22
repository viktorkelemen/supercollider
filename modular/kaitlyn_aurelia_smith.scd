// ============================================================
// KAITLYN AURELIA SMITH STYLE - Organic modular textures
// ============================================================
// Inspired by "EARS" and Buchla explorations:
// - Organic, breathing modulations
// - Complex FM and waveshaping
// - Vocal-like formant synthesis
// - Nature-inspired timbres
// - Interconnected modulation sources

// --------------------------------------------------
// BREATHING VOICE - Vocal-like synthesis
// --------------------------------------------------
(
SynthDef(\breathingVoice, {
	arg out = 0, amp = 0.2, freq = 220, breathRate = 0.3,
		formant1 = 800, formant2 = 1200, formant3 = 2600;
	var sig, breath, formants, env;

	// Breathing modulation
	breath = SinOsc.kr(breathRate).range(0.6, 1);
	breath = breath * LFNoise2.kr(0.1).range(0.9, 1.1);

	// Source - rich harmonic content
	sig = Pulse.ar(freq, LFNoise2.kr(0.2).range(0.3, 0.7)) * 0.3;
	sig = sig + (Saw.ar(freq * 1.001) * 0.3);
	sig = sig + (Saw.ar(freq * 0.999) * 0.3);
	sig = sig + (SinOsc.ar(freq) * 0.2);

	// Formant filters - vowel-like
	formants = BPF.ar(sig, formant1 * LFNoise2.kr(0.1).range(0.95, 1.05), 0.1) * 0.5;
	formants = formants + BPF.ar(sig, formant2 * LFNoise2.kr(0.08).range(0.95, 1.05), 0.1) * 0.4;
	formants = formants + BPF.ar(sig, formant3 * LFNoise2.kr(0.05).range(0.95, 1.05), 0.15) * 0.3;

	sig = (sig * 0.3) + (formants * 0.7);

	// Apply breathing
	sig = sig * breath;

	sig = LPF.ar(sig, 5000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// ORGANIC PLUCK - Natural attack, decay
// --------------------------------------------------
(
SynthDef(\organicPluck, {
	arg out = 0, amp = 0.3, freq = 440, decay = 2, brightness = 0.5;
	var sig, env, fenv, noise;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.001, decay * 0.3, 1, -6));

	// Karplus-Strong-ish
	noise = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(noise, 0.2, 1/freq, decay * 2);

	// Add harmonics
	sig = sig + (SinOsc.ar(freq) * env * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * env * fenv * 0.2);

	// Brightness filter
	sig = LPF.ar(sig, freq * (2 + (brightness * 10)) * (1 + fenv));

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.3).range(-0.3, 0.3)));
}).add;
)

// --------------------------------------------------
// FM TEXTURE - Complex FM synthesis
// --------------------------------------------------
(
SynthDef(\fmTexture, {
	arg out = 0, amp = 0.15, freq = 110, modRatio = 2, modIndex = 3, dur = 4;
	var sig, mod, env, indexEnv;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1, 1, \sin), doneAction: 2);
	indexEnv = EnvGen.kr(Env.perc(0.1, dur * 0.8, 1, -2));

	// Modulator with evolving index
	mod = SinOsc.ar(freq * modRatio) * (modIndex * indexEnv * freq);

	// Carrier with FM
	sig = SinOsc.ar(freq + mod);
	sig = sig + (SinOsc.ar(freq * 2 + (mod * 0.5)) * 0.3);

	// Additional texture
	sig = sig + (SinOsc.ar(freq * 0.5 + (mod * 0.25)) * 0.2);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// NATURE WASH - Evolving textural pad
// --------------------------------------------------
(
SynthDef(\natureWash, {
	arg out = 0, amp = 0.12, freq = 110, spread = 0.02;
	var sig, voices;

	// Multiple detuned voices
	voices = Mix.fill(6, { |i|
		var detune = LFNoise2.kr(0.05 + (i * 0.01)).range(1 - spread, 1 + spread);
		var vibrato = SinOsc.kr(0.1 + (i * 0.03)).range(0.998, 1.002);
		var voice;

		voice = SinOsc.ar(freq * detune * vibrato * [1, 2, 3, 4][i % 4]);
		voice = voice * LFNoise2.kr(0.08).range(0.4, 1);
		voice * (1 / (i + 1).sqrt);
	});

	sig = voices;

	// Slow filter sweep
	sig = LPF.ar(sig, LFNoise2.kr(0.03).range(500, 3000));

	// Subtle chorus
	sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr(0.5).range(0.01, 0.03)) * 0.3;

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: ORGANIC MELODY
// Breathing, vocal-like phrases
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11, 12];  // Major scale
~root = 220;

~voice = Synth(\breathingVoice, [
	\freq, ~root,
	\amp, 0.18,
	\breathRate, 0.25
]);

~wash = Synth(\natureWash, [\freq, ~root / 4, \amp, 0.08]);

~melodyRoutine = Routine({
	var degrees = [0, 0, 2, 4, 5, 4, 2, 0, 4, 7, 5, 4];
	var durations = [0.5, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.5, 0.5, 0.25, 0.25];
	var i = 0;

	inf.do {
		var degree = degrees[i % degrees.size];
		var dur = durations[i % durations.size];
		var freq = ~root * (2 ** (~scale[degree % ~scale.size] / 12));

		~voice.set(\freq, freq);

		// Occasional formant shift
		if (0.2.coin) {
			~voice.set(
				\formant1, rrand(600, 1000),
				\formant2, rrand(1000, 1600),
				\formant3, rrand(2200, 3000)
			);
		};

		i = i + 1;
		dur.wait;
	};
}).play;

"ORGANIC MELODY - Vocal phrases".postln;
)

// Stop
// ~melodyRoutine.stop; ~voice.free; ~wash.free;

// --------------------------------------------------
// EXPERIMENT 2: PLUCK GARDEN
// Overlapping organic plucks
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];  // Pentatonic
~root = 330;

~wash = Synth(\natureWash, [\freq, ~root / 4, \amp, 0.06]);

~pluckRoutine = Routine({
	inf.do {
		var degree = ~scale.choose;
		var octave = [0.5, 1, 2].wchoose([0.2, 0.5, 0.3]);
		var freq = ~root * octave * (2 ** (degree / 12));

		Synth(\organicPluck, [
			\freq, freq,
			\amp, rrand(0.12, 0.25),
			\decay, rrand(1, 4),
			\brightness, rrand(0.3, 0.8)
		]);

		rrand(0.15, 0.6).wait;
	};
}).play;

"PLUCK GARDEN - Natural resonances".postln;
)

// Stop
// ~pluckRoutine.stop; ~wash.free;

// --------------------------------------------------
// EXPERIMENT 3: FM EVOLUTION
// Slowly evolving FM textures
// --------------------------------------------------
(
~root = 55;

~fmRoutine = Routine({
	inf.do {
		var freq = ~root * [1, 1.5, 2, 3, 4].choose;
		var ratio = [1, 1.5, 2, 2.5, 3, 4, 5].choose;
		var index = rrand(1, 8);

		Synth(\fmTexture, [
			\freq, freq,
			\modRatio, ratio,
			\modIndex, index,
			\amp, rrand(0.08, 0.15),
			\dur, rrand(4, 12)
		]);

		rrand(3, 8).wait;
	};
}).play;

// Background wash
~wash = Synth(\natureWash, [\freq, ~root, \amp, 0.05]);

"FM EVOLUTION - Textural metamorphosis".postln;
)

// Stop
// ~fmRoutine.stop; ~wash.free;

// --------------------------------------------------
// EXPERIMENT 4: BREATHING FOREST
// Multiple breathing voices in harmony
// --------------------------------------------------
(
~root = 110;
~voices = [];

// Create choir of breathing voices
~voices = ~voices.add(Synth(\breathingVoice, [
	\freq, ~root,
	\amp, 0.12,
	\breathRate, 0.2,
	\formant1, 700, \formant2, 1100, \formant3, 2500
]));

~voices = ~voices.add(Synth(\breathingVoice, [
	\freq, ~root * 1.5,
	\amp, 0.1,
	\breathRate, 0.23,
	\formant1, 800, \formant2, 1300, \formant3, 2700
]));

~voices = ~voices.add(Synth(\breathingVoice, [
	\freq, ~root * 2,
	\amp, 0.08,
	\breathRate, 0.27,
	\formant1, 900, \formant2, 1400, \formant3, 2900
]));

// Slow harmonic shifts
~harmonyRoutine = Routine({
	var chords = [
		[1, 1.5, 2],     // Root position
		[1, 1.25, 1.5],  // Cluster
		[1, 1.33, 2],    // Fourth
		[0.75, 1, 1.5]   // Inversion
	];

	inf.do {
		var chord = chords.choose;
		~voices.do({ |voice, i|
			voice.set(\freq, ~root * chord[i]);
		});
		rrand(4, 10).wait;
	};
}).play;

"BREATHING FOREST - Harmonic respiration".postln;
)

// Stop
// ~harmonyRoutine.stop; ~voices.do(_.free);

// --------------------------------------------------
// EXPERIMENT 5: INTERCONNECTED SYSTEM
// All elements working together
// --------------------------------------------------
(
~root = 110;

// Base wash
~wash = Synth(\natureWash, [\freq, ~root / 2, \amp, 0.05]);

// Main voice
~voice = Synth(\breathingVoice, [
	\freq, ~root,
	\amp, 0.12,
	\breathRate, 0.22
]);

// Melody routine
~melodyRoutine = Routine({
	var scale = [0, 2, 4, 5, 7, 9, 11];
	inf.do {
		var degree = scale.choose;
		var freq = ~root * (2 ** (degree / 12));
		~voice.set(\freq, freq);
		rrand(0.3, 1.0).wait;
	};
}).play;

// Pluck accents
~pluckRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			var degree = [0, 4, 7, 12].choose;
			var freq = ~root * (2 ** (degree / 12));
			Synth(\organicPluck, [
				\freq, freq,
				\amp, rrand(0.1, 0.2),
				\decay, rrand(1.5, 3)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// FM textures - rare
~fmRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\fmTexture, [
				\freq, ~root * [0.5, 1, 2].choose,
				\modRatio, rrand(1.5, 4),
				\modIndex, rrand(2, 6),
				\amp, rrand(0.05, 0.1),
				\dur, rrand(5, 12)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

"INTERCONNECTED SYSTEM - Organic ecosystem".postln;
)

// Stop
// ~melodyRoutine.stop; ~pluckRoutine.stop; ~fmRoutine.stop;
// ~voice.free; ~wash.free;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
