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

// ============================================================
// PART 2: FRACTAL ARRANGEMENT
// ============================================================
// Self-similarity at multiple scales:
// - Micro: notes within motive
// - Meso: motives within phrase
// - Macro: phrases within section
//
// Following composition best practices:
// - Energy arc (intro → build → peak → breath → resolve)
// - Voice roles (Foundation, Pulse, Focus)
// - Three voice maximum
// - Tension → Release cycles

// --------------------------------------------------
// FRACTAL CONCEPT: Motive shape = Section shape
// --------------------------------------------------
// If motive is [0, 4, 0] (arch: up then down)
// Then section is: build → peak → resolve
// The motive IS the structure at a different scale

(
// Map motive intervals to energy levels (0-1)
~motiveToEnergy = { |motive|
	var min = motive.minItem;
	var max = motive.maxItem;
	var range = max - min;
	if (range == 0) { range = 1 };
	motive.collect { |interval|
		(interval - min) / range;
	};
};

// Map energy levels to composition parameters
~energyToParams = { |energy|
	(
		density: energy.linlin(0, 1, 0.3, 1.0),    // Note density
		register: energy.linlin(0, 1, 48, 72),     // Pitch range
		voices: energy.linlin(0, 1, 1, 3).round,   // Active voices
		amp: energy.linlin(0, 1, 0.15, 0.3)        // Volume
	);
};

"Fractal mapping ready".postln;
)

// --------------------------------------------------
// FRACTAL PHRASE BUILDER
// --------------------------------------------------
// Build phrases by repeating motive at different transpositions
// following its own intervallic pattern

(
~fractalPhrase = { |motive, root = 60, dur = 0.2|
	var phrase = [];
	var transpositions = motive.normalize(0, 7).round;  // Map to transposition levels

	// Each note of motive becomes a transposition point
	transpositions.do { |trans, i|
		var transposedMotive = motive + trans;
		phrase = phrase ++ transposedMotive;
	};

	~playMotive.(phrase, root, dur);
};

// Build phrase with variation at each repetition
~fractalPhraseWithVariation = { |motive, root = 60, dur = 0.2|
	var variations = [
		{ |m| m },
		{ |m| ~invert.(m) },
		{ |m| ~retrograde.(m) },
		{ |m| ~retroInvert.(m) }
	];

	Routine({
		motive.size.do { |i|
			var trans = motive[i];
			var variedMotive = variations.wrapAt(i).(motive);
			~playMotive.(variedMotive, root + trans, dur);
			(dur * motive.size).wait;
		};
	}).play;
};

"Fractal phrase builder ready".postln;
)

// ~fractalPhrase.(~arch, 60, 0.15);
// ~fractalPhraseWithVariation.(~stepUp, 60, 0.2);

// --------------------------------------------------
// CANTOR RHYTHM - Fractal silence pattern
// --------------------------------------------------
// Cantor set: divide into 3, remove middle
// Creates nested gaps at multiple scales

(
~cantorRhythm = { |depth = 3|
	var pattern = [1];  // Start with one beat

	depth.do {
		pattern = pattern.collect { |beat|
			if (beat == 1) { [1, 0, 1] } { [0, 0, 0] };
		}.flatten;
	};

	pattern;
};

~playCantorMotive = { |motive, root = 60, dur = 0.15, depth = 3|
	var rhythm = ~cantorRhythm.(depth);
	var noteIndex = 0;

	Routine({
		rhythm.do { |beat|
			if (beat == 1) {
				var note = motive.wrapAt(noteIndex);
				Synth(\motive, [
					\freq, (root + note).midicps,
					\dur, dur * 0.8,
					\amp, 0.25
				]);
				noteIndex = noteIndex + 1;
			};
			dur.wait;
		};
	}).play;
};

"Cantor rhythm ready".postln;
)

// ~playCantorMotive.(~arpUp, 60, 0.12, 3);
// ~playCantorMotive.(~scale5, 48, 0.1, 4);

// --------------------------------------------------
// GOLDEN RATIO SECTIONS
// --------------------------------------------------
// Phi ≈ 0.618 - natural proportion for tension/release

