// ============================================================
// PAN SONIC STYLE - Harsh industrial minimalism
// ============================================================
// Inspired by "Vakio", "A", "Kulma":
// - Raw, brutal oscillator tones
// - Heavy sub bass frequencies
// - Distortion and clipping
// - Sparse, mechanical rhythms
// - Industrial noise bursts
// - Analog-style harshness

// --------------------------------------------------
// SUB BASS - Deep rumbling low frequency
// --------------------------------------------------
SynthDef(\subBass, {
	arg out = 0, amp = 0.3, freq = 40, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);
	sig = sig.tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HARSH OSC - Distorted aggressive oscillator
// --------------------------------------------------
SynthDef(\harshOsc, {
	arg out = 0, amp = 0.2, freq = 100, dur = 1, drive = 4;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);
	sig = Saw.ar(freq);
	sig = sig + Pulse.ar(freq * 1.01, 0.3);
	sig = (sig * drive).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// INDUSTRIAL PULSE - Mechanical rhythmic tone
// --------------------------------------------------
SynthDef(\industrialPulse, {
	arg out = 0, amp = 0.15, freq = 60, rate = 4, dur = 4;
	var sig, env, trig;
	env = EnvGen.kr(Env.linen(0.05, dur - 0.1, 0.05), doneAction: 2);
	trig = Impulse.ar(rate);
	sig = SinOsc.ar(freq) * Decay.ar(trig, 0.1);
	sig = (sig * 3).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// NOISE BURST - Harsh filtered noise
// --------------------------------------------------
SynthDef(\noiseBurst, {
	arg out = 0, amp = 0.2, dur = 0.1, hpf = 1000, lpf = 8000;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);
	sig = WhiteNoise.ar;
	sig = HPF.ar(sig, hpf);
	sig = LPF.ar(sig, lpf);
	sig = (sig * 2).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// FEEDBACK TONE - Harsh squealing feedback
// --------------------------------------------------
SynthDef(\feedbackTone, {
	arg out = 0, amp = 0.15, freq = 2000, dur = 0.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -2), doneAction: 2);
	sig = SinOsc.ar(freq + (SinOsc.ar(freq * 0.5) * 100));
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.5);
	sig = (sig * 3).clip(-1, 1);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DISTORTED KICK - Punchy bass hit
// --------------------------------------------------
SynthDef(\distortedKick, {
	arg out = 0, amp = 0.4, freq = 50, dur = 0.3;
	var sig, env, freqEnv;
	env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);
	freqEnv = EnvGen.kr(Env.perc(0.001, 0.05, 1, -8));
	sig = SinOsc.ar(freq + (freqEnv * 150));
	sig = (sig * 4).tanh;
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// HARSH DRONE - Continuous brutal tone
// --------------------------------------------------
SynthDef(\harshDrone, {
	arg out = 0, amp = 0.1, freq = 80;
	var sig;
	sig = Saw.ar([freq, freq * 1.005]);
	sig = sig + Pulse.ar([freq * 0.5, freq * 0.502], 0.2);
	sig = (sig * 2).tanh;
	sig = LPF.ar(sig, 2000);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;

// --------------------------------------------------
// STATIC CRACKLE - Low-fi industrial texture
// --------------------------------------------------
SynthDef(\staticCrackle, {
	arg out = 0, amp = 0.05, density = 20;
	var sig;
	sig = Dust.ar(density) * 2;
	sig = sig + (Crackle.ar(1.95) * 0.1);
	sig = (sig * 3).tanh;
	sig = HPF.ar(sig, 500);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

"Pan Sonic SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: VAKIO
// Sparse, brutal, minimal
// --------------------------------------------------
(
~crackle = Synth(\staticCrackle, [\amp, 0.03, \density, 15]);

~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\distortedKick, [\amp, rrand(0.3, 0.45), \freq, [40, 50, 60].choose]);
		};
		i = i + 1;
		0.25.wait;
	};
}).play;

~noiseRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\noiseBurst, [\amp, rrand(0.1, 0.2), \dur, rrand(0.02, 0.1)]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

~bassRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\subBass, [\freq, [30, 40, 50].choose, \amp, rrand(0.2, 0.35), \dur, rrand(1, 3)]);
		};
		rrand(2, 6).wait;
	};
}).play;

"VAKIO - Sparse brutalism".postln;
)

