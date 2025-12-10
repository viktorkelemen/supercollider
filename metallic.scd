(
SynthDef(\metallic, {
	|
	out = 0,
	channel = 0,
	freq = 440,
	amp = 0.3,
	decay = 2,
	brightness = 5000,
	strike = 0.5 |

	var exciter, resonator, env, sig;
	var partials, amps, decays;

	// Inharmonic partial ratios - these non-integer ratios create metallic timbre
	partials = [1, 2.32, 3.17, 4.53, 5.87, 6.42, 7.89, 9.12];

	// Higher partials decay faster (natural acoustic behavior)
	amps = partials.collect({ |p| 1 / p.sqrt });

	// Decay times - higher partials ring out more quickly
	decays = partials.collect({ |p| decay / p.sqrt });

	// Exciter: short impulse simulating the strike
	exciter = Impulse.ar(0) * strike;
	exciter = exciter + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01)) * strike * 0.3);

	// Klank: bank of resonators at inharmonic frequencies
	resonator = Klank.ar(
		`[partials * freq, amps, decays],
		exciter
	);

	// Brightness control via lowpass filter
	sig = LPF.ar(resonator, brightness);

	// Amplitude envelope
	env = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);

	sig = sig * env * amp;

	OffsetOut.ar(channel, sig ! 2);
}).add;
)
