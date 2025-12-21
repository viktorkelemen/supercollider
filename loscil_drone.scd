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

// ============================================================
// VARIATIONS
// ============================================================

// --------------------------------------------------
// VARIATION 1: ABYSS - Maximum depth, near silence
// --------------------------------------------------
(
~stopAll = { ~hydrophoneRoutine.stop; ~pressureRoutine.stop; ~tapeRoutine.stop; x.free };

x = Synth(\submergedDrone, [
	\amp, 0.4,
	\root, 32.7,  // C1 - very low
	\depth, 0.95,
	\warmth, 0.35,
	\hissAmp, 0.015,
	\wowFlutter, 0.002
]);

~pressureRoutine = Routine({
	var roots = [27.5, 32.7, 36.7]; // A0, C1, D1
	inf.do {
		if (0.2.coin) {
			Synth(\pressureShift, [
				\startFreq, roots.choose,
				\endFreq, roots.choose,
				\amp, rrand(0.15, 0.25),
				\dur, rrand(12, 30)
			]);
		};
		rrand(30, 80).wait;
	};
}).play;

"ABYSS - Crushing depth, minimal light".postln;
)

// --------------------------------------------------
// VARIATION 2: ARCTIC - Cold, sparse, crystalline
// --------------------------------------------------
(
SynthDef(\iceCreak, {
	arg out = 0, amp = 0.08, freq = 800, dur = 0.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, dur, 1, -8), doneAction: 2);
	sig = Ringz.ar(Dust.ar(20), freq * LFNoise2.kr(10).range(0.9, 1.1), 0.1);
	sig = sig + Ringz.ar(Dust.ar(10), freq * 1.5, 0.05) * 0.5;
	sig = HPF.ar(sig, 400);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.5).range(-0.8, 0.8)));
}).add;
)

(
~stopAll.value;

x = Synth(\submergedDrone, [
	\amp, 0.3,
	\root, 82.4,  // E2 - higher, colder
	\depth, 0.4,
	\warmth, 0.3,  // Less warmth = colder
	\hissAmp, 0.05,
	\wowFlutter, 0.001
]);

// Ice creaking
~iceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\iceCreak, [
				\freq, rrand(600, 2000),
				\amp, rrand(0.03, 0.08),
				\dur, rrand(0.2, 0.8)
			]);
		};
		rrand(3, 12).wait;
	};
}).play;

// Sparse high pings
~hydrophoneRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\hydrophone, [
				\freq, rrand(400, 800),
				\amp, rrand(0.02, 0.05),
				\dur, rrand(1, 3),
				\depth, 0.3
			]);
		};
		rrand(15, 40).wait;
	};
}).play;

"ARCTIC - Frozen waters, distant ice".postln;
)

// --------------------------------------------------
// VARIATION 3: INDUSTRIAL HARBOR - Mechanical, port
// --------------------------------------------------
(
SynthDef(\shipEngine, {
	arg out = 0, amp = 0.15, freq = 30, dur = 10;
	var sig, env, rumble;
	env = EnvGen.kr(Env.linen(2, dur - 4, 2, 1, \sin), doneAction: 2);

	// Low engine rumble
	rumble = Mix([
		SinOsc.ar(freq) * 0.5,
		SinOsc.ar(freq * 1.5) * 0.3,
		SinOsc.ar(freq * 2) * 0.2
	]);
	rumble = rumble * LFNoise2.kr(0.5).range(0.7, 1);

	// Engine chug
	sig = rumble * (1 + (LFPulse.kr(freq / 10, 0, 0.3) * 0.3));
	sig = LPF.ar(sig, 150);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\chainClank, {
	arg out = 0, amp = 0.1, freq = 300;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.005, 0.4, 1, -6), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, 0.15) * 0.5;
	sig = sig + Ringz.ar(Impulse.ar(0), freq * 2.7, 0.1) * 0.3;
	sig = sig + Ringz.ar(Impulse.ar(0), freq * 4.2, 0.08) * 0.2;
	sig = HPF.ar(sig, 200);
	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.6, 0.6)));
}).add;
)

