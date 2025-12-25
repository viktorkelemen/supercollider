// ============================================================
// APHEX TWIN STYLE - Acid patterns, prepared piano, IDM complexity
// ============================================================
// Inspired by "Selected Ambient Works", "Drukqs", "Analord":
// - 303-style acid bass
// - Prepared/processed piano
// - Complex breakbeats (simulated)
// - Warm analog textures
// - Melodic yet alien

// --------------------------------------------------
// ACID BASS - 303-style resonant bass
// --------------------------------------------------
SynthDef(\acidBass, {
	arg out = 0, amp = 0.15, freq = 55, cutoff = 1000, res = 0.7, dur = 0.3;
	var sig, env, filterEnv;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	filterEnv = EnvGen.kr(Env.perc(0.01, dur * 0.5, 1, -4));

	sig = Saw.ar(freq);
	sig = RLPF.ar(sig, cutoff + (filterEnv * cutoff * 2), res);
	sig = (sig * 1.5).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// PREPARED PIANO - Processed piano-like tone
// --------------------------------------------------
SynthDef(\preparedPiano, {
	arg out = 0, amp = 0.12, freq = 440, decay = 3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -6), doneAction: 2);

	// Piano-like with inharmonic elements
	sig = Mix.fill(6, { |i|
		var ratio = [1, 2.01, 3.02, 4.05, 5.1, 6.2][i];
		var level = [1, 0.5, 0.3, 0.2, 0.1, 0.05][i];
		SinOsc.ar(freq * ratio) * level
	});

	// Prepared elements - metallic
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 5.37, 0.5) * 0.1);
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 7.23, 0.3) * 0.05);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// AMBIENT PAD - Warm analog-style pad
// --------------------------------------------------
SynthDef(\ambientPad, {
	arg out = 0, amp = 0.1, freq = 220, dur = 8;
	var sig, env;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);

	sig = Saw.ar(freq) * 0.3;
	sig = sig + (Saw.ar(freq * 1.002) * 0.25);
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.15);
	sig = sig + (SinOsc.ar(freq * 2) * 0.1);

	sig = LPF.ar(sig, 2000);
	sig = FreeVerb.ar(sig, 0.6, 0.8, 0.3);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SNARE HIT - Electronic snare
// --------------------------------------------------
SynthDef(\snareHit, {
	arg out = 0, amp = 0.15;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.2, 1, -6), doneAction: 2);

	sig = WhiteNoise.ar * 0.6;
	sig = sig + (SinOsc.ar(180) * EnvGen.kr(Env.perc(0.001, 0.05)) * 0.4);
	sig = HPF.ar(sig, 200);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// KICK DRUM - Deep electronic kick
// --------------------------------------------------
SynthDef(\kickDrum, {
	arg out = 0, amp = 0.2, freq = 50;
	var sig, env, pitchEnv;

	env = EnvGen.kr(Env.perc(0.01, 0.3, 1, -6), doneAction: 2);
	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.1, 1, -4));

	sig = SinOsc.ar(freq + (pitchEnv * freq * 2));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HAT - Hi-hat sound
// --------------------------------------------------
SynthDef(\hat, {
	arg out = 0, amp = 0.1, dur = 0.05;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = HPF.ar(sig, 6000);
	sig = BPF.ar(sig, 10000, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// MELODY LEAD - Soft lead synth
// --------------------------------------------------
SynthDef(\melodyLead, {
	arg out = 0, amp = 0.12, freq = 440, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.05, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);
	sig = sig + (SinOsc.ar(freq * 3) * 0.1);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(2).range(-0.5, 0.5)));
}).add;

"Aphex Twin SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: SELECTED AMBIENT WORKS
// Warm, melodic ambient
// --------------------------------------------------
(
// Ambient pads
~padRoutine = Routine({
	var notes = [48, 52, 55, 60, 64].midicps;
	inf.do {
		Synth(\ambientPad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(8, 15)
		]);
		rrand(6, 12).wait;
	};
}).play;

