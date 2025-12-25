// ============================================================
// BEVERLY GLENN-COPELAND STYLE - Pioneering synthesis
// ============================================================
// Inspired by "Keyboard Fantasies":
// - Warm, analog-style synthesis
// - Simple, heartfelt melodies
// - Early digital textures
// - Gentle, meditative quality
// - Voice and synth interplay
//
// NOTE: Pad and lead synths (\analogPad, \warmLead) have no doneAction
// and must be manually freed. This is intentional for sustained voices.

// --------------------------------------------------
// WARM LEAD - Simple, expressive synth voice
// --------------------------------------------------
(
SynthDef(\warmLead, {
	arg out = 0, amp = 0.2, freq = 440, dur = 1, gate = 1, vibDepth = 0.01;
	var sig, env, vibrato;

	env = EnvGen.kr(Env.asr(0.1, 1, 0.3), gate, doneAction: 2);

	// Gentle vibrato
	vibrato = SinOsc.kr(5).range(1 - vibDepth, 1 + vibDepth);

	// Warm waveform mix
	sig = LFTri.ar(freq * vibrato) * 0.4;
	sig = sig + (SinOsc.ar(freq * vibrato) * 0.4);
	sig = sig + (LFSaw.ar(freq * vibrato) * 0.1);
	sig = sig + (SinOsc.ar(freq * 2 * vibrato) * 0.1);

	sig = LPF.ar(sig, 3000);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// ANALOG PAD - Warm, simple pad
// --------------------------------------------------
(
SynthDef(\analogPad, {
	arg out = 0, amp = 0.12, freq = 110;
	var sig, voices;

	voices = Array.fill(4, { |i|
		var partial = i + 1;
		var detune = LFNoise2.kr(0.02).range(0.998, 1.002);
		LFTri.ar(freq * partial * detune) * (1 / partial);
	});

	// Stereo spread for warmth
	sig = Splay.ar(voices, spread: 0.5, center: 0);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Subtle movement
	sig = sig * LFNoise2.kr(0.03).range(0.85, 1);

	sig = LPF.ar(sig, 2500);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// SOFT VOICE - Gentle vocal synthesis
// --------------------------------------------------
(
SynthDef(\softVoice, {
	arg out = 0, amp = 0.1, freq = 220, dur = 4, vowel = 0.5;
	var sig, env, form1, form2;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5, 1, \sin), doneAction: 2);

	// Vowel formants
	form1 = 400 + (vowel * 300);
	form2 = 1000 + (vowel * 600);

	// Source
	sig = LFSaw.ar(freq * LFNoise2.kr(0.05).range(0.99, 1.01)) * 0.3;
	sig = sig + (LFTri.ar(freq) * 0.3);
	sig = sig + (SinOsc.ar(freq) * 0.2);

	// Formant filtering
	sig = BPF.ar(sig, form1, 0.2) * 0.5;
	sig = sig + BPF.ar(sig, form2, 0.15) * 0.4;

	// Breathiness
	sig = sig + (HPF.ar(PinkNoise.ar, 2500) * 0.015);

	sig = LPF.ar(sig, 4000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DIGITAL BELLS - Early digital texture
// --------------------------------------------------
(
SynthDef(\digitalBells, {
	arg out = 0, amp = 0.12, freq = 880, decay = 3, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -5), doneAction: 2);

	// Simple FM bell
	sig = SinOsc.ar(freq + (SinOsc.ar(freq * 2) * freq * 0.5 * env));
	sig = sig * 0.5;

	// Additional harmonics
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3.02) * 0.1);

	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: KEYBOARD FANTASIES
// Classic BGC sound
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];  // Major
~root = 165;  // E

~pad = Synth(\analogPad, [\freq, ~root / 2, \amp, 0.08]);

// Lead synth melody
~lead = Synth(\warmLead, [\freq, ~root, \amp, 0.15, \vibDepth, 0.008]);

~melodyRoutine = Routine({
	var melody = [0, 2, 4, 7, 4, 2, 0, 4, 5, 4, 2, 0];
	var durations = [0.5, 0.5, 1, 0.5, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.5, 1];
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree] / 12));
		~lead.set(\freq, freq);
		durations[i % durations.size].wait;
		i = i + 1;
	};
}).play;

// Occasional voice
~voiceRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\softVoice, [
				\freq, ~root * [0.5, 1].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(3, 8),
				\vowel, rrand(0.3, 0.7)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

// Bells
~bellRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\digitalBells, [
				\freq, ~root * 2 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\decay, rrand(2, 4),
				\pan, rrand(-0.4, 0.4)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

"KEYBOARD FANTASIES - Warm synthesis".postln;
)

// Stop
// ~pad.free; ~lead.free; ~melodyRoutine.stop; ~voiceRoutine.stop; ~bellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: EVER NEW
// Uplifting, hopeful
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];  // Major pentatonic
~root = 196;  // G

~pad = Synth(\analogPad, [\freq, ~root / 2, \amp, 0.1]);

// Simple repeating melody
~lead = Synth(\warmLead, [\freq, ~root, \amp, 0.16, \vibDepth, 0.01]);

~melodyRoutine = Routine({
	var melody = [0, 4, 7, 4, 9, 7, 4, 0];
	var tempo = 0.6;
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree % ~scale.size] / 12));
		~lead.set(\freq, freq);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Voice harmony
~voiceRoutine = Routine({
	inf.do {
		Synth(\softVoice, [
			\freq, ~root * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.05, 0.08),
			\dur, rrand(5, 12),
			\vowel, rrand(0.4, 0.6)
		]);
		rrand(8, 18).wait;
	};
}).play;