(
~phi = 0.618;

// Divide duration by golden ratio for climax placement
~goldenClimax = { |totalDur|
	totalDur * ~phi;  // Climax at ~62% through
};

// Generate golden-proportioned section lengths
~goldenSections = { |totalDur, numSections = 5|
	var sections = [];
	var remaining = totalDur;

	(numSections - 1).do {
		var sectionDur = remaining * (1 - ~phi);
		sections = sections.add(sectionDur);
		remaining = remaining - sectionDur;
	};
	sections = sections.add(remaining);  // Final section

	sections;
};

"Golden ratio ready".postln;
)

// ~goldenSections.(60, 5);  // Returns section durations

// --------------------------------------------------
// ENERGY ARC - Maps composition structure to time
// --------------------------------------------------

(
// Section definitions following COMPOSITION.md
~sections = (
	intro:      (energy: 0.2, voices: 1, desc: "establish mood"),
	develop:    (energy: 0.5, voices: 2, desc: "add movement"),
	peak:       (energy: 1.0, voices: 3, desc: "maximum density"),
	breakdown:  (energy: 0.3, voices: 1, desc: "create absence"),
	resolve:    (energy: 0.4, voices: 2, desc: "partial return")
);

// Get section at normalized time (0-1)
~sectionAt = { |time|
	case
	{ time < 0.2 }  { \intro }
	{ time < 0.5 }  { \develop }
	{ time < 0.7 }  { \peak }
	{ time < 0.85 } { \breakdown }
	{ true }        { \resolve };
};

// Energy curve (tension/release)
~energyAt = { |time|
	var section = ~sectionAt.(time);
	~sections[section][\energy];
};

"Energy arc ready".postln;
)

// --------------------------------------------------
// FRACTAL COMPOSITION - Full piece generator
// --------------------------------------------------

(
~fractalComposition = { |motive, totalDur = 60, root = 60|
	var sectionDurs = ~goldenSections.(totalDur, 5);
	var sectionNames = [\intro, \develop, \peak, \breakdown, \resolve];
	var elapsed = 0;

	~compositionRoutine = Routine({
		sectionNames.do { |sectionName, i|
			var dur = sectionDurs[i];
			var section = ~sections[sectionName];
			var numPhrases = (dur / 4).floor.max(1);  // ~4 sec per phrase
			var phraseDur = dur / numPhrases;

			("=== " ++ sectionName.asString.toUpper ++ " ===").postln;
			("Duration: " ++ dur.round(0.1) ++ "s, Voices: " ++ section[\voices]).postln;

			numPhrases.do { |phraseNum|
				var energy = section[\energy];
				var noteDur = energy.linlin(0, 1, 0.3, 0.12);
				var variation = [
					{ |m| m },
					{ |m| ~invert.(m) },
					{ |m| ~retrograde.(m) }
				].choose;

				// Apply fractal: motive shape at phrase level
				section[\voices].do { |voice|
					var pan = voice.linlin(0, 2, -0.5, 0.5);
					var octave = [-12, 0, 12].wrapAt(voice);
					var varMotive = variation.(motive);

					fork {
						// Stagger voice entries
						(voice * 0.1).wait;
						~playMotive.(varMotive, root + octave, noteDur, energy * 0.15, pan);
					};
				};

				phraseDur.wait;
			};

			elapsed = elapsed + dur;
		};

		"=== COMPOSITION COMPLETE ===".postln;
	}).play;
};

~stopComposition = {
	~compositionRoutine.stop;
	s.freeAll;
};

"Fractal composition ready".postln;
"Use: ~fractalComposition.(~arch, 30, 60)".postln;
)

// ~fractalComposition.(~arch, 30, 60);
// ~stopComposition.();

// --------------------------------------------------
// VOICE ROLES - From composition guide
// --------------------------------------------------

(
SynthDef(\foundation, {
	arg out = 0, freq = 55, amp = 0.2, dur = 2;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.1, dur - 0.3, 0.2), doneAction: 2);
	sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.1);
	sig = LPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\pulse, {
	arg out = 0, freq = 220, amp = 0.15, dur = 0.1, rate = 4;
	var sig, env, trig;
	env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);
	sig = Pulse.ar(freq, 0.3) * 0.3;
	sig = sig + SinOsc.ar(freq);
	sig = LPF.ar(sig, freq * 3);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

"Voice role synths ready".postln;
)

