// ============================================================
// µ-ZIQ STYLE - Frenetic breakbeats, melodic IDM
// ============================================================
// Inspired by "Lunatic Harness", "Royal Astronomy":
// - Fast, complex breakbeats
// - Rich melodic content
// - Warm analog synth textures
// - Playful, energetic rhythms
// - Lush harmonies

// --------------------------------------------------
// WARM LEAD - Rich melodic lead
// --------------------------------------------------
SynthDef(\warmLead, {
	arg out = 0, amp = 0.12, freq = 440, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);

	sig = Saw.ar(freq) * 0.4;
	sig = sig + (Pulse.ar(freq * 1.002, 0.4) * 0.3);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	sig = RLPF.ar(sig, 2500 + (env * 1500), 0.4);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise1.kr(2).range(-0.4, 0.4)));
}).add;

// --------------------------------------------------
// LUSH PAD - Rich harmonic pad
// --------------------------------------------------
SynthDef(\lushPad, {
	arg out = 0, amp = 0.1, freq = 220, dur = 6;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);

	sig = Saw.ar(freq) * 0.25;
	sig = sig + (Saw.ar(freq * 1.003) * 0.2);
	sig = sig + (Saw.ar(freq * 2.01) * 0.15);
	sig = sig + (Pulse.ar(freq * 0.5, 0.3) * 0.15);

	sig = RLPF.ar(sig, 3000, 0.5);

	// Chorus effect
	sig = sig + DelayL.ar(sig, 0.03, SinOsc.kr(1).range(0.01, 0.02)) * 0.4;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BREAK KICK - Punchy kick
// --------------------------------------------------
SynthDef(\breakKick, {
	arg out = 0, amp = 0.2;
	var sig, env, pitchEnv;

	env = EnvGen.kr(Env.perc(0.01, 0.2, 1, -6), doneAction: 2);
	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.08, 1, -4));

	sig = SinOsc.ar(55 + (pitchEnv * 80));
	sig = sig + (SinOsc.ar(110) * 0.3);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BREAK SNARE - Breakbeat snare
// --------------------------------------------------
SynthDef(\breakSnare, {
	arg out = 0, amp = 0.15;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -6), doneAction: 2);

	sig = WhiteNoise.ar * 0.6;
	sig = sig + (SinOsc.ar(200) * EnvGen.kr(Env.perc(0.001, 0.04)) * 0.4);
	sig = BPF.ar(sig, 1200, 0.8);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BREAK HAT - Fast hi-hat
// --------------------------------------------------
SynthDef(\breakHat, {
	arg out = 0, amp = 0.1, dur = 0.03;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = HPF.ar(sig, 7000);
	sig = BPF.ar(sig, 10000, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// BASS SYNTH - Warm bass
// --------------------------------------------------
SynthDef(\bassSynth, {
	arg out = 0, amp = 0.15, freq = 55, dur = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	sig = Saw.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq) * 0.3);
	sig = sig + (Pulse.ar(freq * 2, 0.3) * 0.15);

	sig = LPF.ar(sig, 800);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// ARPEGGIO SYNTH - Fast arpeggiated tones
// --------------------------------------------------
SynthDef(\arpeggioSynth, {
	arg out = 0, amp = 0.1, freq = 440, dur = 0.15;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);

	sig = Pulse.ar(freq, 0.4) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);

	sig = LPF.ar(sig, 4000);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.6, 0.6)));
}).add;

"µ-Ziq SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: LUNATIC HARNESS
// Frenetic breakbeats, rich melody
// --------------------------------------------------
(
var tempo = 0.0625; // Fast 16ths

// Complex break pattern
~breakRoutine = Routine({
	var kickPat = [1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0];
	var hatPat = [1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\breakKick, [\amp, rrand(0.14, 0.2)]) };
		if (snarePat[i % 16] == 1) { Synth(\breakSnare, [\amp, rrand(0.1, 0.15)]) };
		if (hatPat[i % 16] == 1) { Synth(\breakHat, [\amp, rrand(0.04, 0.08)]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

// Melodic lead
~leadRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72, 74, 76].midicps;
	inf.do {
		if (0.7.coin) {
			Synth(\warmLead, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.14),
				\dur, rrand(0.2, 0.6)
			]);
		};
		rrand(0.1, 0.4).wait;
	};
}).play;