// Stop
// ~crackle.free; ~kickRoutine.stop; ~noiseRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: INDUSTRIAL MACHINE
// Mechanical, relentless
// --------------------------------------------------
(
~drone = Synth(\harshDrone, [\amp, 0.06, \freq, 60]);

~pulseRoutine = Routine({
	inf.do {
		Synth(\industrialPulse, [
			\freq, [40, 60, 80].choose,
			\rate, [2, 4, 6, 8].choose,
			\amp, rrand(0.08, 0.15),
			\dur, rrand(2, 4)
		]);
		rrand(3, 6).wait;
	};
}).play;

~harshRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\harshOsc, [
				\freq, rrand(80, 200),
				\amp, rrand(0.1, 0.18),
				\dur, rrand(0.2, 0.8),
				\drive, rrand(3, 6)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

~kickRoutine = Routine({
	inf.do {
		Synth(\distortedKick, [\amp, rrand(0.25, 0.4), \freq, 50]);
		[0.5, 0.5, 1, 0.25].choose.wait;
	};
}).play;

"INDUSTRIAL MACHINE - Mechanical grind".postln;
)

// Stop
// ~drone.free; ~pulseRoutine.stop; ~harshRoutine.stop; ~kickRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: FEEDBACK HELL
// Squealing, aggressive
// --------------------------------------------------
(
~crackle = Synth(\staticCrackle, [\amp, 0.04, \density, 30]);

~feedbackRoutine = Routine({
	inf.do {
		Synth(\feedbackTone, [
			\freq, rrand(1000, 5000),
			\amp, rrand(0.08, 0.15),
			\dur, rrand(0.1, 0.5)
		]);
		rrand(0.3, 1.5).wait;
	};
}).play;

~noiseRoutine = Routine({
	inf.do {
		Synth(\noiseBurst, [
			\amp, rrand(0.15, 0.25),
			\dur, rrand(0.01, 0.05),
			\hpf, rrand(2000, 6000)
		]);
		rrand(0.1, 0.5).wait;
	};
}).play;

~bassRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\subBass, [\freq, [25, 30, 35].choose, \amp, rrand(0.25, 0.4), \dur, rrand(0.5, 2)]);
		};
		rrand(1, 3).wait;
	};
}).play;

"FEEDBACK HELL - Aggressive frequencies".postln;
)

// Stop
// ~crackle.free; ~feedbackRoutine.stop; ~noiseRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: BASS WEIGHT
// Sub-heavy, physical
// --------------------------------------------------
(
~bassRoutine = Routine({
	var freqs = [30, 35, 40, 45, 50];
	inf.do {
		Synth(\subBass, [
			\freq, freqs.choose,
			\amp, rrand(0.3, 0.45),
			\dur, rrand(1, 4)
		]);
		rrand(0.5, 2).wait;
	};
}).play;

~kickRoutine = Routine({
	inf.do {
		Synth(\distortedKick, [\amp, rrand(0.35, 0.5), \freq, [40, 50].choose, \dur, 0.4]);
		[1, 0.5, 1.5, 2].choose.wait;
	};
}).play;

~noiseRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\noiseBurst, [\amp, rrand(0.08, 0.15), \dur, rrand(0.02, 0.08), \lpf, 3000]);
		};
		rrand(0.5, 2).wait;
	};
}).play;

"BASS WEIGHT - Physical pressure".postln;
)

// Stop
// ~bassRoutine.stop; ~kickRoutine.stop; ~noiseRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: DEATH AMBIENT
// Dark, oppressive
// --------------------------------------------------
(
~drone = Synth(\harshDrone, [\amp, 0.08, \freq, 50]);
~crackle = Synth(\staticCrackle, [\amp, 0.03, \density, 10]);

~noiseRoutine = Routine({
	inf.do {
		if (0.1.coin) {
			Synth(\noiseBurst, [\amp, rrand(0.1, 0.2), \dur, rrand(0.05, 0.2), \hpf, 500, \lpf, 2000]);
		};
		rrand(1, 4).wait;
	};
}).play;

~feedbackRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\feedbackTone, [\freq, rrand(800, 2000), \amp, rrand(0.05, 0.1), \dur, rrand(0.3, 1)]);
		};
		rrand(3, 8).wait;
	};
}).play;

~bassRoutine = Routine({
	inf.do {
		Synth(\subBass, [\freq, [25, 30, 40].choose, \amp, rrand(0.2, 0.3), \dur, rrand(3, 8)]);
		rrand(5, 12).wait;
	};
}).play;

"DEATH AMBIENT - Oppressive darkness".postln;
)

// Stop
// ~drone.free; ~crackle.free; ~noiseRoutine.stop; ~feedbackRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