// ============================================================
// 5-MINUTE PIECE - Following COMPOSITION.md exactly
// ============================================================
// Timings from composition guide:
// - Intro:       0:00-1:00 (60s)  - One element, establish mood
// - Development: 1:00-2:30 (90s)  - Add pulse, harmonic movement
// - Peak:        2:30-3:30 (60s)  - Maximum density, all voices
// - Breakdown:   3:30-4:15 (45s)  - Strip to foundation
// - Resolution:  4:15-5:00 (45s)  - Partial return, fade

(
// Exact section timings (in seconds)
~fiveMinSections = (
	intro:      (start: 0,   dur: 60,  voices: 1, energy: 0.2),
	develop:    (start: 60,  dur: 90,  voices: 2, energy: 0.5),
	peak:       (start: 150, dur: 60,  voices: 3, energy: 1.0),
	breakdown:  (start: 210, dur: 45,  voices: 1, energy: 0.3),
	resolve:    (start: 255, dur: 45,  voices: 2, energy: 0.4)
);

~getSectionAt = { |elapsed|
	case
	{ elapsed < 60 }  { \intro }
	{ elapsed < 150 } { \develop }
	{ elapsed < 210 } { \peak }
	{ elapsed < 255 } { \breakdown }
	{ true }          { \resolve };
};

"5-minute structure loaded".postln;
)

// --------------------------------------------------
// THE 5-MINUTE PIECE
// --------------------------------------------------
(
~fiveMinutePiece = { |motive, root = 48|
	var totalDur = 300;  // 5 minutes

	~elapsed = 0;
	~running = true;
	~routines = [];

	// Harmony progression (changes every ~20 seconds)
	~chordRoots = [0, 0, 5, 5, 7, 7, 5, 0];  // I-I-IV-IV-V-V-IV-I
	~currentChord = 0;

	// ========================================
	// FOUNDATION VOICE - Slow bass anchor
	// ========================================
	~routines = ~routines.add(Routine({
		loop {
			var section = ~getSectionAt.(~elapsed);
			var info = ~fiveMinSections[section];

			if (info[\energy] >= 0.3) {
				var chordRoot = ~chordRoots.wrapAt(~currentChord);
				Synth(\foundation, [
					\freq, (root + chordRoot).midicps,
					\amp, info[\energy] * 0.15,
					\dur, 4
				]);
			};

			4.wait;
			~currentChord = ~currentChord + 1;
		};
	}));

	// ========================================
	// PULSE VOICE - Rhythmic element
	// ========================================
	~routines = ~routines.add(Routine({
		60.wait;  // Enter at Development (1:00)

		loop {
			var section = ~getSectionAt.(~elapsed);
			var info = ~fiveMinSections[section];

			if (info[\energy] >= 0.5) {
				// Active pulse
				8.do {
					var chordRoot = ~chordRoots.wrapAt(~currentChord);
					Synth(\pulse, [
						\freq, (root + 12 + chordRoot + [0, 7].choose).midicps,
						\amp, info[\energy] * 0.06,
						\dur, 0.12
					]);
					0.25.wait;
				};
			} {
				// Rest during quiet sections
				2.wait;
			};
		};
	}));

	// ========================================
	// FOCUS VOICE - Melodic motives
	// ========================================
	~routines = ~routines.add(Routine({
		var variations = [
			{ |m| m },                    // Original
			{ |m| ~invert.(m) },          // Inverted
			{ |m| ~retrograde.(m) },      // Retrograde
			{ |m| ~retroInvert.(m) }      // Retrograde-invert
		];
		var variationWeights = [0.4, 0.25, 0.2, 0.15];
		var phraseCount = 0;

		2.wait;  // Let intro establish

		loop {
			var section = ~getSectionAt.(~elapsed);
			var info = ~fiveMinSections[section];
			var chordRoot = ~chordRoots.wrapAt(~currentChord);

			// Note duration based on energy (faster at peak)
			var noteDur = info[\energy].linlin(0.2, 1.0, 0.4, 0.15);

			// Select variation (more variety at peak)
			var variation = if (section == \peak) {
				variations.wchoose(variationWeights);
			} {
				variations.wchoose([0.6, 0.2, 0.15, 0.05]);
			};

			// Play motive transposed to current harmony
			~playMotive.(
				variation.(motive),
				root + 24 + chordRoot,
				noteDur,
				info[\energy] * 0.2,
				0
			);

			// Gap between phrases (shorter at peak, longer at intro)
			(noteDur * motive.size + info[\energy].linlin(0.2, 1.0, 2.5, 0.5)).wait;

			phraseCount = phraseCount + 1;
		};
	}));

	// ========================================
	// SECOND MELODIC VOICE - Counterpoint (Peak only)
	// ========================================
	~routines = ~routines.add(Routine({
		150.wait;  // Enter at Peak (2:30)

		loop {
			var section = ~getSectionAt.(~elapsed);

			if (section == \peak) {
				var chordRoot = ~chordRoots.wrapAt(~currentChord);
				var variation = [
					{ |m| ~invert.(m) },
					{ |m| ~retrograde.(m) }
				].choose;

				// Offset entry for counterpoint effect
				rrand(0.1, 0.3).wait;

				~playMotive.(
					variation.(motive),
					root + 12 + chordRoot,  // Lower octave
					0.2,
					0.12,
					[-0.4, 0.4].choose  // Panned
				);

				rrand(1.5, 3.0).wait;
			} {
				1.wait;
			};
		};
	}));

	// ========================================
	// SECTION ANNOUNCER & TIME TRACKER
	// ========================================
	~routines = ~routines.add(Routine({
		var lastSection = nil;

		loop {
			var section = ~getSectionAt.(~elapsed);
			var mins = (~elapsed / 60).floor.asInteger;
			var secs = (~elapsed % 60).floor.asInteger;

			// Announce section changes
			if (section != lastSection) {
				("").postln;
				("=== " ++ section.asString.toUpper ++ " === [" ++
					mins ++ ":" ++ secs.asString.padLeft(2, "0") ++ "]").postln;
				lastSection = section;
			};

			// End piece
			if (~elapsed >= totalDur) {
				"".postln;
				"=== PIECE COMPLETE ===".postln;
				~stopFiveMin.();
			};

			~elapsed = ~elapsed + 0.5;
			0.5.wait;
		};
	}));

	// Start all routines
	~routines.do(_.play);

	"".postln;
	"╔════════════════════════════════════════╗".postln;
	("║  5-MINUTE PIECE: " ++ motive).postln;
	("║  Root: " ++ root ++ " (" ++ root.midicps.round(0.1) ++ " Hz)").postln;
	"╠════════════════════════════════════════╣".postln;
	"║  0:00  INTRO      - Focus alone        ║".postln;
	"║  1:00  DEVELOP    - Add pulse          ║".postln;
	"║  2:30  PEAK       - Full density       ║".postln;
	"║  3:30  BREAKDOWN  - Strip back         ║".postln;
	"║  4:15  RESOLVE    - Fade out           ║".postln;
	"╚════════════════════════════════════════╝".postln;
};

~stopFiveMin = {
	~running = false;
	~routines.do(_.stop);
	s.freeAll;
	"Stopped".postln;
};

"5-minute piece ready".postln;
"Use: ~fiveMinutePiece.(~arch, 48)".postln;
)

