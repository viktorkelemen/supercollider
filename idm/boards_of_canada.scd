// ============================================================
// BOARDS OF CANADA STYLE - Tape degradation, nostalgic synthesis
// ============================================================
// Inspired by "Music Has the Right to Children", "Geogaddi":
// - Degraded tape textures
// - Detuned, wobbly synthesis
// - Nostalgic, childhood-evoking sounds
// - Warm analog character
// - Hip-hop influenced beats

// --------------------------------------------------
// TAPE PAD - Degraded warm pad
// --------------------------------------------------
SynthDef(\tapePad, {
	arg out = 0, amp = 0.12, freq = 220, wobble = 2, dur = 8;
	var sig, env, mod;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1), doneAction: 2);

	// Tape wobble
	mod = SinOsc.kr(wobble).range(0.98, 1.02);

	sig = Saw.ar(freq * mod) * 0.3;
	sig = sig + (Saw.ar(freq * 1.003 * mod) * 0.25);
	sig = sig + (SinOsc.ar(freq * 0.5 * mod) * 0.2);

	// Tape filtering
	sig = LPF.ar(sig, 2500);
	sig = HPF.ar(sig, 80);

	// Tape hiss
	sig = sig + (HPF.ar(PinkNoise.ar * 0.015, 4000));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DETUNED SYNTH - Slightly out of tune lead
// --------------------------------------------------
SynthDef(\detunedSynth, {
	arg out = 0, amp = 0.12, freq = 440, detune = 5, dur = 1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.05, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq + LFNoise1.kr(0.5).range(detune.neg, detune)) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2 + LFNoise1.kr(0.3).range(-3, 3)) * 0.3);

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(1).range(-0.4, 0.4)));
}).add;

// --------------------------------------------------
// VOCAL SAMPLE - Processed vocal-like texture
// --------------------------------------------------
SynthDef(\vocalSample, {
	arg out = 0, amp = 0.1, freq = 300, formant = 700, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1), doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = BPF.ar(sig, formant, 0.1) * 3;
	sig = sig + BPF.ar(Saw.ar(freq), formant * 1.4, 0.1) * 2;

	// Degradation
	sig = LPF.ar(sig, 2000);
	sig = sig + (HPF.ar(PinkNoise.ar * 0.02, 5000));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// KICK BOC - Warm, muffled kick
// --------------------------------------------------
SynthDef(\kickBoc, {
	arg out = 0, amp = 0.2;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, 0.3, 1, -6), doneAction: 2);

	sig = SinOsc.ar(50 * EnvGen.kr(Env.perc(0.001, 0.1)).range(1, 2));
	sig = sig + (SinOsc.ar(80) * 0.3);
	sig = LPF.ar(sig, 200);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SNARE BOC - Lo-fi snare
// --------------------------------------------------
SynthDef(\snareBoc, {
	arg out = 0, amp = 0.12;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.15, 1, -6), doneAction: 2);

	sig = WhiteNoise.ar * 0.5;
	sig = sig + (SinOsc.ar(180) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.4);
	sig = BPF.ar(sig, 1000, 0.8);
	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HAT BOC - Muffled hi-hat
// --------------------------------------------------
SynthDef(\hatBoc, {
	arg out = 0, amp = 0.08;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.06, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig, 6000, 0.5);
	sig = LPF.ar(sig, 8000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// TAPE CRACKLE - Vinyl/tape noise
// --------------------------------------------------
SynthDef(\tapeCrackle, {
	arg out = 0, amp = 0.04;
	var sig;

	sig = Dust.ar(20) * 0.4;
	sig = sig + (Crackle.ar(1.7) * 0.2);
	sig = sig + (HPF.ar(PinkNoise.ar * 0.3, 5000));
	sig = LPF.ar(sig, 8000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// NATURE SAMPLE - Field recording simulation
// --------------------------------------------------
SynthDef(\natureSample, {
	arg out = 0, amp = 0.06;
	var sig;

	sig = PinkNoise.ar;
	sig = BPF.ar(sig, LFNoise1.kr(0.1).range(300, 800), 0.5);
	sig = sig + BPF.ar(PinkNoise.ar, 1500, 0.3) * 0.3;
	sig = LPF.ar(sig, 3000);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

"Boards of Canada SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: MUSIC HAS THE RIGHT TO CHILDREN
// Classic BoC sound
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.03]);

// Tape pads
~padRoutine = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\wobble, rrand(1, 3),
			\dur, rrand(8, 15)
		]);
		rrand(6, 12).wait;
	};
}).play;

// Detuned melody
~melodyRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72].midicps;
	inf.do {
		if (0.6.coin) {
			Synth(\detunedSynth, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.12),
				\detune, rrand(3, 8),
				\dur, rrand(0.5, 2)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Hip-hop beat
~drumRoutine = Routine({
	var tempo = 0.25;
	var kickPat = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\kickBoc, [\amp, 0.16]) };
		if (snarePat[i % 16] == 1) { Synth(\snareBoc, [\amp, 0.1]) };
		if (hatPat[i % 16] == 1) { Synth(\hatBoc, [\amp, rrand(0.04, 0.08)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"MUSIC HAS THE RIGHT - Classic BoC".postln;
)

// Stop
// ~crackle.free; ~padRoutine.stop; ~melodyRoutine.stop; ~drumRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: GEOGADDI
// Darker, more processed
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.04]);

// Dark pads
~darkPad = Routine({
	var notes = [36, 40, 43, 48].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.14),
			\wobble, rrand(2, 5),
			\dur, rrand(10, 20)
		]);
		rrand(8, 15).wait;
	};
}).play;

