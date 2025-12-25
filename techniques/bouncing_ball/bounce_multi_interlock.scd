// ============================================================
// BOUNCING BALL - Multiple Balls (Interlocking)
// ============================================================
// Gamelan kotekan style - balls fill each other's gaps
// When one is silent, another plays

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
	var maxInterval = 1.5;
	var minInterval = 0.04;
	var interval, progress;
	var maxDecay = 2.0;
	var minDecay = 0.012;
	var maxCombDecay = 2.5;
	var minCombDecay = 0.015;
	// Interlocking patterns (like gamelan polos/sangsih)
	var patterns = [
		[1, 0, 0],  // Ball 1: plays on beat 1
		[0, 1, 0],  // Ball 2: plays on beat 2
		[0, 0, 1],  // Ball 3: plays on beat 3
	];
	// Ball configs: [freq, combFreq, pan, patternIndex, ampScale]
	var balls = [
		[60, 150, -0.6, 0, 1.0],
		[100, 250, 0, 1, 0.85],
		[150, 350, 0.6, 2, 0.7],
	];

	// Generate grid - accelerates then decelerates
	{t < halfPoint}.while({
		gridTimes.add(t);
		progress = t / halfPoint;
		interval = (maxInterval * (1 - progress).pow(2)).max(minInterval);
		t = t + interval;
	});
	{t < totalDur}.while({
		gridTimes.add(t);
		progress = (t - halfPoint) / halfPoint;
		interval = (maxInterval * progress.pow(2)).max(minInterval);
		t = t + interval;
	});

	0.5.wait;

	"BOUNCING BALL - Interlocking".postln;
	"Gamelan style - balls fill each other's gaps".postln;

	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var patternIndex = ballConfig[3];
		var ampScale = ballConfig[4];
		var pattern = patterns[patternIndex];

		gridTimes.do { |gridT, i|
			var beatInCycle = i % 3;
			var shouldPlay = pattern[beatInCycle] == 1;
			var height, decay, combDecay;

			if(shouldPlay, {
				height = if(gridT < halfPoint,
					{ 1 - (gridT / halfPoint) },
					{ (gridT - halfPoint) / halfPoint }
				);
				decay = (maxDecay * height.pow(1.5)) + minDecay;
				combDecay = (maxCombDecay * height.pow(1.5)) + minCombDecay;

				s.sendBundle(gridT, [\s_new, \combTone, -1, 0, 0,
					\freq, freq,
					\combFreq, combFreq,
					\combDecay, combDecay.min(maxCombDecay),
					\decay, decay.min(maxDecay),
					\pan, pan,
					\amp, 0.22 * ampScale
				]);
			});
		};
	};

	"Scheduled! % grid beats, 3-way interlock".format(gridTimes.size).postln;
}).play;
)
