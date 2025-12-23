// ============================================================
// BOUNCING BALL - Multiple Balls (Tempo Ratios)
// ============================================================
// Balls run at related speeds: 1 : 1.5 : 2
// Creates polymetric relationships

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

	// Ball configs: [freq, combFreq, pan, tempoRatio, phaseOffset, ampScale]
	// tempoRatio affects how fast the ball bounces relative to base
	var balls = [
		[60, 150, -0.6, 1.0, 0, 1.0],     // Low ball: base tempo
		[100, 250, 0, 1.5, 5, 0.8],       // Mid ball: 1.5x faster, starts 5s later
		[150, 350, 0.6, 2.0, 10, 0.6],    // High ball: 2x faster, starts 10s later
	];

	0.5.wait;

	"BOUNCING BALL - Tempo Ratios".postln;
	"Balls at 1:1.5:2 speed ratios".postln;

	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var tempoRatio = ballConfig[3];
		var phaseOffset = ballConfig[4];
		var ampScale = ballConfig[5];
		var t = 0;
		var interval, decay, combDecay, progress;
		var ballHalfPoint, ballTotalDur;

		// Adjusted timing based on tempo ratio
		ballHalfPoint = halfPoint / tempoRatio;
		ballTotalDur = totalDur / tempoRatio;

		// === DOWN phase ===
		{t < ballHalfPoint}.while({
			progress = t / ballHalfPoint;
			// Interval scales with tempo ratio
			interval = ((maxDecay / tempoRatio) * (1 - progress).pow(2)).max(minInterval);
			decay = (maxDecay / tempoRatio) * (1 - progress).pow(1.5) + minDecay;
			combDecay = (maxCombDecay / tempoRatio) * (1 - progress).pow(1.5) + minCombDecay;

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

		// === UP phase ===
		{t < ballTotalDur}.while({
			progress = (t - ballHalfPoint) / ballHalfPoint;
			interval = ((maxDecay / tempoRatio) * progress.pow(2)).max(minInterval);
			decay = minDecay + ((maxDecay / tempoRatio) * progress.pow(1.5));
			combDecay = minCombDecay + ((maxCombDecay / tempoRatio) * progress.pow(1.5));

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

	"Scheduled!".postln;
	"Ball 1: 60s cycle, Ball 2: 40s cycle, Ball 3: 30s cycle".postln;
}).play;
)
