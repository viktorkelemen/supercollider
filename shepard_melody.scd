// ============================================================
// SHEPARD MELODY - Melodic explorations with the Shepard illusion
// ============================================================
// The paradox: melodies that rise forever but never get higher

// --------------------------------------------------
// SYNTH DEFINITION - Discrete Shepard note
// --------------------------------------------------
(
SynthDef(\shepardNote, {
    arg out = 0, note = 0, amp = 0.3, sustain = 0.5,
        attack = 0.01, release = 0.4, baseFreq = 32.7, brightness = 5;
    var numOctaves = 10;
    var sig, pitchClass, env;

    // Note is pitch class 0-11 (or MIDI note - we take mod 12)
    // This means note 60 and note 72 sound IDENTICAL - octave is meaningless!
    pitchClass = note.mod(12);

    // Generate all octave copies with Gaussian weighting
    sig = Mix.fill(numOctaves, { |i|
        var octaveFreq, gaussianWeight;

        octaveFreq = baseFreq * (2 ** (pitchClass / 12)) * (2 ** i);

        // Gaussian centered at 'brightness' parameter (default 5 = middle)
        // Lower = darker/bassier, Higher = brighter/trebly
        gaussianWeight = exp(-1 * (i - brightness).squared / 3);

        SinOsc.ar(octaveFreq) * gaussianWeight;
    });

    env = EnvGen.kr(
        Env.perc(attack, sustain + release, 1, -4),
        doneAction: 2
    );

    sig = sig * env * amp / numOctaves;
    Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// DEMO 1: Infinite Staircase (Chromatic)
// --------------------------------------------------
// Ascends through all 12 pitch classes, then "wraps" invisibly
// Your ear perceives endless rising, but it's cycling 0-11
(
Routine({
    4.do { |cycle|
        "Cycle %".format(cycle + 1).postln;
        12.do { |note|
            Synth(\shepardNote, [
                \note, note,
                \amp, 0.35,
                \sustain, 0.15,
                \release, 0.2
            ]);
            0.2.wait;
        };
    };
    "Done - did you notice where it 'reset'? You shouldn't!".postln;
}).play;
)

// --------------------------------------------------
// DEMO 2: Whole Tone Staircase
// --------------------------------------------------
// Uses whole tone scale (0,2,4,6,8,10) - more dreamlike
(
Routine({
    var wholeTone = [0, 2, 4, 6, 8, 10];
    5.do { |cycle|
        wholeTone.do { |note|
            Synth(\shepardNote, [
                \note, note,
                \amp, 0.35,
                \sustain, 0.25,
                \release, 0.3,
                \brightness, 5.5
            ]);
            0.3.wait;
        };
    };
}).play;
)

// --------------------------------------------------
// DEMO 3: Descending (The Bottomless Pit)
// --------------------------------------------------
// Same trick in reverse - falls forever
(
Routine({
    4.do { |cycle|
        (11..0).do { |note|  // Descending
            Synth(\shepardNote, [
                \note, note,
                \amp, 0.35,
                \sustain, 0.15,
                \release, 0.2,
                \brightness, 4.5  // Slightly darker
            ]);
            0.2.wait;
        };
    };
}).play;
)

// --------------------------------------------------
// DEMO 4: Paradox Melody
// --------------------------------------------------
// A melody that SOUNDS like it rises, but look at the notes:
// It actually descends by large leaps and rises by small steps!
(
Routine({
    // Pattern: up a minor 2nd, up a minor 2nd, DOWN a major 3rd
    // Net motion per cycle: +1 +1 -4 = -2 (descending!)
    // But perceptually: sounds like it's rising
    var pattern = [0, 1, 2, -2, -1, 0, -4, -3, -2, -6]; // etc
    var note = 0;

    3.do {
        [1, 1, 1, -4, 1, 1, 1, -4, 1, 1, 1, -4].do { |step|
            note = note + step;
            Synth(\shepardNote, [
                \note, note,
                \amp, 0.35,
                \sustain, 0.2,
                \release, 0.25
            ]);
            0.25.wait;
        };
    };
    "Net motion was DOWNWARD, but did it sound that way?".postln;
}).play;
)

// --------------------------------------------------
// DEMO 5: Shepard Arpeggio (Chord Exploration)
// --------------------------------------------------
// Major and minor chords in Shepard space
(
Routine({
    var chords = [
        [0, 4, 7],      // C major
        [5, 9, 0],      // F major
        [7, 11, 2],     // G major
        [0, 4, 7],      // C major
    ];

    chords.do { |chord|
        // Arpeggiate up
        chord.do { |note|
            Synth(\shepardNote, [\note, note, \amp, 0.3, \sustain, 0.4]);
            0.15.wait;
        };
        // Then play as chord
        chord.do { |note|
            Synth(\shepardNote, [\note, note, \amp, 0.25, \sustain, 0.6]);
        };
        0.8.wait;
    };
}).play;
)

// --------------------------------------------------
// DEMO 6: Canon at the Tritone
// --------------------------------------------------
// Two voices, 6 semitones apart (tritone = half octave)
// Creates a strange parallel motion
(
Routine({
    24.do { |i|
        var note = i.mod(12);
        // Voice 1
        Synth(\shepardNote, [
            \note, note,
            \amp, 0.25,
            \sustain, 0.2,
            \brightness, 4
        ]);
        // Voice 2 - tritone above (6 semitones)
        Synth(\shepardNote, [
            \note, note + 6,
            \amp, 0.25,
            \sustain, 0.2,
            \brightness, 6
        ]);
        0.25.wait;
    };
}).play;
)

// --------------------------------------------------
// DEMO 7: Rhythmic Shepard Pattern
// --------------------------------------------------
// Minimalist repeating figure with subtle shifts
(
Routine({
    var pattern = [0, 3, 7, 3];  // A simple motif
    var offset = 0;

    8.do { |cycle|
        pattern.do { |note|
            Synth(\shepardNote, [
                \note, note + offset,
                \amp, 0.3,
                \sustain, 0.1,
                \release, 0.15
            ]);
            0.125.wait;
        };
        offset = offset + 1;  // Shift up each cycle - infinite rise!
    };
}).play;
)

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
