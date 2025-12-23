// ============================================================
// BOUNCING BALL - Interrupted Cycles
// ============================================================
// Explores breaking the predictable bounce arc:
// - Early restarts (ball resets before completing cycle)
// - Jump cuts (sudden position changes within cycle)
// - Asymmetric loops (different up/down durations)

(
~masterBus = Bus.audio(s, 2);

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
	var totalDur = 90;
	var maxInterval = 2.0;
	var minInterval = 0.1;  // Higher floor = more articulate at bottom
	var maxDecay = 2.0;
	var minDecay = 0.012;
	var maxCombDecay = 2.5;
	var minCombDecay = 0.015;

	// E minor chord
	var rootFreq = 40.midicps;
	var thirdFreq = 43.midicps;
	var fifthFreq = 47.midicps;
	var subFreq = 28.midicps;

	// Ball configs: [freq, combFreq, pan, ampScale]
	var balls = [
		[rootFreq, rootFreq * 2, -0.6, 1.0],
		[thirdFreq, thirdFreq * 2, 0, 0.8],
		[fifthFreq, fifthFreq * 2, 0.6, 0.6],
	];

	// Cycle definitions: [startPhase, endPhase, duration]
	// Phase: 0 = top (slow), 0.5 = bottom (fast), 1 = back to top
	// Early restart: endPhase < 1
	// Jump: startPhase != previous endPhase
	var cycles = [
		[0, 0.5, 8],      // Fall only (top to bottom)
		[0.5, 0.8, 4],    // Partial rise
		[0, 0.3, 3],      // Short fall, restart early
		[0.3, 0.7, 5],    // Jump to middle, fall then partial rise
		[0, 0.5, 6],      // Fall again
		[0.5, 1.0, 8],    // Full rise
		[0.2, 0.6, 4],    // Middle section only
		[0.6, 0.2, 5],    // Backwards! (rise then fall)
		[0, 0.4, 3],      // Quick partial fall
		[0.4, 0.9, 6],    // Jump, continue rising
		[0.1, 0.5, 4],    // Near-top to bottom
		[0.5, 0.5, 8],    // Stay at bottom (constant fast)
		[0.5, 0, 10],     // Full rise (reversed direction)
		[0, 0.5, 6],      // Normal fall
		[0.5, 1.0, 8],    // Normal rise to end
	];

	var currentT = 0;
	var cycleIndex = 0;
	var subCounter = 0;
	var hitCounter = 0;  // For accent pattern

	0.5.wait;
	Synth(\masterBus, [\in, ~masterBus.index, \out, 0]);

	"BOUNCING BALL - Interrupted Cycles".postln;
	"Early restarts, jump cuts, asymmetric loops".postln;

	cycles.do { |cycleSpec, ci|
		var startPhase = cycleSpec[0];
		var endPhase = cycleSpec[1];
		var cycleDur = cycleSpec[2];
		var phaseStep, numSteps;
		var t = 0;
		var phase = startPhase;
		var direction = (endPhase - startPhase).sign;

		"Cycle %: phase % -> % over %s".format(ci, startPhase, endPhase, cycleDur).postln;

		// Generate events for this cycle
		{t < cycleDur}.while({
			var height, interval, decay, combDecay, cutoff, rq, verbMix, verbRoom;

			// Height from phase (V shape: 0,1 = top, 0.5 = bottom)
			height = (1 - (phase * 2)).abs;

			// Timing based on height
			interval = (maxInterval * height.pow(2)).max(minInterval);

			// Sound parameters based on height
			decay = (maxDecay * height.pow(1.5)) + minDecay;
			combDecay = (maxCombDecay * height.pow(1.5)) + minCombDecay;
			cutoff = 800 + (7200 * height);
			rq = 0.7 - (0.4 * height);
			verbMix = 0.05 + (0.35 * (1 - height));
			verbRoom = 0.3 + (0.5 * (1 - height));

			// Accent pattern: every 4th hit at bottom gets louder/brighter
			// Only applies when height < 0.3 (near bottom)
			{
				var isAccent = (height < 0.3) && ((hitCounter % 4) == 0);
				var accentAmp = if(isAccent, { 1.4 }, { 1.0 });
				var accentCutoff = if(isAccent, { cutoff * 1.3 }, { cutoff });

				// Schedule all three balls
				balls.do { |ballConfig, bi|
					var freq = ballConfig[0];
					var combFreq = ballConfig[1];
					var pan = ballConfig[2];
					var ampScale = ballConfig[3];
					var timeOffset = bi * 0.02;  // Tiny offset for stereo spread

					s.sendBundle(currentT + t + timeOffset, [\s_new, \combToneFull, -1, 0, 0,
						\out, ~masterBus.index,
						\freq, freq,
						\combFreq, combFreq,
						\combDecay, combDecay.min(maxCombDecay),
						\decay, decay.min(maxDecay),
						\pan, pan,
						\cutoff, accentCutoff.min(12000),
						\rq, rq,
						\verbMix, verbMix,
						\verbRoom, verbRoom,
						\amp, 0.18 * ampScale * accentAmp
					]);
				};
			}.value;
			hitCounter = hitCounter + 1;

			// Sub on every 6th hit
			if((subCounter % 6) == 0, {
				s.sendBundle(currentT + t, [\s_new, \subHit, -1, 0, 0,
					\out, ~masterBus.index,
					\freq, subFreq,
					\amp, 0.1 + (0.08 * (1 - height)),
					\decay, 0.3 + (0.4 * (1 - height))
				]);
			});
			subCounter = subCounter + 1;

			t = t + interval;

			// Update phase based on time progress in cycle
			phase = startPhase + ((endPhase - startPhase) * (t / cycleDur));
			phase = phase.clip(startPhase.min(endPhase), startPhase.max(endPhase));
		});

		currentT = currentT + cycleDur;
	};

	"Scheduled! Total duration: %s".format(currentT).postln;
}).play;
)
