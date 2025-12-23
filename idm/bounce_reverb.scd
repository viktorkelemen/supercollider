// ============================================================
// BOUNCING BALL - Reverb/Space
// ============================================================
// Dry at top, increasingly wet toward bottom
// Ball falling into a cavern

(
SynthDef(\combToneVerb, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0, verbMix = 0, verbRoom = 0.5;
	var sig, env, dry, wet;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);
	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq) * 0.3);
	sig = sig * env * amp;

	dry = sig;
	wet = FreeVerb.ar(sig, 1, verbRoom, 0.5);
	sig = ((1 - verbMix) * dry) + (verbMix * wet);

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
	var verbMix, verbRoom;

	0.5.wait;

	"BOUNCING BALL - Reverb/Space".postln;
	"Dry at top, wet cavern at bottom".postln;

	// === DOWN: falling into cavern ===
	{t < halfPoint}.while({
		progress = t / halfPoint;
		interval = (maxDecay * (1 - progress).pow(2)).max(minInterval);
		decay = maxDecay * (1 - progress).pow(1.5) + minDecay;
		combDecay = maxCombDecay * (1 - progress).pow(1.5) + minCombDecay;

		// Reverb increases as ball falls
		verbMix = progress.pow(0.7) * 0.8;  // 0 -> 0.8
		verbRoom = 0.3 + (progress * 0.7);   // 0.3 -> 1.0

		s.sendBundle(t, [\s_new, \combToneVerb, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\verbMix, verbMix,
			\verbRoom, verbRoom,
			\amp, 0.25
		]);

		t = t + interval;
	});

	// === UP: emerging from cavern ===
	{t < totalDur}.while({
		progress = (t - halfPoint) / halfPoint;
		interval = (maxDecay * progress.pow(2)).max(minInterval);
		decay = minDecay + (maxDecay * progress.pow(1.5));
		combDecay = minCombDecay + (maxCombDecay * progress.pow(1.5));

		// Reverb decreases as ball rises
		verbMix = (1 - progress).pow(0.7) * 0.8;
		verbRoom = 1.0 - (progress * 0.7);

		s.sendBundle(t, [\s_new, \combToneVerb, -1, 0, 0,
			\freq, 80,
			\combFreq, 200,
			\combDecay, combDecay.min(maxCombDecay),
			\decay, decay.min(maxDecay),
			\verbMix, verbMix,
			\verbRoom, verbRoom,
			\amp, 0.25
		]);

		t = t + interval;
	});

	"Scheduled!".postln;
}).play;
)
