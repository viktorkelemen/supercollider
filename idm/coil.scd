// ============================================================
// COIL STYLE - Ritualistic electronics, unpredictable structures
// ============================================================
// Inspired by "Time Machines", "Musick to Play in the Dark":
// - Drone-based ritualism
// - Unpredictable, organic electronics
// - Dark, occult atmosphere
// - Analog warmth meets digital cold
// - Hypnotic, trance-inducing repetition

// --------------------------------------------------
// RITUAL DRONE - Dark sustained tone
// --------------------------------------------------
SynthDef(\ritualDrone, {
	arg out = 0, amp = 0.12, freq = 55, dur = 15;
	var sig, env;

	env = EnvGen.kr(Env.linen(2, dur - 4, 2), doneAction: 2);

	// Dark harmonics
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 1.5) * 0.25);
	sig = sig + (SinOsc.ar(freq * 2.01) * 0.15);
	sig = sig + (Saw.ar(freq * 0.5) * 0.1);

	// Subtle modulation
	sig = sig * (1 + (SinOsc.kr(0.1).range(-0.1, 0.1)));

	sig = LPF.ar(sig, 1500);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// VOICE FRAGMENT - Ghostly vocal texture
// --------------------------------------------------
SynthDef(\voiceFragment, {
	arg out = 0, amp = 0.1, freq = 300, formant = 700, dur = 3;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);

	// Formant synthesis
	sig = Saw.ar(freq) * 0.4;
	sig = BPF.ar(sig, formant, 0.08) * 4;
	sig = sig + BPF.ar(Saw.ar(freq), formant * 1.3, 0.08) * 2;
	sig = sig + (SinOsc.ar(freq) * 0.2);

	// Ghostly reverb
	sig = FreeVerb.ar(sig, 0.8, 0.9, 0.4);

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// OCCULT BELL - Dark bell tone
// --------------------------------------------------
SynthDef(\occultBell, {
	arg out = 0, amp = 0.12, freq = 220, decay = 4;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, decay, 1, -6), doneAction: 2);

	// Inharmonic bell
	sig = Mix.fill(5, { |i|
		var ratio = [1, 2.3, 3.7, 5.2, 7.1][i];
		SinOsc.ar(freq * ratio) * (1 / (i + 1))
	});

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// ANALOG WARMTH - Warm analog-style texture
// --------------------------------------------------
SynthDef(\analogWarmth, {
	arg out = 0, amp = 0.1, freq = 110, dur = 5;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.5, dur - 1, 0.5), doneAction: 2);

	sig = Saw.ar(freq) * 0.3;
	sig = sig + (Saw.ar(freq * 1.003) * 0.25);
	sig = sig + (Pulse.ar(freq * 0.5, 0.4) * 0.15);

	// Warm filtering
	sig = RLPF.ar(sig, 800 + (SinOsc.kr(0.2).range(0, 400)), 0.4);
	sig = (sig * 1.3).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// DARK PULSE - Rhythmic dark element
// --------------------------------------------------
SynthDef(\darkPulse, {
	arg out = 0, amp = 0.15, freq = 50, dur = 0.5;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

	sig = SinOsc.ar(freq);
	sig = sig + (SinOsc.ar(freq * 2) * 0.2);
	sig = (sig * 1.5).tanh;

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// STATIC BED - Atmospheric noise
// --------------------------------------------------
SynthDef(\staticBed, {
	arg out = 0, amp = 0.05;
	var sig;

	sig = PinkNoise.ar * 0.5;
	sig = sig + (Crackle.ar(1.7) * 0.3);
	sig = LPF.ar(sig, 2000);
	sig = HPF.ar(sig, 100);

	sig = sig * amp;
	Out.ar(out, sig ! 2);
}).add;

// --------------------------------------------------
// TAPE WOBBLE - Degraded tape effect
// --------------------------------------------------
SynthDef(\tapeWobble, {
	arg out = 0, amp = 0.1, freq = 220, wobbleRate = 2, dur = 4;
	var sig, env, mod;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);

	mod = SinOsc.kr(wobbleRate).range(0.97, 1.03);

	sig = SinOsc.ar(freq * mod) * 0.5;
	sig = sig + (SinOsc.ar(freq * 2 * mod) * 0.3);
	sig = sig + (HPF.ar(PinkNoise.ar * 0.02, 4000)); // tape hiss

	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Coil SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: TIME MACHINES
// Drone-based trance induction
// --------------------------------------------------
(
// Continuous drone
~droneRoutine = Routine({
	var freqs = [55, 65.4, 73.4, 82.4];
	inf.do {
		Synth(\ritualDrone, [
			\freq, freqs.choose,
			\amp, rrand(0.1, 0.15),
			\dur, rrand(15, 30)
		]);
		rrand(10, 20).wait;
	};
}).play;

// Analog warmth layer
~warmRoutine = Routine({
	var freqs = [55, 82.4, 110];
	inf.do {
		if (0.4.coin) {
			Synth(\analogWarmth, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.1),
				\dur, rrand(6, 12)
			]);
		};
		rrand(8, 18).wait;
	};
}).play;

// Static bed
~static = Synth(\staticBed, [\amp, 0.03]);

"TIME MACHINES - Drone trance".postln;
)

// Stop
// ~droneRoutine.stop; ~warmRoutine.stop; ~static.free;

// --------------------------------------------------
// EXPERIMENT 2: MUSICK TO PLAY IN THE DARK
// Nighttime ritual
// --------------------------------------------------
(
~static = Synth(\staticBed, [\amp, 0.04]);

// Occult bells
~bellRoutine = Routine({
	var freqs = [165, 220, 277, 330, 392];
	inf.do {
		if (0.4.coin) {
			Synth(\occultBell, [
				\freq, freqs.choose,
				\amp, rrand(0.06, 0.1),
				\decay, rrand(3, 6)
			]);
		};
		rrand(4, 12).wait;
	};
}).play;

// Voice fragments
~voiceRoutine = Routine({
	inf.do {
		if (0.3.coin) {
			Synth(\voiceFragment, [
				\freq, rrand(150, 350),
				\amp, rrand(0.05, 0.09),
				\formant, rrand(500, 900),
				\dur, rrand(3, 6)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

// Dark pulse rhythm
~pulseRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\darkPulse, [
				\freq, [40, 50, 60].choose,
				\amp, rrand(0.1, 0.16),
				\dur, rrand(0.3, 0.7)
			]);
		};
		rrand(2, 6).wait;
	};
}).play;

// Tape wobble
~tapeRoutine = Routine({
	inf.do {
		if (0.2.coin) {
			Synth(\tapeWobble, [
				\freq, rrand(150, 300),
				\amp, rrand(0.05, 0.08),
				\wobbleRate, rrand(1, 4),
				\dur, rrand(3, 6)
			]);
		};
		rrand(8, 20).wait;
	};
}).play;

"MUSICK TO PLAY IN THE DARK - Nighttime ritual".postln;
)

// Stop
// ~static.free; ~bellRoutine.stop; ~voiceRoutine.stop; ~pulseRoutine.stop; ~tapeRoutine.stop;

// --------------------------------------------------
// EXPERIMENT 3: LOVE'S SECRET DOMAIN
// Industrial dance elements
// --------------------------------------------------
(
var tempo = 0.3;

// Dark pulse rhythm
~rhythmRoutine = Routine({
	var pattern = [1, 0, 0, 1, 0, 1, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\darkPulse, [
				\freq, [50, 60].choose,
				\amp, rrand(0.12, 0.18),
				\dur, 0.3
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

// Analog synth
~analogRoutine = Routine({
	var notes = [55, 60, 62, 67].midicps;
	inf.do {
		Synth(\analogWarmth, [
			\freq, notes.choose,
			\amp, rrand(0.08, 0.12),
			\dur, rrand(2, 5)
		]);
		rrand(2, 5).wait;
	};
}).play;

// Bell accents
~bellAccent = Routine({
	var pattern = [0, 0, 0, 0, 1, 0, 0, 0];
	var i = 0;
	inf.do {
		if (pattern[i % pattern.size] == 1) {
			Synth(\occultBell, [
				\freq, [330, 392, 440].choose,
				\amp, 0.08,
				\decay, 2
			]);
		};
		i = i + 1;
		tempo.wait;
	};
}).play;

"LOVE'S SECRET DOMAIN - Industrial dance".postln;
)

// Stop
// ~rhythmRoutine.stop; ~analogRoutine.stop; ~bellAccent.stop;

// --------------------------------------------------
// EXPERIMENT 4: ASTRAL DISASTER
// Cosmic, unsettling
// --------------------------------------------------
(
~static = Synth(\staticBed, [\amp, 0.05]);

// Shifting drones
~droneRoutine = Routine({
	var freqs = [36, 43, 48, 55].midicps;
	inf.do {
		Synth(\ritualDrone, [
			\freq, freqs.choose,
			\amp, rrand(0.08, 0.14),
			\dur, rrand(10, 20)
		]);
		rrand(6, 15).wait;
	};
}).play;

// Ghostly voices
~ghostRoutine = Routine({
	inf.do {
		if (0.35.coin) {
			Synth(\voiceFragment, [
				\freq, rrand(200, 400),
				\amp, rrand(0.06, 0.1),
				\formant, rrand(600, 1000),
				\dur, rrand(2, 5)
			]);
		};
		rrand(4, 10).wait;
	};
}).play;

// Unsettling bells
~unsettlingBell = Routine({
	inf.do {
		if (0.25.coin) {
			Synth(\occultBell, [
				\freq, rrand(150, 500),
				\amp, rrand(0.06, 0.1),
				\decay, rrand(4, 8)
			]);
		};
		rrand(6, 15).wait;
	};
}).play;

"ASTRAL DISASTER - Cosmic unsettling".postln;
)

// Stop
// ~static.free; ~droneRoutine.stop; ~ghostRoutine.stop; ~unsettlingBell.stop;

// --------------------------------------------------
// EXPERIMENT 5: BLACK ANTLERS
// Dark ambient
// --------------------------------------------------
(
~static = Synth(\staticBed, [\amp, 0.03]);

// Very slow drone
~slowDrone = Routine({
	var freq = 55;
	inf.do {
		Synth(\ritualDrone, [
			\freq, freq,
			\amp, rrand(0.1, 0.15),
			\dur, rrand(20, 40)
		]);
		rrand(25, 45).wait;
	};
}).play;

// Rare tape
~rareTape = Routine({
	inf.do {
		if (0.15.coin) {
			Synth(\tapeWobble, [
				\freq, rrand(100, 250),
				\amp, rrand(0.05, 0.08),
				\wobbleRate, rrand(0.5, 2),
				\dur, rrand(5, 10)
			]);
		};
		rrand(15, 35).wait;
	};
}).play;

// Very sparse bell
~sparseBell = Routine({
	inf.do {
		if (0.1.coin) {
			Synth(\occultBell, [
				\freq, [110, 165, 220].choose,
				\amp, rrand(0.06, 0.1),
				\decay, rrand(5, 10)
			]);
		};
		rrand(20, 45).wait;
	};
}).play;

"BLACK ANTLERS - Dark ambient".postln;
)

// Stop
// ~static.free; ~slowDrone.stop; ~rareTape.stop; ~sparseBell.stop;

// --------------------------------------------------
// EXPERIMENT 6: THE APE OF NAPLES
// Electronic orchestral
// --------------------------------------------------
(
// Layered analog
~analogLayers = Routine({
	var notes = [48, 52, 55, 60, 64].midicps;
	inf.do {
		2.do {
			Synth(\analogWarmth, [
				\freq, notes.choose,
				\amp, rrand(0.05, 0.09),
				\dur, rrand(4, 8)
			]);
		};
		rrand(3, 7).wait;
	};
}).play;

// Bell orchestration
~bellOrch = Routine({
	var notes = [60, 64, 67, 72, 76].midicps;
	inf.do {
		if (0.5.coin) {
			Synth(\occultBell, [
				\freq, notes.choose,
				\amp, rrand(0.06, 0.1),
				\decay, rrand(2, 4)
			]);
		};
		rrand(2, 5).wait;
	};
}).play;

// Voice choir
~voiceChoir = Routine({
	inf.do {
		if (0.3.coin) {
			2.do {
				Synth(\voiceFragment, [
					\freq, rrand(180, 350),
					\amp, rrand(0.04, 0.07),
					\formant, rrand(550, 850),
					\dur, rrand(3, 6)
				]);
			};
		};
		rrand(6, 12).wait;
	};
}).play;

"THE APE OF NAPLES - Electronic orchestral".postln;
)

// Stop
// ~analogLayers.stop; ~bellOrch.stop; ~voiceChoir.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
*/
