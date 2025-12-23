// ============================================================
// BOUNCING BALL - Pitch Descent/Ascent
// ============================================================
// Ball falls in pitch as it drops, rises back up
// Creates a Doppler-like gravity effect

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
	var maxCombDecay = 2.5;
	var minCombDecay = 0.015;
	var t = 0;
	var interval, decay, combDecay, progress;
	var freq, combFreq;
	var highFreq = 120, lowFreq = 50;      // Pitch range
	var highCombFreq = 400, lowCombFreq = 150;

	0.5.wait;

	"BOUNCING BALL - Pitch Descent".postln;

	// === DOWN: pitch falls ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		// Pitch descends as ball falls
		freq = highFreq + ((lowFreq - highFreq) * progress);
		combFreq = highCombFreq + ((lowCombFreq - highCombFreq) * progress);

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, freq,
			\combFreq, combFreq,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		t = t + interval;
	});

	// === UP: pitch rises ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		// Pitch rises as ball rises
		freq = lowFreq + ((highFreq - lowFreq) * progress);
		combFreq = lowCombFreq + ((highCombFreq - lowCombFreq) * progress);

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, freq,
			\combFreq, combFreq,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
