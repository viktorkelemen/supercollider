// ============================================================
// VENETIAN SNARES STYLE - Breakcore, odd meters, amen chaos
// ============================================================
// Inspired by "Rossz Csillag Alatt Szuletett", "Higgins Ultra Low Track Glue":
// - Complex odd time signatures (7/8, 5/4, 7/4)
// - Chopped and rearranged amen breaks
// - Classical music influences
// - Extreme tempo (170-200+ BPM)
// - Retrigger and stutter effects
// - Pitched/tuned drums

// --------------------------------------------------
// BREAKCORE KICK - Punchy with pitch sweep
// --------------------------------------------------
SynthDef(\brkKick, {
	arg out = 0, freq = 60, punch = 0.8, decay = 0.3, amp = 0.5, dist = 0;
	var body, click, env, sig;

	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

	// Pitch envelope for that punchy attack (high to low)
	body = SinOsc.ar(freq * EnvGen.kr(Env([4, 1], [0.04], [-8]))) * env;

	// Transient click
	click = LPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.01)) * punch;
	sig = body + click;

	// Optional distortion
	sig = Select.ar(dist > 0, [sig, (sig * (1 + (dist * 10))).tanh]);

	Out.ar(out, sig.dup * amp);
}).add;

// --------------------------------------------------
// BREAKCORE SNARE - Tight, tunable
// --------------------------------------------------
SynthDef(\brkSnare, {
	arg out = 0, freq = 180, decay = 0.15, tone = 0.3, amp = 0.5;
	var body, noise, env, sig;

	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

	// Tonal body with pitch sweep
	body = SinOsc.ar(freq * EnvGen.kr(Env([2, 1], [0.01]))) * env * tone;

	// Noise component
	noise = HPF.ar(WhiteNoise.ar, 1000) * EnvGen.kr(Env.perc(0.001, decay * 0.7));

	sig = body + noise;
	Out.ar(out, sig.dup * amp);
}).add;

// --------------------------------------------------
// BREAKCORE HAT - Sharp, variable decay
// --------------------------------------------------
SynthDef(\brkHat, {
	arg out = 0, decay = 0.05, hpf = 7000, amp = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

	sig = HPF.ar(WhiteNoise.ar, hpf);
	sig = sig * env;

	Out.ar(out, sig.dup * amp);
}).add;

// --------------------------------------------------
// BREAKCORE GLITCH - Ringy metallic accents
// --------------------------------------------------
SynthDef(\brkGlitch, {
	arg out = 0, freq = 1000, decay = 0.03, amp = 0.3;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

	sig = Ringz.ar(Impulse.ar(0), freq, decay * 2) * 5;
	sig = sig + (HPF.ar(WhiteNoise.ar, freq * 0.8) * 0.3);

	Out.ar(out, sig.dup * env * amp);
}).add;

// --------------------------------------------------
// BREAKCORE BASS - Saw + pulse, filtered
// --------------------------------------------------
SynthDef(\brkBass, {
	arg out = 0, freq = 80, decay = 0.2, filt = 2000, res = 0.3, amp = 0.4;
	var sig, env, filtEnv;

	env = EnvGen.kr(Env.perc(0.005, decay), doneAction: 2);
	filtEnv = EnvGen.kr(Env.perc(0.001, decay * 0.5));

	sig = Saw.ar(freq) + Pulse.ar(freq * 0.5, 0.3, 0.5);
	sig = RLPF.ar(sig, filt * filtEnv + 200, res);
	sig = (sig * 3).tanh; // soft clip

	Out.ar(out, sig.dup * env * amp);
}).add;

