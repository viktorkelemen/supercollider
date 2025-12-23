// ============================================================
// BOUNCING BALL - Chord Version (E minor)
// ============================================================
// Same as full production but with harmonically tuned frequencies
// E minor chord: E2-G2-B2 with sub on E1
// Counter-rhythm uses notes from E minor scale

(
// Master bus - allocate 2 channels
~masterBus = Bus.audio(s, 2);

// Master chain: HPF -> Compressor -> Limiter
SynthDef(\masterBus, {
	arg in, out = 0, hpFreq = 30, compThresh = 0.5, compRatio = 3,
	    compAttack = 0.03, compRelease = 0.15, limitLevel = 0.95, gain = 1.2;
	var sig, compressed;

	sig = In.ar(in, 2);
	sig = HPF.ar(sig, hpFreq);
	compressed = Compander.ar(sig, sig,
		thresh: compThresh,
		slopeBelow: 1,
		slopeAbove: compRatio.reciprocal,
		clampTime: compAttack,
		relaxTime: compRelease
	);
	compressed = compressed * gain;
	compressed = (compressed * limitLevel).tanh;
	Out.ar(out, compressed);
}).add;

// Main ball synth with filter and reverb
SynthDef(\combToneFull, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0,
	    cutoff = 4000, rq = 0.5, verbMix = 0.1, verbRoom = 0.5;
	var sig, env, dry, wet;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);
	sig = sig + (SinOsc.ar(freq) * 0.25);

	sig = RLPF.ar(sig, cutoff, rq);

	sig = sig * env * amp;

	dry = sig;
	wet = FreeVerb.ar(sig, 1, verbRoom, 0.3);
	sig = ((1 - verbMix) * dry) + (verbMix * wet);

	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Counter-rhythm - FM click
SynthDef(\fmClick, {
	arg out = 0, amp = 0.2, freq = 800, ratio = 3.5, index = 3, decay = 0.08, pan = 0, lpf = 4000;
	var sig, env, mod;
	env = EnvGen.kr(Env.perc(0.002, decay, 1, -5), doneAction: 2);
	mod = SinOsc.ar(freq * ratio) * freq * index * env;
	sig = SinOsc.ar(freq + mod);
	sig = LPF.ar(sig, lpf);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Sub bass synth
SynthDef(\subHit, {
	arg out = 0, amp = 0.3, freq = 40, decay = 0.4;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.1);
	sig = (sig * 1.5).tanh;
	sig = LPF.ar(sig, 120);
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

	// E minor chord frequencies (MIDI to Hz)
	// E2=40, G2=43, B2=47
	var rootFreq = 40.midicps;   // E2 = 82.4 Hz
	var thirdFreq = 43.midicps;  // G2 = 98 Hz
	var fifthFreq = 47.midicps;  // B2 = 123.5 Hz

	// Sub bass on E1 (octave below root)
	var subFreq = 28.midicps;    // E1 = 41.2 Hz

	// Counter-rhythm notes from E minor scale (higher register)
	// E4=64, G4=67, A4=69, B4=71, D5=74
	var counterNotes = [64, 67, 69, 71, 74].collect(_.midicps);

	// Ball configs: [freq, combFreq, pan, timeOffset, ampScale]
	// combFreq is one octave up from fundamental
	var balls = [
		[rootFreq, rootFreq * 2, -0.6, 0, 1.0],     // E2, comb at E3
		[thirdFreq, thirdFreq * 2, 0, 10, 0.8],    // G2, comb at G3
		[fifthFreq, fifthFreq * 2, 0.6, 20, 0.6],  // B2, comb at B3
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

	Synth(\masterBus, [\in, ~masterBus.index, \out, 0]);

	"BOUNCING BALL - E Minor Chord".postln;
	"Root: E2 (82Hz), Third: G2 (98Hz), Fifth: B2 (124Hz)".postln;

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

			introFade = (1 - (actualT / introDur)).max(0);

			height = if(localProgress < 0.5,
				{ 1 - (localProgress * 2) },
				{ (localProgress - 0.5) * 2 }
			);

			decay = (maxDecay * height.pow(1.5)) + minDecay;
			combDecay = (maxCombDecay * height.pow(1.5)) + minCombDecay;

			cutoff = 800 + (7200 * height);
			cutoff = (400 * introFade) + (cutoff * (1 - introFade));

			rq = 0.7 - (0.4 * height);

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

	// Schedule sparse sub bass hits on E1
	gridTimes.do { |gridT, i|
		var height, subAmp, subDecay;

		if((i % 8) == 0, {
			height = if((i / gridTimes.size) < 0.5,
				{ 1 - ((i / gridTimes.size) * 2) },
				{ ((i / gridTimes.size) - 0.5) * 2 }
			);

			subAmp = 0.1 + (0.08 * (1 - height));  // Quieter sub
			subDecay = 0.3 + (0.4 * (1 - height));

			s.sendBundle(gridT, [\s_new, \subHit, -1, 0, 0,
				\out, ~masterBus.index,
				\freq, subFreq,
				\amp, subAmp,
				\decay, subDecay
			]);
		});
	};

	// Counter-rhythm using E minor scale notes
	{
		var counterT = 0;
		var counterMaxInterval = 0.8;
		var counterMinInterval = 0.08;
		var counterInterval, counterHeight, counterProgress;
		var noteIndex = 0;

		{counterT < totalDur}.while({
			counterProgress = counterT / totalDur;
			counterHeight = if(counterProgress < 0.5,
				{ counterProgress * 2 },
				{ 1 - ((counterProgress - 0.5) * 2) }
			);

			counterInterval = counterMinInterval + (counterMaxInterval * (1 - counterHeight).pow(1.5));

			// Cycle through E minor scale notes
			s.sendBundle(counterT, [\s_new, \fmClick, -1, 0, 0,
				\out, ~masterBus.index,
				\freq, counterNotes.wrapAt(noteIndex),
				\ratio, 2.5 + (counterHeight * 1.5),
				\index, 1.5 + (counterHeight * 2.5),
				\decay, 0.04 + (0.08 * counterHeight),
				\lpf, 2000 + (2000 * counterHeight),  // Darker
				\pan, (counterHeight - 0.5) * 0.6,
				\amp, 0.025 + (0.015 * counterHeight)  // Quieter
			]);

			noteIndex = noteIndex + 1;
			counterT = counterT + counterInterval;
		});
	}.value;

	"Scheduled! % grid beats + counter-rhythm".format(gridTimes.size).postln;
}).play;
)