(
~stopAll.value;

x = Synth(\submergedDrone, [
	\amp, 0.25,
	\root, 41.2,  // E1
	\depth, 0.5,
	\warmth, 0.5,
	\hissAmp, 0.06
]);

// Ship engines passing
~engineRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\shipEngine, [
				\freq, rrand(25, 40),
				\amp, rrand(0.1, 0.18),
				\dur, rrand(8, 20)
			]);
		};
		rrand(20, 60).wait;
	};
}).play;

// Chain and metal sounds
~chainRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\chainClank, [
				\freq, rrand(200, 500),
				\amp, rrand(0.04, 0.1)
			]);
		};
		rrand(4, 15).wait;
	};
}).play;

// More frequent hydrophone
~hydrophoneRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\hydrophone, [
				\freq, rrand(150, 400),
				\amp, rrand(0.05, 0.1),
				\dur, rrand(1.5, 4),
				\depth, 0.5
			]);
		};
		rrand(6, 18).wait;
	};
}).play;

"INDUSTRIAL HARBOR - Machinery and commerce".postln;
)

// --------------------------------------------------
// VARIATION 4: KELP FOREST - Organic, swaying
// --------------------------------------------------
(
SynthDef(\kelpSway, {
	arg out = 0, amp = 0.1, freq = 220, dur = 4;
	var sig, env, sway;
	env = EnvGen.kr(Env.linen(1, dur - 2, 1, 1, \sin), doneAction: 2);

	// Organic swaying motion
	sway = SinOsc.kr(0.2 + Rand(0, 0.1)).range(0.95, 1.05);

	sig = SinOsc.ar(freq * sway) * 0.5;
	sig = sig + SinOsc.ar(freq * 2 * sway) * 0.25;
	sig = sig + SinOsc.ar(freq * 3 * sway) * 0.15;
	sig = sig + SinOsc.ar(freq * 5 * sway) * 0.1;

	sig = LPF.ar(sig, freq * 4 * LFNoise2.kr(0.3).range(0.8, 1.2));
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, SinOsc.kr(0.15).range(-0.5, 0.5)));
}).add;

SynthDef(\bubbles, {
	arg out = 0, amp = 0.05, density = 3;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.5, 2, 0.5, 1), doneAction: 2);
	sig = Ringz.ar(Dust.ar(density), TRand.kr(800, 2000, Dust.kr(density)), 0.05);
	sig = HPF.ar(sig, 600);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(1).range(-0.7, 0.7)));
}).add;
)

(
~stopAll.value;

x = Synth(\submergedDrone, [
	\amp, 0.28,
	\root, 55,  // A1
	\depth, 0.45,
	\warmth, 0.7,  // Warmer, more life
	\hissAmp, 0.03
]);

// Kelp fronds swaying
~kelpRoutine = Routine({
	var notes = [110, 146.8, 164.8, 196, 220]; // A2, D3, E3, G3, A3
	inf.do {
		if (0.4.coin) {
			Synth(\kelpSway, [
				\freq, notes.choose,
				\amp, rrand(0.04, 0.1),
				\dur, rrand(3, 8)
			]);
		};
		rrand(2, 8).wait;
	};
}).play;

// Occasional bubbles
~bubbleRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\bubbles, [
				\density, rrand(2, 6),
				\amp, rrand(0.02, 0.05)
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

// Gentle pressure shifts
~pressureRoutine = Routine({
	var roots = [49, 55, 73.4];
	inf.do {
		if (0.2.coin) {
			Synth(\pressureShift, [
				\startFreq, roots.choose,
				\endFreq, roots.choose,
				\amp, rrand(0.08, 0.15),
				\dur, rrand(6, 12)
			]);
		};
		rrand(15, 35).wait;
	};
}).play;

"KELP FOREST - Sunlit, swaying, alive".postln;
)

// --------------------------------------------------
// VARIATION 5: PRESSURE HULL - Creaking metal stress
// --------------------------------------------------
(
SynthDef(\hullCreak, {
	arg out = 0, amp = 0.12, freq = 150, dur = 1.5;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);

	// Metal stress - descending pitch
	sig = SinOsc.ar(XLine.kr(freq, freq * 0.7, dur)) * 0.4;
	sig = sig + SinOsc.ar(XLine.kr(freq * 2.1, freq * 1.5, dur)) * 0.25;
	sig = sig + SinOsc.ar(XLine.kr(freq * 3.7, freq * 2.8, dur)) * 0.15;

	// Add some noise burst
	sig = sig + (BPF.ar(WhiteNoise.ar, freq, 0.1) * EnvGen.kr(Env.perc(0.01, 0.1)) * 0.3);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.8, 0.8)));
}).add;

