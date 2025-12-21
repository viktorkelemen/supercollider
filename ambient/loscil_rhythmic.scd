// ============================================================
// LOSCIL RHYTHMIC - Pulsing ambient textures
// ============================================================
// Exploring ways to add subtle rhythm to drone textures
// while maintaining the Loscil aesthetic: felt, not heard
// ============================================================

// --------------------------------------------------
// TECHNIQUE 1: SUB-BASS PULSE
// Deep, subsonic swells that create physical rhythm
// --------------------------------------------------
(
SynthDef(\subPulse, {
	arg out = 0, freq = 36.7, rate = 0.25, amp = 0.25, width = 0.5;
	var sig, env;
	// Squared sine creates smoother rise/fall than pure sine
	env = SinOsc.kr(rate, 0.5pi).range(0, 1).pow(width.linlin(0, 1, 0.5, 3));
	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.15); // Subtle second harmonic
	sig = LPF.ar(sig, 80);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// TECHNIQUE 2: BREATHING DRONE
// Main drone with built-in amplitude modulation
// --------------------------------------------------
(
SynthDef(\breathingDrone, {
	arg out = 0, amp = 0.3, root = 55,
		depth = 0.6, warmth = 0.6,
		breathRate = 0.2,    // Breath cycle speed in Hz
		breathDepth = 0.25;  // How much amplitude varies (0-1)
	var drone, harmonics, sub, sig;
	var lfoSlow, lfoMed, tapeMod, breath;
	var numVoices = 6;

	// Slow modulation
	lfoSlow = LFNoise2.kr(0.02);
	lfoMed = LFNoise2.kr(0.05);
	tapeMod = LFNoise2.kr(0.3).range(0.997, 1.003);

	// === BREATHING ENVELOPE ===
	// Asymmetric: slower rise, faster fall (like inhale/exhale)
	breath = LFTri.kr(breathRate, 3).range(0, 1);
	breath = breath.pow(0.7); // Skew toward longer sustain
	breath = breath.linlin(0, 1, 1 - breathDepth, 1);

	// === HARMONIC STACK ===
	harmonics = Mix.fill(numVoices, { |i|
		var freq, detune, voice, partial;
		partial = [1, 1, 2, 3, 4, 5][i];
		detune = LFNoise2.kr(0.02 + (i * 0.008)).range(0.995, 1.005);
		freq = root * partial * detune * tapeMod;

		voice = SinOsc.ar(freq) * 0.5;
		voice = voice + (LFTri.ar(freq) * 0.3);
		voice = LPF.ar(voice, freq * lfoMed.range(4, 10));
		voice * (1 / partial.sqrt) * LFNoise2.kr(0.04).range(0.6, 1);
	});

	harmonics = (harmonics * 1.3).tanh * 0.75;

	// === SUB ===
	sub = SinOsc.ar(root * 0.5 * tapeMod);
	sub = LPF.ar(sub, 90) * 0.4;

	// === COMBINE ===
	drone = harmonics + sub;
	drone = LPF.ar(drone, lfoSlow.range(400, 1500) * (1.2 - depth));
	drone = LPF.ar(drone, 2000);

	// Apply breathing
	sig = drone * breath * warmth;
	sig = Limiter.ar(sig, 0.85);

	Out.ar(out, sig ! 2 * amp);
}).add;
)

// --------------------------------------------------
// TECHNIQUE 3: SIDECHAIN DRONE
// Ducking/pumping effect - the drone breathes around a ghost beat
// --------------------------------------------------
(
SynthDef(\sidechainDrone, {
	arg out = 0, amp = 0.3, root = 55,
		depth = 0.6, warmth = 0.6,
		pumpRate = 0.5,      // Duck rate in Hz (0.5 = every 2 sec)
		pumpDepth = 0.3,     // How much to duck (0-1)
		pumpAttack = 0.02,   // Duck attack time
		pumpRelease = 0.8;   // Duck release time
	var drone, harmonics, sub, sig;
	var lfoSlow, tapeMod, duck, trigger;
	var numVoices = 6;

	lfoSlow = LFNoise2.kr(0.02);
	tapeMod = LFNoise2.kr(0.3).range(0.997, 1.003);

	// === SIDECHAIN PUMP ===
	trigger = Impulse.kr(pumpRate);
	duck = EnvGen.kr(
		Env.perc(pumpAttack, pumpRelease, 1, -4),
		trigger
	);
	duck = 1 - (duck * pumpDepth); // Invert: 1 = full, ducked = lower

	// === HARMONIC STACK ===
	harmonics = Mix.fill(numVoices, { |i|
		var freq, detune, voice, partial;
		partial = [1, 1, 2, 3, 4, 5][i];
		detune = LFNoise2.kr(0.02 + (i * 0.008)).range(0.995, 1.005);
		freq = root * partial * detune * tapeMod;

		voice = SinOsc.ar(freq) * 0.5;
		voice = voice + (LFTri.ar(freq) * 0.3);
		voice = LPF.ar(voice, freq * 6);
		voice * (1 / partial.sqrt);
	});

	harmonics = (harmonics * 1.3).tanh * 0.75;

	sub = SinOsc.ar(root * 0.5 * tapeMod);
	sub = LPF.ar(sub, 90) * 0.4;

	drone = harmonics + sub;
	drone = LPF.ar(drone, lfoSlow.range(500, 1800) * (1.2 - depth));

	// Apply sidechain ducking
	sig = drone * duck * warmth;
	sig = Limiter.ar(sig, 0.85);

	Out.ar(out, sig ! 2 * amp);
}).add;
)

// --------------------------------------------------
// TECHNIQUE 4: FILTER PULSE
// Rhythmic filter opening/closing
// --------------------------------------------------
(
SynthDef(\filterPulseDrone, {
	arg out = 0, amp = 0.3, root = 55,
		depth = 0.6, warmth = 0.6,
		filterRate = 0.25,    // Filter modulation rate
		filterRange = 0.6;    // How much filter sweeps (0-1)
	var drone, harmonics, sub, sig;
	var tapeMod, filterMod, filterEnv;
	var numVoices = 6;

	tapeMod = LFNoise2.kr(0.3).range(0.997, 1.003);

	// === FILTER RHYTHM ===
	// Triangle wave for smooth sweep, slight noise for organic feel
	filterEnv = LFTri.kr(filterRate).range(0, 1);
	filterEnv = filterEnv + (LFNoise2.kr(0.5) * 0.1); // Slight variation
	filterEnv = filterEnv.clip(0, 1);

	// Map to filter frequency
	filterMod = filterEnv.linexp(0, 1,
		200 * (1.5 - depth),
		2000 * (1.5 - depth) * (0.5 + filterRange)
	);

	// === HARMONIC STACK (richer for filter sweep) ===
	harmonics = Mix.fill(numVoices, { |i|
		var freq, detune, voice, partial;
		partial = [1, 1, 2, 2, 3, 4][i];
		detune = LFNoise2.kr(0.02 + (i * 0.008)).range(0.994, 1.006);
		freq = root * partial * detune * tapeMod;

		// Use saw for more harmonics to filter
		voice = LFSaw.ar(freq) * 0.3;
		voice = voice + (SinOsc.ar(freq) * 0.4);
		voice * (1 / partial);
	});

	sub = SinOsc.ar(root * 0.5 * tapeMod);
	sub = LPF.ar(sub, 90) * 0.5;

	drone = harmonics + sub;

	// Apply rhythmic filter
	drone = RLPF.ar(drone, filterMod, 0.5);
	drone = LPF.ar(drone, filterMod * 1.5); // Gentle second stage

	sig = drone * warmth;
	sig = (sig * 1.2).tanh * 0.8; // Soft saturation
	sig = Limiter.ar(sig, 0.85);

	Out.ar(out, sig ! 2 * amp);
}).add;
)

// --------------------------------------------------
// TECHNIQUE 5: DELAY RHYTHM
// Sparse impulses creating echo-based pulse
// --------------------------------------------------
(
SynthDef(\delayRhythm, {
	arg out = 0, amp = 0.1, freq = 200,
		delayTime = 0.5,  // Echo time (0.5 = 120bpm feel)
		feedback = 0.6,   // Echo repetitions
		density = 0.3;    // Impulses per second
	var sig, impulse, delayed;

	// Sparse resonant impulses
	impulse = Dust.ar(density);
	sig = Ringz.ar(impulse, freq * LFNoise2.kr(0.2).range(0.9, 1.1), 0.3);
	sig = sig + Ringz.ar(impulse, freq * 1.5, 0.2) * 0.5;
	sig = sig + Ringz.ar(impulse, freq * 2.5, 0.15) * 0.3;

	// Rhythmic delay
	delayed = sig;
	delayed = CombL.ar(delayed, 2, delayTime, delayTime * feedback * 10);
	delayed = LPF.ar(delayed, 1500); // Darken echoes

	sig = sig + (delayed * 0.7);
	sig = LPF.ar(sig, 3000);
	sig = HPF.ar(sig, 100);

	sig = sig * amp;
	Out.ar(out, Pan2.ar(sig, LFNoise2.kr(0.3).range(-0.5, 0.5)));
}).add;
)

// --------------------------------------------------
// TECHNIQUE 6: GRANULAR STUTTER
// Rhythmic grain clouds
// --------------------------------------------------
(
SynthDef(\grainPulse, {
	arg out = 0, amp = 0.15, freq = 110,
		grainRate = 4,     // Grains per second
		grainDur = 0.15,   // Each grain length
		spread = 0.1;      // Frequency spread
	var sig, trigger, env;

	trigger = Impulse.kr(grainRate);
	env = EnvGen.kr(Env.perc(0.01, grainDur), trigger);

	sig = SinOsc.ar(freq * TRand.kr(1 - spread, 1 + spread, trigger));
	sig = sig + SinOsc.ar(freq * 2 * TRand.kr(0.99, 1.01, trigger)) * 0.3;
	sig = sig + SinOsc.ar(freq * 0.5) * 0.4;

	sig = sig * env;
	sig = LPF.ar(sig, 800);

	sig = sig * amp;
	Out.ar(out, Pan2.ar(sig, TRand.kr(-0.6, 0.6, trigger)));
}).add;
)

// --------------------------------------------------
// TECHNIQUE 7: PROBABILISTIC DRUMS
// Grid-locked but randomly skipping beats
// --------------------------------------------------
(
SynthDef(\probKick, {
	arg out = 0, amp = 0.2, freq = 45,
		rate = 0.5, prob = 0.7, decay = 0.5;
	var sig, env, pitchEnv, trigger, gate, gatedTrig;

	// Grid trigger
	trigger = Impulse.kr(rate);
	// Random gate - coin flip each beat
	gate = TRand.kr(0, 1, trigger) < prob;
	gatedTrig = trigger * gate;

	pitchEnv = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), gatedTrig);
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -6), gatedTrig);

	sig = SinOsc.ar(freq + (pitchEnv * freq * 3.5));
	sig = sig * env;
	sig = (sig * 1.3).tanh * amp;

	Out.ar(out, sig ! 2);
}).add;
)

