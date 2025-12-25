// ============================================================
// MIKA VAINIO STYLE - Solo work, extends Pan Sonic vocabulary
// ============================================================
// Inspired by "Onko", "Black Telephone", "Kilo":
// - Low frequency exploration
// - Sine wave purity with distortion
// - Industrial textures
// - Minimal, focused compositions
// - Electronics as physical force

// --------------------------------------------------
// DEEP SINE - Pure low frequency sine
// --------------------------------------------------
SynthDef(\deepSine, {
	arg out = 0, amp = 0.3, freq = 40, dur = 3;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1), doneAction: 2);

	sig = SinOsc.ar(freq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// INDUSTRIAL PULSE - Heavy rhythmic pulse
// --------------------------------------------------
SynthDef(\industrialPulse, {
	arg out = 0, amp = 0.2, freq = 60, dur = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, dur, 1, -8), doneAction: 2);

	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);

	// Subtle distortion
	sig = (sig * 1.5).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// STATIC CRACKLE - Industrial static
// --------------------------------------------------
SynthDef(\staticCrackle, {
	arg out = 0, amp = 0.08, density = 50;
	var sig;

	sig = Dust.ar(density) * 0.5;
	sig = sig + (Crackle.ar(1.9) * 0.3);
	sig = sig + (LFNoise0.ar(density * 10) * 0.2);

	sig = HPF.ar(sig, 500);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// METAL RESONANCE - Metallic ringing
// --------------------------------------------------
SynthDef(\metalRing, {
	arg out = 0, amp = 0.12, freq = 400, decay = 2;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -6), doneAction: 2);

	// Modal synthesis
	sig = Mix.fill(4, { |i|
		var ratio = [1, 2.32, 4.15, 6.72][i];
		Ringz.ar(Impulse.ar(0), freq * ratio, decay / (i + 1)) * (1 / (i + 1))
	});

	sig = sig.tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// SATURATED TONE - Warm distorted tone
// --------------------------------------------------
SynthDef(\saturatedTone, {
	arg out = 0, amp = 0.15, freq = 110, drive = 2, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.6;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.25);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.15);

	// Saturation
	sig = (sig * drive).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// NOISE BURST - Short noise element
// --------------------------------------------------
SynthDef(\noiseBurstV, {
	arg out = 0, amp = 0.12, freq = 2000, dur = 0.1;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

	sig = BPF.ar(WhiteNoise.ar, freq, 0.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Vainio SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: ONKO
// Deep bass meditation
// --------------------------------------------------
(
// Deep sine drone
~deepRoutine = Routine({
	var freqs = [30, 35, 40, 45, 50];
	inf.do {
		Synth(\deepSine, [
			\freq, freqs.choose,
			\amp, rrand(0.2, 0.35),
			\dur, rrand(4, 10)
		]);
		rrand(3, 8).wait;
	};
}).play;

// Sparse industrial pulse
~pulseRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\industrialPulse, [
				\freq, [40, 50, 60].choose,
				\amp, rrand(0.12, 0.2),
				\dur, rrand(0.2, 0.5)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

// Static crackle bed
~crackle = Synth(\staticCrackle, [\amp, 0.04, \density, 30]);

"ONKO - Deep bass meditation".postln;
)

// Stop
// ~deepRoutine.stop; ~pulseRoutine.stop; ~crackle.free;

// --------------------------------------------------
// EXPERIMENT 2: KILO
// Rhythmic industrial
// --------------------------------------------------
(
var tempo = 0.25;

// Industrial rhythm
~rhythmRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\industrialPulse, [
				\freq, [50, 60, 80].choose,
				\amp, rrand(0.14, 0.22),
				\dur, rrand(0.15, 0.3)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Metal accents
~metalRoutine = Routine({
	var pattern = [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\metalRing, [
				\freq, [300, 400, 500].choose,
				\amp, rrand(0.08, 0.12),
				\decay, rrand(1, 2)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Static layer
~crackle = Synth(\staticCrackle, [\amp, 0.05, \density, 40]);

"KILO - Rhythmic industrial".postln;
)

// Stop
// ~rhythmRoutine.stop; ~metalRoutine.stop; ~crackle.free;

// --------------------------------------------------
// EXPERIMENT 3: BLACK TELEPHONE
// Harsh telecommunications
// --------------------------------------------------
(
// Saturated tones
~saturatedRoutine = Routine({
	var freqs = [110, 165, 220, 330];
	inf.do {
		Synth(\saturatedTone, [
			\freq, freqs.choose,
			\amp, rrand(0.1, 0.16),
			\drive, rrand(2, 4),
			\dur, rrand(1.5, 4)
		]);
		rrand(2, 5).wait;
	};
}).play;

// Noise bursts
~noiseRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\noiseBurstV, [
				\freq, rrand(1000, 4000),
				\amp, rrand(0.08, 0.14),
				\dur, rrand(0.05, 0.2)
			]);
		};
		rrand(0.3, 1.5).wait;
	};
}).play;

// Deep pulses
~deepPulse = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\industrialPulse, [
				\freq, [40, 50].choose,
				\amp, rrand(0.15, 0.22),
				\dur, rrand(0.3, 0.6)
			]);
		};
		rrand(1, 3).wait;
	};
}).play;

"BLACK TELEPHONE - Harsh telecom".postln;
)

// Stop
// ~saturatedRoutine.stop; ~noiseRoutine.stop; ~deepPulse.stop;

// --------------------------------------------------
// EXPERIMENT 4: LIFE
// Minimal sustained
// --------------------------------------------------
(
// Single deep sine
~singleDeep = Routine({
	var freq = 40;
	inf.do {
		Synth(\deepSine, [
			\freq, freq,
			\amp, rrand(0.25, 0.35),
			\dur, rrand(8, 15)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Rare metallic
~rareMetal = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\metalRing, [
				\freq, rrand(200, 500),
				\amp, rrand(0.08, 0.12),
				\decay, rrand(2, 4)
			]);
		};
		rrand(5, 15).wait;
	};
}).play;

// Subtle crackle
~crackle = Synth(\staticCrackle, [\amp, 0.03, \density, 20]);

"LIFE - Minimal sustained".postln;
)

// Stop
// ~singleDeep.stop; ~rareMetal.stop; ~crackle.free;

// --------------------------------------------------
// EXPERIMENT 5: MAGNETITE
// Dense metallic
// --------------------------------------------------
(
// Overlapping metal
~metalRoutine = Routine({
	inf.do {
		Synth(\metalRing, [
			\freq, rrand(150, 600),
			\amp, rrand(0.08, 0.14),
			\decay, rrand(1.5, 4)
		]);
		rrand(0.5, 2).wait;
	};
}).play;

// Industrial pulse
~pulseRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\industrialPulse, [
				\freq, rrand(50, 100),
				\amp, rrand(0.12, 0.2),
				\dur, rrand(0.2, 0.4)
			]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

// Saturated drone
~droneRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\saturatedTone, [
				\freq, [55, 82.4, 110].choose,
				\amp, rrand(0.1, 0.14),
				\drive, rrand(1.5, 2.5),
				\dur, rrand(3, 6)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

"MAGNETITE - Dense metallic".postln;
)

// Stop
// ~metalRoutine.stop; ~pulseRoutine.stop; ~droneRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 6: ELECTRON
// Pure electronic
// --------------------------------------------------
(
// Clean sines
~cleanRoutine = Routine({
	var freqs = [55, 110, 165, 220, 330];
	inf.do {
		Synth(\deepSine, [
			\freq, freqs.choose,
			\amp, rrand(0.15, 0.25),
			\dur, rrand(2, 5)
		]);
		rrand(1.5, 4).wait;
	};
}).play;

// Precise pulses
~precisePulse = Routine({
	var tempo = 0.5;
	var pattern = [1, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\industrialPulse, [
				\freq, 60,
				\amp, 0.16,
				\dur, 0.2
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Noise punctuation
~noisePunct = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\noiseBurstV, [
				\freq, rrand(2000, 6000),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(0.03, 0.1)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

"ELECTRON - Pure electronic".postln;
)

// Stop
// ~cleanRoutine.stop; ~precisePulse.stop; ~noisePunct.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
