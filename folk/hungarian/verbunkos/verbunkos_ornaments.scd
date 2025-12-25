// ============================================================================
// VERBUNKOS ORNAMENTS - Grace Notes, Trills, Mordents, Slides
// ============================================================================
// Ornamentation is ESSENTIAL to authentic Verbunkos. The style features:
// - Grace notes (előke): quick notes before the main note
// - Trills (trilla): rapid alternation between adjacent notes
// - Mordents: quick lower/upper neighbor and return
// - Slides/portamento: pitch gliding (violin technique)
// - Turns: ornamental figures around a note
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR ORNAMENTED PLAYING
// ============================================================================
(
// Basic tone for comparison
SynthDef(\verbPlain, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5|
    var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    var sig = Saw.ar(freq) + Pulse.ar(freq * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, freq * 3);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Synth with portamento/slide capability
SynthDef(\verbSlide, {
    |out = 0, startFreq = 440, endFreq = 440, amp = 0.3, dur = 0.5, slideTime = 0.1|
    var freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.01, slideTime]));
    var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    var sig = Saw.ar(freqEnv) + Pulse.ar(freqEnv * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, freqEnv * 3);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Synth with vibrato (for sustained ornamental notes)
SynthDef(\verbVibrato, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, vibRate = 5, vibDepth = 0.02|
    var vibrato = SinOsc.kr(vibRate, 0, freq * vibDepth);
    var env = EnvGen.kr(Env.linen(0.02, dur * 0.7, dur * 0.28), doneAction: 2);
    var sig = Saw.ar(freq + vibrato) + Pulse.ar((freq + vibrato) * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, freq * 3);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Trill synth - rapid alternation built in
SynthDef(\verbTrill, {
    |out = 0, freq = 440, trillFreq = 466, amp = 0.3, dur = 0.5, trillRate = 12|
    var trill = LFPulse.kr(trillRate).range(freq, trillFreq);
    var env = EnvGen.kr(Env.linen(0.01, dur * 0.8, dur * 0.19), doneAction: 2);
    var sig = Saw.ar(trill) + Pulse.ar(trill * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, trill * 3);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Grace notes (előke)
// ============================================================================
(
// Single grace note before main note
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Grace note (from below):".postln;
    // Quick grace note
    Synth(\verbPlain, [
        \freq, ~scaleToFreq.(root, scale, 3), // F#
        \dur, 0.05,
        \amp, 0.2
    ]);
    0.04.wait;
    // Main note
    Synth(\verbPlain, [
        \freq, ~scaleToFreq.(root, scale, 4), // G
        \dur, 0.5,
        \amp, 0.35
    ]);

    1.0.wait;

    "Double grace notes (gruppetto):".postln;
    // Two quick grace notes
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04, \amp, 0.18]);
    0.03.wait;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.04, \amp, 0.2]);
    0.03.wait;
    // Main note
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.5, \amp, 0.35]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Trills
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Standard trill (to upper neighbor):".postln;
    Synth(\verbTrill, [
        \freq, ~scaleToFreq.(root, scale, 4),      // G
        \trillFreq, ~scaleToFreq.(root, scale, 5), // Ab
        \dur, 0.8,
        \trillRate, 10,
        \amp, 0.35
    ]);

    1.2.wait;

    "Accelerating trill:".postln;
    // Manual accelerating trill
    12.do { |i|
        var rate = 0.08 - (i * 0.005);
        var note = if(i % 2 == 0, 4, 5);
        Synth(\verbPlain, [
            \freq, ~scaleToFreq.(root, scale, note),
            \dur, rate * 1.5,
            \amp, 0.3
        ]);
        rate.wait;
    };
    // Resolve
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.5, \amp, 0.35]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Mordents (lower and upper)
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Lower mordent (main-lower-main):".postln;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.06, \amp, 0.3]);
    0.05.wait;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04, \amp, 0.25]);
    0.03.wait;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.5, \amp, 0.35]);

    1.0.wait;

    "Upper mordent (main-upper-main):".postln;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.06, \amp, 0.3]);
    0.05.wait;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.04, \amp, 0.25]);
    0.03.wait;
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.5, \amp, 0.35]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Slides / Portamento
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Upward slide (expressive):".postln;
    Synth(\verbSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 2),  // Eb
        \endFreq, ~scaleToFreq.(root, scale, 4),    // G
        \dur, 0.7,
        \slideTime, 0.15,
        \amp, 0.35
    ]);

    1.2.wait;

    "Downward slide (lamenting):".postln;
    Synth(\verbSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 6),  // B
        \endFreq, ~scaleToFreq.(root, scale, 4),    // G
        \dur, 0.8,
        \slideTime, 0.2,
        \amp, 0.35
    ]);

    1.2.wait;

    "Quick slide (violin 'scoop'):".postln;
    Synth(\verbSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 3) * 0.97, // Just below F#
        \endFreq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.5,
        \slideTime, 0.06,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Turn (gruppetto around a note)
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Turn around G (upper-main-lower-main):".postln;
    var mainNote = 4; // G
    var durations = [0.08, 0.08, 0.08, 0.5];
    var notes = [mainNote + 1, mainNote, mainNote - 1, mainNote]; // Ab-G-F#-G

    notes.do { |deg, i|
        Synth(\verbPlain, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durations[i] * 1.5,
            \amp, if(i == 3, 0.35, 0.25)
        ]);
        durations[i].wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Vibrato intensity variations
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Gentle vibrato (lyrical):".postln;
    Synth(\verbVibrato, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \vibRate, 4,
        \vibDepth, 0.015,
        \amp, 0.35
    ]);

    1.5.wait;

    "Intense vibrato (passionate):".postln;
    Synth(\verbVibrato, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \vibRate, 7,
        \vibDepth, 0.035,
        \amp, 0.35
    ]);

    1.5.wait;

    "Wide, slow vibrato (crying):".postln;
    Synth(\verbVibrato, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \vibRate, 3.5,
        \vibDepth, 0.05,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Combined ornamental phrase
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Full ornamental phrase:".postln;

    // Grace note into main note
    Synth(\verbPlain, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.05, \amp, 0.2]);
    0.04.wait;
    Synth(\verbVibrato, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.6, \vibRate, 5, \amp, 0.35]);
    0.5.wait;

    // Slide down
    Synth(\verbSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.4,
        \slideTime, 0.12,
        \amp, 0.3
    ]);
    0.35.wait;

    // Quick turn
    [3, 2, 1, 2].do { |deg, i|
        Synth(\verbPlain, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.08,
            \amp, 0.25
        ]);
        0.06.wait;
    };

    // Trill on resolution
    Synth(\verbTrill, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \trillFreq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.6,
        \trillRate, 8,
        \amp, 0.3
    ]);
    0.5.wait;

    // Final note with vibrato
    Synth(\verbVibrato, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.0,
        \vibRate, 5,
        \vibDepth, 0.02,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 8: Virtuosic ascending run with ornaments
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Virtuosic ascending run:".postln;

    // Fast scalar run with occasional grace notes
    (0..10).do { |deg, i|
        var dur = 0.08;
        var hasGrace = [2, 5, 8].includes(i);

        if(hasGrace) {
            // Add grace note from below
            Synth(\verbPlain, [
                \freq, ~scaleToFreq.(root, scale, deg - 1),
                \dur, 0.03,
                \amp, 0.15
            ]);
            0.02.wait;
        };

        Synth(\verbPlain, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.5,
            \amp, 0.3
        ]);
        dur.wait;
    };

    // Top note with trill
    Synth(\verbTrill, [
        \freq, ~scaleToFreq.(root, scale, 11),
        \trillFreq, ~scaleToFreq.(root, scale, 12),
        \dur, 0.8,
        \trillRate, 12,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