// Processed vocals
~vocalRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\vocalSample, [
				\freq, rrand(150, 350),
				\amp, rrand(0.06, 0.1),
				\formant, rrand(500, 900),
				\dur, rrand(1.5, 4)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Slow beat
~slowBeat = Routine({
	var tempo = 0.3;
	var kickPat = [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\kickBoc, [\amp, 0.14]) };
		if (snarePat[i % 16] == 1) { Synth(\snareBoc, [\amp, 0.08]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"GEOGADDI - Dark processed".postln;
)

// Stop
// ~crackle.free; ~darkPad.stop; ~vocalRoutine.stop; ~slowBeat.stop;

// --------------------------------------------------
// EXPERIMENT 3: CAMPFIRE HEADPHASE
// Warmer, guitar-influenced
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.03]);
~nature = Synth(\natureSample, [\amp, 0.04]);

// Warm pads
~warmPad = Routine({
	var notes = [55, 60, 62, 67].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\wobble, rrand(1, 2),
			\dur, rrand(8, 14)
		]);
		rrand(6, 12).wait;
	};
}).play;

// Melodic leads
~warmMelody = Routine({
	var notes = [60, 62, 64, 66, 67, 69, 71, 72].midicps;
	var i = 0;
	inf.do {
		Synth(\detunedSynth, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.08, 0.12),
			\detune, rrand(2, 5),
			\dur, rrand(0.4, 1.2)
		]);
		i = i + 1;
		rrand(0.3, 0.8).wait;
	};
}).play;

// Relaxed beat
~relaxBeat = Routine({
	var tempo = 0.22;
	var kickPat = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\kickBoc, [\amp, 0.14]) };
		if (hatPat[i % 16] == 1) { Synth(\hatBoc, [\amp, rrand(0.04, 0.07)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"CAMPFIRE HEADPHASE - Warm guitar".postln;
)

// Stop
// ~crackle.free; ~nature.free; ~warmPad.stop; ~warmMelody.stop; ~relaxBeat.stop;

// --------------------------------------------------
// EXPERIMENT 4: TOMORROW'S HARVEST
// Cold, apocalyptic
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.05]);

// Cold pads
~coldPad = Routine({
	var notes = [36, 41, 43, 48].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.1, 0.15),
			\wobble, rrand(3, 6),
			\dur, rrand(12, 25)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Sparse melody
~sparseMelody = Routine({
	var notes = [48, 51, 53, 55, 58, 60].midicps;
	inf.do {
		if (0.35.coin) {
			Synth(\detunedSynth, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\detune, rrand(5, 12),
				\dur, rrand(1, 3)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Minimal beat
~minimalBeat = Routine({
	var tempo = 0.35;
	var kickPat = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\kickBoc, [\amp, 0.15]) };
		if ((i % 32 == 8).and(0.5.coin)) { Synth(\snareBoc, [\amp, 0.08]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"TOMORROW'S HARVEST - Cold apocalyptic".postln;
)

// Stop
// ~crackle.free; ~coldPad.stop; ~sparseMelody.stop; ~minimalBeat.stop;

// --------------------------------------------------
// EXPERIMENT 5: TURQUOISE HEXAGON SUN
// Nostalgic, dreamy
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.03]);
~nature = Synth(\natureSample, [\amp, 0.05]);

// Dreamy layers
~dreamPad1 = Routine({
	var notes = [48, 55, 60, 64].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\wobble, rrand(1, 2),
			\dur, rrand(10, 18)
		]);
		rrand(8, 15).wait;
	};
}).play;

~dreamPad2 = Routine({
	var notes = [60, 67, 72, 76].midicps;
	inf.do {
		if (0.5.coin) {
			Synth(\tapePad, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.08),
				\wobble, rrand(1.5, 3),
				\dur, rrand(8, 14)
			]);
		};
		rrand(10, 20).wait;
	};
}).play;

// Sparse detuned
~sparseLead = Routine({
	var notes = [60, 64, 67, 72].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\detunedSynth, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.09),
				\detune, rrand(4, 10),
				\dur, rrand(1.5, 4)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

"TURQUOISE HEXAGON SUN - Dreamy".postln;
)

// Stop
// ~crackle.free; ~nature.free; ~dreamPad1.stop; ~dreamPad2.stop; ~sparseLead.stop;

// --------------------------------------------------
// EXPERIMENT 6: NO BEAT AMBIENT
// Pure texture, no rhythm
// --------------------------------------------------
(
~crackle = Synth(\tapeCrackle, [\amp, 0.04]);
~nature = Synth(\natureSample, [\amp, 0.06]);

// Multiple pad layers
~padLayer1 = Routine({
	var notes = [36, 43, 48].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\wobble, rrand(2, 4),
			\dur, rrand(15, 30)
		]);
		rrand(12, 25).wait;
	};
}).play;

~padLayer2 = Routine({
	var notes = [55, 60, 67].midicps;
	inf.do {
		Synth(\tapePad, [
			\freq, notes.choose,
			\amp, rrand(0.05, 0.09),
			\wobble, rrand(1, 3),
			\dur, rrand(12, 22)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Occasional vocal
~vocalRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\vocalSample, [
				\freq, rrand(180, 300),
				\amp, rrand(0.04, 0.07),
				\formant, rrand(550, 800),
				\dur, rrand(3, 6)
			]);
		};
		rrand(12, 30).wait;
	};
}).play;

"NO BEAT AMBIENT - Pure texture".postln;
)

// Stop
// ~crackle.free; ~nature.free; ~padLayer1.stop; ~padLayer2.stop; ~vocalRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
