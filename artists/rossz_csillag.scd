// ============================================================
// ROSSZ CSILLAG - Venetian Snares style composition (2 min)
// Classical + breakcore fusion at 170 BPM
// ============================================================

// --------------------------------------------------
// SYNTHDEFS - Run this block first (Cmd+Enter)
// --------------------------------------------------
(
SynthDef(\brkKick, {
	arg out = 0, freq = 60, punch = 0.8, decay = 0.3, amp = 0.5, dist = 0;
	var body, click, env, sig;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	body = SinOsc.ar(freq * EnvGen.kr(Env([4, 1], [0.04], [-8]))) * env;
	click = LPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.01)) * punch;
	sig = body + click;
	sig = Select.ar(dist > 0, [sig, (sig * (1 + (dist * 10))).tanh]);
	Out.ar(out, sig.dup * amp);
}).add;

SynthDef(\brkSnare, {
	arg out = 0, freq = 180, decay = 0.15, tone = 0.3, amp = 0.5;
	var body, noise, env, sig;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	body = SinOsc.ar(freq * EnvGen.kr(Env([2, 1], [0.01]))) * env * tone;
	noise = HPF.ar(WhiteNoise.ar, 1000) * EnvGen.kr(Env.perc(0.001, decay * 0.7));
	sig = body + noise;
	Out.ar(out, sig.dup * amp);
}).add;

SynthDef(\brkHat, {
	arg out = 0, decay = 0.05, hpf = 7000, amp = 0.3;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	sig = HPF.ar(WhiteNoise.ar, hpf) * env;
	Out.ar(out, sig.dup * amp);
}).add;

SynthDef(\brkGlitch, {
	arg out = 0, freq = 1000, decay = 0.03, amp = 0.3;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, decay * 2) * 5;
	sig = sig + (HPF.ar(WhiteNoise.ar, freq * 0.8) * 0.3);
	Out.ar(out, sig.dup * env * amp);
}).add;

SynthDef(\brkBass, {
	arg out = 0, freq = 80, decay = 0.2, filt = 2000, res = 0.3, amp = 0.4;
	var sig, env, filtEnv;
	env = EnvGen.kr(Env.perc(0.005, decay), doneAction: 2);
	filtEnv = EnvGen.kr(Env.perc(0.001, decay * 0.5));
	sig = Saw.ar(freq) + Pulse.ar(freq * 0.5, 0.3, 0.5);
	sig = RLPF.ar(sig, filt * filtEnv + 200, res);
	sig = (sig * 3).tanh;
	Out.ar(out, sig.dup * env * amp);
}).add;

SynthDef(\brkStrings, {
	arg out = 0, freq = 220, amp = 0.1, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.2, dur - 0.4, 0.2), doneAction: 2);
	sig = Mix([
		Saw.ar(freq * [1, 1.002]) * 0.3,
		Saw.ar(freq * 2 * [1, 0.998]) * 0.15,
		SinOsc.ar(freq) * 0.2
	]);
	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

"ROSSZ CSILLAG SynthDefs loaded".postln;
)

// --------------------------------------------------
// COMPOSITION (2 minutes) - Run this block second
// --------------------------------------------------
(
var bpm = 170, beat = 60/bpm, step = beat/4;
var t = 0.1;

var scale = [48, 50, 51, 54, 55, 56, 59, 60]; // Hungarian minor
var chords = [
	[55, 58, 62], // G Ab B
	[48, 51, 55], // C Eb G
	[50, 54, 57], // D F# A
	[51, 55, 58], // Eb G Ab
];

// =====================================================
// INTRO (0:00 - 0:15) - Strings with early drums
// =====================================================
2.do { |i|
	var chord = chords[i];
	var onset = t + (i * 7);
	chord.do { |note, j|
		s.sendBundle(onset + (j * 0.2), [\s_new, \brkStrings, -1, 0, 0,
			\freq, note.midicps, \amp, 0.1, \dur, 6]);
	};
};

// Drums enter at 0:08
4.do { |bar|
	var barOffset = t + 8 + (bar * beat * 4);
	s.sendBundle(barOffset, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.45]);
	s.sendBundle(barOffset + (beat * 2), [\s_new, \brkSnare, -1, 0, 0, \freq, 185, \amp, 0.4]);
};

// =====================================================
// DEVELOPMENT (0:15 - 0:40) - Full pattern builds
// =====================================================
18.do { |bar|
	var barOffset = t + 15 + (bar * beat * 4);
	var intensity = (bar / 18).min(1);

	// Amen-style kicks
	[0, 2.5, 5, 8, 10.5, 13].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 52, \amp, 0.45 + (intensity * 0.15)]);
	};

	// Snares
	s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \amp, 0.5]);
	s.sendBundle(barOffset + (step * 12), [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \amp, 0.5]);
	s.sendBundle(barOffset + (step * 7), [\s_new, \brkSnare, -1, 0, 0, \freq, 210, \decay, 0.06, \amp, 0.25]);
	s.sendBundle(barOffset + (step * 15), [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \decay, 0.06, \amp, 0.25]);

	// Hats - density increases
	(8 + (bar / 3).floor.asInteger).min(16).do { |i|
		s.sendBundle(barOffset + (step * i), [\s_new, \brkHat, -1, 0, 0,
			\decay, if(i % 4 == 0, 0.04, 0.02), \amp, if(i % 2 == 0, 0.18, 0.1)]);
	};

	// Strings every 6 bars
	if(bar % 6 == 0, {
		var chord = chords[bar div: 6 % 4];
		chord.do { |note, j|
			s.sendBundle(barOffset + (j * 0.15), [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps, \amp, 0.08, \dur, 4]);
		};
	});
};

