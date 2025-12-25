// ============================================================
// PORTER RICKS STYLE - Industrial dub techno, chain reactions
// ============================================================
// Inspired by "Biokinetics":
// - Mechanical, industrial textures
// - Chain reaction-like sequences
// - Pressurized, tense atmospheres
// - Hypnotic, relentless repetition
// - Deep, propulsive bass

// --------------------------------------------------
// MECHANICAL PULSE - Industrial rhythm element
// --------------------------------------------------
(
SynthDef(\mechPulse, {
	arg out = 0, amp = 0.2, freq = 100, decay = 0.15;
	var sig, env, noise;

	env = EnvGen.kr(Env.perc(0.002, decay, 1, -6), doneAction: 2);

	// Metallic body
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 2.7, 0.05) * 0.3);

	// Industrial noise burst
	noise = HPF.ar(WhiteNoise.ar, 1000) * EnvGen.kr(Env.perc(0.001, 0.015));
	sig = sig + (noise * 0.2);

	sig = HPF.ar(sig, 60);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.4, 0.4)));
}).add;
)

// --------------------------------------------------
// CHAIN SEQUENCE - Interlocking mechanical sounds
// --------------------------------------------------
(
SynthDef(\chainSeq, {
	arg out = 0, amp = 0.15, freq = 200, rate = 8, dur = 2;
	var sig, env, trig, clicks;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);
	trig = Impulse.ar(rate);

	// Chain of resonant clicks
	clicks = Ringz.ar(trig, freq * [1, 1.5, 2.2, 3.1], 0.03);
	sig = Mix(clicks) * 0.3;

	// Add subtle noise
	sig = sig + (HPF.ar(WhiteNoise.ar, 2000) * trig * 0.1);

	sig = LPF.ar(sig, 6000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PRESSURE BASS - Relentless low end
// --------------------------------------------------
(
SynthDef(\pressureBass, {
	arg out = 0, amp = 0.4, freq = 45, dur = 0.5;
	var sig, env, sub;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Main tone
	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);

	// Sub weight
	sub = SinOsc.ar(freq * 0.5) * 0.4;

	sig = sig + sub;
	sig = LPF.ar(sig, 150);
	sig = (sig * 1.3).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// INDUSTRIAL KICK - Hard, pressurized
// --------------------------------------------------
(
SynthDef(\industrialKick, {
	arg out = 0, amp = 0.55, freq = 50, decay = 0.3;
	var sig, env, click, body;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);

	// Hard click
	click = HPF.ar(WhiteNoise.ar, 800) * EnvGen.kr(Env.perc(0.001, 0.008));

	// Body
	body = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.04, 1, -8)).range(1, 2));
	body = body + (SinOsc.ar(freq * 0.5) * 0.5);

	sig = body + (click * 0.4);
	sig = (sig * 1.5).tanh;
	sig = LPF.ar(sig, 300);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PRESSURIZED PAD - Tense, sustained texture
// --------------------------------------------------
(
SynthDef(\pressurePad, {
	arg out = 0, amp = 0.1, freq = 55, tension = 0.5;
	var sig, mod, noise;

	// Tense modulation
	mod = LFNoise2.kr(0.1).range(0.98, 1.02);

	// Dense harmonics
	sig = Mix.fill(5, { |i|
		var partial = i + 1;
		var detune = LFNoise2.kr(0.03).range(0.995, 1.005);
		SinOsc.ar(freq * partial * detune * mod) * (1 / partial);
	});

	// High-frequency tension
	noise = HPF.ar(PinkNoise.ar, 4000) * tension * 0.1;
	sig = sig + noise;

	// Subtle amplitude modulation
	sig = sig * (1 + (LFNoise2.kr(0.2) * 0.15));

	sig = LPF.ar(sig, 2000);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: BIOKINETICS
// Relentless, mechanical dub
// --------------------------------------------------
(
var tempo = 0.25;  // 240 BPM feel

~pad = Synth(\pressurePad, [\freq, 55, \amp, 0.06, \tension, 0.4]);

// Driving kick
~kickRoutine = Routine({
	var pattern = [1, 0, 1, 0, 1, 0, 1, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\industrialKick, [
				\amp, rrand(0.45, 0.6),
				\decay, rrand(0.2, 0.35)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Bass follows kick
~bassRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var notes = [45, 45, 50, 45, 40, 45, 50, 55];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\pressureBass, [
				\freq, notes[i % 8],
				\amp, rrand(0.3, 0.4),
				\dur, tempo * 1.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Mechanical pulses
~pulseRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\mechPulse, [
				\freq, rrand(80, 200),
				\amp, rrand(0.1, 0.18),
				\decay, rrand(0.08, 0.2)
			]);
		};
		(tempo * rrand(1, 4)).wait;
	};
}).play;

// Chain sequences
~chainRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\chainSeq, [
				\freq, rrand(150, 400),
				\amp, rrand(0.08, 0.14),
				\rate, [8, 12, 16].choose,
				\dur, rrand(1, 3)
			]);
		};
		(tempo * rrand(8, 24)).wait;
	};
}).play;

"BIOKINETICS - Industrial propulsion".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~bassRoutine.stop; ~pulseRoutine.stop; ~chainRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: CHAIN REACTION
// Focus on interlocking patterns
// --------------------------------------------------
(
var tempo = 0.2;

~pad = Synth(\pressurePad, [\freq, 41.2, \amp, 0.05, \tension, 0.3]);

// Multiple interlocking pulse patterns
~pulse1 = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\mechPulse, [\freq, 120, \amp, 0.15, \decay, 0.12]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

~pulse2 = Routine({
	var pattern = [0, 1, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\mechPulse, [\freq, 180, \amp, 0.12, \decay, 0.1]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

~pulse3 = Routine({
	var pattern = [0, 0, 1, 0, 0, 1, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\mechPulse, [\freq, 240, \amp, 0.1, \decay, 0.08]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Anchor kick
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\industrialKick, [\amp, 0.5, \decay, 0.25]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Sparse bass
~bassRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\pressureBass, [
				\freq, [41.2, 45, 49].choose,
				\amp, rrand(0.25, 0.35),
				\dur, rrand(0.3, 0.6)
			]);
		};
		(tempo * rrand(4, 10)).wait;
	};
}).play;

"CHAIN REACTION - Interlocking mechanics".postln;
)

// Stop
// ~pad.free; ~pulse1.stop; ~pulse2.stop; ~pulse3.stop; ~kickRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: PRESSURIZED
// Maximum tension
// --------------------------------------------------
(
var tempo = 0.22;

~pad = Synth(\pressurePad, [\freq, 49, \amp, 0.08, \tension, 0.7]);

// Intense kick
~kickRoutine = Routine({
	var pattern = [1, 1, 0, 1, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\industrialKick, [
				\amp, rrand(0.5, 0.65),
				\decay, 0.2
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Constant bass pressure
~bassRoutine = Routine({
	var notes = [49, 49, 55, 49, 41.2, 49, 55, 61.7];
	var i = 0;
	inf.do {
		Synth(\pressureBass, [
			\freq, notes[i % 8],
			\amp, rrand(0.35, 0.45),
			\dur, tempo * 1.8
		]);
		i = i + 1;
		(tempo * 2).wait;
	};
}).play;

// Dense mechanical textures
~mechRoutine = Routine({
	inf.do {
		if (0.6.coin) {
			Synth(\mechPulse, [
				\freq, rrand(100, 300),
				\amp, rrand(0.1, 0.2),
				\decay, rrand(0.05, 0.15)
			]);
		};
		(tempo * rrand(0.5, 2)).wait;
	};
}).play;

// Chain sequences - more frequent
~chainRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\chainSeq, [
				\freq, rrand(150, 500),
				\amp, rrand(0.1, 0.16),
				\rate, [12, 16, 20, 24].choose,
				\dur, rrand(0.5, 2)
			]);
		};
		(tempo * rrand(4, 12)).wait;
	};
}).play;

"PRESSURIZED - Maximum tension".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~bassRoutine.stop; ~mechRoutine.stop; ~chainRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: DEEP MECHANISM
// Slower, heavier
// --------------------------------------------------
(
var tempo = 0.35;

~pad = Synth(\pressurePad, [\freq, 36.7, \amp, 0.06, \tension, 0.35]);

// Heavy, slow kick
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\industrialKick, [
				\amp, rrand(0.5, 0.6),
				\freq, 45,
				\decay, rrand(0.35, 0.5)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Deep bass
~bassRoutine = Routine({
	var notes = [36.7, 41.2, 36.7, 32.7];
	inf.do {
		if (0.4.coin) {
			Synth(\pressureBass, [
				\freq, notes.choose,
				\amp, rrand(0.35, 0.5),
				\dur, rrand(0.5, 1)
			]);
		};
		(tempo * rrand(2, 6)).wait;
	};
}).play;

// Sparse mechanical elements
~mechRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\mechPulse, [
				\freq, rrand(60, 150),
				\amp, rrand(0.12, 0.2),
				\decay, rrand(0.15, 0.3)
			]);
		};
		(tempo * rrand(2, 6)).wait;
	};
}).play;

"DEEP MECHANISM - Slow industrial".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~bassRoutine.stop; ~mechRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: BIOKINETIC AMBIENT
// Textural, less rhythmic
// --------------------------------------------------
(
~pad = Synth(\pressurePad, [\freq, 55, \amp, 0.08, \tension, 0.5]);

// Occasional kicks - very sparse
~kickRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\industrialKick, [
				\amp, rrand(0.35, 0.5),
				\decay, rrand(0.3, 0.5)
			]);
		};
		rrand(2, 8).wait;
	};
}).play;

// Mechanical textures - main focus
~mechRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\mechPulse, [
				\freq, rrand(80, 300),
				\amp, rrand(0.08, 0.16),
				\decay, rrand(0.1, 0.3)
			]);
		};
		rrand(0.5, 3).wait;
	};
}).play;

// Long chain sequences
~chainRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\chainSeq, [
				\freq, rrand(100, 350),
				\amp, rrand(0.06, 0.12),
				\rate, rrand(4, 12),
				\dur, rrand(3, 10)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

// Rare bass events
~bassRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\pressureBass, [
				\freq, [36.7, 41.2, 49, 55].choose,
				\amp, rrand(0.2, 0.35),
				\dur, rrand(0.8, 2)
			]);
		};
		rrand(6, 20).wait;
	};
}).play;

"BIOKINETIC AMBIENT - Textural machines".postln;
)

// Stop
// ~pad.free; ~kickRoutine.stop; ~mechRoutine.stop; ~chainRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
