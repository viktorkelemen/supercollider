// ============================================================
// SQUAREPUSHER STYLE - Bass complexity, jazz-inflected IDM
// ============================================================
// Inspired by "Hard Normal Daddy", "Feed Me Weird Things":
// - Complex bass guitar-like synthesis
// - Intricate breakbeats
// - Jazz harmony influences
// - Virtuosic programming
// - Fusion of acoustic and electronic

// --------------------------------------------------
// BASS SLAP - Slap bass-like tone
// --------------------------------------------------
SynthDef(\bassSlap, {
	arg out = 0, amp = 0.15, freq = 55, dur = 0.2;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);

	// Bass body
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);

	// Slap transient
	click = HPF.ar(WhiteNoise.ar, 2000) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.5;
	sig = sig + click;

	// String harmonics
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 3, 0.1) * 0.2);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BASS FINGER - Fingerstyle bass
// --------------------------------------------------
SynthDef(\bassFinger, {
	arg out = 0, amp = 0.15, freq = 55, dur = 0.4;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Pluck simulation
	sig = Pluck.ar(
		PinkNoise.ar,
		Impulse.kr(0),
		1/freq,
		1/freq,
		dur * 2,
		0.4
	);

	sig = sig + (SinOsc.ar(freq) * 0.4);
	sig = LPF.ar(sig, 2000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SYNTH LEAD - Warm synth lead
// --------------------------------------------------
SynthDef(\synthLeadSP, {
	arg out = 0, amp = 0.1, freq = 440, dur = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq * 1.002, 0.4) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	sig = RLPF.ar(sig, 3000 + (env * 2000), 0.5);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(3).range(-0.5, 0.5)));
}).add;

// --------------------------------------------------
// DRILL KICK - Rapid-fire kick
// --------------------------------------------------
SynthDef(\drillKick, {
	arg out = 0, amp = 0.18;
	var sig, env, pitchEnv;

	env = EnvGen.kr(Env.perc(0.005, 0.15, 1, -8), doneAction: 2);
	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.05, 1, -4));

	sig = SinOsc.ar(60 + (pitchEnv * 100));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DRILL SNARE - Tight snare
// --------------------------------------------------
SynthDef(\drillSnare, {
	arg out = 0, amp = 0.12;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar * 0.6;
	sig = sig + (SinOsc.ar(220) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.4);
	sig = BPF.ar(sig, 1500, 0.7);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DRILL HAT - Precise hi-hat
// --------------------------------------------------
SynthDef(\drillHat, {
	arg out = 0, amp = 0.08, dur = 0.02;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -10), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = HPF.ar(sig, 8000);
	sig = BPF.ar(sig, 12000, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// JAZZ CHORD - Complex chord voicing
// --------------------------------------------------
SynthDef(\jazzChord, {
	arg out = 0, amp = 0.08, freq = 220, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1), doneAction: 2);

	// Jazz voicing (root, 3rd, 7th, 9th)
	sig = Mix([
		SinOsc.ar(freq) * 0.3,
		SinOsc.ar(freq * 1.26) * 0.25,  // major 3rd
		SinOsc.ar(freq * 1.78) * 0.2,   // minor 7th
		SinOsc.ar(freq * 2.12) * 0.15   // 9th
	]);

	sig = LPF.ar(sig, 2500);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// ACID SQUELCH - Acid-influenced bass
// --------------------------------------------------
SynthDef(\acidSquelch, {
	arg out = 0, amp = 0.12, freq = 55, cutoff = 1500, res = 0.8, dur = 0.2;
	var sig, env, filterEnv;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
	filterEnv = EnvGen.kr(Env.perc(0.01, dur * 0.6, 1, -4));

	sig = Saw.ar(freq);
	sig = RLPF.ar(sig, cutoff + (filterEnv * cutoff * 2), res);
	sig = (sig * 1.5).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Squarepusher SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: HARD NORMAL DADDY
// Virtuosic bass and breaks
// --------------------------------------------------
(
var tempo = 0.0625;

// Complex break pattern
~drillBreak = Routine({
	var kickPat = [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0];
	var hatPat = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\drillKick, [\amp, rrand(0.14, 0.2)]) };
		if (snarePat[i % 16] == 1) { Synth(\drillSnare, [\amp, rrand(0.08, 0.14)]) };
		if (hatPat[i % 16] == 1) { Synth(\drillHat, [\amp, rrand(0.03, 0.07)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Virtuosic bass
~bassRoutine = Routine({
	var notes = [36, 38, 41, 43, 45, 48, 50, 53].midicps;
	inf.do {
		// Fast bass run
		rrand(4, 10).do {
			var synth = [\bassSlap, \bassFinger].choose;
			Synth(synth, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(0.1, 0.25)
			]);
			rrand(0.04, 0.12).wait;
		};
		rrand(0.1, 0.5).wait;
	};
}).play;

// Synth lead accents
~leadRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\synthLeadSP, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.15, 0.4)
			]);
		};
		rrand(0.1, 0.4).wait;
	};
}).play;

"HARD NORMAL DADDY - Virtuosic bass".postln;
)

// Stop
// ~drillBreak.stop; ~bassRoutine.stop; ~leadRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: FEED ME WEIRD THINGS
// Jazz-influenced IDM
// --------------------------------------------------
(
var tempo = 0.1;

// Jazz chords
~chordRoutine = Routine({
	var roots = [48, 50, 53, 55].midicps;
	inf.do {
		Synth(\jazzChord, [
			\freq, roots.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(2, 5)
		]);
		rrand(3, 6).wait;
	};
}).play;

// Finger bass melody
~bassRoutine = Routine({
	var notes = [36, 38, 41, 43, 45, 48].midicps;
	var i = 0;
	inf.do {
		Synth(\bassFinger, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.12, 0.18),
			\dur, rrand(0.2, 0.5)
		]);
		i = i + ([1, 1, 2, -1].choose);
		if (i < 0) { i = 0 };
		if (i > 5) { i = 5 };
		rrand(0.1, 0.3).wait;
	};
}).play;

