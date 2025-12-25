// ============================================================================
// HALLGATÓ - "Listening Song" (Parlando Rubato)
// ============================================================================
// Hallgató means "a song for listening to, not for dancing."
//
// Characteristics:
// - Parlando rubato: free rhythm following speech patterns
// - Heavily ornamented melodic lines
// - Descending melodic contour (old-style)
// - Solo voice or violin, minimal accompaniment
// - Deep emotional expression, often melancholic
// - Pentatonic foundation with chromatic inflection
// - No strict meter - time stretches and contracts
// ============================================================================

(
// Old-style pentatonic (more archaic feel)
~pentatonic = [0, 2, 4, 7, 9];
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR HALLGATÓ
// ============================================================================
(
// Expressive violin with wide vibrato
SynthDef(\hallgatoViolin, {
    |out = 0, freq = 440, amp = 0.35, dur = 1.0, pan = 0,
     vibRate = 4, vibDepth = 0.025, vibDelay = 0.15,
     attack = 0.1, peak = 0.3, release = 0.4,
     brightness = 0.5|

    var env, vibEnv, vibrato, sig, formant1, formant2, formant3;

    // Expressive envelope with slow attack
    env = EnvGen.kr(
        Env([0, 1, 0.8, 0.6, 0],
            [attack, peak * dur, (1 - peak - release) * dur, release * dur],
            [3, -1, -2, -4]),
        doneAction: 2
    );

    // Delayed, expressive vibrato
    vibEnv = EnvGen.kr(Env([0, 0, 1, 1.2, 0.8], [vibDelay, 0.2, dur * 0.3, dur * 0.3]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.5, 0.5))
              * freq * vibDepth * vibEnv;

    sig = LFSaw.ar(freq + vibrato);

    // Warm body resonance
    formant1 = BPF.ar(sig, 280, 0.25) * 3;
    formant2 = BPF.ar(sig, 500, 0.3) * 2;
    formant3 = BPF.ar(sig, 2200, 0.15) * 1.5;

    sig = sig + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (2 + (brightness * 5)));
    sig = (sig * 1.4).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Slide/portamento for expressive transitions
SynthDef(\hallgatoSlide, {
    |out = 0, startFreq = 440, endFreq = 400, amp = 0.35, dur = 0.8,
     slideTime = 0.25, vibRate = 4, vibDepth = 0.02, pan = 0|

    var env, freqEnv, vibrato, sig, formant1, formant2, freq;

    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.05, slideTime], \exp));
    freq = freqEnv;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.08, dur * 0.6, dur * 0.32], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    sig = LFSaw.ar(freq + vibrato);

    formant1 = BPF.ar(sig, 280, 0.25) * 3;
    formant2 = BPF.ar(sig, 500, 0.3) * 2;
    sig = sig + formant1 + formant2;

    sig = LPF.ar(sig, freq * 4);
    sig = (sig * 1.4).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Grace note for ornaments
SynthDef(\hallgatoGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.04|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);
    sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 500, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, freq * 3);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Sparse drone (optional, very quiet)
SynthDef(\hallgatoDrone, {
    |out = 0, freq = 110, amp = 0.08, gate = 1|
    var env, sig;

    env = EnvGen.kr(Env.asr(1.0, 1, 2.0), gate, doneAction: 2);
    sig = SinOsc.ar([freq, freq * 1.5]) * [0.7, 0.3];
    sig = sig.sum;
    sig = LPF.ar(sig, 300);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Simple descending phrase (old-style contour)
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

// Rubato timing - irregular, speech-like
var melody = [4, 3, 2, 1, 0, -1, 0];
var durations = [0.9, 0.4, 0.7, 0.35, 0.8, 0.3, 1.5]; // Irregular

Routine({
    "Hallgató - descending phrase:".postln;

    melody.do { |deg, i|
        var dur = durations[i];

        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \amp, 0.38 - (i * 0.02), // Slight decrescendo
            \vibRate, 4 + rrand(-0.5, 0.5),
            \vibDepth, 0.022,
            \vibDelay, 0.12
        ]);

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Ornamented phrase
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Hallgató - ornamented phrase:".postln;

    // Grace note into first note
    Synth(\hallgatoGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04]);
    0.03.wait;

    Synth(\hallgatoViolin, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \vibRate, 4,
        \vibDepth, 0.028,
        \amp, 0.4
    ]);
    1.0.wait;

    // Slide down
    Synth(\hallgatoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.9,
        \slideTime, 0.2,
        \amp, 0.38
    ]);
    0.8.wait;

    // Quick ornamental turn
    [3, 2, 1, 2].do { |deg|
        Synth(\hallgatoGrace, [\freq, ~scaleToFreq.(root, scale, deg), \dur, 0.05, \amp, 0.18]);
        0.04.wait;
    };

    // Held note with intense vibrato
    Synth(\hallgatoViolin, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 1.5,
        \vibRate, 4.5,
        \vibDepth, 0.035,  // Wide vibrato
        \amp, 0.36
    ]);
    1.4.wait;

    // Final descent
    Synth(\hallgatoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 1),
        \endFreq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.2,
        \slideTime, 0.15,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Full rubato phrase (speech-like timing)
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