// =====================================================
// PEAK (0:40 - 1:25) - Maximum chaos
// =====================================================
32.do { |bar|
	var barOffset = t + 40 + (bar * beat * 4);

	// Distorted kicks
	[0, 3, 5.5, 8, 11, 13.5].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 48 + (bar % 4 * 2), \amp, 0.6, \dist, 0.35]);
	};

	// Pitched snares
	s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0,
		\freq, 180 + (bar % 8 * 5), \amp, 0.55]);
	s.sendBundle(barOffset + (step * 12), [\s_new, \brkSnare, -1, 0, 0, \freq, 195, \amp, 0.55]);

	// Ghost snares
	[7, 10, 15].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkSnare, -1, 0, 0,
			\freq, 210 + (bar * 2), \decay, 0.07, \amp, 0.3]);
	};

	// Full 16th hats
	16.do { |i|
		s.sendBundle(barOffset + (step * i), [\s_new, \brkHat, -1, 0, 0,
			\decay, if(i % 4 == 0, 0.05, 0.015), \amp, if(i % 2 == 0, 0.2, 0.1)]);
	};

	// Glitches
	if(bar % 2 == 1, {
		[6, 14].do { |pos|
			s.sendBundle(barOffset + (step * pos), [\s_new, \brkGlitch, -1, 0, 0,
				\freq, 1500 + (bar * 60), \amp, 0.22]);
		};
	});

	// Retrigger rolls every 8 bars
	if(bar % 8 == 7, {
		8.do { |i|
			s.sendBundle(barOffset + (step * 12) + (step * 0.125 * i), [\s_new, \brkSnare, -1, 0, 0,
				\freq, 170 + (i * 20), \decay, 0.04, \amp, 0.35 + (i * 0.03)]);
		};
	});

	// Bass stabs
	if(bar % 3 == 0, {
		s.sendBundle(barOffset, [\s_new, \brkBass, -1, 0, 0,
			\freq, scale[bar % 8].midicps / 2, \decay, 0.25, \filt, 2000, \amp, 0.38]);
	});

	// Strings every 4 bars
	if(bar % 4 == 0, {
		var chord = chords[bar div: 4 % 4];
		chord.do { |note|
			s.sendBundle(barOffset, [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps, \amp, 0.1, \dur, 3]);
		};
	});
};

// =====================================================
// BREAKDOWN (1:25 - 1:40) - Brief respite with texture
// =====================================================
4.do { |i|
	var onset = t + 85 + (i * 3.5);
	var chord = chords[i % 4];

	chord.do { |note, j|
		s.sendBundle(onset + (j * 0.25), [\s_new, \brkStrings, -1, 0, 0,
			\freq, note.midicps, \amp, 0.09, \dur, 3]);
	};

	// Sparse percussion keeps momentum
	s.sendBundle(onset + 1, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.35]);
	s.sendBundle(onset + 2.5, [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \decay, 0.1, \amp, 0.3]);
};

// =====================================================
// RESOLUTION (1:40 - 2:00) - Quick fade with activity
// =====================================================
14.do { |bar|
	var barOffset = t + 100 + (bar * beat * 4);
	var fade = 1 - (bar / 16);

	// Fading kicks
	s.sendBundle(barOffset, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.5 * fade]);
	if(bar < 10, {
		s.sendBundle(barOffset + (step * 8), [\s_new, \brkKick, -1, 0, 0, \freq, 55, \amp, 0.35 * fade]);
	});

	// Fading snare
	if(bar < 12, {
		s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 185, \amp, 0.45 * fade]);
	});

	// Sparse hats
	if(bar < 8, {
		4.do { |i|
			s.sendBundle(barOffset + (step * i * 4), [\s_new, \brkHat, -1, 0, 0,
				\decay, 0.03, \amp, 0.15 * fade]);
		};
	});

	// Final chords
	if(bar % 3 == 0, {
		var chord = chords[bar div: 3 % 4];
		chord.do { |note, j|
			s.sendBundle(barOffset + (j * 0.2), [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps, \amp, 0.07 * fade, \dur, 5]);
		};
	});
};

// Final resolving chord
s.sendBundle(t + 118, [\s_new, \brkStrings, -1, 0, 0, \freq, 48.midicps, \amp, 0.05, \dur, 6]);
s.sendBundle(t + 118.2, [\s_new, \brkStrings, -1, 0, 0, \freq, 55.midicps, \amp, 0.04, \dur, 5]);
s.sendBundle(t + 118.4, [\s_new, \brkStrings, -1, 0, 0, \freq, 60.midicps, \amp, 0.03, \dur, 4]);

"ROSSZ CSILLAG (2 min) scheduled".postln;
)

// --------------------------------------------------
// STOP
// --------------------------------------------------
// s.freeAll;
