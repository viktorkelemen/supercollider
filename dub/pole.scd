// ============================================================
// POLE STYLE - Crackle aesthetics, filtered dub
// ============================================================
// Inspired by the "1", "2", "3" trilogy:
// - Broken/glitched CD player as instrument
// - Heavy lowpass filtering
// - Minimal dub elements
// - Crackle and digital artifacts as texture
// - Sparse, hypnotic repetition

// --------------------------------------------------
// CRACKLE GENERATOR - Signature Pole sound
// --------------------------------------------------
(
SynthDef(\polecrackle, {
	arg out = 0, amp = 0.08, density = 15, brightness = 0.5;
	var sig, crackle, clicks;

	// Digital crackle - like CD errors
	crackle = Dust2.ar(density) * 0.4;
	crackle = crackle + (Dust.ar(density * 2) * 0.3);

	// Occasional louder clicks
	clicks = Dust.ar(density / 5) * 0.6;

	sig = crackle + clicks;

	// Filter the crackle
	sig = LPF.ar(sig, 800 + (brightness * 4000));
	sig = HPF.ar(sig, 100);

	// Add subtle resonance
	sig = sig + (Ringz.ar(clicks, LFNoise0.kr(2).range(200, 600), 0.05) * 0.2);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// FILTERED BASS - Deep, murky sub
// --------------------------------------------------
(
SynthDef(\filteredBass, {
	arg out = 0, amp = 0.4, freq = 45, dur = 2, filterFreq = 200;
	var sig, env, fenv;

	env = EnvGen.kr(Env.linen(0.05, dur - 0.15, 0.1, 1, \sin), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.01, 0.2, 1, -4));

	// Simple sine bass
	sig = SinOsc.ar(freq) * 0.7;
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.15);

	// Heavy filtering
	sig = LPF.ar(sig, filterFreq + (fenv * 100));
	sig = LPF.ar(sig, filterFreq);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// MINIMAL KICK - Muffled, deep
// --------------------------------------------------
(
SynthDef(\minimalKick, {
	arg out = 0, amp = 0.5, freq = 50, decay = 0.4;
	var sig, env, click;

	env = EnvGen.kr(Env.perc(0.005, decay, 1, -8), doneAction: 2);

	// Deep thud
	sig = SinOsc.ar(freq * EnvGen.kr(Env.perc(0.001, 0.05, 1, -6)).range(1, 1.3));
	sig = sig + (SinOsc.ar(freq * 0.5) * 0.3);

	// Muffled click
	click = LPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.02));

	sig = (sig + (click * 0.3)) * env * amp;
	sig = LPF.ar(sig, 150);
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// FILTERED CHORD - Murky pad stabs
// --------------------------------------------------
(
SynthDef(\filteredChord, {
	arg out = 0, amp = 0.15, freq = 220, filterFreq = 400, dur = 2;
	var sig, env, fenv;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.3, 0.2, 1, \sin), doneAction: 2);
	fenv = EnvGen.kr(Env.perc(0.05, dur * 0.5, 1, -3));

	// Simple chord tones
	sig = SinOsc.ar(freq) * 0.4;
	sig = sig + (SinOsc.ar(freq * 1.5) * 0.25);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig + (LFTri.ar(freq * 0.5) * 0.15);

	// Heavy filtering
	sig = LPF.ar(sig, filterFreq + (fenv * 400));
	sig = LPF.ar(sig, filterFreq * 1.5);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DUBBY DELAY - Filtered feedback delay
// --------------------------------------------------
(
SynthDef(\dubbyDelay, {
	arg out = 0, in, amp = 0.4, delayTime = 0.375,
		feedback = 0.6, filterFreq = 800, dur = 8;
	var sig, delayed, local, env;

	env = EnvGen.kr(Env.linen(0.1, dur - 0.2, 0.1), doneAction: 2);

	local = LocalIn.ar(2);
	sig = In.ar(in, 2) + (local * feedback);

	delayed = DelayC.ar(sig, 2, delayTime);

	// Filter each repeat
	delayed = LPF.ar(delayed, filterFreq);
	delayed = HPF.ar(delayed, 40);

	LocalOut.ar(delayed);

	sig = delayed * amp * env;
	Out.ar(out, sig);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: TRILOGY MINIMAL
// Sparse, crackle-focused
// --------------------------------------------------
(
~crackle = Synth(\polecrackle, [\amp, 0.06, \density, 12, \brightness, 0.3]);

// Very sparse kick
~kickRoutine = Routine({
	var intervals = [1.5, 1.5, 1, 2, 1.5];
	var i = 0;
	inf.do {
		if (0.8.coin) {
			Synth(\minimalKick, [
				\amp, rrand(0.35, 0.5),
				\freq, [45, 50].choose,
				\decay, rrand(0.3, 0.5)
			]);
		};
		intervals[i % intervals.size].wait;
		i = i + 1;
	};
}).play;

// Very occasional bass
~bassRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\filteredBass, [
				\freq, [36.7, 41.2, 49].choose,
				\amp, rrand(0.25, 0.4),
				\dur, rrand(1.5, 3),
				\filterFreq, rrand(100, 250)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

"TRILOGY MINIMAL - Crackle and space".postln;
)

// Stop
// ~crackle.free; ~kickRoutine.stop; ~bassRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: FILTERED DUB
// More traditional dub elements, heavily filtered
// --------------------------------------------------
(
var tempo = 0.5;  // Half second per beat

~crackle = Synth(\polecrackle, [\amp, 0.05, \density, 10]);

// Kick pattern
~kickRoutine = Routine({
	var pattern = [1, 0, 0, 0, 1, 0, 1, 0];
	var i = 0;
	inf.do {
		if (pattern[i % 8] == 1) {
			Synth(\minimalKick, [
				\amp, rrand(0.4, 0.55),
				\decay, rrand(0.3, 0.5)
			]);
		};
		i = i + 1;
		(tempo / 2).wait;
	};
}).play;

// Bass - follows kick loosely
~bassRoutine = Routine({
	var notes = [41.2, 41.2, 49, 36.7];
	inf.do {
		if (0.5.coin) {
			Synth(\filteredBass, [
				\freq, notes.choose,
				\amp, rrand(0.3, 0.4),
				\dur, rrand(1, 2.5),
				\filterFreq, rrand(120, 200)
			]);
		};
		(tempo * rrand(2, 4)).wait;
	};
}).play;

// Filtered chord stabs
~chordRoutine = Routine({
	var notes = [110, 130.8, 146.8, 164.8];
	inf.do {
		if (0.25.coin) {
			Synth(\filteredChord, [
				\freq, notes.choose,
				\amp, rrand(0.08, 0.15),
				\filterFreq, rrand(200, 500),
				\dur, rrand(1.5, 4)
			]);
		};
		(tempo * rrand(4, 10)).wait;
	};
}).play;

"FILTERED DUB - Murky rhythms".postln;
)

// Stop
// ~crackle.free; ~kickRoutine.stop; ~bassRoutine.stop; ~chordRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: CRACKLE MEDITATION
// Almost ambient, crackle as main voice
// --------------------------------------------------
(
// Dense crackle
~crackle = Synth(\polecrackle, [\amp, 0.08, \density, 20, \brightness, 0.4]);

// Very deep, slow bass tones
~bassRoutine = Routine({
	var notes = [27.5, 32.7, 36.7];  // Very low
	inf.do {
		Synth(\filteredBass, [
			\freq, notes.choose,
			\amp, rrand(0.2, 0.35),
			\dur, rrand(4, 10),
			\filterFreq, rrand(80, 150)
		]);
		rrand(8, 20).wait;
	};
}).play;

// Distant filtered chords
~chordRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\filteredChord, [
				\freq, rrand(80, 200),
				\amp, rrand(0.04, 0.1),
				\filterFreq, rrand(150, 350),
				\dur, rrand(4, 12)
			]);
		};
		rrand(10, 30).wait;
	};
}).play;

"CRACKLE MEDITATION - Texture focus".postln;
)

// Stop
// ~crackle.free; ~bassRoutine.stop; ~chordRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 4: CD SKIP
// Glitched, stuttering patterns
// --------------------------------------------------
(
SynthDef(\cdSkip, {
	arg out = 0, amp = 0.1, freq = 200, skipRate = 8, dur = 1;
	var sig, env, skip;

	env = EnvGen.kr(Env.linen(0.01, dur - 0.02, 0.01), doneAction: 2);

	// Repeated micro-sample
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (Pulse.ar(freq, 0.3) * 0.2);

	// Skip/stutter effect
	skip = LFPulse.kr(skipRate, 0, 0.3);
	sig = sig * skip;

	sig = LPF.ar(sig, 600);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

~crackle = Synth(\polecrackle, [\amp, 0.07, \density, 15]);

// Skip events
~skipRoutine = Routine({
	inf.do {
		if (0.4.coin) {
			Synth(\cdSkip, [
				\freq, rrand(100, 400),
				\amp, rrand(0.06, 0.12),
				\skipRate, rrand(4, 20),
				\dur, rrand(0.2, 1.5)
			]);
		};
		rrand(0.5, 3).wait;
	};
}).play;

// Minimal kick
~kickRoutine = Routine({
	inf.do {
		if (0.6.coin) {
			Synth(\minimalKick, [
				\amp, rrand(0.3, 0.45),
				\decay, rrand(0.25, 0.4)
			]);
		};
		rrand(0.75, 2).wait;
	};
}).play;

"CD SKIP - Digital malfunction".postln;
)

// Stop
// ~crackle.free; ~skipRoutine.stop; ~kickRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: SUBMERGED POLE
// Deep underwater version
// --------------------------------------------------
(
~crackle = Synth(\polecrackle, [\amp, 0.04, \density, 8, \brightness, 0.15]);

// Very filtered everything
~bassRoutine = Routine({
	var notes = [32.7, 36.7, 41.2, 49];
	inf.do {
		Synth(\filteredBass, [
			\freq, notes.choose,
			\amp, rrand(0.3, 0.45),
			\dur, rrand(2, 5),
			\filterFreq, rrand(60, 120)  // Very dark
		]);
		rrand(3, 8).wait;
	};
}).play;

~kickRoutine = Routine({
	inf.do {
		if (0.5.coin) {
			Synth(\minimalKick, [
				\amp, rrand(0.25, 0.4),
				\freq, 40,
				\decay, rrand(0.4, 0.6)
			]);
		};
		rrand(1, 3).wait;
	};
}).play;

// Very distant chords
~chordRoutine = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\filteredChord, [
				\freq, rrand(60, 150),
				\amp, rrand(0.03, 0.08),
				\filterFreq, rrand(100, 200),
				\dur, rrand(5, 15)
			]);
		};
		rrand(12, 30).wait;
	};
}).play;

"SUBMERGED POLE - Deep pressure".postln;
)

// Stop
// ~crackle.free; ~bassRoutine.stop; ~kickRoutine.stop; ~chordRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