(
SynthDef(\probRim, {
	arg out = 0, amp = 0.1, freq = 350,
		rate = 0.5, prob = 0.4, decay = 0.12;
	var sig, env, trigger, gate, gatedTrig;

	trigger = Impulse.kr(rate);
	gate = TRand.kr(0, 1, trigger) < prob;
	gatedTrig = trigger * gate;

	env = EnvGen.kr(Env.perc(0.002, decay, 1, -8), gatedTrig);

	sig = Ringz.ar(K2A.ar(gatedTrig), freq * TRand.kr(0.95, 1.05, gatedTrig), 0.03) * 0.4;
	sig = sig + Ringz.ar(K2A.ar(gatedTrig), freq * 1.8, 0.02) * 0.3;
	sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.kr(Env.perc(0.001, 0.04), gatedTrig) * 0.25);

	sig = LPF.ar(sig, 2200);
	sig = HPF.ar(sig, 180);
	sig = sig * env * amp;

	Out.ar(out, Pan2.ar(sig, TRand.kr(-0.4, 0.4, gatedTrig)));
}).add;
)

(
SynthDef(\probHat, {
	arg out = 0, amp = 0.05, rate = 1, prob = 0.5, decay = 0.08, tone = 6500;
	var sig, env, trigger, gate, gatedTrig;

	trigger = Impulse.kr(rate);
	gate = TRand.kr(0, 1, trigger) < prob;
	gatedTrig = trigger * gate;

	env = EnvGen.kr(Env.perc(0.003, decay * TRand.kr(0.7, 1.3, gatedTrig), 1, -6), gatedTrig);

	sig = WhiteNoise.ar * 0.4 + (PinkNoise.ar * 0.6);
	sig = BPF.ar(sig, tone * TRand.kr(0.85, 1.15, gatedTrig), 0.25);
	sig = HPF.ar(sig, 2500);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, TRand.kr(-0.6, 0.6, gatedTrig)));
}).add;
)

