// ============================================================
// MIDORI TAKADA - RITUAL EXTENDED (2 minutes)
// Timbre evolution through waves, based on "Through the Looking Glass"
// ============================================================

// Load synths first
(
SynthDef(\marimbaVar, {
	arg out = 0, amp = 0.2, freq = 440, decay = 1.5, pan = 0, timbre = 0.5;
	var sig, env, click, brightness;
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -5), doneAction: 2);
	brightness = timbre.linexp(0, 1, 2, 12);
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 4) * timbre * 0.3 * EnvGen.kr(Env.perc(0.001, 0.05)));
	sig = sig + (SinOsc.ar(freq * 10) * timbre * 0.1 * EnvGen.kr(Env.perc(0.001, 0.02)));
	sig = sig + (SinOsc.ar(freq * 2) * (1 - timbre) * 0.2);
	click = BPF.ar(PinkNoise.ar, freq * brightness, 0.2) * EnvGen.kr(Env.perc(0.001, 0.02));
	sig = sig + (click * 0.15 * timbre);
	sig = LPF.ar(sig, freq * brightness);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\gong, {
	arg out = 0, amp = 0.25, freq = 80, decay = 8;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.1, decay, 1, -3), doneAction: 2);
	sig = Mix([
		SinOsc.ar(freq) * 0.4,
		SinOsc.ar(freq * 1.47) * 0.25,
		SinOsc.ar(freq * 2.09) * 0.18,
		SinOsc.ar(freq * 2.56) * 0.12,
		SinOsc.ar(freq * 3.24) * 0.08
	]);
	sig = sig * (1 + (SinOsc.kr(0.5) * 0.05));
	sig = LPF.ar(sig, 2000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\woodBlock, {
	arg out = 0, amp = 0.15, freq = 800, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, 0.03) * 0.5;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 1.6, 0.02) * 0.3);
	sig = HPF.ar(sig, 300);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Play the 2-minute ritual
(
var t = 0;
var phraseLen = 1.2;
var pattern = [220, 220, 262, 220, 294, 262, 330, 294];
var accents = [1, 0, 0, 1, 0, 0, 1, 0];
var stepDur = 0.15;

// Timbre wave function - oscillates between 0.15 and 1.0
var getTimbre = { |phraseNum, stepNum|
	var wave = (phraseNum / 4 * pi).sin.abs;
	var base = 0.15 + (wave * 0.85);
	var micro = stepNum * 0.02;
	(base + micro).clip(0.15, 1.0);
};

// Gong at start
s.sendBundle(0, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.2, \decay, 8]);

// 100 phrases = ~2 minutes
100.do { |phraseNum|
	var phraseStart = phraseNum * phraseLen;

	// Every 12 phrases, add a gong
	if (phraseNum % 12 == 0 && phraseNum > 0) {
		s.sendBundle(phraseStart, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.15, \decay, 6]);
	};

	// Marimba pattern
	8.do { |step|
		var time = phraseStart + (step * stepDur);
		var freq = pattern[step];
		var isAccent = accents[step] == 1;
		var timbre = getTimbre.value(phraseNum, step);
		var amp = if(isAccent, { 0.2 }, { 0.12 });
		var decay = if(isAccent, { 1.0 }, { 0.5 });
		var pan = [-0.1, 0.1].wrapAt(step);

		s.sendBundle(time, [\s_new, \marimbaVar, -1, 0, 0,
			\freq, freq,
			\amp, amp,
			\decay, decay,
			\pan, pan,
			\timbre, timbre
		]);
	};

	// Wood blocks on accented beats
	if (phraseNum % 2 == 0) {
		s.sendBundle(phraseStart, [\s_new, \woodBlock, -1, 0, 0,
			\freq, 700 + (getTimbre.value(phraseNum, 0) * 400),
			\amp, 0.06
		]);
		s.sendBundle(phraseStart + (3 * stepDur), [\s_new, \woodBlock, -1, 0, 0,
			\freq, 750 + (getTimbre.value(phraseNum, 3) * 400),
			\amp, 0.06
		]);
	};
};

// Final gong
s.sendBundle(120, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.25, \decay, 12]);

"RITUAL EXTENDED - 2 minutes of timbre waves".postln;
)
