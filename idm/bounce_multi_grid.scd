// ============================================================
// BOUNCING BALL - Multiple Balls (Quantized Grid)
// ============================================================
// All balls snap to a common beat grid that accelerates
// Creates rhythmic cohesion while maintaining bounce physics

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
	var gridTimes = List[];
	var t = 0;
	var maxInterval = 2.0;
	var minInterval = 0.06;
	var interval, progress;
	// Ball configs: [freq, combFreq, pan, startIndex, ampScale]
	var balls = [
		[60, 150, -0.6, 0, 1.0],       // Low ball, left, starts at beat 0
		[100, 250, 0, 8, 0.8],         // Mid ball, center, starts at beat 8 (~10s)
		[150, 350, 0.6, 16, 0.6],      // High ball, right, starts at beat 16 (~18s)
	];

	// Generate grid times for DOWN phase
	{t < halfPoint}.while({
		gridTimes.add(t);
		progress = t / halfPoint;
		interval = (maxInterval * (1 - progress).pow(2)).max(minInterval);
		t = t + interval;
	});

	// Generate grid times for UP phase
	{t < totalDur}.while({
		gridTimes.add(t);
		progress = (t - halfPoint) / halfPoint;
		interval = (maxInterval * progress.pow(2)).max(minInterval);
		t = t + interval;
	});

	0.5.wait;

	"BOUNCING BALL - Quantized Grid".postln;
	"All balls snap to common accelerating grid".postln;

	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var startIndex = ballConfig[3];
		var ampScale = ballConfig[4];
		var maxDecay = 2.0;
		var minDecay = 0.012;
		var maxCombDecay = 2.5;
		var minCombDecay = 0.015;

		// Play on every grid beat from startIndex
		(startIndex, startIndex + 1 .. gridTimes.size - 1).do { |i|
			var gridT = gridTimes[i];
			var ballT = gridT - gridTimes[startIndex];  // Time since this ball started
			var ballDur = gridTimes.size - startIndex;
			var ballHalf = ballDur / 2;
			var localProgress = (i - startIndex) / ballDur;
			var decay, combDecay;

			if(localProgress < 0.5, {
				// DOWN phase for this ball
				decay = maxDecay * (1 - (localProgress * 2)).pow(1.5) + minDecay;
				combDecay = maxCombDecay * (1 - (localProgress * 2)).pow(1.5) + minCombDecay;
			}, {
				// UP phase for this ball
				decay = minDecay + (maxDecay * ((localProgress - 0.5) * 2).pow(1.5));
				combDecay = minCombDecay + (maxCombDecay * ((localProgress - 0.5) * 2).pow(1.5));
			});

			s.sendBundle(gridT, [\s_new, \combTone, -1, 0, 0,
				\freq, freq,
				\combFreq, combFreq,
				\combDecay, combDecay.min(maxCombDecay),
				\decay, decay.min(maxDecay),
				\pan, pan,
				\amp, 0.18 * ampScale
			]);
		};
	};

	"Scheduled! Grid has % beats".format(gridTimes.size).postln;
}).play;
)
