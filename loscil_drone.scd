// ============================================================
// LOSCIL-INSPIRED DRONE - Submerged, warm, lo-fi texture
// ============================================================
// Inspired by Scott Morgan's approach:
// - Warmth over cold digital synthesis
// - Tape-like degradation and hiss
// - Underwater/submarine pressure feel
// - Very slow evolution, loop-based
// - Spectral smearing and convolution-like textures

// --------------------------------------------------
// SUBMERGED DRONE - Deep underwater atmosphere
// --------------------------------------------------
(
SynthDef(\submergedDrone, {
	arg out = 0, amp = 0.3, root = 55, // A1
		depth = 0.7, // 0-1, how "submerged" (darker = deeper)
		warmth = 0.6, hissAmp = 0.04, wowFlutter = 0.003;
	var drone, harmonics, sub, hiss, sig;
	var lfoSlow, lfoMed, filterMod, tapeMod;
	var numVoices = 8;

	// Very slow modulation - Loscil patience
	lfoSlow = LFNoise2.kr(0.015);
	lfoMed = LFNoise2.kr(0.04);

	// Tape wow and flutter
	tapeMod = LFNoise2.kr(0.3).range(1 - wowFlutter, 1 + wowFlutter);
	tapeMod = tapeMod * LFNoise2.kr(2.5).range(0.999, 1.001); // Flutter

	// === WARM HARMONIC DRONE ===
	// Multiple detuned voices - more like sampled strings than synths
	harmonics = Mix.fill(numVoices, { |i|
		var freq, detune, vibrato, voice, partial;

		partial = [1, 1, 2, 2, 3, 4, 5, 6][i];
		detune = LFNoise2.kr(0.02 + (i * 0.005)).range(0.994, 1.006);
		vibrato = SinOsc.kr(0.08 + (i * 0.02), Rand(0, 2pi)).range(0.998, 1.002);
		freq = root * partial * detune * vibrato * tapeMod;

		// Mix of waveforms for warmth - less pure sine
		voice = SinOsc.ar(freq) * 0.6;
		voice = voice + (LFTri.ar(freq) * 0.25);
		voice = voice + (LFPar.ar(freq) * 0.15); // Parabolic - softer than saw

		// Individual filtering per voice
		voice = LPF.ar(voice, freq * lfoMed.range(3, 8));

		voice * (1 / (partial.sqrt)) * LFNoise2.kr(0.03 + (i * 0.01)).range(0.5, 1);
	});

	// Gentle saturation for warmth
	harmonics = (harmonics * 1.5).tanh * 0.7;

	// === SUB PRESSURE ===
	// Deep sub with slow breathing - underwater pressure
	sub = SinOsc.ar(root * 0.5 * tapeMod);
	sub = sub + (SinOsc.ar(root * tapeMod) * 0.4);
	sub = sub * LFNoise2.kr(0.02).range(0.4, 1);
	sub = LPF.ar(sub, 100);

	// === TAPE HISS / ROOM TONE ===
	// Lo-fi texture - not white noise, more like tape + room
	hiss = PinkNoise.ar * 0.6;
	hiss = hiss + (BrownNoise.ar * 0.4);
	hiss = HPF.ar(hiss, 400);
	hiss = LPF.ar(hiss, 6000 * (1 - (depth * 0.5)));
	// Subtle movement in hiss
	hiss = hiss * LFNoise2.kr(0.1).range(0.7, 1);

	// === SPECTRAL SMEAR ===
	// Comb filtering for metallic resonance (like convolution artifacts)
	drone = harmonics + (sub * 0.5);
	drone = drone + CombL.ar(drone, 0.25, lfoSlow.range(0.02, 0.08), 2) * 0.15;
	drone = drone + CombL.ar(drone, 0.25, lfoMed.range(0.03, 0.12), 1.5) * 0.1;

	// === SUBMERSION FILTER ===
	// Depth control - like being underwater
	filterMod = lfoSlow.range(
		200 + ((1 - depth) * 800),
		1200 + ((1 - depth) * 3000)
	);
	drone = LPF.ar(drone, filterMod);
	drone = LPF.ar(drone, filterMod * 1.5); // Double filter for steeper rolloff

	// === MIX ===
	sig = (drone * warmth) + (hiss * hissAmp);

	// Subtle stereo from decorrelated noise
	sig = sig + (LPF.ar(PinkNoise.ar([1, 1]) * 0.01, 2000) * depth);

	// Final gentle limiting
	sig = Limiter.ar(sig, 0.85);

	Out.ar(out, sig ! 2 * amp);
}).add;
)