// --------------------------------------------------
// STATIC DRONE (non-rhythmic base layer)
// --------------------------------------------------
(
SynthDef(\staticDrone, {
	arg out = 0, amp = 0.25, root = 55, depth = 0.6;
	var drone, harmonics, sig;
	var lfoSlow, tapeMod;
	var numVoices = 6;

	lfoSlow = LFNoise2.kr(0.015);
	tapeMod = LFNoise2.kr(0.3).range(0.997, 1.003);

	harmonics = Mix.fill(numVoices, { |i|
		var freq, detune, voice, partial;
		partial = [1, 1, 2, 3, 4, 5][i];
		detune = LFNoise2.kr(0.02 + (i * 0.008)).range(0.995, 1.005);
		freq = root * partial * detune * tapeMod;

		voice = SinOsc.ar(freq) * 0.5;
		voice = voice + (LFTri.ar(freq) * 0.3);
		voice = LPF.ar(voice, freq * 6);
		voice * (1 / partial.sqrt);
	});

	harmonics = (harmonics * 1.3).tanh * 0.7;

	drone = harmonics;
	drone = LPF.ar(drone, lfoSlow.range(400, 1200) * (1.2 - depth));

	sig = Limiter.ar(drone, 0.85);
	Out.ar(out, sig ! 2 * amp);
}).add;
)

