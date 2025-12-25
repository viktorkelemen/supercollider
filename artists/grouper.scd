// ============================================================
// GROUPER STYLE - Hazy textures, voice as instrument
// ============================================================
// Inspired by "Ruins":
// - Heavily processed, distant vocals
// - Piano/guitar textures
// - Dense reverb and fog
// - Emotional, melancholic quality
// - Lo-fi warmth

// --------------------------------------------------
// HAZY VOICE - Processed vocal-like synthesis
// --------------------------------------------------
(
SynthDef(\hazyVoice, {
	arg out = 0, amp = 0.15, freq = 220, dur = 4, formant = 0.5;
	var sig, env, form1, form2, form3;

	env = EnvGen.kr(Env.linen(1, dur - 2, 1, 1, \sin), doneAction: 2);

	// Formant frequencies (vowel-like)
	form1 = 400 + (formant * 400);
	form2 = 1200 + (formant * 800);
	form3 = 2400 + (formant * 600);

	// Source - rich harmonic content
	sig = Saw.ar(freq * LFNoise2.kr(0.1).range(0.99, 1.01)) * 0.3;
	sig = sig + (Saw.ar(freq * 2.01 * LFNoise2.kr(0.08).range(0.99, 1.01)) * 0.15);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	// Formant filtering
	sig = BPF.ar(sig, form1 * LFNoise2.kr(0.05).range(0.95, 1.05), 0.15) * 0.5;
	sig = sig + BPF.ar(sig, form2, 0.1) * 0.3;
	sig = sig + BPF.ar(sig, form3, 0.08) * 0.2;

	// Breathiness
	sig = sig + (HPF.ar(PinkNoise.ar, 2000) * 0.03);

	// Lo-fi warmth
	sig = LPF.ar(sig, 4000);
	sig = (sig * 1.2).tanh * 0.8;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PIANO TEXTURE - Distant, reverbed piano
// --------------------------------------------------
(
SynthDef(\distantPiano, {
	arg out = 0, amp = 0.12, freq = 440, decay = 3, darkness = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);

	// Piano-like harmonics
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.2);
	sig = sig + (SinOsc.ar(freq * 3.02) * 0.12);
	sig = sig + (SinOsc.ar(freq * 4.05) * 0.08);

	// Hammer strike
	sig = sig + (BPF.ar(WhiteNoise.ar, freq * 5, 0.1) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.2);

	// Distance/darkness filtering
	sig = LPF.ar(sig, 2000 - (darkness * 1200));
	sig = LPF.ar(sig, 3000 - (darkness * 1500));

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// FOG PAD - Dense, enveloping texture
// --------------------------------------------------
(
SynthDef(\fogPad, {
	arg out = 0, amp = 0.08, freq = 110;
	var sig, noise;

	sig = Mix.fill(6, { |i|
		var partial = [1, 2, 3, 4, 5, 6][i];
		var detune = LFNoise2.kr(0.01 + (i * 0.005)).range(0.995, 1.005);
		SinOsc.ar(freq * partial * detune) * (1 / (partial * 1.5));
	});

	// Add noise layer
	noise = LPF.ar(PinkNoise.ar, 1500) * 0.1;
	sig = sig + noise;

	// Slow modulation
	sig = sig * LFNoise2.kr(0.02).range(0.7, 1);

	// Heavy filtering
	sig = LPF.ar(sig, LFNoise2.kr(0.03).range(800, 2000));

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// REVERB WASH - Long decay space
// --------------------------------------------------
(
SynthDef(\reverbWash, {
	arg out = 0, in, amp = 0.5, decay = 6;
	var sig, verb;

	sig = In.ar(in, 2);

	// Long reverb
	verb = sig;
	8.do({ |i|
		verb = AllpassC.ar(verb, 0.2, rrand(0.02, 0.15), decay * (1 - (i * 0.08)));
	});

	// Extra smear
	verb = verb + CombL.ar(verb, 0.5, 0.25, decay * 0.5) * 0.2;

	verb = LPF.ar(verb, 3000);
	verb = verb * amp;
	Out.ar(out, verb);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: RUINS
// Voice and piano in fog
// --------------------------------------------------
(
~scale = [0, 2, 3, 5, 7, 8, 10];  // Natural minor
~root = 146.8;  // D

~fog = Synth(\fogPad, [\freq, ~root / 2, \amp, 0.06]);

// Voice phrases
~voiceRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			var freq = ~root * [0.5, 1, 2].wchoose([0.2, 0.5, 0.3]) *
			           (2 ** (~scale.choose / 12));
			Synth(\hazyVoice, [
				\freq, freq,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(3, 8),
				\formant, rrand(0.2, 0.8)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Piano figures
~pianoRoutine = Routine({
	var pattern = [0, 3, 5, 7, 5, 3, 0, 2];
	var i = 0;
	inf.do {
		if (0.6.coin) {
			var degree = pattern[i % 8];
			var freq = ~root * (2 ** (~scale[degree] / 12));
			Synth(\distantPiano, [
				\freq, freq,
				\amp, rrand(0.08, 0.12),
				\decay, rrand(2, 5),
				\darkness, rrand(0.4, 0.7)
			]);
		};
		i = i + 1;
		rrand(0.8, 2.5).wait;
	};
}).play;

"RUINS - Hazy and distant".postln;
)

// Stop
// ~fog.free; ~voiceRoutine.stop; ~pianoRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: DRAGGING A DEAD DEER
// Darker, more distant
// --------------------------------------------------
(
~scale = [0, 1, 3, 5, 6, 8, 10];  // Phrygian
~root = 110;

~fog = Synth(\fogPad, [\freq, ~root / 2, \amp, 0.07]);

// Very sparse voice
~voiceRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\hazyVoice, [
				\freq, ~root * [0.5, 1].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.14),
				\dur, rrand(5, 12),
				\formant, rrand(0.1, 0.4)  // Darker vowels
			]);
		};
		rrand(8, 25).wait;
	};
}).play;

// Very dark piano
~pianoRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\distantPiano, [
				\freq, ~root * [0.5, 1, 2].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\decay, rrand(3, 8),
				\darkness, rrand(0.6, 0.9)  // Very dark
			]);
		};
		rrand(2, 8).wait;
	};
}).play;

"DRAGGING A DEAD DEER - Maximum darkness".postln;
)

// Stop
// ~fog.free; ~voiceRoutine.stop; ~pianoRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: A I A
// Layered vocals
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];  // Major
~root = 165;  // E

