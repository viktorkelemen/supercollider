// ============================================================
// MIDORI TAKADA STYLE - Percussive minimalism
// ============================================================
// Inspired by "Through the Looking Glass":
// - Marimba and mallet percussion
// - Minimalist phasing patterns
// - Polyrhythmic layering
// - Meditative repetition
// - Organic, acoustic character

// --------------------------------------------------
// MARIMBA - Resonant mallet percussion
// --------------------------------------------------
(
SynthDef(\marimba, {
	arg out = 0, amp = 0.2, freq = 440, decay = 1.5, pan = 0;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -5), doneAction: 2);

	// Fundamental
	sig = SinOsc.ar(freq) * 0.5;

	// Harmonics - marimba-like
	sig = sig + (SinOsc.ar(freq * 4) * 0.2 * EnvGen.kr(Env.perc(0.001, 0.05)));
	sig = sig + (SinOsc.ar(freq * 10) * 0.05 * EnvGen.kr(Env.perc(0.001, 0.02)));

	// Soft mallet click
	click = BPF.ar(PinkNoise.ar, freq * 3, 0.2) * EnvGen.kr(Env.perc(0.001, 0.02));
	sig = sig + (click * 0.15);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// VIBRAPHONE - Sustaining metallic percussion
// --------------------------------------------------
(
SynthDef(\vibraphone, {
	arg out = 0, amp = 0.15, freq = 440, decay = 3, pan = 0, tremRate = 5;
	var sig, env, trem;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);

	// Motor tremolo
	trem = SinOsc.kr(tremRate).range(0.8, 1);

	// Metallic harmonics
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.25);
	sig = sig + (SinOsc.ar(freq * 3) * 0.15);
	sig = sig + (SinOsc.ar(freq * 4) * 0.08);

	sig = sig * trem;
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// GONG - Deep resonant strike
// --------------------------------------------------
(
SynthDef(\gong, {
	arg out = 0, amp = 0.25, freq = 80, decay = 8;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.1, decay, 1, -3), doneAction: 2);

	// Complex inharmonic spectrum
	sig = Mix([
		SinOsc.ar(freq) * 0.4,
		SinOsc.ar(freq * 1.47) * 0.25,
		SinOsc.ar(freq * 2.09) * 0.18,
		SinOsc.ar(freq * 2.56) * 0.12,
		SinOsc.ar(freq * 3.24) * 0.08
	]);

	// Slight modulation
	sig = sig * (1 + (SinOsc.kr(0.5) * 0.05));

	sig = LPF.ar(sig, 2000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// WOOD BLOCK - Short percussive accent
// --------------------------------------------------
(
SynthDef(\woodBlock, {
	arg out = 0, amp = 0.15, freq = 800, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), doneAction: 2);

	sig = Ringz.ar(Impulse.ar(0), freq, 0.03) * 0.5;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 1.6, 0.02) * 0.3);

	sig = HPF.ar(sig, 300);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: THROUGH THE LOOKING GLASS
// Phasing marimba patterns
// --------------------------------------------------
(
// Pentatonic scale
~scale = [0, 2, 4, 7, 9, 12];  // A pentatonic in semitones
~root = 220;

// Pattern 1 - base tempo
~pattern1 = Routine({
	var pattern = [0, 4, 2, 4, 0, 7, 4, 2];
	var tempo = 0.25;
	var i = 0;
	inf.do {
		var degree = pattern[i % pattern.size];
		var freq = ~root * (2 ** (~scale[degree % ~scale.size] / 12));

		Synth(\marimba, [
			\freq, freq,
			\amp, rrand(0.12, 0.18),
			\decay, rrand(0.8, 1.5),
			\pan, -0.3
		]);

		i = i + 1;
		tempo.wait;
	};
}).play;

// Pattern 2 - slightly faster (phasing)
~pattern2 = Routine({
	var pattern = [0, 4, 2, 4, 0, 7, 4, 2];  // Same pattern
	var tempo = 0.248;  // Slightly faster
	var i = 0;
	inf.do {
		var degree = pattern[i % pattern.size];
		var freq = ~root * 2 * (2 ** (~scale[degree % ~scale.size] / 12));

		Synth(\marimba, [
			\freq, freq,
			\amp, rrand(0.1, 0.14),
			\decay, rrand(0.6, 1.2),
			\pan, 0.3
		]);

		i = i + 1;
		tempo.wait;
	};
}).play;

// Occasional gong
~gongRoutine = Routine({
	inf.do {
		Synth(\gong, [
			\freq, ~root / 4,
			\amp, rrand(0.15, 0.22),
			\decay, rrand(6, 12)
		]);
		rrand(20, 40).wait;
	};
}).play;

"THROUGH THE LOOKING GLASS - Phasing marimbas".postln;
)

// Stop
// ~pattern1.stop; ~pattern2.stop; ~gongRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: MR. HENRI ROUSSEAU'S DREAM
// Vibraphone focused
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];  // Major scale
~root = 293.7;  // D

// Vibraphone melody
~vibRoutine = Routine({
	var melody = [0, 2, 4, 7, 4, 2, 5, 4];
	var durations = [0.5, 0.5, 0.25, 0.25, 0.5, 0.25, 0.25, 0.5];
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree] / 12));

		Synth(\vibraphone, [
			\freq, freq,
			\amp, rrand(0.1, 0.15),
			\decay, rrand(2, 4),
			\tremRate, rrand(4, 6)
		]);

		durations[i % durations.size].wait;
		i = i + 1;
	};
}).play;

