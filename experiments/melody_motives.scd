// ============================================================
// MELODY MOTIVES - Short melodic cells as building blocks
// ============================================================
// Exploring 2-5 note motives that can be:
// - Transposed, inverted, retrograde
// - Combined and sequenced
// - Varied rhythmically

// --------------------------------------------------
// SIMPLE SYNTH - Clean tone for hearing melodic shapes
// --------------------------------------------------
(
SynthDef(\motive, {
	arg out = 0, freq = 440, amp = 0.3, dur = 0.3, pan = 0;
	var sig, env;

	env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

	// Clean sine + soft overtone
	sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.2);
	sig = sig * env * amp;

	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Test the synth
// Synth(\motive, [\freq, 440, \dur, 0.5]);

// --------------------------------------------------
// MOTIVE DEFINITIONS - Classic melodic cells
// --------------------------------------------------
(
// Motives as interval patterns (semitones from root)
// Positive = up, Negative = down

// Two-note motives
~m2up = [0, 2];           // Major 2nd up (step)
~m2down = [0, -2];        // Major 2nd down
~m3up = [0, 4];           // Major 3rd up (leap)
~p5up = [0, 7];           // Perfect 5th up
~octave = [0, 12];        // Octave leap

// Three-note motives (classic shapes)
~stepUp = [0, 2, 4];                // Ascending steps
~stepDown = [0, -2, -4];            // Descending steps
~arch = [0, 4, 0];                  // Up and back
~dip = [0, -3, 0];                  // Down and back
~leapStep = [0, 7, 5];              // Leap up, step down
~stepLeap = [0, 2, 7];              // Step up, leap up

// Four-note motives
~turnUp = [0, 2, 0, -1];            // Upper neighbor turn
~turnDown = [0, -2, 0, 1];          // Lower neighbor turn
~arpUp = [0, 4, 7, 12];             // Major arpeggio up
~arpDown = [0, -5, -8, -12];        // Arpeggio down
~zigzag = [0, 4, 2, 5];             // Alternating direction

// Five-note motives
~scale5 = [0, 2, 4, 5, 7];          // Pentatonic fragment
~wave = [0, 3, 1, 4, 2];            // Wavelike motion
~reach = [0, 2, 7, 5, 9];           // Reaching upward

"Motives loaded".postln;
)

// --------------------------------------------------
// MOTIVE PLAYER - Plays a motive from a root note
// --------------------------------------------------
(
~playMotive = { |motive, root = 60, dur = 0.25, amp = 0.25, pan = 0|
	Routine({
		motive.do { |interval|
			var note = root + interval;
			Synth(\motive, [
				\freq, note.midicps,
				\dur, dur * 0.9,
				\amp, amp,
				\pan, pan
			]);
			dur.wait;
		};
	}).play;
};

"Player ready - use: ~playMotive.(~stepUp, 60)".postln;
)

// Test different motives
// ~playMotive.(~stepUp, 60);
// ~playMotive.(~arch, 64);
// ~playMotive.(~arpUp, 48);
// ~playMotive.(~turnUp, 72);

// --------------------------------------------------
// MOTIVE TRANSFORMATIONS
// --------------------------------------------------
(
// Transpose: shift all notes by semitones
~transpose = { |motive, semitones|
	motive + semitones;
};

// Invert: flip intervals (up becomes down)
~invert = { |motive|
	motive.collect { |interval| interval.neg };
};

// Retrograde: reverse the motive
~retrograde = { |motive|
	motive.reverse;
};

// Retrograde Inversion: both
~retroInvert = { |motive|
	~invert.(~retrograde.(motive));
};

// Augment: multiply intervals
~augment = { |motive, factor = 2|
	motive.collect { |interval| interval * factor };
};

// Diminish: compress intervals
~diminish = { |motive, factor = 2|
	motive.collect { |interval| (interval / factor).round };
};

"Transformations ready".postln;
)

// Test transformations
// ~playMotive.(~stepUp, 60);                      // Original: 0, 2, 4
// ~playMotive.(~invert.(~stepUp), 60);            // Inverted: 0, -2, -4
// ~playMotive.(~retrograde.(~stepUp), 60);        // Retrograde: 4, 2, 0
// ~playMotive.(~augment.(~stepUp), 60);           // Augmented: 0, 4, 8

// --------------------------------------------------
// MOTIVE COMBINATIONS - Chaining motives
// --------------------------------------------------
(
~chain = { |motives, root = 60, dur = 0.25|
	var combined = [];
	var currentRoot = 0;

	motives.do { |motive|
		// Offset each motive by where the previous ended
		motive.do { |interval, i|
			combined = combined.add(currentRoot + interval);
		};
		// Next motive starts from end of this one
		currentRoot = currentRoot + motive.last;
	};

	~playMotive.(combined, root, dur);
};

// Sequence: play motives one after another with roots
~sequence = { |motives, roots, dur = 0.25, gap = 0.1|
	Routine({
		motives.do { |motive, i|
			var root = roots.wrapAt(i);
			~playMotive.(motive, root, dur);
			(dur * motive.size + gap).wait;
		};
	}).play;
};

"Combinations ready".postln;
)

// Test combinations
// ~chain.([~stepUp, ~stepDown], 60);
// ~chain.([~arch, ~dip], 60);
// ~sequence.([~stepUp, ~arch, ~leapStep], [60, 64, 67]);

// --------------------------------------------------
// EXAMPLE 1: Developing a single motive
// --------------------------------------------------
(
~developMotive = { |baseMotive, root = 60|
	Routine({
		// Original
		"Original".postln;
		~playMotive.(baseMotive, root);
		1.5.wait;

		// Transposed up a 4th
		"Transposed +5".postln;
		~playMotive.(baseMotive, root + 5);
		1.5.wait;

		// Inverted
		"Inverted".postln;
		~playMotive.(~invert.(baseMotive), root + 7);
		1.5.wait;

		// Retrograde
		"Retrograde".postln;
		~playMotive.(~retrograde.(baseMotive), root);
		1.5.wait;

		// Original again (return)
		"Return to original".postln;
		~playMotive.(baseMotive, root);
	}).play;
};
)

// ~developMotive.(~arch, 60);
// ~developMotive.(~leapStep, 64);

// --------------------------------------------------
// EXAMPLE 2: Call and Response with motives
// --------------------------------------------------
(
~callResponse = Routine({
	var call = ~stepUp;
	var response = ~invert.(~stepUp);

	inf.do {
		// Call (left)
		~playMotive.(call, 60, 0.2, 0.25, -0.5);
		0.8.wait;

		// Response (right)
		~playMotive.(response, 67, 0.2, 0.25, 0.5);
		0.8.wait;

		// Variation
		call = [call, ~arch, ~leapStep].choose;
		response = ~invert.(call);
	};
});
)

// ~callResponse.play;
// ~callResponse.stop;

// --------------------------------------------------
// EXAMPLE 3: Motive ostinato with variations
// --------------------------------------------------
(
~motiveOstinato = Routine({
	var baseMotive = ~arpUp;
	var roots = [48, 48, 53, 50];  // I - I - IV - ii
	var variations = [
		{ |m| m },                    // Original
		{ |m| ~invert.(m) },          // Invert
		{ |m| ~retrograde.(m) },      // Retrograde
		{ |m| m ++ [m.last + 2] },    // Extend
	];
	var varIndex = 0;

	inf.do { |i|
		var root = roots.wrapAt(i);
		var motive = variations.wrapAt(varIndex).(baseMotive);

		~playMotive.(motive, root, 0.15, 0.2);
		(0.15 * motive.size + 0.3).wait;

		// Change variation every 4 bars
		if (i % 4 == 3) {
			varIndex = (varIndex + 1) % variations.size;
		};
	};
});
)

// ~motiveOstinato.play;
// ~motiveOstinato.stop;

// --------------------------------------------------
// EXAMPLE 4: Two-voice counterpoint with motives
// --------------------------------------------------
(
~twoVoices = {
	var voice1 = Routine({
		var motives = [~stepUp, ~arch, ~leapStep, ~turnUp];
		inf.do {
			var m = motives.choose;
			~playMotive.(m, rrand(60, 72), 0.2, 0.2, -0.4);
			(0.2 * m.size + rrand(0.1, 0.4)).wait;
		};
	});

	var voice2 = Routine({
		var motives = [~stepDown, ~dip, ~arpDown, ~turnDown];
		0.3.wait;  // Offset entry
		inf.do {
			var m = motives.choose;
			~playMotive.(m, rrand(48, 60), 0.25, 0.18, 0.4);
			(0.25 * m.size + rrand(0.2, 0.5)).wait;
		};
	});

	~v1 = voice1.play;
	~v2 = voice2.play;
};
)

// ~twoVoices.();
// ~v1.stop; ~v2.stop;

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
