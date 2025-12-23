// ============================================================
// BOUNCING BALL - Stereo Movement
// ============================================================
// Ball bounces left-right across stereo field
// Each bounce alternates sides with decreasing width

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
	var pan, panWidth, bounceCount = 0;

	0.5.wait;

	"BOUNCING BALL - Stereo Movement".postln;

	// === DOWN: bouncing left-right ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		// Pan alternates L/R, width decreases toward center
		panWidth = 0.8 * (1 - progress);
		pan = if(bounceCount.even, { panWidth.neg }, { panWidth });

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\pan, pan,
			\amp, 0.25
		]);

		bounceCount = bounceCount + 1;
		t = t + interval;
	});

	// === UP: bouncing left-right, width increases ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		// Pan width increases as ball rises
		panWidth = 0.8 * progress;
		pan = if(bounceCount.even, { panWidth.neg }, { panWidth });

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\pan, pan,
			\amp, 0.25
		]);

		bounceCount = bounceCount + 1;
		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