// ============================================================
// PLAY EXAMPLES
// ============================================================

// --------------------------------------------------
// EXAMPLE 1: Breathing Drone (simplest rhythmic feel)
// --------------------------------------------------
// x = Synth(\breathingDrone, [\amp, 0.35, \root, 55, \breathRate, 0.15, \breathDepth, 0.3]);
// x.free;

// --------------------------------------------------
// EXAMPLE 2: Sub-bass pulse under static drone
// --------------------------------------------------
(
// x = Synth(\staticDrone, [\amp, 0.25, \root, 55, \depth, 0.5]);
// y = Synth(\subPulse, [\freq, 27.5, \rate, 0.2, \amp, 0.3, \width, 0.6]);
)
// x.free; y.free;

// --------------------------------------------------
// EXAMPLE 3: Sidechain pumping drone
// --------------------------------------------------
// x = Synth(\sidechainDrone, [\amp, 0.35, \root, 41.2, \pumpRate, 0.33, \pumpDepth, 0.35, \pumpRelease, 1.2]);
// x.free;

// --------------------------------------------------
// EXAMPLE 4: Filter pulse (techno-ish but subtle)
// --------------------------------------------------
// x = Synth(\filterPulseDrone, [\amp, 0.3, \root, 55, \filterRate, 0.25, \filterRange, 0.7, \depth, 0.4]);
// x.free;

