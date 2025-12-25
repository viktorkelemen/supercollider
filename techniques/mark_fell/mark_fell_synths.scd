// ============================================================
// MARK FELL STYLE SYNTHS - Minimal, precise, algorithmic
// ============================================================
// Design principles:
// - Clean, precise timbres
// - Resonant filters for color
// - FM for metallic/bell tones
// - Pulse waves with variable width
// - Everything serves the rhythm

// --------------------------------------------------
// 1. RESONANT CLICK - Click with filter sweep
// --------------------------------------------------
(
SynthDef(\resClick, {
	arg out = 0, amp = 0.2, freq = 2000, res = 0.5, decay = 0.03, pan = 0;
	var sig, env, fenv;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);
	// Filter envelope - starts high, sweeps down
	fenv = EnvGen.kr(Env.perc(0.001, decay * 0.5, 1, -4));

	// Impulse through resonant filter
	sig = Impulse.ar(0);
	sig = RLPF.ar(sig, freq * (1 + (fenv * 2)), 1 - res);

	sig = sig * env * amp * 10;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\resClick, [\freq, 3000, \res, 0.8, \decay, 0.05]);

// --------------------------------------------------
// 2. FM CLICK - Metallic FM percussion
// --------------------------------------------------
(
SynthDef(\fmClick, {
	arg out = 0, amp = 0.2, freq = 800, ratio = 3.5, index = 4, decay = 0.08, pan = 0;
	var sig, env, mod;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -6), doneAction: 2);

	// FM: carrier + modulator
	mod = SinOsc.ar(freq * ratio) * freq * index * env;
	sig = SinOsc.ar(freq + mod);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\fmClick, [\freq, 600, \ratio, 2.7, \index, 3, \decay, 0.1]);

// --------------------------------------------------
// 3. PULSE TONE - Variable pulse width
// --------------------------------------------------
(
SynthDef(\pulseTone, {
	arg out = 0, amp = 0.15, freq = 440, width = 0.5, decay = 0.1,
	    cutoff = 2000, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);

	sig = Pulse.ar(freq, width);
	sig = LPF.ar(sig, cutoff);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\pulseTone, [\freq, 330, \width, 0.2, \cutoff, 1500]);

// --------------------------------------------------
// 4. COMB TONE - Metallic comb filter resonance
// --------------------------------------------------
(
SynthDef(\combTone, {
	arg out = 0, amp = 0.2, freq = 200, combFreq = 400,
	    combDecay = 0.1, decay = 0.15, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	// Noise burst through comb filter
	sig = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = CombL.ar(sig, 0.05, combFreq.reciprocal, combDecay);

	// Add pitched element
	sig = sig + (SinOsc.ar(freq) * 0.3);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\combTone, [\freq, 150, \combFreq, 300, \combDecay, 0.2]);

// --------------------------------------------------
// 5. FILTERED NOISE - Percussive noise burst
// --------------------------------------------------
(
SynthDef(\filtNoise, {
	arg out = 0, amp = 0.15, freq = 1000, bw = 0.5, decay = 0.05, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig, freq, bw);

	sig = sig * env * amp * 5;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\filtNoise, [\freq, 2000, \bw, 0.3, \decay, 0.03]);

// --------------------------------------------------
// 6. RING MOD TONE - Ring modulation texture
// --------------------------------------------------
(
SynthDef(\ringTone, {
	arg out = 0, amp = 0.15, freq = 300, modFreq = 150, decay = 0.12, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);

	// Ring modulation creates sum and difference frequencies
	sig = SinOsc.ar(freq) * SinOsc.ar(modFreq);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\ringTone, [\freq, 400, \modFreq, 170]);

// --------------------------------------------------
// 7. FORMANT CLICK - Vowel-like resonance
// --------------------------------------------------
(
SynthDef(\formantClick, {
	arg out = 0, amp = 0.2, freq = 200, formant = 800, bw = 80,
	    decay = 0.08, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay, 1, -6), doneAction: 2);

	// Impulse through formant filter
	sig = Impulse.ar(0);
	sig = BBandPass.ar(sig, formant, bw) * 20;
	sig = sig + (SinOsc.ar(freq) * 0.2); // Add fundamental

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\formantClick, [\freq, 150, \formant, 600, \bw, 100]);

// --------------------------------------------------
// 8. DUAL SINE - Two detuned sines for beating
// --------------------------------------------------
(
SynthDef(\dualSine, {
	arg out = 0, amp = 0.15, freq = 440, detune = 2, decay = 0.2, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);

	// Two slightly detuned sines create beating
	sig = SinOsc.ar(freq) + SinOsc.ar(freq + detune);
	sig = sig * 0.5;

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\dualSine, [\freq, 330, \detune, 3, \decay, 0.3]);

// --------------------------------------------------
// 9. SUB CLICK - Sub bass with transient click
// --------------------------------------------------
(
SynthDef(\subClick, {
	arg out = 0, amp = 0.3, freq = 50, clickFreq = 1500, decay = 0.2;
	var sig, env, click, clickEnv;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);
	clickEnv = EnvGen.kr(Env.perc(0.001, 0.015, 1, -8));

	// Sub sine
	sig = SinOsc.ar(freq);

	// High click for attack
	click = SinOsc.ar(clickFreq) * clickEnv * 0.3;

	sig = (sig + click) * env * amp;
	Out.ar(out, [sig, sig]);
}).add;
)

// Test: Synth(\subClick, [\freq, 55, \clickFreq, 2000, \decay, 0.15]);

// --------------------------------------------------
// 10. WAVEFOLD TONE - Wavefolding distortion
// --------------------------------------------------
(
SynthDef(\wavefoldTone, {
	arg out = 0, amp = 0.15, freq = 200, fold = 2, decay = 0.15, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -4), doneAction: 2);

	// Sine wave with wavefolding for harmonic richness
	sig = SinOsc.ar(freq) * fold;
	sig = sig.fold(-1, 1);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test: Synth(\wavefoldTone, [\freq, 150, \fold, 3, \decay, 0.2]);

// --------------------------------------------------
// LOAD ALL
// --------------------------------------------------
"Mark Fell synths loaded: resClick, fmClick, pulseTone, combTone, filtNoise, ringTone, formantClick, dualSine, subClick, wavefoldTone".postln;