// --------------------------------------------------
// RUN THE 5-MINUTE PIECE
// --------------------------------------------------
// ~fiveMinutePiece.(~arch, 48);        // Arch motive in C
// ~fiveMinutePiece.(~leapStep, 53);    // Leap-step in F
// ~fiveMinutePiece.(~scale5, 45);      // Pentatonic in A
// ~stopFiveMin.();

// --------------------------------------------------
// QUICK TEST (30 seconds, same structure compressed)
// --------------------------------------------------
(
~testPiece = { |motive, root = 48|
	// Compressed version for testing
	~fiveMinSections = (
		intro:      (start: 0,  dur: 6,  voices: 1, energy: 0.2),
		develop:    (start: 6,  dur: 9,  voices: 2, energy: 0.5),
		peak:       (start: 15, dur: 6,  voices: 3, energy: 1.0),
		breakdown:  (start: 21, dur: 4,  voices: 1, energy: 0.3),
		resolve:    (start: 25, dur: 5,  voices: 2, energy: 0.4)
	);

	~getSectionAt = { |elapsed|
		case
		{ elapsed < 6 }  { \intro }
		{ elapsed < 15 } { \develop }
		{ elapsed < 21 } { \peak }
		{ elapsed < 25 } { \breakdown }
		{ true }         { \resolve };
	};

	"TEST MODE: 30 second piece".postln;
	~fiveMinutePiece.(motive, root);
};
)

// ~testPiece.(~arch, 48);
// ~stopFiveMin.();

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
