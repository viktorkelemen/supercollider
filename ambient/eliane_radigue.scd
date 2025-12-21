// ============================================================
// ELIANE RADIGUE STYLE - Slow evolution, ARP 2500
// ============================================================
// Inspired by "Trilogie de la Mort":
// - Extremely slow, patient evolution
// - Beating frequencies / acoustic phenomena
// - Minimal harmonic content
// - Meditative, contemplative pacing
// - Subtle filtering and modulation

// --------------------------------------------------
// BEATING DRONE - Core beating frequency drone
// --------------------------------------------------
(
SynthDef(\beatingDrone, {
	arg out = 0, amp = 0.15, freq = 55, beatFreq = 0.5;
	var sig, osc1, osc2, osc3;

	// Slightly detuned oscillators create beating
	osc1 = SinOsc.ar(freq);
	osc2 = SinOsc.ar(freq + beatFreq);
	osc3 = SinOsc.ar(freq - (beatFreq * 0.7));

	sig = (osc1 + osc2 + osc3) / 3;

	// Very subtle filtering movement
	sig = LPF.ar(sig, freq * 4 * LFNoise2.kr(0.01).range(0.9, 1.1));

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// HARMONIC BEATING - Higher partials with beating
// --------------------------------------------------
(
SynthDef(\harmonicBeating, {
	arg out = 0, amp = 0.08, freq = 110, partial = 2, beatFreq = 0.3;
	var sig, osc1, osc2;

	osc1 = SinOsc.ar(freq * partial);
	osc2 = SinOsc.ar((freq * partial) + beatFreq);

	sig = (osc1 + osc2) / 2;

	// Slow amplitude envelope
	sig = sig * LFNoise2.kr(0.02).range(0.6, 1);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SLOW FILTER - Extremely slow filter sweep
// --------------------------------------------------
(
SynthDef(\slowFilter, {
	arg out = 0, amp = 0.12, freq = 55, sweepTime = 300;
	var sig, filterFreq;

	// Very slow filter movement
	filterFreq = Line.kr(freq * 2, freq * 8, sweepTime);

	// Rich source
	sig = Saw.ar(freq) * 0.3;
	sig = sig + (Saw.ar(freq * 2.01) * 0.15);
	sig = sig + (SinOsc.ar(freq) * 0.3);

	sig = LPF.ar(sig, filterFreq);
	sig = LPF.ar(sig, filterFreq * 1.2);  // Extra filtering

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// SUBHARMONIC - Deep, almost subsonic tone
// --------------------------------------------------
(
SynthDef(\subharmonic, {
	arg out = 0, amp = 0.2, freq = 27.5;
	var sig;

	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.3);

	// Very slow breathing
	sig = sig * LFNoise2.kr(0.01).range(0.7, 1);

	sig = LPF.ar(sig, 100);
	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// EXPERIMENT 1: TRILOGIE
// Classic Radigue - patient, beating
// --------------------------------------------------
(
// Core beating drone
~drone = Synth(\beatingDrone, [\freq, 55, \amp, 0.12, \beatFreq, 0.4]);

// Subharmonic foundation
~sub = Synth(\subharmonic, [\freq, 27.5, \amp, 0.15]);

// Slow harmonic evolution
~harmonicRoutine = Routine({
	var partials = [2, 3, 4, 5, 6];
	inf.do {
		var partial = partials.choose;
		Synth(\harmonicBeating, [
			\freq, 55,
			\partial, partial,
			\beatFreq, rrand(0.2, 0.6),
			\amp, rrand(0.04, 0.08)
		]);
		rrand(60, 180).wait;
	};
}).play;

"TRILOGIE - Patient beating".postln;
)

// Stop
// ~drone.free; ~sub.free; ~harmonicRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 2: ADNOS
// Even slower, near-static
// --------------------------------------------------
(
~drone = Synth(\beatingDrone, [\freq, 41.2, \amp, 0.1, \beatFreq, 0.25]);
~sub = Synth(\subharmonic, [\freq, 20.6, \amp, 0.12]);

// Very rare harmonic events
~harmonicRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\harmonicBeating, [
				\freq, 41.2,
				\partial, [2, 3, 4].choose,
				\beatFreq, rrand(0.15, 0.35),
				\amp, rrand(0.03, 0.06)
			]);
		};
		rrand(120, 360).wait;
	};
}).play;

// Very slow filter movement
~filter = Synth(\slowFilter, [\freq, 41.2, \amp, 0.05, \sweepTime, 600]);

"ADNOS - Near static".postln;
)

// Stop
// ~drone.free; ~sub.free; ~filter.free; ~harmonicRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: GESTATION
// Gradual development
// --------------------------------------------------
(
~drone = Synth(\beatingDrone, [\freq, 55, \amp, 0.08, \beatFreq, 0.3]);
~sub = Synth(\subharmonic, [\freq, 27.5, \amp, 0.1]);

// Slow filter
~filter = Synth(\slowFilter, [\freq, 55, \amp, 0.06, \sweepTime, 400]);

// Gradual addition of harmonics
~gestationRoutine = Routine({
	var harmonics = [];
	var partials = [2, 3, 4, 5, 6, 7, 8];
	var i = 0;

	inf.do {
		if (i < partials.size) {
			var synth = Synth(\harmonicBeating, [
				\freq, 55,
				\partial, partials[i],
				\beatFreq, rrand(0.2, 0.5),
				\amp, 0.03 / (i + 1).sqrt
			]);
			harmonics = harmonics.add(synth);
			i = i + 1;
			"Added partial %".format(partials[i - 1]).postln;
		};
		rrand(90, 180).wait;
	};
}).play;

"GESTATION - Gradual development".postln;
)

// Stop
// ~drone.free; ~sub.free; ~filter.free; ~gestationRoutine.stop; s.freeAll;

// --------------------------------------------------
// EXPERIMENT 4: BIOGENESIS
// Focus on deep frequencies
// --------------------------------------------------
(
// Very deep fundamental
~sub = Synth(\subharmonic, [\freq, 18.35, \amp, 0.18]);

// Low beating drone
~drone = Synth(\beatingDrone, [\freq, 36.7, \amp, 0.1, \beatFreq, 0.2]);

// Occasional harmonics
~harmonicRoutine = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\harmonicBeating, [
				\freq, 36.7,
				\partial, [3, 4, 5, 6].choose,
				\beatFreq, rrand(0.1, 0.3),
				\amp, rrand(0.02, 0.05)
			]);
		};
		rrand(90, 240).wait;
	};
}).play;

"BIOGENESIS - Deep frequencies".postln;
)

// Stop
// ~sub.free; ~drone.free; ~harmonicRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 5: CHRY-PTUS
// Higher register exploration
// --------------------------------------------------
(
~drone = Synth(\beatingDrone, [\freq, 110, \amp, 0.1, \beatFreq, 0.5]);

// Sub foundation
~sub = Synth(\subharmonic, [\freq, 55, \amp, 0.08]);

// Higher harmonics
~harmonicRoutine = Routine({
	var partials = [2, 3, 4, 5, 6, 7, 8, 9, 10];
	inf.do {
		Synth(\harmonicBeating, [
			\freq, 110,
			\partial, partials.choose,
			\beatFreq, rrand(0.3, 0.8),
			\amp, rrand(0.03, 0.06)
		]);
		rrand(45, 120).wait;
	};
}).play;

// Slow filter
~filter = Synth(\slowFilter, [\freq, 110, \amp, 0.05, \sweepTime, 300]);

"CHRY-PTUS - Higher partials".postln;
)

// Stop
// ~drone.free; ~sub.free; ~filter.free; ~harmonicRoutine.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
