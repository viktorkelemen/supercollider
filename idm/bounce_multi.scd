// ============================================================
// BOUNCING BALL - Multiple Balls
// ============================================================
// 3 balls at different phases and pitches
// Creates polyrhythmic interplay

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

	// Ball configs: [freq, combFreq, pan, phaseOffset, ampScale]
	var balls = [
		[60, 150, -0.6, 0, 1.0],      // Low ball, left, starts first
		[100, 250, 0, 20, 0.7],       // Mid ball, center, 20s behind
		[150, 350, 0.6, 40, 0.5],     // High ball, right, 40s behind
	];

	0.5.wait;

	"BOUNCING BALL - Multiple Balls".postln;

	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var phaseOffset = ballConfig[3];
		var ampScale = ballConfig[4];
		var t = 0;
		var interval, decay, combDecay, progress;

		// === DOWN ===
		{t < halfPoint}.while({
			progress = t / halfPoint;
			interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
			decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
			combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

			s.sendBundle(t + phaseOffset, [\s_new, \combTone, -1, 0, 0,
				\freq, freq,
				\combFreq, combFreq,
				\combDecay, combDecay.min(maxCombDecay),
				\decay, decay.min(maxDecay),
				\pan, pan,
				\amp, 0.2 * ampScale
			]);

			t = t + interval;
		});

		// === UP ===
		{t < totalDur}.while({
			progress = (t - halfPoint) / halfPoint;
			interval = (maxDecay * progress.pow(2)).max(minInterval);
			decay = minDecay + (maxDecay * progress.pow(1.5));
			combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

			s.sendBundle(t + phaseOffset, [\s_new, \combTone, -1, 0, 0,
				\freq, freq,
				\combFreq, combFreq,
				\combDecay, combDecay.min(maxCombDecay),
				\decay, decay.min(maxDecay),
				\pan, pan,
				\amp, 0.2 * ampScale
			]);

			t = t + interval;
		});
	};

	"Scheduled 3 balls!".postln;
	"Ball 1: 0-60s, Ball 2: 20-80s, Ball 3: 40-100s".postln;
}).play;
)