// --------------------------------------------------
// EXAMPLE 5: Layered rhythmic texture
// --------------------------------------------------
(
// Base drone
// a = Synth(\staticDrone, [\amp, 0.2, \root, 55, \depth, 0.6]);

// Sub pulse underneath
// b = Synth(\subPulse, [\freq, 27.5, \rate, 0.167, \amp, 0.25]); // 6 sec cycle

// Delay rhythm on top
// c = Synth(\delayRhythm, [\amp, 0.08, \freq, 220, \delayTime, 0.75, \density, 0.2]);

// Grain accents
// d = Synth(\grainPulse, [\amp, 0.06, \freq, 146.8, \grainRate, 0.5, \grainDur, 0.2]);
)
// a.free; b.free; c.free; d.free;
// s.freeAll;

// --------------------------------------------------
// EXAMPLE 6: Pressure hull with pulse (ominous)
// --------------------------------------------------
(
// Sidechain for that underwater compression feel
// x = Synth(\sidechainDrone, [
//     \amp, 0.35,
//     \root, 36.7,      // D1 - ominous
//     \depth, 0.75,
//     \warmth, 0.4,
//     \pumpRate, 0.25,  // Slow pump
//     \pumpDepth, 0.4,
//     \pumpRelease, 1.5
// ]);

// Deep sub pulse
// y = Synth(\subPulse, [\freq, 30.9, \rate, 0.125, \amp, 0.28, \width, 0.7]);
)
// x.free; y.free;

// --------------------------------------------------
// EXAMPLE 7: Explicit pump (classic sidechain feel)
// --------------------------------------------------
(
x = Synth(\sidechainDrone, [
	\amp, 0.4,
	\root, 41.2,       // E1
	\depth, 0.5,
	\warmth, 0.6,
	\pumpRate, 0.5,    // 2 sec cycle - faster, more obvious
	\pumpDepth, 0.6,   // Deep duck
	\pumpRelease, 0.6  // Tight release
]);

y = Synth(\subPulse, [\freq, 27.5, \rate, 0.25, \amp, 0.32, \width, 0.4]);
)
// x.free; y.free;

// --------------------------------------------------
// EXAMPLE 8: Probabilistic drums (dub techno feel)
// --------------------------------------------------
(
// Pumping drone base
a = Synth(\sidechainDrone, [
	\amp, 0.35,
	\root, 41.2,
	\depth, 0.5,
	\warmth, 0.6,
	\pumpRate, 0.5,
	\pumpDepth, 0.5,
	\pumpRelease, 0.7
]);

// Sub pulse
b = Synth(\subPulse, [\freq, 27.5, \rate, 0.25, \amp, 0.25, \width, 0.5]);

// Probabilistic drums - grid-locked but random
c = Synth(\probKick, [\freq, 45, \rate, 0.5, \prob, 0.75, \amp, 0.2, \decay, 0.55]);
d = Synth(\probRim, [\freq, 320, \rate, 0.5, \prob, 0.35, \amp, 0.1, \decay, 0.1]);
e = Synth(\probHat, [\rate, 1, \prob, 0.45, \amp, 0.04, \decay, 0.09, \tone, 7000]);
)
// a.free; b.free; c.free; d.free; e.free;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;

// ============================================================
// NOTES ON USAGE
// ============================================================
//
// Rate/tempo relationships:
//   0.125 Hz = 8 second cycle
//   0.167 Hz = 6 second cycle
//   0.25 Hz  = 4 second cycle
//   0.33 Hz  = 3 second cycle
//   0.5 Hz   = 2 second cycle
//   1.0 Hz   = 1 second cycle
//
// For Loscil-style, stay in 0.1 - 0.3 Hz range (3-10 second cycles)
// Faster rates (0.5+) start feeling more like traditional electronic music
//
// Layer combinations that work well:
//   - staticDrone + subPulse (felt bass movement)
//   - breathingDrone alone (self-contained)
//   - sidechainDrone + delayRhythm (hypnotic)
//   - filterPulseDrone + grainPulse (textural)
//
// ============================================================
