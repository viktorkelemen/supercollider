// ============================================================
// GENERATIVE TEXTURE DRONE - Evolving atmosphere with bass
// ============================================================

// --------------------------------------------------
// TEXTURE DRONE - Continuous evolving texture with sub bass
// --------------------------------------------------
(
SynthDef(\textureDrone, {
	arg out = 0, amp = 0.3, root = 41.2, // E1
		noiseAmp = 0.15, subAmp = 0.4, harmAmp = 0.25,
		filterLo = 200, filterHi = 3000, filterRes = 0.3;
	var noise, sub, harmonics, sig;
	var lfo1, lfo2, lfo3, filterMod, panMod;

	// Slow LFOs for modulation - different rates for complexity
	lfo1 = LFNoise2.kr(0.03);  // Very slow
	lfo2 = LFNoise2.kr(0.07);  // Slow
	lfo3 = LFNoise1.kr(0.12);  // Slightly faster, stepped

	// Filter modulation - slow sweep
	filterMod = lfo1.range(filterLo, filterHi);

	// === SUB BASS LAYER ===
	// Breathing sub with slight pitch drift
	sub = SinOsc.ar(root * LFNoise2.kr(0.02).range(0.995, 1.005));
	sub = sub + SinOsc.ar(root * 2 * LFNoise2.kr(0.03).range(0.998, 1.002)) * 0.3;
	sub = sub * LFNoise2.kr(0.05).range(0.6, 1);  // Amplitude breathing
	sub = LPF.ar(sub, 120);

	// === NOISE TEXTURE LAYER ===
	// Filtered noise with resonant sweep
	noise = PinkNoise.ar;
	noise = RLPF.ar(noise, filterMod, filterRes + lfo2.range(0, 0.4));
	noise = noise + BPF.ar(BrownNoise.ar, lfo1.range(80, 400), 0.1) * 0.5;

	// Dust for micro-texture
	noise = noise + (Dust.ar(lfo3.range(2, 15)) * 0.08);

	// === HARMONIC LAYER ===
	// Slowly shifting cluster of partials
	harmonics = Mix.fill(6, { |i|
		var partial, freq, detune, localAmp;
		partial = [1, 2, 3, 4, 6, 8][i];
		detune = LFNoise2.kr(0.02 + (i * 0.01)).range(0.99, 1.01);
		freq = root * partial * detune;
		localAmp = LFNoise2.kr(0.04 + (i * 0.02)).range(0.1, 0.6) / (i + 1);
		SinOsc.ar(freq) * localAmp;
	});
	harmonics = LPF.ar(harmonics, lfo2.range(800, 4000));

	// === MIX ===
	sig = (sub * subAmp) + (noise * noiseAmp) + (harmonics * harmAmp);

	// Subtle stereo movement
	panMod = lfo3.range(-0.3, 0.3);
	sig = Balance2.ar(sig, sig, panMod);

	// Final gentle compression
	sig = Limiter.ar(sig, 0.9);

	Out.ar(out, sig * amp);
}).add;
)

// --------------------------------------------------
// TEXTURE GRAIN - Irregular grain events
// --------------------------------------------------
(
SynthDef(\textureGrain, {
	arg out = 0, freq = 200, amp = 0.1, dur = 0.3, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (BPF.ar(WhiteNoise.ar, freq, 0.05) * 0.5);
	sig = sig * env * amp;

	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// BASS PULSE - Occasional deep pulse
// --------------------------------------------------
(
SynthDef(\bassPulse, {
	arg out = 0, freq = 41.2, amp = 0.3, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.1, dur, 1, -4), doneAction: 2);

	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig + (LFTri.ar(freq) * 0.1);
	sig = LPF.ar(sig, 150);
	sig = sig * env * amp;

	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PLAY: Continuous texture drone
// --------------------------------------------------
x = Synth(\textureDrone, [\amp, 0.35, \root, 41.2]);  // E1

// Darker variation
// x = Synth(\textureDrone, [\amp, 0.35, \root, 36.7, \filterHi, 1500, \noiseAmp, 0.1]);  // D1

// Brighter, higher root
// x = Synth(\textureDrone, [\amp, 0.3, \root, 55, \filterHi, 5000, \harmAmp, 0.35]);  // A1

// x.free;

// --------------------------------------------------
// PLAY: With generative grain events
// --------------------------------------------------
(
~grainRoutine = Routine({
	var root = 41.2;
	var scale = [0, 3, 5, 7, 10, 12, 15, 19];  // Minor pentatonic + extensions

	inf.do {
		if (0.3.coin) {  // 30% chance each cycle
			var degree = scale.choose;
			var freq = root * (2 ** (degree / 12));
			var pan = rrand(-0.7, 0.7);
			var dur = rrand(0.2, 0.8);

			Synth(\textureGrain, [
				\freq, freq * [2, 4, 8].choose,  // Higher octaves
				\amp, rrand(0.03, 0.08),
				\dur, dur,
				\pan, pan
			]);
		};
		rrand(0.5, 3.0).wait;  // Irregular timing
	};
}).play;
)

// ~grainRoutine.stop;

// --------------------------------------------------
// PLAY: With occasional bass pulses
// --------------------------------------------------
(
~bassRoutine = Routine({
	var root = 41.2;
	var notes = [0, -5, 3, 7];  // Root, 4th below, minor 3rd, 5th

	inf.do {
		if (0.4.coin) {  // 40% chance
			var note = notes.choose;
			var freq = root * (2 ** (note / 12));

			Synth(\bassPulse, [
				\freq, freq,
				\amp, rrand(0.15, 0.25),
				\dur, rrand(1.5, 4.0)
			]);
		};
		rrand(4.0, 12.0).wait;  // Very sparse
	};
}).play;
)

// ~bassRoutine.stop;

// --------------------------------------------------
// PLAY: Full generative system
// --------------------------------------------------
(
// Start all layers
x = Synth(\textureDrone, [\amp, 0.3, \root, 41.2]);

~grainRoutine = Routine({
	var root = 41.2;
	var scale = [0, 3, 5, 7, 10, 12, 15, 19];
	inf.do {
		if (0.25.coin) {
			var degree = scale.choose;
			var freq = root * (2 ** (degree / 12));
			Synth(\textureGrain, [
				\freq, freq * [2, 4, 8].choose,
				\amp, rrand(0.02, 0.06),
				\dur, rrand(0.2, 0.6),
				\pan, rrand(-0.6, 0.6)
			]);
		};
		rrand(0.8, 4.0).wait;
	};
}).play;

~bassRoutine = Routine({
	var root = 41.2;
	var notes = [0, -5, 3, 7];
	inf.do {
		if (0.35.coin) {
			var note = notes.choose;
			var freq = root * (2 ** (note / 12));
			Synth(\bassPulse, [
				\freq, freq,
				\amp, rrand(0.12, 0.2),
				\dur, rrand(2.0, 5.0)
			]);
		};
		rrand(6.0, 15.0).wait;
	};
}).play;

"Generative texture system running".postln;
)

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// ~grainRoutine.stop; ~bassRoutine.stop; x.free;
// s.freeAll;