// Marimba accompaniment
~marRoutine = Routine({
	1.wait;  // Offset
	inf.do {
		if (0.4.coin) {
			var freq = ~root / 2 * (2 ** (~scale.choose / 12));
			Synth(\marimba, [
				\freq, freq,
				\amp, rrand(0.08, 0.12),
				\decay, rrand(1, 2),
				\pan, rrand(-0.4, 0.4)
			]);
		};
		rrand(0.3, 0.8).wait;
	};
}).play;

// Wood block accents
~woodRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\woodBlock, [
				\freq, rrand(600, 1000),
				\amp, rrand(0.06, 0.1),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"MR. HENRI ROUSSEAU'S DREAM - Vibraphone melody".postln;
)

// Stop
// ~vibRoutine.stop; ~marRoutine.stop; ~woodRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: POLYRHYTHM
// Multiple interlocking patterns
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];
~root = 220;
var tempo = 0.2;

// 4-step pattern
~layer1 = Routine({
	var pattern = [0, 2, 4, 2];
	var i = 0;
	inf.do {
		Synth(\marimba, [
			\freq, ~root * (2 ** (~scale[pattern[i % 4]] / 12)),
			\amp, 0.14,
			\pan, -0.5
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// 3-step pattern (3 against 4)
~layer2 = Routine({
	var pattern = [4, 2, 0];
	var i = 0;
	inf.do {
		Synth(\marimba, [
			\freq, ~root * 2 * (2 ** (~scale[pattern[i % 3]] / 12)),
			\amp, 0.1,
			\pan, 0.5
		]);
		i = i + 1;
		(tempo * 4 / 3).wait;
	};
}).play;

// 5-step pattern
~layer3 = Routine({
	var pattern = [0, 4, 2, 4, 0];
	var i = 0;
	inf.do {
		Synth(\vibraphone, [
			\freq, ~root * (2 ** (~scale[pattern[i % 5]] / 12)),
			\amp, 0.08,
			\decay, 2
		]);
		i = i + 1;
		(tempo * 4 / 5).wait;
	};
}).play;

// Gong marker
~gongRoutine = Routine({
	inf.do {
		Synth(\gong, [\freq, ~root / 4, \amp, 0.18]);
		(tempo * 16).wait;
	};
}).play;

"POLYRHYTHM - 3:4:5 layers".postln;
)

// Stop
// ~layer1.stop; ~layer2.stop; ~layer3.stop; ~gongRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: MEDITATION
// Sparse, contemplative
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];
~root = 196;  // G

// Very sparse marimba
~marRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			var freq = ~root * (2 ** (~scale.choose / 12)) * [0.5, 1, 2].choose;
			Synth(\marimba, [
				\freq, freq,
				\amp, rrand(0.1, 0.16),
				\decay, rrand(1.5, 3),
				\pan, rrand(-0.4, 0.4)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

// Rare vibraphone
~vibRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\vibraphone, [
				\freq, ~root * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.12),
				\decay, rrand(3, 6),
				\tremRate, rrand(3, 5)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Very rare gong
~gongRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\gong, [
				\freq, ~root / 4,
				\amp, rrand(0.12, 0.2),
				\decay, rrand(8, 15)
			]);
		};
		rrand(20, 60).wait;
	};
}).play;

"MEDITATION - Sparse contemplation".postln;
)

// Stop
// ~marRoutine.stop; ~vibRoutine.stop; ~gongRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: RITUAL
// Dense, driving
// --------------------------------------------------
(
~scale = [0, 3, 5, 7, 10];  // Minor pentatonic
~root = 220;
var tempo = 0.15;

// Driving marimba
~driveRoutine = Routine({
	var pattern = [0, 0, 2, 0, 3, 2, 4, 3];
	var accents = [1, 0, 0, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		var degree = pattern[i % 8];
		var accent = accents[i % 8];

		Synth(\marimba, [
			\freq, ~root * (2 ** (~scale[degree] / 12)),
			\amp, if(accent == 1, { rrand(0.18, 0.22) }, { rrand(0.1, 0.14) }),
			\decay, if(accent == 1, { 1.2 }, { 0.6 }),
			\pan, rrand(-0.2, 0.2)
		]);

		i = i + 1;
		tempo.wait;
	};
}).play;

// High marimba counterpoint
~highRoutine = Routine({
	(tempo * 2).wait;
	var pattern = [4, 3, 4, 2, 4, 3, 2, 0];
	var i = 0;
	inf.do {
		if (0.7.coin) {
			Synth(\marimba, [
				\freq, ~root * 2 * (2 ** (~scale[pattern[i % 8]] / 12)),
				\amp, rrand(0.08, 0.12),
				\decay, 0.5,
				\pan, rrand(-0.5, 0.5)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Wood block pulse
~woodRoutine = Routine({
	var pattern = [1, 0, 1, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\woodBlock, [
				\freq, [700, 900, 1100].choose,
				\amp, rrand(0.06, 0.1)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Periodic gong
~gongRoutine = Routine({
	inf.do {
		Synth(\gong, [\freq, ~root / 4, \amp, 0.2, \decay, 6]);
		(tempo * 32).wait;
	};
}).play;

"RITUAL - Driving patterns".postln;
)

// Stop
// ~driveRoutine.stop; ~highRoutine.stop; ~woodRoutine.stop; ~gongRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
