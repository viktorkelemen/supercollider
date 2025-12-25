// ============================================================
// BOUNCING BALL - Counterpoint
// ============================================================
// High sine tone does the opposite arc (rises while ball falls)
// Creates tension/release against the comb texture

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

// Pure sine for counterpoint voice
SynthDef(\counterSine, {
	arg out = 0, amp = 0.1, freq = 800, decay = 0.3, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, decay, 1, -6), doneAction: 2);
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);  // Slight beating
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

	// Counterpoint parameters
	var counterLowFreq = 400, counterHighFreq = 1200;
	var counterInterval = 0.8;  // Slower, sustained
	var counterT = 0;
	var counterFreq, counterAmp;

	0.5.wait;

	"BOUNCING BALL - Counterpoint".postln;
	"Ball falls while sine rises, then opposite".postln;

	// Schedule counterpoint voice (opposite motion)
	{counterT < totalDur}.while({
		if(counterT < halfPoint, {
			// First half: sine rises while ball falls
			progress = counterT / halfPoint;
			counterFreq = counterLowFreq + ((counterHighFreq - counterLowFreq) * progress);
			counterAmp = 0.08 + (progress * 0.07);  // Gets louder
		}, {
			// Second half: sine falls while ball rises
			progress = (counterT - halfPoint) / halfPoint;
			counterFreq = counterHighFreq - ((counterHighFreq - counterLowFreq) * progress);
			counterAmp = 0.15 - (progress * 0.07);  // Gets quieter
		});

		s.sendBundle(counterT, [\s_new, \counterSine, -1, 0, 0,
			\freq, counterFreq,
			\decay, 0.5,
			\amp, counterAmp,
			\pan, 0.4
		]);

		counterT = counterT + counterInterval;
	});

	// Schedule ball (same as original)
	// === DOWN ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\pan, -0.4,
			\amp, 0.22
		]);

		t = t + interval;
	});

	// === UP ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		s.sendBundle(t, [\s_new, \combTone, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\pan, -0.4,
			\amp, 0.22
		]);

		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