// Bells on strong beats
~bellRoutine = Routine({
	var tempo = 0.6;
	var pattern = [1, 0, 0, 1, 0, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\digitalBells, [
				\freq, ~root * 2 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.12),
				\decay, 2.5
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"EVER NEW - Uplifting melody".postln;
)

// Stop
// ~pad.free; ~lead.free; ~melodyRoutine.stop; ~voiceRoutine.stop; ~bellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: WANDERING SOUL
// More contemplative
// --------------------------------------------------
(
~scale = [0, 2, 3, 5, 7, 8, 10];  // Natural minor
~root = 146.8;  // D

~pad = Synth(\analogPad, [\freq, ~root / 2, \amp, 0.08]);

~lead = Synth(\warmLead, [\freq, ~root, \amp, 0.14, \vibDepth, 0.012]);

// Slower, more expressive melody
~melodyRoutine = Routine({
	var melody = [0, 3, 5, 3, 0, 7, 5, 3, 0, 2, 3, 5];
	var durations = [1, 0.5, 0.5, 1, 1.5, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 1.5];
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree % ~scale.size] / 12));
		~lead.set(\freq, freq);
		durations[i % durations.size].wait;
		i = i + 1;
	};
}).play;

// Gentle voice
~voiceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\softVoice, [
				\freq, ~root * [0.5, 1].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.05, 0.09),
				\dur, rrand(4, 10),
				\vowel, rrand(0.2, 0.5)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

// Sparse bells
~bellRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\digitalBells, [
				\freq, ~root * [1, 2].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\decay, rrand(3, 5)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

"WANDERING SOUL - Contemplative".postln;
)

// Stop
// ~pad.free; ~lead.free; ~melodyRoutine.stop; ~voiceRoutine.stop; ~bellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: COLOUR OF ANYHOW
// Textural, ambient
// --------------------------------------------------
(
~scale = [0, 2, 4, 7, 9];
~root = 110;

~pad = Synth(\analogPad, [\freq, ~root, \amp, 0.1]);

// No lead - focus on texture
// Voice drones
~voiceRoutine = Routine({
	inf.do {
		Synth(\softVoice, [
			\freq, ~root * [0.5, 1, 1.5, 2].choose * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.04, 0.08),
			\dur, rrand(6, 15),
			\vowel, rrand(0.3, 0.7)
		]);
		rrand(5, 12).wait;
	};
}).play;

// Bells as main melodic element
~bellRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\digitalBells, [
				\freq, ~root * [1, 2, 4].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.14),
				\decay, rrand(3, 6),
				\pan, rrand(-0.5, 0.5)
			]);
		};
		rrand(1, 4).wait;
	};
}).play;

"COLOUR OF ANYHOW - Ambient texture".postln;
)

// Stop
// ~pad.free; ~voiceRoutine.stop; ~bellRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: LA VITA
// Celebratory, full
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 220;

~pad = Synth(\analogPad, [\freq, ~root / 2, \amp, 0.08]);

~lead = Synth(\warmLead, [\freq, ~root, \amp, 0.18, \vibDepth, 0.015]);

// Active melody
~melodyRoutine = Routine({
	var melody = [0, 2, 4, 7, 9, 7, 4, 2, 0, 4, 7, 11, 9, 7, 4, 0];
	var tempo = 0.3;
	var i = 0;
	inf.do {
		var degree = melody[i % melody.size];
		var freq = ~root * (2 ** (~scale[degree] / 12));
		~lead.set(\freq, freq);
		i = i + 1;
		tempo.wait;
	};
}).play;

// Harmony voice
~voiceRoutine = Routine({
	inf.do {
		Synth(\softVoice, [
			\freq, ~root * [1, 1.5].choose * (2 ** (~scale.choose / 12)),
			\amp, rrand(0.05, 0.08),
			\dur, rrand(4, 8),
			\vowel, rrand(0.4, 0.7)
		]);
		rrand(4, 10).wait;
	};
}).play;

// Active bells
~bellRoutine = Routine({
	var tempo = 0.3;
	var pattern = [1, 0, 1, 0, 0, 1, 0, 1];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\digitalBells, [
				\freq, ~root * 2 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.07, 0.11),
				\decay, 2,
				\pan, rrand(-0.3, 0.3)
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"LA VITA - Celebratory".postln;
)

// Stop
// ~pad.free; ~lead.free; ~melodyRoutine.stop; ~voiceRoutine.stop; ~bellRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
