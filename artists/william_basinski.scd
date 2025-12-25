// ============================================================
// WILLIAM BASINSKI STYLE - Tape loops, decay
// ============================================================
// Inspired by "The Disintegration Loops":
// - Tape loop degradation
// - Slow decay and entropy
// - Melancholic, nostalgic character
// - Repetition with variation
// - Physical media decay simulation

// --------------------------------------------------
// TAPE LOOP - Degrading loop with wow/flutter
// --------------------------------------------------
(
SynthDef(\tapeLoopBasi, {
	arg out = 0, amp = 0.2, freq = 220, loopTime = 4, decayTime = 60,
		degradeRate = 0.01, wowDepth = 0.005, flutterDepth = 0.002;
	var sig, loop, wow, flutter, degrade, env;

	env = EnvGen.kr(Env.linen(2, decayTime - 4, 2), doneAction: 2);

	// Source melody fragment
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.15);

	// Initial attack
	sig = sig * EnvGen.kr(Env.perc(0.05, 0.5));

	// Wow and flutter
	wow = SinOsc.kr(0.3).range(1 - wowDepth, 1 + wowDepth);
	flutter = LFNoise2.kr(6).range(1 - flutterDepth, 1 + flutterDepth);

	// Create loop with degradation
	loop = CombL.ar(sig, loopTime + 0.5, loopTime * wow * flutter, decayTime);

	// Degradation over time
	degrade = Line.kr(1, 0.3, decayTime);

	// Apply degradation - filtering gets darker
	loop = LPF.ar(loop, 3000 * degrade + 500);
	loop = LPF.ar(loop, 4000 * degrade + 800);

	// Add noise as it degrades
	loop = loop + (PinkNoise.ar * (1 - degrade) * 0.03);

	// Occasional dropouts
	loop = loop * LFNoise2.kr(0.1).range(0.85, 1);

	sig = loop * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// TAPE HISS - Degraded tape noise
// --------------------------------------------------
(
SynthDef(\tapeHiss, {
	arg out = 0, amp = 0.02, degradation = 0;
	var sig;

	sig = PinkNoise.ar * 0.6;
	sig = sig + (BrownNoise.ar * 0.3);
	sig = sig + (Dust.ar(5 + (degradation * 20)) * 0.2);

	sig = HPF.ar(sig, 300);
	sig = LPF.ar(sig, 6000 - (degradation * 3000));

	sig = sig * amp * (1 + (degradation * 0.5));
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DROPOUT - Random signal loss
// --------------------------------------------------
(
SynthDef(\dropout, {
	arg out = 0, amp = 0.8, rate = 0.5;
	var sig, gate;

	// Random amplitude holes
	gate = LFNoise0.kr(rate).range(0.7, 1);
	gate = gate * (1 - (Dust.kr(rate * 0.5) * 0.3));

	sig = In.ar(out, 2);
	sig = sig * gate;

	ReplaceOut.ar(out, sig);
}).add;
)

// --------------------------------------------------
// MELODY FRAGMENT - Short melodic phrase
// --------------------------------------------------
(
SynthDef(\melodyFragment, {
	arg out = 0, amp = 0.15, freq = 440, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.3, 0.2, 1, \sin), doneAction: 2);

	// Warm, nostalgic tone
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (LFTri.ar(freq) * 0.15);
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.1);

	sig = LPF.ar(sig, 2000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: DISINTEGRATION LOOP
// Classic Basinski decay
// --------------------------------------------------
(
// Tape hiss foundation
~hiss = Synth(\tapeHiss, [\amp, 0.015, \degradation, 0]);

// Main loop
~loop = Synth(\tapeLoopBasi, [
	\freq, 220,
	\amp, 0.18,
	\loopTime, 6,
	\decayTime, 300,
	\degradeRate, 0.02
]);

// Gradually increase hiss degradation
~degradeRoutine = Routine({
	var degradation = 0;
	300.do { |i|
		degradation = i / 300;
		~hiss.set(\degradation, degradation);
		1.wait;
	};
}).play;

"DISINTEGRATION LOOP - Slow decay".postln;
)

// Stop
// ~hiss.free; ~loop.free; ~degradeRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: MELANCHOLIA
// Multiple overlapping loops
// --------------------------------------------------
(
~hiss = Synth(\tapeHiss, [\amp, 0.012]);

// Layer 1
~loop1 = Synth(\tapeLoopBasi, [
	\freq, 164.8,
	\amp, 0.12,
	\loopTime, 5,
	\decayTime, 180
]);

// Layer 2 - offset
~loop2 = nil;
~delayStart = Routine({
	3.wait;
	~loop2 = Synth(\tapeLoopBasi, [
		\freq, 220,
		\amp, 0.1,
		\loopTime, 7,
		\decayTime, 200
	]);
}).play;

// Layer 3 - more offset
~loop3 = nil;
~delayStart2 = Routine({
	8.wait;
	~loop3 = Synth(\tapeLoopBasi, [
		\freq, 293.7,
		\amp, 0.08,
		\loopTime, 4.5,
		\decayTime, 150
	]);
}).play;

"MELANCHOLIA - Layered loops".postln;
)

// Stop
// ~hiss.free; ~loop1.free; ~loop2.free; ~loop3.free;

// --------------------------------------------------
// EXPERIMENT 3: 92982
// Shorter, more active loops
// --------------------------------------------------
(
~hiss = Synth(\tapeHiss, [\amp, 0.018, \degradation, 0.2]);

// Multiple short loops
~loopRoutine = Routine({
	var freqs = [196, 220, 261.6, 293.7, 329.6];
	inf.do {
		Synth(\tapeLoopBasi, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.14),
			\loopTime, rrand(2, 5),
			\decayTime, rrand(30, 90),
			\wowDepth, rrand(0.003, 0.01)
		]);
		rrand(15, 40).wait;
	};
}).play;

"92982 - Active loops".postln;
)

// Stop
// ~hiss.free; ~loopRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: SILENT NIGHT
// Very slow, minimal
// --------------------------------------------------
(
~hiss = Synth(\tapeHiss, [\amp, 0.01]);

// Single long loop
~loop = Synth(\tapeLoopBasi, [
	\freq, 146.8,
	\amp, 0.12,
	\loopTime, 12,
	\decayTime, 600,
	\degradeRate, 0.005,
	\wowDepth, 0.008
]);

// Rare melody fragments
~fragmentRoutine = Routine({
	var notes = [146.8, 164.8, 196, 220];
	inf.do {
		if (0.2.coin) {
			Synth(\melodyFragment, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.08),
				\dur, rrand(2, 5)
			]);
		};
		rrand(30, 90).wait;
	};
}).play;

"SILENT NIGHT - Long form".postln;
)

// Stop
// ~hiss.free; ~loop.free; ~fragmentRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: WATERMUSIC
// Higher register, more movement
// --------------------------------------------------
(
~hiss = Synth(\tapeHiss, [\amp, 0.015]);

// Higher loops
~loop1 = Synth(\tapeLoopBasi, [
	\freq, 440,
	\amp, 0.1,
	\loopTime, 3,
	\decayTime, 120,
	\flutterDepth, 0.004
]);

~loop2 = Synth(\tapeLoopBasi, [
	\freq, 523.25,
	\amp, 0.08,
	\loopTime, 4,
	\decayTime, 150,
	\wowDepth, 0.006
]);

// Additional fragments
~fragmentRoutine = Routine({
	var notes = [392, 440, 523.25, 587.33, 659.26];
	inf.do {
		if (0.35.coin) {
			Synth(\melodyFragment, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.1),
				\dur, rrand(1, 3)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

"WATERMUSIC - Higher register".postln;
)

// Stop
// ~hiss.free; ~loop1.free; ~loop2.free; ~fragmentRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
