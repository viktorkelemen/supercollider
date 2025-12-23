// ============================================================
// BOUNCING BALL - Full Production (LPF + Reverb + Sub)
// ============================================================
// Multi-ball grid with:
// - Intro: muffled + large reverb for first 10s, then opens up
// - Dynamic LPF (bright at top, dark at bottom)
// - Reverb that increases at bottom
// - Sparse sub bass hits for foundation

(
// Main ball synth with filter and reverb
SynthDef(\combToneFull, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0,
	    cutoff = 4000, rq = 0.5, verbMix = 0.1, verbRoom = 0.5;
	var sig, env, dry, wet;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Dynamic LPF with resonance
	sig = RLPF.ar(sig, cutoff, rq);

	sig = sig * env * amp;

	// Reverb blend
	dry = sig;
	wet = FreeVerb.ar(sig, 1, verbRoom, 0.3);
	sig = ((1 - verbMix) * dry) + (verbMix * wet);

	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Sub bass synth
SynthDef(\subHit, {
	arg out = 0, amp = 0.3, freq = 40, decay = 0.4;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);

	// Clean sub with slight saturation
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.1);  // Slight 2nd harmonic
	sig = (sig * 1.5).tanh;  // Soft saturation

	sig = LPF.ar(sig, 120);  // Keep it subby
	sig = sig * env * amp;
	Out.ar(out, [sig, sig]);
}).add;

Routine({
	var totalDur = 60;
	var halfPoint = 30;
	var gridTimes = List[];
	var t = 0;
	var maxInterval = 2.0;
	var minInterval = 0.06;
	var interval, progress;

	// Ball configs: [freq, combFreq, pan, timeOffset, ampScale]
	var balls = [
		[60, 150, -0.6, 0, 1.0],
		[100, 250, 0, 10, 0.8],
		[150, 350, 0.6, 20, 0.6],
	];

	// Generate grid
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

	"BOUNCING BALL - Full Production".postln;
	"LPF dynamics + Reverb + Sub bass".postln;

	// Schedule balls with LPF and reverb
	balls.do { |ballConfig|
		var freq = ballConfig[0];
		var combFreq = ballConfig[1];
		var pan = ballConfig[2];
		var timeOffset = ballConfig[3];
		var ampScale = ballConfig[4];
		var maxDecay = 2.0;
		var minDecay = 0.012;
		var maxCombDecay = 2.5;
		var minCombDecay = 0.015;

		gridTimes.do { |gridT, i|
			var actualT = gridT + timeOffset;
			var localProgress = i / gridTimes.size;
			var decay, combDecay;
			var height, cutoff, rq, verbMix, verbRoom;
			var introFade, introDur = 10;

			// Intro fade: 1 at start, 0 after introDur seconds
			introFade = (1 - (actualT / introDur)).max(0);

			// Height: 1 at top, 0 at bottom, 1 at top again
			height = if(localProgress < 0.5,
				{ 1 - (localProgress * 2) },
				{ (localProgress - 0.5) * 2 }
			);

			// Decay based on height
			decay = (maxDecay * height.pow(1.5)) + minDecay;
			combDecay = (maxCombDecay * height.pow(1.5)) + minCombDecay;

			// LPF: bright at top (8000Hz), dark at bottom (800Hz)
			// Intro: start very dark (400Hz), open up over 10s
			cutoff = 800 + (7200 * height);
			cutoff = (400 * introFade) + (cutoff * (1 - introFade));

			// Resonance increases at bottom
			rq = 0.7 - (0.4 * height);  // 0.3 at bottom, 0.7 at top

			// Reverb: more at bottom
			// Intro: start very wet (0.7), large room (0.9)
			verbMix = 0.05 + (0.35 * (1 - height));
			verbMix = (0.7 * introFade) + (verbMix * (1 - introFade));
			verbRoom = 0.3 + (0.5 * (1 - height));
			verbRoom = (0.9 * introFade) + (verbRoom * (1 - introFade));

			s.sendBundle(actualT, [\s_new, \combToneFull, -1, 0, 0,
				\freq, freq,
				\combFreq, combFreq,
				\combDecay, combDecay.min(maxCombDecay),
				\decay, decay.min(maxDecay),
				\pan, pan,
				\cutoff, cutoff,
				\rq, rq,
				\verbMix, verbMix,
				\verbRoom, verbRoom,
				\amp, 0.18 * ampScale
			]);
		};
	};

	// Schedule sparse sub bass hits (every 8th grid beat, only for first ball)
	gridTimes.do { |gridT, i|
		var height, subAmp, subDecay;

		if((i % 8) == 0, {
			height = if((i / gridTimes.size) < 0.5,
				{ 1 - ((i / gridTimes.size) * 2) },
				{ ((i / gridTimes.size) - 0.5) * 2 }
			);

			// Sub louder and longer at bottom
			subAmp = 0.2 + (0.15 * (1 - height));
			subDecay = 0.3 + (0.4 * (1 - height));

			s.sendBundle(gridT, [\s_new, \subHit, -1, 0, 0,
				\freq, 40,
				\amp, subAmp,
				\decay, subDecay
			]);
		});
	};

	"Scheduled! % grid beats".format(gridTimes.size).postln;
}).play;
)