// --------------------------------------------------
// HYDROPHONE - Underwater mechanical sounds
// --------------------------------------------------
(
SynthDef(\hydrophone, {
	arg out = 0, amp = 0.1, freq = 200, dur = 3, depth = 0.7;
	var sig, env, resonance;

	env = EnvGen.kr(Env.perc(0.1, dur, 1, -4), doneAction: 2);

	// Metallic ping - like distant submarine machinery
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2.3) * 0.2);
	sig = sig + (SinOsc.ar(freq * 4.7) * 0.1);

	// Resonant body
	resonance = Ringz.ar(Impulse.ar(0), freq, dur * 0.5) * 0.3;
	sig = sig + resonance;

	// Heavy filtering - underwater
	sig = LPF.ar(sig, 800 * (1 - (depth * 0.6)));
	sig = LPF.ar(sig, 1200);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.2).range(-0.5, 0.5)));
}).add;
)

// --------------------------------------------------
// PRESSURE SHIFT - Deep bass movement
// --------------------------------------------------
(
SynthDef(\pressureShift, {
	arg out = 0, amp = 0.25, startFreq = 40, endFreq = 55, dur = 8;
	var sig, env, freq;

	env = EnvGen.kr(Env.linen(dur * 0.3, dur * 0.4, dur * 0.3, 1, \sin), doneAction: 2);
	freq = XLine.kr(startFreq, endFreq, dur);

	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = LPF.ar(sig, 120);

	// Subtle beating
	sig = sig * (1 + (SinOsc.kr(0.5) * 0.1));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// TAPE LOOP - Degraded, looping texture
// --------------------------------------------------
(
SynthDef(\tapeLoop, {
	arg out = 0, amp = 0.15, freq = 110, loopTime = 4, decay = 6;
	var sig, loop, env;

	env = EnvGen.kr(Env.linen(2, decay, 3, 1, \sin), doneAction: 2);

	// Source tone
	sig = LFTri.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.3);

	// Feedback delay simulating tape loop
	loop = CombL.ar(sig, loopTime, loopTime, decay * 2);
	loop = LPF.ar(loop, 2000); // Tape roll-off
	loop = HPF.ar(loop, 60);

	// Wow and flutter on the loop
	loop = DelayL.ar(loop, 0.1, SinOsc.kr(0.2).range(0.01, 0.03));

	sig = (sig * 0.3) + (loop * 0.7);
	sig = sig * env * amp;

	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PLAY: Basic submerged drone
// --------------------------------------------------
x = Synth(\submergedDrone, [\amp, 0.35, \root, 55, \depth, 0.6]);

// Deeper, darker
// x = Synth(\submergedDrone, [\amp, 0.35, \root, 41.2, \depth, 0.85, \warmth, 0.5]);

// Shallower, brighter
// x = Synth(\submergedDrone, [\amp, 0.3, \root, 73.4, \depth, 0.3, \warmth, 0.7]);

// x.free;

// --------------------------------------------------
// PLAY: Full generative system (Submers-inspired)
// --------------------------------------------------
(
// Main drone
x = Synth(\submergedDrone, [\amp, 0.3, \root, 55, \depth, 0.65, \hissAmp, 0.03]);

// Occasional hydrophone pings
~hydrophoneRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			var freq = [100, 150, 200, 280, 340].choose;
			Synth(\hydrophone, [
				\freq, freq,
				\amp, rrand(0.04, 0.1),
				\dur, rrand(2, 5),
				\depth, rrand(0.5, 0.8)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

// Slow pressure shifts
~pressureRoutine = Routine({
	var roots = [36.7, 41.2, 49, 55, 61.7]; // D1, E1, G1, A1, B1
	inf.do {
		if (0.3.coin) {
			var start = roots.choose;
			var end = roots.choose;
			Synth(\pressureShift, [
				\startFreq, start,
				\endFreq, end,
				\amp, rrand(0.1, 0.2),
				\dur, rrand(6, 15)
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

// Rare tape loops
~tapeRoutine = Routine({
	var notes = [55, 73.4, 82.4, 110]; // A1, D2, E2, A2
	inf.do {
		if (0.15.coin) {
			Synth(\tapeLoop, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.12),
				\loopTime, rrand(2, 6),
				\decay, rrand(4, 10)
			]);
		};
		rrand(30, 90).wait;
	};
}).play;

"Submerged drone system running - Loscil inspired".postln;
)

// --------------------------------------------------
// PLAY: Minimal version - just drone + pressure
// --------------------------------------------------
(
x = Synth(\submergedDrone, [\amp, 0.35, \root, 55, \depth, 0.7, \hissAmp, 0.025]);

~pressureRoutine = Routine({
	var roots = [41.2, 49, 55];
	inf.do {
		if (0.25.coin) {
			Synth(\pressureShift, [
				\startFreq, roots.choose,
				\endFreq, roots.choose,
				\amp, rrand(0.12, 0.18),
				\dur, rrand(8, 20)
			]);
		};
		rrand(20, 50).wait;
	};
}).play;

"Minimal submerged drone running".postln;
)

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// ~hydrophoneRoutine.stop; ~pressureRoutine.stop; ~tapeRoutine.stop; x.free;
// s.freeAll;
