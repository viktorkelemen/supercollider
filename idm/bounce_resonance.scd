// ============================================================
// BOUNCING BALL - Resonance Builds
// ============================================================
// combDecay increases as ball falls - more metallic buildup
// At bottom, rapid hits create pitched drone from overlapping tails

(
SynthDef(\combTone, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);
	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq) * 0.3);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

Routine({
	var totalDur = 60;
	var halfPoint = 30;
	var minInterval = 0.06;
	var maxDecay = 2.0;
	var minDecay = 0.012;
	var t = 0;
	var interval, decay, combDecay, progress;

	// Resonance parameters - OPPOSITE of normal
	var minCombDecay = 0.1;   // Short at top
	var maxCombDecay = 4.0;   // Very long at bottom (builds up)

	0.5.wait;

	"BOUNCING BALL - Resonance Builds".postln;
	"Comb decay INCREASES as ball falls - creates drone at bottom".postln;

	// === DOWN: resonance builds ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;

		// Resonance INCREASES as ball falls
		combDecay = minCombDecay + ((maxCombDecay - minCombDecay) * progress.pow(0.8));

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay,
			\decay, decay.min(maxDecay),
			\amp, 0.22
		]);

		t = t + interval;
	});

	// === UP: resonance fades ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));

		// Resonance DECREASES as ball rises
		combDecay = maxCombDecay - ((maxCombDecay - minCombDecay) * progress.pow(0.8));

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay,
			\decay, decay.min(maxDecay),
			\amp, 0.22
		]);

		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