// Lush pad
~padRoutine = Routine({
	var notes = [48, 52, 55, 60].midicps;
	inf.do {
		Synth(\lushPad, [
			\freq, notes.choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(5, 10)
		]);
		rrand(4, 8).wait;
	};
}).play;

// Bass
~bassRoutine = Routine({
	var notes = [36, 38, 41, 43].midicps;
	var pattern = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 16] == 1) {
			Synth(\bassSynth, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(0.15, 0.3)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"LUNATIC HARNESS - Frenetic breaks".postln;
)

// Stop
// ~breakRoutine.stop; ~leadRoutine.stop; ~padRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: ROYAL ASTRONOMY
// Lush, melodic
// --------------------------------------------------
(
var tempo = 0.1;

// Melodic arpeggios
~arpRoutine = Routine({
	var chord = [60, 64, 67, 72, 76].midicps;
	var i = 0;
	inf.do {
		Synth(\arpeggioSynth, [
			\freq, chord[i % chord.size],
			\amp, rrand(0.06, 0.1),
			\dur, 0.12
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Warm lead phrases
~leadRoutine = Routine({
	var notes = [60, 62, 64, 67, 69, 72].midicps;
	inf.do {
		// Phrase
		rrand(3, 6).do {
			Synth(\warmLead, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.15),
				\dur, rrand(0.3, 0.8)
			]);
			rrand(0.15, 0.35).wait;
		};
		rrand(1, 3).wait;
	};
}).play;

// Pad bed
~padRoutine = Routine({
	var chords = [
		[48, 55, 60].midicps,
		[50, 57, 62].midicps,
		[52, 59, 64].midicps
	];
	inf.do {
		var chord = chords.choose;
		chord.do { |freq|
			Synth(\lushPad, [
				\freq, freq,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(6, 10)
			]);
		};
		rrand(6, 12).wait;
	};
}).play;

// Gentle beat
~beatRoutine = Routine({
	var kickPat = [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0];
	var hatPat = [0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\breakKick, [\amp, 0.12]) };
		if (hatPat[i % 16] == 1) { Synth(\breakHat, [\amp, 0.05]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"ROYAL ASTRONOMY - Lush melodic".postln;
)

// Stop
// ~arpRoutine.stop; ~leadRoutine.stop; ~padRoutine.stop; ~beatRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: URMUR BILE TRANSEN
// Chaotic, glitchy
// --------------------------------------------------
(
var tempo = 0.05;

// Chaotic breaks
~chaoticBreak = Routine({
	var kickPat = [1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1];
	var snarePat = [0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0];
	var hatPat = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\breakKick, [\amp, rrand(0.12, 0.2)]) };
		if (snarePat[i % 16] == 1) { Synth(\breakSnare, [\amp, rrand(0.08, 0.14)]) };
		if (hatPat[i % 16] == 1) {
			Synth(\breakHat, [\amp, rrand(0.02, 0.06), \dur, rrand(0.01, 0.04)]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Rapid arpeggios
~rapidArp = Routine({
	var notes = [48, 52, 55, 60, 64, 67, 72].midicps;
	inf.do {
		Synth(\arpeggioSynth, [
			\freq, notes.choose,
			\amp, rrand(0.05, 0.1),
			\dur, rrand(0.05, 0.12)
		]);
		rrand(0.03, 0.1).wait;
	};
}).play;

// Bass chaos
~bassChaos = Routine({
	var notes = [36, 38, 39, 41, 43].midicps;
	inf.do {
		if (0.4.coin) {
			Synth(\bassSynth, [
				\freq, notes.choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(0.08, 0.2)
			]);
		};
		rrand(0.05, 0.2).wait;
	};
}).play;

"URMUR BILE TRANSEN - Chaotic glitch".postln;
)

// Stop
// ~chaoticBreak.stop; ~rapidArp.stop; ~bassChaos.stop;

// --------------------------------------------------
// EXPERIMENT 4: BRACE YOURSELF JASON
// Melodic complexity
// --------------------------------------------------
(
var tempo = 0.08;

// Complex melody
~melodyRoutine = Routine({
	var scale = [60, 62, 64, 65, 67, 69, 71, 72].midicps;
	var i = 0;
	inf.do {
		Synth(\warmLead, [
			\freq, scale[i % scale.size],
			\amp, rrand(0.08, 0.14),
			\dur, rrand(0.15, 0.4)
		]);
		i = i + ([-1, 1, 2, 3].choose);
		if (i < 0) { i = 0 };
		if (i > 7) { i = 7 };
		rrand(0.08, 0.2).wait;
	};
}).play;

// Counter melody
~counterMelody = Routine({
	var scale = [72, 74, 76, 77, 79, 81, 83, 84].midicps;
	inf.do {
		if (0.5.coin) {
			Synth(\arpeggioSynth, [
				\freq, scale.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.1, 0.25)
			]);
		};
		rrand(0.1, 0.3).wait;
	};
}).play;

// Pad
~padRoutine = Routine({
	var notes = [48, 55, 60, 64].midicps;
	inf.do {
		2.do {
			Synth(\lushPad, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.07),
				\dur, rrand(6, 10)
			]);
		};
		rrand(8, 15).wait;
	};
}).play;

// Breakbeat
~breakRoutine = Routine({
	var kickPat = [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\breakKick, [\amp, 0.16]) };
		if (snarePat[i % 16] == 1) { Synth(\breakSnare, [\amp, 0.12]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"BRACE YOURSELF JASON - Melodic complexity".postln;
)

// Stop
// ~melodyRoutine.stop; ~counterMelody.stop; ~padRoutine.stop; ~breakRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: HASTY BOOM ALERT
// Playful, bouncy
// --------------------------------------------------
(
var tempo = 0.09;

// Bouncy melody
~bouncyMelody = Routine({
	var notes = [60, 64, 67, 72, 67, 64, 60, 64].midicps;
	var i = 0;
	inf.do {
		Synth(\warmLead, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.1, 0.15),
			\dur, 0.2
		]);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Arpeggiated accomp
~arpAccomp = Routine({
	var notes = [48, 52, 55, 60].midicps;
	var i = 0;
	inf.do {
		Synth(\arpeggioSynth, [
			\freq, notes[i % notes.size],
			\amp, rrand(0.05, 0.08),
			\dur, 0.08
		]);
		i = i + 1;
		(tempo / 2).wait;
	};
}).play;

// Bass line
~bassLine = Routine({
	var notes = [36, 36, 41, 41, 43, 43, 41, 41].midicps;
	var i = 0;
	inf.do {
		Synth(\bassSynth, [
			\freq, notes[i % notes.size],
			\amp, 0.14,
			\dur, 0.15
		]);
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

// Playful beat
~playfulBeat = Routine({
	var kickPat = [1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0];
	var snarePat = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var hatPat = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (kickPat[i % 16] == 1) { Synth(\breakKick, [\amp, 0.14]) };
		if (snarePat[i % 16] == 1) { Synth(\breakSnare, [\amp, 0.1]) };
		if (hatPat[i % 16] == 1) { Synth(\breakHat, [\amp, 0.05]) };
		i = i + 1;
		tempo.wait;
	};
}).play;

"HASTY BOOM ALERT - Playful bouncy".postln;
)

// Stop
// ~bouncyMelody.stop; ~arpAccomp.stop; ~bassLine.stop; ~playfulBeat.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
