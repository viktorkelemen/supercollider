// ============================================================
// BOUNCING BALL - Multiple Balls (Phase-Locked)
// ============================================================
// Balls start at exact phase relationships (0, 1/3, 2/3 of cycle)
// All three balls complete their arcs together

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

	// Ball configs: [freq, combFreq, pan, phaseOffset (0-1), ampScale]
	// phaseOffset is fraction of the cycle (0 = start, 0.33 = 1/3 through, etc)
	var balls = [
		[60, 150, -0.6, 0.0, 1.0],     // Low ball, starts at top
		[100, 250, 0, 0.33, 0.8],      // Mid ball, starts 1/3 down
		[150, 350, 0.6, 0.66, 0.6],    // High ball, starts 2/3 down (near bottom)
	];

	0.5.wait;

	"BOUNCING BALL - Phase-Locked".postln;
	"Balls at 0, 1/3, 2/3 phase - all finish together".postln;

	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var phaseOffset = ballConfig[3];
		var ampScale = ballConfig[4];
		var t = 0;
		var interval, decay, combDecay, progress, phase, height;

		// Phase 0 = top (slow), Phase 0.5 = bottom (fast), Phase 1 = back to top
		{t < totalDur}.while({
			progress = t / totalDur;
			phase = (progress + phaseOffset).mod(1.0);
			// Height: 0 and 1 are top, 0.5 is bottom (V shape)
			height = (1 - (phase * 2)).abs;

			interval = (maxDecay * height.pow(2)).max(minInterval);
			decay = (maxDecay * height.pow(1.5)) + minDecay;
			combDecay = (maxCombDecay * height.pow(1.5)) + minCombDecay;

			s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
				\freq, freq,
				\combFreq, combFreq,
				\combDecay, combDecay.min(maxCombDecay),
				\decay, decay.min(maxDecay),
				\pan, pan,
				\amp, 0.18 * ampScale
			]);

			t = t + interval;
		});
	};

	"Scheduled!".postln;
}).play;
)
