// ============================================================
// BOUNCING BALL - Rhythmic Variation
// ============================================================
// Adds randomness to intervals at the bottom (chaos)
// Swing/shuffle that increases toward the middle

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
	var chaos, swing, bounceCount = 0;

	0.5.wait;

	"BOUNCING BALL - Rhythmic Variation".postln;
	"Chaos at bottom, swing in middle".postln;

	// === DOWN: increasing chaos ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		// Chaos increases toward bottom (random timing variation)
		chaos = progress.pow(2) * 0.4;  // 0 -> 0.4
		interval = interval * (1 + (chaos * (1.0.rand2)));

		// Swing in the middle section
		swing = (1 - ((progress - 0.5).abs * 2)).max(0) * 0.3;
		if(bounceCount.odd, {
			interval = interval * (1 + swing);
		});

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		bounceCount = bounceCount + 1;
		t = t + interval.max(minInterval);
	});

	// === UP: decreasing chaos ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		// Chaos decreases as ball rises
		chaos = (1 - progress).pow(2) * 0.4;
		interval = interval * (1 + (chaos * (1.0.rand2)));

		// Swing in the middle section
		swing = (1 - ((progress - 0.5).abs * 2)).max(0) * 0.3;
		if(bounceCount.odd, {
			interval = interval * (1 + swing);
		});

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		bounceCount = bounceCount + 1;
		t = t + interval.max(minInterval);
	});

	"Scheduled!".postln;
}).play;
)
