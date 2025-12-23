// ============================================================
// BOUNCING BALL - Harmonic Content Shifts
// ============================================================
// combFreq changes with height (brighter at top, darker at bottom)
// Adds FM index that increases at bottom for more grit

(
SynthDef(\combToneFM, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0, fmIndex = 0;
	var sig, env, mod;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	// FM modulation for grit
	mod = SinOsc.ar(freq * 2.5) * freq * fmIndex;

	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq + mod) * 0.3);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

Routine({
	var totalDur = 60;
	var halfPoint = 30;
	var minInterval = 0.06;
	var maxDecay = 2.0;
	var minDecay = 0.012;
	var maxCombDecay = 2.5;
	var minCombDecay = 0.015;
	var t = 0;
	var interval, decay, combDecay, progress;
	var combFreq, fmIndex;
	var brightCombFreq = 500, darkCombFreq = 120;
	var minFM = 0, maxFM = 3;

	0.5.wait;

	"BOUNCING BALL - Harmonic Shifts".postln;
	"Bright at top, dark+gritty at bottom".postln;

	// === DOWN: gets darker and grittier ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		// Timbre shifts: bright -> dark
		combFreq = brightCombFreq + ((darkCombFreq - brightCombFreq) * progress);
		// FM index increases at bottom
		fmIndex = minFM + ((maxFM - minFM) * progress.pow(2));

		s.sendBundle(t, [\s_new, \combToneFM, -1, 0, 0,
			\freq, 80,
			\combFreq, combFreq,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\fmIndex, fmIndex,
			\amp, 0.25
		]);

		t = t + interval;
	});

	// === UP: gets brighter and cleaner ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		// Timbre shifts: dark -> bright
		combFreq = darkCombFreq + ((brightCombFreq - darkCombFreq) * progress);
		// FM index decreases
		fmIndex = maxFM - ((maxFM - minFM) * progress.pow(2));

		s.sendBundle(t, [\s_new, \combToneFM, -1, 0, 0,
			\freq, 80,
			\combFreq, combFreq,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\fmIndex, fmIndex,
			\amp, 0.25
		]);

		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