SynthDef(\rivets, {
	arg out = 0, amp = 0.08;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.15, 1, -8), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), Rand(1000, 3000), 0.08);
	sig = HPF.ar(sig, 800);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, Rand(-0.9, 0.9)));
}).add;
)

(
~stopAll.value;

x = Synth(\submergedDrone, [
	\amp, 0.35,
	\root, 36.7,  // D1 - ominous
	\depth, 0.8,
	\warmth, 0.4,
	\hissAmp, 0.02,
	\wowFlutter, 0.004  // More instability
]);

// Hull creaking under pressure
~creakRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\hullCreak, [
				\freq, rrand(80, 250),
				\amp, rrand(0.06, 0.14),
				\dur, rrand(0.8, 2.5)
			]);
		};
		rrand(5, 20).wait;
	};
}).play;

// Rivet pings
~rivetRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\rivets, [\amp, rrand(0.03, 0.08)]);
		};
		rrand(3, 12).wait;
	};
}).play;

// Heavy pressure
~pressureRoutine = Routine({
	var roots = [30.9, 36.7, 41.2]; // B0, D1, E1
	inf.do {
		if (0.3.coin) {
			Synth(\pressureShift, [
				\startFreq, roots.choose,
				\endFreq, roots.choose * rrand(0.9, 1.1),
				\amp, rrand(0.18, 0.28),
				\dur, rrand(10, 25)
			]);
		};
		rrand(12, 35).wait;
	};
}).play;

"PRESSURE HULL - Descent into the crush".postln;
)

// --------------------------------------------------
// VARIATION 6: NIGHT SURFACE - Calm, reflective
// --------------------------------------------------
(
SynthDef(\surfaceRipple, {
	arg out = 0, amp = 0.08, freq = 400, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.1, dur, 1, -3), doneAction: 2);

	sig = SinOsc.ar(freq * LFNoise2.kr(2).range(0.98, 1.02)) * 0.6;
	sig = sig + SinOsc.ar(freq * 2 * LFNoise2.kr(1.5).range(0.99, 1.01)) * 0.3;
	sig = sig + SinOsc.ar(freq * 0.5) * 0.2;

	sig = LPF.ar(sig, 2000);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.3).range(-0.6, 0.6)));
}).add;
)

(
~stopAll.value;

x = Synth(\submergedDrone, [
	\amp, 0.3,
	\root, 55,
	\depth, 0.25,  // Shallow - near surface
	\warmth, 0.65,
	\hissAmp, 0.035
]);

// Surface ripples
~rippleRoutine = Routine({
	var notes = [220, 293.7, 329.6, 392, 440]; // A3, D4, E4, G4, A4
	inf.do {
		if (0.3.coin) {
			Synth(\surfaceRipple, [
				\freq, notes.choose,
				\amp, rrand(0.03, 0.07),
				\dur, rrand(1.5, 4)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Gentle tape loops
~tapeRoutine = Routine({
	var notes = [110, 146.8, 164.8];
	inf.do {
		if (0.2.coin) {
			Synth(\tapeLoop, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.1),
				\loopTime, rrand(3, 6),
				\decay, rrand(5, 10)
			]);
		};
		rrand(25, 60).wait;
	};
}).play;

"NIGHT SURFACE - Stars reflected on still water".postln;
)

// --------------------------------------------------
// STOP VARIATIONS
// --------------------------------------------------
// ~stopAll.value;
// ~iceRoutine.stop; ~engineRoutine.stop; ~chainRoutine.stop;
// ~kelpRoutine.stop; ~bubbleRoutine.stop;
// ~creakRoutine.stop; ~rivetRoutine.stop; ~rippleRoutine.stop;
// s.freeAll;