~fog = Synth(\fogPad, [\freq, ~root / 2, \amp, 0.05]);

// Multiple voice layers
~voice1 = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\hazyVoice, [
				\freq, ~root * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.12),
				\dur, rrand(4, 8),
				\formant, 0.5
			]);
		};
		rrand(3, 8).wait;
	};
}).play;

~voice2 = Routine({
	2.wait;  // Offset
	inf.do {
		if (0.4.coin) {
			Synth(\hazyVoice, [
				\freq, ~root * 1.5 * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\dur, rrand(3, 6),
				\formant, 0.7
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Occasional piano
~pianoRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\distantPiano, [
				\freq, ~root * [1, 2].choose * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.06, 0.1),
				\decay, rrand(2, 5),
				\darkness, rrand(0.3, 0.5)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

"A I A - Layered voices".postln;
)

// Stop
// ~fog.free; ~voice1.stop; ~voice2.stop; ~pianoRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: THE MAN WHO DIED IN HIS BOAT
// Piano focused, minimal voice
// --------------------------------------------------
(
~scale = [0, 2, 3, 5, 7, 8, 11];  // Harmonic minor
~root = 196;  // G

~fog = Synth(\fogPad, [\freq, ~root / 2, \amp, 0.05]);

// Active piano
~pianoRoutine = Routine({
	var pattern = [0, 2, 3, 5, 3, 2, 0, 7, 5, 3];
	var i = 0;
	inf.do {
		var degree = pattern[i % pattern.size];
		var freq = ~root * [1, 2].wchoose([0.6, 0.4]) * (2 ** (~scale[degree % ~scale.size] / 12));

		Synth(\distantPiano, [
			\freq, freq,
			\amp, rrand(0.08, 0.14),
			\decay, rrand(2, 4),
			\darkness, rrand(0.3, 0.6)
		]);

		i = i + 1;
		rrand(0.5, 1.5).wait;
	};
}).play;

// Very rare voice
~voiceRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\hazyVoice, [
				\freq, ~root * (2 ** (~scale.choose / 12)),
				\amp, rrand(0.08, 0.12),
				\dur, rrand(6, 15),
				\formant, rrand(0.3, 0.6)
			]);
		};
		rrand(15, 45).wait;
	};
}).play;

"THE MAN WHO DIED IN HIS BOAT - Piano focus".postln;
)

// Stop
// ~fog.free; ~pianoRoutine.stop; ~voiceRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: GRID OF POINTS
// More structured, repeating
// --------------------------------------------------
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 220;

~fog = Synth(\fogPad, [\freq, ~root / 2, \amp, 0.04]);

// Repeating piano figure
~pianoRoutine = Routine({
	var pattern = [0, 4, 7, 4, 0, 5, 7, 5];
	var tempo = 0.6;
	var i = 0;
	inf.do {
		var degree = pattern[i % 8];
		var freq = ~root * (2 ** (~scale[degree] / 12));

		Synth(\distantPiano, [
			\freq, freq,
			\amp, rrand(0.1, 0.14),
			\decay, 2,
			\darkness, 0.4
		]);

		i = i + 1;
		tempo.wait;
	};
}).play;

// Voice drone
~voiceRoutine = Routine({
	inf.do {
		Synth(\hazyVoice, [
			\freq, ~root * [0.5, 1].choose,
			\amp, rrand(0.06, 0.1),
			\dur, rrand(8, 20),
			\formant, rrand(0.4, 0.6)
		]);
		rrand(12, 30).wait;
	};
}).play;

"GRID OF POINTS - Structured repetition".postln;
)

// Stop
// ~fog.free; ~pianoRoutine.stop; ~voiceRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