// Soft melody
~melodyRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72, 74].midicps;
	inf.do {
		if (0.6.coin) {
			Synth(\melodyLead, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.5, 2)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Sparse drums
~drumRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\kickDrum, [\amp, rrand(0.1, 0.15)]);
		};
		if (0.2.coin) {
			Synth(\snareHit, [\amp, rrand(0.06, 0.1)]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"SELECTED AMBIENT WORKS - Warm melodic".postln;
)

// Stop
// ~padRoutine.stop; ~melodyRoutine.stop; ~drumRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: ANALORD (Acid)
// 303 acid patterns
// --------------------------------------------------
(
var tempo = 0.125;

// Acid bass sequence
~acidRoutine = Routine({
	var pattern = [60, 60, 0, 60, 0, 63, 60, 0, 60, 0, 60, 67, 0, 60, 63, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] != 0) {
			Synth(\acidBass, [
				\freq, pattern[i % pattern.size].midicps * 0.5,
				\amp, rrand(0.12, 0.18),
				\cutoff, rrand(400, 1500),
				\res, rrand(0.6, 0.85),
				\dur, rrand(0.1, 0.25)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// 4/4 kick
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\kickDrum, [\amp, 0.18]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Hi-hats
~hatRoutine = Routine({
	var pattern = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\hat, [\amp, rrand(0.06, 0.1), \dur, 0.05]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"ANALORD - Acid patterns".postln;
)

// Stop
// ~acidRoutine.stop; ~kickRoutine.stop; ~hatRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: DRUKQS (Prepared Piano)
// Processed piano pieces
// --------------------------------------------------
(
// Prepared piano phrases
~pianoRoutine = Routine({
	var notes = [48, 52, 55, 57, 60, 62, 64, 67, 69, 72].midicps;
	inf.do {
		// Phrase
		rrand(3, 8).do {
			Synth(\preparedPiano, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\decay, rrand(2, 5)
			]);
			rrand(0.1, 0.5).wait;
		};
		// Pause
		rrand(1, 4).wait;
	};
}).play;

// Very sparse ambient pad
~sparsePad = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\ambientPad, [
				\freq, [110, 165, 220].choose,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(10, 20)
			]);
		};
		rrand(15, 30).wait;
	};
}).play;

"DRUKQS - Prepared piano".postln;
)

// Stop
// ~pianoRoutine.stop; ~sparsePad.stop;

// --------------------------------------------------
// EXPERIMENT 4: COME TO DADDY ERA
// Aggressive, fast
// --------------------------------------------------
(
var tempo = 0.0625; // Fast

// Aggressive acid
~aggroAcid = Routine({
	var pattern = [1, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0];
	var notes = [36, 38, 39, 41, 43].midicps;
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\acidBass, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\cutoff, rrand(800, 2500),
				\res, rrand(0.7, 0.9),
				\dur, 0.08
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Fast kicks
~fastKick = Routine({
	var pattern = [1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\kickDrum, [\amp, rrand(0.12, 0.18)]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Snare chaos
~snareChaos = Routine({
	var pattern = [0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\snareHit, [\amp, rrand(0.1, 0.15)]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"COME TO DADDY - Aggressive fast".postln;
)

// Stop
// ~aggroAcid.stop; ~fastKick.stop; ~snareChaos.stop;

// --------------------------------------------------
// EXPERIMENT 5: SYRO
// Modern, detailed
// --------------------------------------------------
(
var tempo = 0.15;

// Complex acid pattern
~complexAcid = Routine({
	var notes = [36, 38, 41, 43, 48, 50, 53].midicps;
	var pattern = [1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\acidBass, [
				\freq, notes[i % notes.size],
				\amp, rrand(0.08, 0.14),
				\cutoff, rrand(600, 2000),
				\res, rrand(0.5, 0.8),
				\dur, rrand(0.1, 0.3)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Melodic lead
~leadRoutine = Routine({
	var notes = [60, 62, 64, 65, 67, 69, 71, 72].midicps;
	var i = 0;
	inf.do {
		if (0.5.coin) {
			Synth(\melodyLead, [
				\freq, notes[i % notes.size],
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.3, 0.8)
			]);
		};
		i = i + 1;
		rrand(0.2, 0.5).wait;
	};
}).play;

// Drums
~drumRoutine = Routine({
	var kickPat = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\kickDrum, [\amp, 0.15]) };
		if (snarePat[i % 16] == 1) { Synth(\snareHit, [\amp, 0.12]) };
		if (hatPat[i % 16] == 1) { Synth(\hat, [\amp, rrand(0.04, 0.08)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"SYRO - Modern detailed".postln;
)

// Stop
// ~complexAcid.stop; ~leadRoutine.stop; ~drumRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 6: LICHEN
// Slow ambient
// --------------------------------------------------
(
// Long ambient pads
~longPad = Routine({
	var notes = [36, 43, 48, 55].midicps;
	inf.do {
		Synth(\ambientPad, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(15, 30)
		]);
		rrand(12, 25).wait;
	};
}).play;

// Occasional piano
~occasionalPiano = Routine({
	var notes = [48, 52, 55, 60, 64, 67].midicps;
	inf.do {
		if (0.25.coin) {
			Synth(\preparedPiano, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\decay, rrand(4, 8)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Sparse melody
~sparseMelody = Routine({
	var notes = [60, 64, 67, 72].midicps;
	inf.do {
		if (0.2.coin) {
			Synth(\melodyLead, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(1, 3)
			]);
		};
		rrand(5, 15).wait;
	};
}).play;

"LICHEN - Slow ambient".postln;
)

// Stop
// ~longPad.stop; ~occasionalPiano.stop; ~sparseMelody.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
