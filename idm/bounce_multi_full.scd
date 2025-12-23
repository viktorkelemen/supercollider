// ============================================================
// BOUNCING BALL - Full Production (LPF + Reverb + Sub)
// ============================================================
// Multi-ball grid with:
// - Intro: muffled + large reverb for first 10s, then opens up
// - Dynamic LPF (bright at top, dark at bottom)
// - Reverb that increases at bottom
// - Sparse sub bass hits for foundation
// - Master bus: HPF + Compressor + Soft Limiter

(
// Master bus - allocate 2 channels
~masterBus = Bus.audio(s, 2);

// Master chain: HPF → Compressor → Limiter
SynthDef(\masterBus, {
	arg in, out = 0, hpFreq = 30, compThresh = 0.5, compRatio = 3,
	    compAttack = 0.03, compRelease = 0.15, limitLevel = 0.95, gain = 1.2;
	var sig, compressed;

	sig = In.ar(in, 2);

	// HPF to clean up sub-lows
	sig = HPF.ar(sig, hpFreq);

	// Compressor (Compander)
	// threshold, slopeBelow, slopeAbove, clampTime, relaxTime
	compressed = Compander.ar(sig, sig,
		thresh: compThresh,
		slopeBelow: 1,
		slopeAbove: compRatio.reciprocal,  // 3:1 ratio = 0.33 slope
		clampTime: compAttack,
		relaxTime: compRelease
	);

	// Makeup gain
	compressed = compressed * gain;

	// Soft limiter (tanh saturation)
	compressed = (compressed * limitLevel).tanh;

	Out.ar(out, compressed);
}).add;

// Main ball synth with filter and reverb
SynthDef(\combToneFull, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0,
	    cutoff = 4000, rq = 0.5, verbMix = 0.1, verbRoom = 0.5;
	var sig, env, dry, wet;
	env = EnvGen.kr(Env.perc(0.003, decay, 1, -3), doneAction: 2);  // Softer attack & curve

	sig = PinkNoise.ar * 0.8 * EnvGen.kr(Env.perc(0.002, 0.015));  // Pink noise, slightly longer
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq) * 0.35);  // Slightly more sine body

	// Dynamic LPF with resonance + gentle rolloff
	sig = RLPF.ar(sig, cutoff, rq);
	sig = LPF.ar(sig, 8000);  // Tame harsh highs

	sig = sig * env * amp;

	// Reverb blend
	dry = sig;
	wet = FreeVerb.ar(sig, 1, verbRoom, 0.3);
	sig = ((1 - verbMix) * dry) + (verbMix * wet);

	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Counter-rhythm - FM click (from Mark Fell synths)
SynthDef(\fmClick, {
	arg out = 0, amp = 0.2, freq = 800, ratio = 3.5, index = 3, decay = 0.08, pan = 0, lpf = 4000;
	var sig, env, mod;
	env = EnvGen.kr(Env.perc(0.002, decay, 1, -5), doneAction: 2);  // Slightly softer attack
	mod = SinOsc.ar(freq * ratio) * freq * index * env;
	sig = SinOsc.ar(freq + mod);
	sig = LPF.ar(sig, lpf);  // Soften the highs
	sig = sig * env * amp;
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

	// Start master bus synth (runs for duration + tail)
	Synth(\masterBus, [\in, ~masterBus.index, \out, 0]);

	"BOUNCING BALL - Full Production".postln;
	"LPF + Reverb + Sub + Master compression".postln;

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
				\out, ~masterBus.index,
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
				\out, ~masterBus.index,
				\freq, 40,
				\amp, subAmp,
				\decay, subDecay
			]);
		});
	};

	// Schedule counter-rhythm (inverse density - sparse at bottom, frequent at top)
	// Uses fixed intervals that speed up when balls slow down
	{
		var counterT = 0;
		var counterMaxInterval = 0.8;
		var counterMinInterval = 0.08;
		var counterInterval, counterHeight, counterProgress;

		{counterT < totalDur}.while({
			counterProgress = counterT / totalDur;
			// Inverse of ball height: dense (short interval) at top, sparse at bottom
			counterHeight = if(counterProgress < 0.5,
				{ counterProgress * 2 },      // 0→1 as balls fall (we speed up)
				{ 1 - ((counterProgress - 0.5) * 2) }  // 1→0 as balls rise (we slow down)
			);

			// Interval: short at top (fast clicks), long at bottom (sparse)
			counterInterval = counterMinInterval + (counterMaxInterval * (1 - counterHeight).pow(1.5));

			// Play click with varying freq based on position
			s.sendBundle(counterT, [\s_new, \fmClick, -1, 0, 0,
				\out, ~masterBus.index,
				\freq, 500 + (300 * counterHeight),  // Slightly lower range
				\ratio, 2.5 + (counterHeight * 1.5), // Less aggressive FM
				\index, 1.5 + (counterHeight * 2.5), // Reduced brightness
				\decay, 0.04 + (0.08 * counterHeight),
				\lpf, 2500 + (2500 * counterHeight), // Opens up at top
				\pan, (counterHeight - 0.5) * 0.6,   // Less extreme stereo
				\amp, 0.05 + (0.03 * counterHeight)  // Slightly quieter
			]);

			counterT = counterT + counterInterval;
		});
	}.value;

	"Scheduled! % grid beats + counter-rhythm".format(gridTimes.size).postln;
}).play;
)