// --------------------------------------------------
// STRING PAD - For classical elements
// --------------------------------------------------
SynthDef(\brkStrings, {
	arg out = 0, freq = 220, amp = 0.1, dur = 2;
	var sig, env;

	env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);

	sig = Mix([
		Saw.ar(freq * [1, 1.002]) * 0.3,
		Saw.ar(freq * 2 * [1, 0.998]) * 0.15,
		SinOsc.ar(freq) * 0.2
	]);

	sig = LPF.ar(sig, 3000);
	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;

"Venetian Snares SynthDefs loaded".postln;

// ============================================================
// EXPERIMENTS - Select and evaluate each block individually
// ============================================================

/*
// --------------------------------------------------
// EXPERIMENT 1: 7/8 ODD METER
// Asymmetric time signature @ 175 BPM
// --------------------------------------------------
(
var bpm = 175, beat = 60/bpm, step = beat/4;
var t = 0.1;

// 7/8 = 7 eighth notes per bar
7.do { |bar|
	var barOffset = t + (bar * step * 7);

	// Kick on 1 - pitch rises each bar
	s.sendBundle(barOffset + (step * 0), [\s_new, \brkKick, -1, 0, 0, \freq, 52 + (bar * 2), \amp, 0.6, \dist, 0.1]);

	// Hat patterns - asymmetric
	s.sendBundle(barOffset + (step * 0), [\s_new, \brkHat, -1, 0, 0, \decay, 0.02, \amp, 0.25]);
	s.sendBundle(barOffset + (step * 1), [\s_new, \brkHat, -1, 0, 0, \decay, 0.02, \amp, 0.15]);
	s.sendBundle(barOffset + (step * 2), [\s_new, \brkHat, -1, 0, 0, \decay, 0.04, \amp, 0.2]);
	s.sendBundle(barOffset + (step * 4), [\s_new, \brkHat, -1, 0, 0, \decay, 0.02, \amp, 0.2]);
	s.sendBundle(barOffset + (step * 5), [\s_new, \brkHat, -1, 0, 0, \decay, 0.06, \amp, 0.25]);

	// Snare on beat 3 and 6 (unusual for 7/8)
	s.sendBundle(barOffset + (step * 2.5), [\s_new, \brkSnare, -1, 0, 0, \freq, 180 + (bar * 8), \amp, 0.5]);
	s.sendBundle(barOffset + (step * 5.5), [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \decay, 0.1, \amp, 0.45]);

	// Ghost kick on odd bars
	if(bar.odd, {
		s.sendBundle(barOffset + (step * 3.5), [\s_new, \brkKick, -1, 0, 0, \freq, 65, \amp, 0.35]);
	});
};

"7/8 ODD METER scheduled".postln;
)

// --------------------------------------------------
// EXPERIMENT 2: RETRIGGER CHAOS
// Rapid-fire stutters and glitches @ 180 BPM
// --------------------------------------------------
(
var bpm = 180, beat = 60/bpm, step = beat/4;
var t = 0.1;

// Bar 1 - building
s.sendBundle(t, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.6]);
s.sendBundle(t + (step * 2), [\s_new, \brkHat, -1, 0, 0, \decay, 0.08, \amp, 0.35]);
s.sendBundle(t + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 180, \amp, 0.5]);

// Retrigger section - rapid fire snare (32nd notes)
8.do { |i|
	var rt = t + (step * 6) + (step * 0.125 * i);
	s.sendBundle(rt, [\s_new, \brkSnare, -1, 0, 0,
		\freq, 180 + (i * 15),
		\decay, 0.04 - (i * 0.003),
		\amp, 0.3 + (i * 0.03)]);
};

// Glitch hits
s.sendBundle(t + (step * 8), [\s_new, \brkGlitch, -1, 0, 0, \freq, 2000, \amp, 0.25]);
s.sendBundle(t + (step * 8.5), [\s_new, \brkGlitch, -1, 0, 0, \freq, 3000, \amp, 0.2]);
s.sendBundle(t + (step * 9), [\s_new, \brkGlitch, -1, 0, 0, \freq, 1500, \amp, 0.25]);

// Kick roll
4.do { |i|
	var kt = t + (step * 10) + (step * 0.25 * i);
	s.sendBundle(kt, [\s_new, \brkKick, -1, 0, 0,
		\freq, 55 - (i * 5),
		\decay, 0.15,
		\amp, 0.5]);
};

// Final chaos - everything at once
s.sendBundle(t + (step * 12), [\s_new, \brkKick, -1, 0, 0, \freq, 48, \amp, 0.65, \dist, 0.5]);
s.sendBundle(t + (step * 12), [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \amp, 0.5]);
s.sendBundle(t + (step * 12), [\s_new, \brkGlitch, -1, 0, 0, \freq, 4000, \amp, 0.3]);

// Triple snare hit ending
s.sendBundle(t + (step * 14), [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \decay, 0.12, \amp, 0.5]);
s.sendBundle(t + (step * 14.33), [\s_new, \brkSnare, -1, 0, 0, \freq, 210, \decay, 0.1, \amp, 0.5]);
s.sendBundle(t + (step * 14.66), [\s_new, \brkSnare, -1, 0, 0, \freq, 230, \decay, 0.08, \amp, 0.55]);
s.sendBundle(t + (step * 15), [\s_new, \brkKick, -1, 0, 0, \freq, 45, \amp, 0.7, \dist, 0.4]);

"RETRIGGER CHAOS scheduled".postln;
)

// --------------------------------------------------
// EXPERIMENT 3: ROSSZ CSILLAG
// Classical + breakcore fusion @ 170 BPM
// --------------------------------------------------
(
var bpm = 170, beat = 60/bpm, step = beat/4;
var t = 0.1;

// String pad (Bartok-influenced)
s.sendBundle(t, [\s_new, \brkStrings, -1, 0, 0, \freq, 55.midicps, \amp, 0.12, \dur, 4]);
s.sendBundle(t + 1, [\s_new, \brkStrings, -1, 0, 0, \freq, 58.midicps, \amp, 0.1, \dur, 3]);
s.sendBundle(t + 2, [\s_new, \brkStrings, -1, 0, 0, \freq, 62.midicps, \amp, 0.1, \dur, 2]);

// Chopped amen pattern - 2 bars
16.do { |i|
	var time = t + (step * i);

	// Kick pattern with accents
	if([0, 5, 8, 11, 14].includes(i), {
		s.sendBundle(time, [\s_new, \brkKick, -1, 0, 0,
			\freq, 52,
			\amp, if(i == 0, 0.65, 0.5)]);
	});

	// Snare pattern
	if([4, 12].includes(i), {
		s.sendBundle(time, [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \amp, 0.55]);
	});
	if([7, 10, 15].includes(i), {
		s.sendBundle(time, [\s_new, \brkSnare, -1, 0, 0, \freq, 210, \decay, 0.08, \amp, 0.35]);
	});

	// Hats - 16ths with accents
	s.sendBundle(time, [\s_new, \brkHat, -1, 0, 0,
		\decay, if(i % 4 == 0, 0.05, 0.02),
		\amp, if(i % 2 == 0, 0.22, 0.12)]);
};

"ROSSZ CSILLAG scheduled".postln;
)

// --------------------------------------------------
// EXPERIMENT 4: 5/4 POLYRHYTHM
// Five against four @ 165 BPM
// --------------------------------------------------
(
var bpm = 165, beat = 60/bpm, step = beat/4;
var t = 0.1;

// 5/4 bars (20 sixteenths per bar)
4.do { |bar|
	var barOffset = t + (bar * step * 20);

	// Kick on 1, 6, 11, 16 (every 5 sixteenths)
	[0, 5, 10, 15].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 50 + (bar * 3),
			\amp, 0.55]);
	};

	// Snare cross-rhythm (every 4 sixteenths against the 5)
	[4, 8, 12, 16].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkSnare, -1, 0, 0,
			\freq, 185,
			\amp, 0.45]);
	};

	// Continuous hats
	20.do { |i|
		s.sendBundle(barOffset + (step * i), [\s_new, \brkHat, -1, 0, 0,
			\decay, 0.02,
			\amp, if(i % 5 == 0, 0.25, 0.12)]);
	};

	// Ghost notes
	[3, 7, 13, 17].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 65,
			\amp, 0.25]);
	};
};

"5/4 POLYRHYTHM scheduled".postln;
)

// --------------------------------------------------
// EXPERIMENT 5: HIGGINS ULTRA LOW
// Dark, aggressive @ 190 BPM
// --------------------------------------------------
(
var bpm = 190, beat = 60/bpm, step = beat/4;
var t = 0.1;

// Dark bass drone
s.sendBundle(t, [\s_new, \brkBass, -1, 0, 0, \freq, 30, \decay, 2, \filt, 400, \amp, 0.4]);

// Aggressive break - 4 bars
32.do { |i|
	var time = t + (step * i);

	// Distorted kicks
	if([0, 3, 6, 8, 11, 14, 16, 19, 22, 24, 27, 30].includes(i), {
		s.sendBundle(time, [\s_new, \brkKick, -1, 0, 0,
			\freq, 48,
			\amp, 0.6,
			\dist, 0.4]);
	});

	// Pitched snares
	if([4, 12, 20, 28].includes(i), {
		s.sendBundle(time, [\s_new, \brkSnare, -1, 0, 0,
			\freq, 170 + (i * 2),
			\amp, 0.55]);
	});

	// Fast hats
	if(i % 2 == 0, {
		s.sendBundle(time, [\s_new, \brkHat, -1, 0, 0, \decay, 0.015, \amp, 0.2]);
	});

	// Glitch accents
	if([7, 15, 23, 31].includes(i), {
		s.sendBundle(time, [\s_new, \brkGlitch, -1, 0, 0,
			\freq, 1500 + (i * 80),
			\amp, 0.25]);
	});
};

// Snare roll finale
8.do { |i|
	var rt = t + (step * 32) + (step * 0.125 * i);
	s.sendBundle(rt, [\s_new, \brkSnare, -1, 0, 0,
		\freq, 160 + (i * 20),
		\decay, 0.05,
		\amp, 0.4 + (i * 0.025)]);
};

"HIGGINS ULTRA LOW scheduled".postln;
)

// --------------------------------------------------
// EXPERIMENT 6: 7/4 MAGYAR
// Hungarian scale influence @ 168 BPM
// --------------------------------------------------
(
var bpm = 168, beat = 60/bpm, step = beat/4;
var t = 0.1;

// Hungarian minor scale bass notes
var scale = [48, 50, 51, 54, 55, 56, 59, 60].midicps; // C D Eb F# G Ab B C

// 7/4 = 28 sixteenths per bar
3.do { |bar|
	var barOffset = t + (bar * step * 28);

	// Kick pattern for 7/4
	[0, 7, 12, 19, 24].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 50,
			\amp, 0.55]);
	};

	// Snare on unusual beats
	[4, 11, 18, 25].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkSnare, -1, 0, 0,
			\freq, 185,
			\amp, 0.5]);
	};

	// Bass melody
	7.do { |note|
		s.sendBundle(barOffset + (step * note * 4), [\s_new, \brkBass, -1, 0, 0,
			\freq, scale[note],
			\decay, 0.2,
			\filt, 1500,
			\amp, 0.35]);
	};

	// Hats
	28.do { |i|
		s.sendBundle(barOffset + (step * i), [\s_new, \brkHat, -1, 0, 0,
			\decay, if(i % 4 == 0, 0.04, 0.02),
			\amp, if(i % 7 == 0, 0.25, 0.12)]);
	};
};

"7/4 MAGYAR scheduled".postln;
)

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;

// --------------------------------------------------
// COMPOSITION: ROSSZ CSILLAG EXTENDED (5 minutes)
// Structure: Intro → Development → Peak → Breakdown → Resolution
// --------------------------------------------------
(
var bpm = 170, beat = 60/bpm, step = beat/4;
var t = 0.1;

// Hungarian minor scale
var scale = [48, 50, 51, 54, 55, 56, 59, 60]; // C D Eb F# G Ab B C
var chords = [
	[55, 58, 62], // G Ab B (tense)
	[48, 51, 55], // C Eb G (minor)
	[50, 54, 57], // D F# A (altered)
	[51, 55, 58], // Eb G Ab
];

// =====================================================
// INTRO (0:00 - 1:00) - Strings only, establish mood
// =====================================================
"Scheduling INTRO...".postln;

// Slow string chord progression - one chord every ~15 seconds
4.do { |i|
	var chord = chords[i];
	var onset = t + (i * 15);
	chord.do { |note, j|
		s.sendBundle(onset + (j * 0.3), [\s_new, \brkStrings, -1, 0, 0,
			\freq, note.midicps,
			\amp, 0.08 + (j * 0.02),
			\dur, 12 - (j * 2)
		]);
	};
};

// =====================================================
// DEVELOPMENT (1:00 - 2:30) - Add drums gradually
// =====================================================
"Scheduling DEVELOPMENT...".postln;

// Sparse drums enter at 1:00
// First 30 seconds: just kick and occasional snare
12.do { |bar|
	var barOffset = t + 60 + (bar * beat * 4);

	// Kick on 1
	s.sendBundle(barOffset, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.45]);

	// Snare every other bar
	if(bar.even, {
		s.sendBundle(barOffset + (beat * 2), [\s_new, \brkSnare, -1, 0, 0, \freq, 185, \amp, 0.4]);
	});

	// String stabs (every 4 bars)
	if(bar % 4 == 0, {
		var chord = chords[bar div: 4 % 4];
		chord.do { |note|
			s.sendBundle(barOffset, [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps,
				\amp, 0.07,
				\dur, 3
			]);
		};
	});
};

// Fuller pattern from 1:30
24.do { |bar|
	var barOffset = t + 90 + (bar * beat * 4);

	// Amen-style kick pattern
	[0, 2.5, 5, 8, 10.5, 13].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 52,
			\amp, if(pos == 0, 0.55, 0.4)
		]);
	};

	// Snare backbeat + ghost notes
	s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \amp, 0.5]);
	s.sendBundle(barOffset + (step * 12), [\s_new, \brkSnare, -1, 0, 0, \freq, 190, \amp, 0.5]);
	s.sendBundle(barOffset + (step * 7), [\s_new, \brkSnare, -1, 0, 0, \freq, 210, \decay, 0.06, \amp, 0.25]);
	s.sendBundle(barOffset + (step * 15), [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \decay, 0.06, \amp, 0.25]);

	// Hats every 8th
	8.do { |i|
		s.sendBundle(barOffset + (step * i * 2), [\s_new, \brkHat, -1, 0, 0,
			\decay, if(i % 2 == 0, 0.04, 0.02),
			\amp, if(i == 0, 0.22, 0.14)
		]);
	};

	// String chords every 8 bars
	if(bar % 8 == 0, {
		var chord = chords[bar div: 8 % 4];
		chord.do { |note, j|
			s.sendBundle(barOffset + (j * 0.2), [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps,
				\amp, 0.09,
				\dur, 6
			]);
		};
	});
};

// =====================================================
// PEAK (2:30 - 3:30) - Maximum density, full chaos
// =====================================================
"Scheduling PEAK...".postln;

42.do { |bar|
	var barOffset = t + 150 + (bar * beat * 4);

	// Aggressive kick pattern with distortion
	[0, 3, 5.5, 8, 11, 13.5].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkKick, -1, 0, 0,
			\freq, 48 + (bar % 4 * 2),
			\amp, 0.6,
			\dist, 0.3
		]);
	};

	// Pitched snares
	s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 180 + (bar % 8 * 5), \amp, 0.55]);
	s.sendBundle(barOffset + (step * 12), [\s_new, \brkSnare, -1, 0, 0, \freq, 195, \amp, 0.55]);

	// Ghost snares
	[7, 10, 15].do { |pos|
		s.sendBundle(barOffset + (step * pos), [\s_new, \brkSnare, -1, 0, 0,
			\freq, 210 + (bar * 2),
			\decay, 0.07,
			\amp, 0.3
		]);
	};

	// 16th note hats
	16.do { |i|
		s.sendBundle(barOffset + (step * i), [\s_new, \brkHat, -1, 0, 0,
			\decay, if(i % 4 == 0, 0.05, 0.015),
			\amp, if(i % 2 == 0, 0.2, 0.1)
		]);
	};

	// Glitch hits on accents
	if(bar % 2 == 1, {
		[6, 14].do { |pos|
			s.sendBundle(barOffset + (step * pos), [\s_new, \brkGlitch, -1, 0, 0,
				\freq, 1500 + (bar * 50),
				\amp, 0.2
			]);
		};
	});

	// Retrigger rolls every 8 bars
	if(bar % 8 == 7, {
		8.do { |i|
			s.sendBundle(barOffset + (step * 12) + (step * 0.125 * i), [\s_new, \brkSnare, -1, 0, 0,
				\freq, 170 + (i * 20),
				\decay, 0.04,
				\amp, 0.35 + (i * 0.025)
			]);
		};
	});

	// Bass stabs
	if(bar % 4 == 0, {
		s.sendBundle(barOffset, [\s_new, \brkBass, -1, 0, 0,
			\freq, scale[bar % 8].midicps / 2,
			\decay, 0.3,
			\filt, 1800,
			\amp, 0.35
		]);
	});

	// Strings in chaos (every 6 bars)
	if(bar % 6 == 0, {
		var chord = chords[bar div: 6 % 4];
		chord.do { |note|
			s.sendBundle(barOffset, [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps,
				\amp, 0.1,
				\dur, 4
			]);
		};
	});
};

// =====================================================
// BREAKDOWN (3:30 - 4:15) - Strip to foundation
// =====================================================
"Scheduling BREAKDOWN...".postln;

// Strings return, drums sparse
6.do { |i|
	var onset = t + 210 + (i * 7.5);
	var chord = chords[i % 4];

	chord.do { |note, j|
		s.sendBundle(onset + (j * 0.4), [\s_new, \brkStrings, -1, 0, 0,
			\freq, note.midicps,
			\amp, 0.1 - (i * 0.01),
			\dur, 6
		]);
	};

	// Sparse kick
	s.sendBundle(onset + 2, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.35]);

	// Occasional snare ghost
	if(i.odd, {
		s.sendBundle(onset + 4, [\s_new, \brkSnare, -1, 0, 0, \freq, 200, \decay, 0.08, \amp, 0.25]);
	});
};

// =====================================================
// RESOLUTION (4:15 - 5:00) - Partial return, fade
// =====================================================
"Scheduling RESOLUTION...".postln;

// Gentle return of pattern, fading
16.do { |bar|
	var barOffset = t + 255 + (bar * beat * 4);
	var fade = 1 - (bar / 20); // Fade out factor

	// Soft kick
	s.sendBundle(barOffset, [\s_new, \brkKick, -1, 0, 0, \freq, 50, \amp, 0.4 * fade]);
	if(bar < 12, {
		s.sendBundle(barOffset + (step * 8), [\s_new, \brkKick, -1, 0, 0, \freq, 55, \amp, 0.3 * fade]);
	});

	// Snare (fading)
	if(bar < 14, {
		s.sendBundle(barOffset + (step * 4), [\s_new, \brkSnare, -1, 0, 0, \freq, 185, \amp, 0.4 * fade]);
	});

	// Sparse hats
	if(bar < 10, {
		4.do { |i|
			s.sendBundle(barOffset + (step * i * 4), [\s_new, \brkHat, -1, 0, 0,
				\decay, 0.03,
				\amp, 0.15 * fade
			]);
		};
	});

	// Final string chord
	if(bar % 4 == 0, {
		var chord = chords[bar div: 4 % 4];
		chord.do { |note, j|
			s.sendBundle(barOffset + (j * 0.3), [\s_new, \brkStrings, -1, 0, 0,
				\freq, note.midicps,
				\amp, 0.08 * fade,
				\dur, 8
			]);
		};
	});
};

// Final resolving chord
s.sendBundle(t + 295, [\s_new, \brkStrings, -1, 0, 0, \freq, 48.midicps, \amp, 0.06, \dur, 10]);
s.sendBundle(t + 295.3, [\s_new, \brkStrings, -1, 0, 0, \freq, 55.midicps, \amp, 0.05, \dur, 9]);
s.sendBundle(t + 295.6, [\s_new, \brkStrings, -1, 0, 0, \freq, 60.midicps, \amp, 0.04, \dur, 8]);

"ROSSZ CSILLAG EXTENDED (5 min) scheduled".postln;
)
*/