// Simulating speech rhythm: long syllables, short syllables, pauses
var phrase = [
    // [degree, duration, dynamic, hasGrace, hasSlideToNext]
    [4, 1.0, 0.4, true, false],    // Start high, grace note
    [3, 0.35, 0.35, false, false], // Quick
    [4, 0.8, 0.38, false, true],   // Linger, slide to next
    [2, 0.9, 0.36, false, false],  // Pause on this
    [3, 0.25, 0.32, false, false], // Quick passing
    [2, 0.5, 0.34, false, true],   // Slide down
    [1, 0.7, 0.33, false, false],
    [0, 0.4, 0.3, false, false],
    [-1, 0.3, 0.28, false, false], // Below tonic
    [0, 1.8, 0.35, false, false],  // Final rest
];

Routine({
    "Hallgató - rubato (speech-like):".postln;

    phrase.do { |note, i|
        var deg = note[0];
        var dur = note[1];
        var amp = note[2];
        var hasGrace = note[3];
        var hasSlide = note[4];
        var nextDeg = if(i < (phrase.size - 1), phrase[i+1][0], deg);

        // Grace note
        if(hasGrace) {
            Synth(\hallgatoGrace, [\freq, ~scaleToFreq.(root, scale, deg - 1), \dur, 0.035]);
            0.03.wait;
        };

        // Main note or slide
        if(hasSlide) {
            Synth(\hallgatoSlide, [
                \startFreq, ~scaleToFreq.(root, scale, deg),
                \endFreq, ~scaleToFreq.(root, scale, nextDeg),
                \dur, dur * 1.1,
                \slideTime, dur * 0.4,
                \amp, amp
            ]);
        } {
            Synth(\hallgatoViolin, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.05,
                \amp, amp,
                \vibRate, 4 + rrand(-0.3, 0.3),
                \vibDepth, if(dur > 0.6, 0.025, 0.015),
                \vibDelay, dur * 0.1
            ]);
        };

        // Add slight pause variations (rubato)
        (dur + rrand(-0.05, 0.08)).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: With sparse drone
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~pentatonic;

Routine({
    var drone;
    var melody = [4, 3, 4, 2, 1, 0, -1, 0];
    var durs = [1.2, 0.4, 0.9, 0.7, 0.5, 0.6, 0.3, 2.0];

    "Hallgató with drone:".postln;

    // Start quiet drone
    drone = Synth(\hallgatoDrone, [\freq, root.midicps, \amp, 0.06]);

    1.0.wait;

    // Melody

    melody.do { |deg, i|
        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, 0.35,
            \vibRate, 4,
            \vibDepth, 0.022
        ]);
        durs[i].wait;
    };

    1.0.wait;
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 5: Lament-like phrase (keserves - bitter song)
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Hallgató - lament style:".postln;

    // Start from highest point
    Synth(\hallgatoViolin, [
        \freq, ~scaleToFreq.(root, scale, 6),  // High
        \dur, 1.5,
        \vibRate, 3.5,
        \vibDepth, 0.04,  // Very wide, crying vibrato
        \amp, 0.42,
        \attack, 0.15
    ]);
    1.4.wait;

    // Long slide down (yearning)
    Synth(\hallgatoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 6),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \slideTime, 0.35,
        \vibRate, 4,
        \amp, 0.4
    ]);
    1.1.wait;

    // Pause (breath)
    0.4.wait;

    // Continue descent
    [4, 3, 2, 1, 0].do { |deg, i|
        var dur = [0.6, 0.8, 0.5, 0.7, 1.8].at(i);
        var amp = 0.38 - (i * 0.02);

        if(i == 2) {
            // Ornament on middle note
            Synth(\hallgatoGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04]);
            0.03.wait;
        };

        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \amp, amp,
            \vibRate, 4 - (i * 0.2),
            \vibDepth, 0.025 + (i * 0.003)
        ]);

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Comparing tempo giusto vs rubato
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;
var melody = [4, 3, 2, 1, 0];
var durs;

Routine({
    // Tempo giusto (strict timing) - NOT authentic hallgató
    "Strict tempo (not authentic):".postln;
    melody.do { |deg|
        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.5,
            \amp, 0.35,
            \vibRate, 5
        ]);
        0.5.wait;  // Equal timing
    };

    1.5.wait;

    // Rubato (authentic hallgató)
    "Rubato (authentic):".postln;
    durs = [0.9, 0.35, 0.7, 0.4, 1.4];
    melody.do { |deg, i|
        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, 0.35 - (i * 0.015),
            \vibRate, 4,
            \vibDepth, 0.025
        ]);
        (durs[i] + rrand(-0.05, 0.05)).wait;  // Uneven timing
    };
}).play;
)

// ============================================================================
// EXPERIMENT 7: Hungarian minor vs Pentatonic
// ============================================================================
(
var root = 60;

Routine({
    var pent = ~pentatonic;
    var hung = ~hungarianMinor;

    "Pentatonic (archaic, old-style):".postln;
    [4, 3, 2, 1, 0].do { |deg, i|
        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, pent, deg),
            \dur, [0.8, 0.4, 0.6, 0.35, 1.2].at(i),
            \amp, 0.35
        ]);
        [0.7, 0.35, 0.5, 0.3, 1.0].at(i).wait;
    };

    1.5.wait;

    "Hungarian minor (newer influence):".postln;
    [4, 3, 2, 1, 0].do { |deg, i|
        Synth(\hallgatoViolin, [
            \freq, ~scaleToFreq.(root, hung, deg),
            \dur, [0.8, 0.4, 0.6, 0.35, 1.2].at(i),
            \amp, 0.35
        ]);
        [0.7, 0.35, 0.5, 0.3, 1.0].at(i).wait;
    };
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