// Jazzy break
~jazzyBreak = Routine({
	var kickPat = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\drillKick, [\amp, 0.15]) };
		if (snarePat[i % 16] == 1) { Synth(\drillSnare, [\amp, 0.1]) };
		if (hatPat[i % 16] == 1) { Synth(\drillHat, [\amp, rrand(0.03, 0.06)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Lead melody
~leadMelody = Routine({
	var notes = [60, 62, 64, 65, 67, 69, 71, 72].midicps;
	inf.do {
		if (0.5.coin) {
			Synth(\synthLeadSP, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.2, 0.6)
			]);
		};
		rrand(0.2, 0.6).wait;
	};
}).play;

"FEED ME WEIRD THINGS - Jazz IDM".postln;
)

// Stop
// ~chordRoutine.stop; ~bassRoutine.stop; ~jazzyBreak.stop; ~leadMelody.stop;

// --------------------------------------------------
// EXPERIMENT 3: GO PLASTIC
// Acid and drill patterns
// --------------------------------------------------
(
var tempo = 0.05;

// Drill pattern
~drillPattern = Routine({
	var kickPat = [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1];
	var snarePat = [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\drillKick, [\amp, rrand(0.12, 0.18)]) };
		if (snarePat[i % 16] == 1) { Synth(\drillSnare, [\amp, rrand(0.08, 0.12)]) };
		if (0.8.coin) { Synth(\drillHat, [\amp, rrand(0.02, 0.05)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Acid bass
~acidRoutine = Routine({
	var notes = [36, 36, 38, 36, 41, 36, 43, 36].midicps;
	var i = 0;
	inf.do {
		Synth(\acidSquelch, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.1, 0.15),
			\cutoff, rrand(500, 2000),
			\res, rrand(0.6, 0.9),
			\dur, rrand(0.08, 0.18)
		]);
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

// Slap bass accents
~slapAccents = Routine({
	var notes = [36, 41, 43, 48].midicps;
	inf.do {
		if (0.3.coin) {
			Synth(\bassSlap, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, 0.15
			]);
		};
		rrand(0.1, 0.3).wait;
	};
}).play;

"GO PLASTIC - Acid drill".postln;
)

// Stop
// ~drillPattern.stop; ~acidRoutine.stop; ~slapAccents.stop;

// --------------------------------------------------
// EXPERIMENT 4: ULTRAVISITOR
// Frenetic complexity
// --------------------------------------------------
(
var tempo = 0.04;

// Extreme drill
~extremeDrill = Routine({
	var i = 0;
	inf.do {
		if (0.6.coin) { Synth(\drillKick, [\amp, rrand(0.1, 0.18)]) };
		if (0.3.coin) { Synth(\drillSnare, [\amp, rrand(0.06, 0.12)]) };
		if (0.7.coin) { Synth(\drillHat, [\amp, rrand(0.02, 0.05), \dur, rrand(0.01, 0.03)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Rapid bass
~rapidBass = Routine({
	var notes = [36, 38, 41, 43, 45, 48, 50, 53].midicps;
	inf.do {
		Synth([\bassSlap, \bassFinger, \acidSquelch].choose, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(0.05, 0.15),
			\cutoff, rrand(600, 2500),
			\res, rrand(0.5, 0.8)
		]);
		rrand(0.03, 0.1).wait;
	};
}).play;

// Lead chaos
~leadChaos = Routine({
	var notes = [60, 62, 64, 67, 69, 72, 74, 76].midicps;
	inf.do {
		if (0.5.coin) {
			Synth(\synthLeadSP, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(0.05, 0.2)
			]);
		};
		rrand(0.03, 0.12).wait;
	};
}).play;

"ULTRAVISITOR - Frenetic complexity".postln;
)

// Stop
// ~extremeDrill.stop; ~rapidBass.stop; ~leadChaos.stop;

// --------------------------------------------------
// EXPERIMENT 5: MUSIC FOR ROBOTS
// Precise, mechanical
// --------------------------------------------------
(
var tempo = 0.08;

// Precise pattern
~precisePattern = Routine({
	var kickPat = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\drillKick, [\amp, 0.18]) };
		if (snarePat[i % 16] == 1) { Synth(\drillSnare, [\amp, 0.12]) };
		if (hatPat[i % 16] == 1) { Synth(\drillHat, [\amp, 0.04]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Mechanical bass
~mechBass = Routine({
	var notes = [36, 36, 36, 41, 36, 36, 43, 36].midicps;
	var i = 0;
	inf.do {
		Synth(\bassFinger, [
			\freq, notes[i % notes.size],
			\amp, 0.14,
			\dur, 0.12
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Lead sequence
~leadSeq = Routine({
	var notes = [60, 64, 67, 72, 67, 64, 60, 55].midicps;
	var i = 0;
	inf.do {
		Synth(\synthLeadSP, [
			\freq, notes[i % notes.size],
			\amp, 0.08,
			\dur, 0.15
		]);
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

"MUSIC FOR ROBOTS - Precise mechanical".postln;
)

// Stop
// ~precisePattern.stop; ~mechBass.stop; ~leadSeq.stop;

// --------------------------------------------------
// EXPERIMENT 6: DAMOGEN FURIES
// Modern Squarepusher
// --------------------------------------------------
(
var tempo = 0.06;

// Complex rhythm
~complexRhythm = Routine({
	var kickPat = [1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1];
	var snarePat = [0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\drillKick, [\amp, rrand(0.12, 0.18)]) };
		if (snarePat[i % 16] == 1) { Synth(\drillSnare, [\amp, rrand(0.08, 0.12)]) };
		if (0.6.coin) { Synth(\drillHat, [\amp, rrand(0.02, 0.05)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Layered bass
~layeredBass = Routine({
	var notes = [36, 38, 41, 43, 45, 48].midicps;
	inf.do {
		// Slap
		Synth(\bassSlap, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(0.1, 0.2)
		]);
		rrand(0.08, 0.2).wait;
		// Finger follow
		if (0.5.coin) {
			Synth(\bassFinger, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.12),
				\dur, rrand(0.15, 0.3)
			]);
		};
		rrand(0.08, 0.2).wait;
	};
}).play;

// Chord stabs
~chordStabs = Routine({
	var roots = [48, 50, 53, 55].midicps;
	inf.do {
		if (0.25.coin) {
			Synth(\jazzChord, [
				\freq, roots.choose,
				\amp, rrand(0.05, 0.08),
				\dur, rrand(0.5, 1.5)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Lead flourishes
~leadFlourish = Routine({
	var notes = [60, 62, 64, 67, 69, 72, 74, 76].midicps;
	inf.do {
		// Flourish
		rrand(3, 7).do {
			Synth(\synthLeadSP, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(0.08, 0.2)
			]);
			rrand(0.04, 0.1).wait;
		};
		rrand(0.5, 2).wait;
	};
}).play;

"DAMOGEN FURIES - Modern Squarepusher".postln;
)

// Stop
// ~complexRhythm.stop; ~layeredBass.stop; ~chordStabs.stop; ~leadFlourish.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
