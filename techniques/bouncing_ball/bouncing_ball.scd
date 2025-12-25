// ============================================================
// BOUNCING BALL - 1-minute comb filter effect
// ============================================================
// Ball falls for 30s (accelerating, shortening decay)
// Ball bounces back up for 30s (decelerating, lengthening decay)
// Minimum interval: 60ms to prevent noise

(
// Load combTone SynthDef
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
	var totalDur = 60;      // 1 minute total
	var halfPoint = 30;     // 30s down, 30s up
	var minInterval = 0.06; // 60ms minimum
	var maxDecay = 2.0;     // Maximum decay at top
	var minDecay = 0.012;   // Minimum decay at bottom
	var maxCombDecay = 2.5;
	var minCombDecay = 0.015;
	var t = 0;
	var interval, decay, combDecay, progress;

	0.5.wait; // Wait for SynthDef

	"BOUNCING BALL - 1 minute".postln;
	"30s falling, 30s rising".postln;

	// === DOWN: 0-30s ===
	{t < halfPoint}.while({
		// Progress from 0 to 1 as we fall
		progress = t / halfPoint;

		// Interval shrinks exponentially from ~2.2s to 0.06s
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);

		// Decay shrinks with progress
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		t = t + interval;
	});

	// === UP: 30-60s ===
	{t < totalDur}.while({
		// Progress from 0 to 1 as we rise
		progress = (t - halfPoint) / halfPoint;

		// Interval grows exponentially from 0.06s to ~2.2s
		interval = (maxDecay * progress.pow(2)).max(minInterval);

		// Decay grows with progress
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\amp, 0.25
		]);

		t = t + interval;
	});

	"Scheduled! Playing for 1 minute...".postln;
}).play;
)

// STOP
// s.freeAll;
