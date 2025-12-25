// ============================================================================
// SHAMISEN SAWARI - Three-Stringed Lute with Buzz Synthesis
// ============================================================================
// The shamisen is a three-stringed plucked lute central to min'yo and theater.
// Its distinctive buzzing sound (sawari) comes from the string barely touching
// the upper bridge, creating a rattling overtone series.
//
// Key characteristics:
// - Percussive attack from bachi (plectrum) striking cat/dog skin
// - Sawari buzz - sustained rattling overtones on open strings
// - Three types: hosozao (thin neck), chuzao (medium), futozao (thick)
// - Pitch bends and slides
// - Hajiki (fingernail pluck) and suri (slide) techniques
//
// Tunings vary by genre:
// - Honchoshi (standard): 4th + 5th (e.g., D-G-C)
// - Niagari: 4th + 4th (e.g., D-G-Bb)
// - Sansagari: 5th + 4th (e.g., D-A-D)
//
// Load core library first:
// "/path/to/studies/japanese_folk/lib/japanese_core.scd".load;
// ============================================================================

// Local scale definitions (if core library not loaded)
(
~inScale = [0, 1, 5, 7, 8];      // A Bb D E F - dark, urban shamisen
~yoScale = [0, 2, 5, 7, 9];      // D E G A B - bright, folk
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    if(degree < 0) {
        idx = scale.size + (degree % scale.size);
        oct = (degree / scale.size).floor;
    };
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SHAMISEN SYNTHDEFS
// ============================================================================
(
// Main shamisen synth with sawari buzz
SynthDef(\shamisen, {
    |out = 0, freq = 220, amp = 0.35, dur = 1.0, pan = 0,
     sawari = 0.5, brightness = 0.6,
     attack = 0.004, decay = 0.08|

    var env, pluck, string, buzz, body, sig;
    var exciter, sawariFreq, formant1, formant2;
    var skinHit, bachiNoise;

    // Sharp percussive envelope
    env = EnvGen.kr(
        Env.perc(attack, dur, 1, -8),
        doneAction: 2
    );

    // Bachi strike - skin percussion + string excitation
    bachiNoise = WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.008));
    skinHit = BPF.ar(bachiNoise, 400, 0.5) * 3  // Skin resonance
            + BPF.ar(bachiNoise, 1200, 0.3) * 2; // Attack brightness

    // String excitation
    exciter = Impulse.ar(0) + (skinHit * 0.5);

    // Main string (Karplus-Strong)
    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 0.8);
    string = string + (CombL.ar(exciter, 0.025, (freq * 2).reciprocal, dur * 0.5) * 0.25);

    // SAWARI - the characteristic buzz
    // Simulated by ring modulation + filtered noise at string frequency
    sawariFreq = freq * LFNoise2.kr(50).range(0.99, 1.01); // Slight instability
    buzz = Ringz.ar(
        exciter,
        [sawariFreq, sawariFreq * 2, sawariFreq * 3],
        [0.3, 0.2, 0.1]
    ).sum * 0.3;

    // Add inharmonic buzz components (the rattle)
    buzz = buzz + BPF.ar(
        string * LFNoise1.kr(80).range(0.5, 1),
        freq * 1.5,
        0.8
    ) * 0.4;

    // Combine string and sawari
    sig = string + (buzz * sawari);

    // Shamisen body formants (cat/dog skin + wood)
    formant1 = BPF.ar(sig, 350, 0.35) * 2;   // Skin resonance
    formant2 = BPF.ar(sig, 1800, 0.25) * 1.8; // Brightness

    sig = sig + formant1 + formant2;

    // Brightness control
    sig = LPF.ar(sig, freq * (2 + (brightness * 8)));

    // Add some edge/grit
    sig = (sig * 1.4).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shamisen with stronger sawari (open string drone)
SynthDef(\shamisenDrone, {
    |out = 0, freq = 146.83, amp = 0.3, dur = 3.0, pan = 0,
     sawari = 0.8, decay = 0.5|

    var env, exciter, string, buzz, sig;
    var sawariMod, formant1, formant2;

    env = EnvGen.kr(
        Env([0, 1, 0.6, 0.3, 0], [0.005, 0.1, dur * 0.6, dur * 0.3], [-4, -2, -3, -4]),
        doneAction: 2
    );

    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.006)));

    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * decay);
    string = string + (CombL.ar(exciter, 0.025, (freq * 2).reciprocal, dur * 0.4) * 0.2);

    // Enhanced sawari for drone strings
    sawariMod = LFNoise2.kr(30).range(0.98, 1.02);
    buzz = Ringz.ar(exciter, freq * sawariMod * [1, 2, 3, 4], [0.5, 0.3, 0.2, 0.1]).sum * 0.4;
    buzz = buzz + HPF.ar(
        string * LFNoise1.kr(60).range(0.4, 1) * EnvGen.kr(Env.perc(0.01, dur * 0.5)),
        freq * 2
    ) * 0.3;

    sig = string + (buzz * sawari);

    formant1 = BPF.ar(sig, 350, 0.4) * 2.5;
    formant2 = BPF.ar(sig, 1800, 0.3) * 2;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * 8);
    sig = (sig * 1.3).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shamisen with pitch bend (suri - slide technique)
SynthDef(\shamisenSlide, {
    |out = 0, startFreq = 220, endFreq = 247, amp = 0.35, dur = 0.8, pan = 0,
     slideTime = 0.12, sawari = 0.4, brightness = 0.6|

    var env, freqEnv, exciter, string, buzz, sig;
    var formant1, formant2;

    freqEnv = EnvGen.kr(
        Env([startFreq, startFreq, endFreq], [0.01, slideTime], [\lin, 4])
    );

    env = EnvGen.kr(Env.perc(0.004, dur, 1, -8), doneAction: 2);

    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.006)));

    string = CombL.ar(exciter, 0.05, freqEnv.reciprocal, dur * 0.8);
    buzz = Ringz.ar(exciter, freqEnv * [1, 2, 3], [0.25, 0.15, 0.1]).sum * 0.25;

    sig = string + (buzz * sawari);

    formant1 = BPF.ar(sig, 350, 0.35) * 2;
    formant2 = BPF.ar(sig, 1800, 0.25) * 1.8;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freqEnv * (2 + (brightness * 8)));
    sig = (sig * 1.4).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hajiki - fingernail pluck (softer, less sawari)
SynthDef(\shamisenHajiki, {
    |out = 0, freq = 220, amp = 0.25, dur = 0.6, pan = 0,
     brightness = 0.5|

    var env, exciter, string, sig;
    var formant1, formant2;

    env = EnvGen.kr(Env.perc(0.002, dur, 1, -6), doneAction: 2);

    // Softer excitation (no bachi)
    exciter = Impulse.ar(0) * 0.7 + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.003)) * 0.3);

    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 0.7);
    string = string + (CombL.ar(exciter, 0.025, (freq * 2).reciprocal, dur * 0.5) * 0.2);

    // Less sawari for hajiki
    sig = string + (Ringz.ar(exciter, freq * 2, 0.1) * 0.15);

    formant1 = BPF.ar(sig, 400, 0.4) * 1.5;
    formant2 = BPF.ar(sig, 1500, 0.3) * 1.2;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * (3 + (brightness * 6)));
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Quick grace note
SynthDef(\shamisenGrace, {
    |out = 0, freq = 220, amp = 0.2, dur = 0.05, pan = 0|

    var env, exciter, sig;

    env = EnvGen.kr(Env.perc(0.002, dur), doneAction: 2);

    exciter = Impulse.ar(0);
    sig = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 3);
    sig = LPF.ar(sig, freq * 5);
    sig = BPF.ar(sig, 400, 0.5) * 2 + (sig * 0.5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Uchi (hammering on)
SynthDef(\shamisenUchi, {
    |out = 0, freq = 220, amp = 0.28, dur = 0.4, pan = 0,
     sawari = 0.3|

    var env, exciter, string, buzz, sig;
    var formant1, formant2;

    // Softer attack (finger hammer, no bachi)
    env = EnvGen.kr(Env.perc(0.008, dur, 1, -6), doneAction: 2);

    exciter = Impulse.ar(0) * 0.6;

    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 0.9);
    buzz = Ringz.ar(exciter, freq * [1, 2], [0.2, 0.1]).sum * 0.2;

    sig = string + (buzz * sawari);

    formant1 = BPF.ar(sig, 350, 0.35) * 1.8;
    formant2 = BPF.ar(sig, 1600, 0.3) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * 6);
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Tremolo (rapid repeated strikes)
SynthDef(\shamisenTremolo, {
    |out = 0, freq = 220, amp = 0.28, dur = 1.0, pan = 0,
     rate = 10, sawari = 0.4, brightness = 0.6|

    var env, trigger, exciter, string, buzz, sig;
    var formant1, formant2;

    env = EnvGen.kr(Env.linen(0.02, dur * 0.85, dur * 0.13), doneAction: 2);

    trigger = Impulse.ar(rate);
    exciter = trigger + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.004), trigger));

    string = CombL.ar(exciter, 0.05, freq.reciprocal, 0.25);
    buzz = Ringz.ar(exciter, freq * [1, 2, 3], [0.15, 0.1, 0.07]).sum * 0.2;

    sig = string + (buzz * sawari);

    formant1 = BPF.ar(sig, 350, 0.35) * 2;
    formant2 = BPF.ar(sig, 1800, 0.25) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));
    sig = (sig * 1.3).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Tsugaru-style powerful stroke
SynthDef(\shamisenTsugaru, {
    |out = 0, freq = 220, amp = 0.4, dur = 1.2, pan = 0,
     sawari = 0.7, brightness = 0.7|

    var env, exciter, string, buzz, sig;
    var skinSlap, formant1, formant2;

    // Strong percussive envelope
    env = EnvGen.kr(
        Env([0, 1, 0.5, 0.2, 0], [0.003, 0.05, dur * 0.5, dur * 0.4], [-2, -4, -4, -6]),
        doneAction: 2
    );

    // Heavy bachi strike with skin slap
    skinSlap = BPF.ar(
        WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.015)),
        [300, 600, 1000],
        0.4
    ).sum * 2;

    exciter = Impulse.ar(0) * 1.2 + skinSlap;

    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 0.9);
    string = string + (CombL.ar(exciter, 0.025, (freq * 2).reciprocal, dur * 0.6) * 0.3);

    // Strong sawari
    buzz = Ringz.ar(exciter, freq * [1, 2, 3, 4], [0.4, 0.25, 0.15, 0.1]).sum * 0.35;
    buzz = buzz + HPF.ar(
        string * LFNoise1.kr(50).range(0.6, 1),
        freq * 1.5
    ) * 0.25;

    sig = string + (buzz * sawari);

    formant1 = BPF.ar(sig, 400, 0.3) * 2.5;
    formant2 = BPF.ar(sig, 2200, 0.2) * 2;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * (2 + (brightness * 10)));
    sig = (sig * 1.5).clip2(0.9) * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic shamisen tone with sawari
// ============================================================================
(
Routine({
    var root = 50;  // D3 - typical shamisen root
    var scale = ~inScale;

    "Basic shamisen with sawari:".postln;
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \sawari, 0.5,
        \amp, 0.38
    ]);

    2.5.wait;

    "Without sawari:".postln;
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \sawari, 0.0,
        \amp, 0.38
    ]);

    2.5.wait;

    "Heavy sawari:".postln;
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \sawari, 0.9,
        \amp, 0.38
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Open string drone with sawari
// ============================================================================
(
Routine({
    "Open string drone (strong sawari):".postln;

    // Low string drone (D)
    Synth(\shamisenDrone, [
        \freq, 146.83,  // D3
        \dur, 4.0,
        \sawari, 0.85,
        \amp, 0.35
    ]);

    4.5.wait;

    // Middle string drone (G)
    Synth(\shamisenDrone, [
        \freq, 196.00,  // G3
        \dur, 4.0,
        \sawari, 0.8,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Suri (slide) technique
// ============================================================================
(
Routine({
    var root = 50;
    var scale = ~inScale;

    "Suri (slide) technique:".postln;

    "Ascending slide:".postln;
    Synth(\shamisenSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 0),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.0,
        \slideTime, 0.15,
        \amp, 0.36
    ]);

    1.5.wait;

    "Descending slide:".postln;
    Synth(\shamisenSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 3),
        \endFreq, ~scaleToFreq.(root, scale, 1),
        \dur, 1.0,
        \slideTime, 0.18,
        \amp, 0.36
    ]);

    1.5.wait;

    "Quick ornamental slide:".postln;
    Synth(\shamisenSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 1),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.6,
        \slideTime, 0.06,
        \amp, 0.36
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Hajiki vs Bachi comparison
// ============================================================================
(
Routine({
    var root = 50;
    var scale = ~inScale;
    var note = ~scaleToFreq.(root, scale, 2);

    "Bachi (plectrum) strike:".postln;
    Synth(\shamisen, [
        \freq, note,
        \dur, 1.2,
        \sawari, 0.5,
        \amp, 0.36
    ]);

    1.8.wait;

    "Hajiki (fingernail pluck):".postln;
    Synth(\shamisenHajiki, [
        \freq, note,
        \dur, 1.0,
        \amp, 0.32
    ]);

    1.5.wait;

    "Uchi (hammer-on):".postln;
    Synth(\shamisenUchi, [
        \freq, note,
        \dur, 0.8,
        \amp, 0.3
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: In scale melody (dark urban shamisen)
// ============================================================================
(
var root = 50;
var scale = ~inScale;
// In scale: A Bb D E F - dark, dramatic
var melody = [0, 1, 2, 3, 2, 1, 0, -1, 0];
var durations = [0.5, 0.35, 0.4, 0.7, 0.35, 0.35, 0.5, 0.3, 0.9];
var hasSlide = [false, true, false, false, true, false, false, true, false];

Routine({
    "In scale melody (dark character):".postln;

    melody.do { |deg, i|
        var dur = durations[i];

        if(hasSlide[i] && (i > 0)) {
            Synth(\shamisenSlide, [
                \startFreq, ~scaleToFreq.(root, scale, melody[i-1]),
                \endFreq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.2,
                \slideTime, 0.08,
                \sawari, 0.4,
                \amp, 0.35
            ]);
        } {
            Synth(\shamisen, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.2,
                \sawari, if(dur > 0.5, 0.5, 0.3),
                \amp, 0.35
            ]);
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Shamisen tremolo
// ============================================================================
(
Routine({
    var root = 50;
    var scale = ~inScale;

    "Shamisen tremolo:".postln;

    "Slow tremolo:".postln;
    Synth(\shamisenTremolo, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \rate, 6,
        \sawari, 0.4,
        \amp, 0.32
    ]);

    2.0.wait;

    "Fast tremolo:".postln;
    Synth(\shamisenTremolo, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.2,
        \rate, 14,
        \sawari, 0.5,
        \amp, 0.32
    ]);

    1.7.wait;

    "Accelerating tremolo:".postln;
    [7, 10, 14, 18].do { |rate|
        Synth(\shamisenTremolo, [
            \freq, ~scaleToFreq.(root, scale, 2),
            \dur, 0.4,
            \rate, rate,
            \sawari, 0.45,
            \amp, 0.3
        ]);
        0.35.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 7: Tsugaru-style powerful playing
// ============================================================================
(
var root = 50;
var scale = ~inScale;

Routine({
    "Tsugaru-style (futozao - thick neck, powerful):".postln;

    // Opening strike
    Synth(\shamisenTsugaru, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.5,
        \sawari, 0.8,
        \amp, 0.42
    ]);
    1.3.wait;

    // Rapid phrase
    [2, 3, 4, 3, 2, 1, 0].do { |deg, i|
        var dur = 0.18 - (i * 0.01);

        Synth(\shamisenTsugaru, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 2,
            \sawari, 0.6,
            \amp, 0.38
        ]);
        dur.wait;
    };

    // Powerful final note with drone
    Synth(\shamisenTsugaru, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \sawari, 0.85,
        \amp, 0.45
    ]);

    // Simultaneous open string
    0.1.wait;
    Synth(\shamisenDrone, [
        \freq, ~scaleToFreq.(root - 12, scale, 0),
        \dur, 2.5,
        \sawari, 0.7,
        \amp, 0.3
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 8: Grace notes and ornamentation
// ============================================================================
(
var root = 50;
var scale = ~inScale;

Routine({
    "Grace note ornamentation:".postln;

    // Grace from below
    Synth(\shamisenGrace, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.04,
        \amp, 0.2
    ]);
    0.03.wait;
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.0,
        \sawari, 0.5,
        \amp, 0.36
    ]);

    1.3.wait;

    // Grace from above
    Synth(\shamisenGrace, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.04,
        \amp, 0.2
    ]);
    0.03.wait;
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.0,
        \sawari, 0.5,
        \amp, 0.36
    ]);

    1.3.wait;

    // Uchi hammer-on ornament
    Synth(\shamisen, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.4,
        \amp, 0.34
    ]);
    0.25.wait;
    Synth(\shamisenUchi, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.8,
        \amp, 0.3
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 9: Melody with drone accompaniment
// ============================================================================
(
var root = 50;
var scale = ~inScale;
var melody = [0, 2, 3, 2, 1, 2, 0];
var durations = [0.5, 0.4, 0.6, 0.35, 0.35, 0.4, 0.8];

Routine({
    var drone;

    "Melody with open string drone:".postln;

    // Start drone on low D
    drone = Synth(\shamisenDrone, [
        \freq, ~scaleToFreq.(root - 12, scale, 0),
        \dur, 6.0,
        \sawari, 0.6,
        \amp, 0.25
    ]);

    0.5.wait;

    // Melody
    melody.do { |deg, i|
        var dur = durations[i];
        var hasSlide = [2, 4].includes(i);

        if(hasSlide && (i > 0)) {
            Synth(\shamisenSlide, [
                \startFreq, ~scaleToFreq.(root, scale, melody[i-1]),
                \endFreq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.2,
                \slideTime, 0.1,
                \amp, 0.36
            ]);
        } {
            Synth(\shamisen, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.2,
                \sawari, 0.45,
                \amp, 0.36
            ]);
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 10: Full ornamented phrase
// ============================================================================
(
var root = 50;
var scale = ~inScale;

Routine({
    "Full ornamented shamisen phrase:".postln;

    // Opening - grace into strong note
    Synth(\shamisenGrace, [\freq, ~scaleToFreq.(root, scale, 2), \dur, 0.04, \amp, 0.2]);
    0.03.wait;
    Synth(\shamisenTsugaru, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.2,
        \sawari, 0.7,
        \amp, 0.4
    ]);
    1.0.wait;

    // Slide down
    Synth(\shamisenSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 3),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.8,
        \slideTime, 0.12,
        \amp, 0.36
    ]);
    0.7.wait;

    // Quick descent with hajiki
    [2, 1, 0].do { |deg|
        Synth(\shamisenHajiki, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.35,
            \amp, 0.28
        ]);
        0.22.wait;
    };

    // Uchi ornament
    Synth(\shamisen, [\freq, ~scaleToFreq.(root, scale, 1), \dur, 0.3, \amp, 0.32]);
    0.2.wait;
    Synth(\shamisenUchi, [\freq, ~scaleToFreq.(root, scale, 2), \dur, 0.5, \amp, 0.28]);
    0.4.wait;

    // Tremolo climax
    Synth(\shamisenTremolo, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.8,
        \rate, 12,
        \sawari, 0.5,
        \amp, 0.34
    ]);
    0.7.wait;

    // Final resolution with drone
    Synth(\shamisenTsugaru, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \sawari, 0.8,
        \amp, 0.42
    ]);

    0.15.wait;

    Synth(\shamisenDrone, [
        \freq, ~scaleToFreq.(root - 12, scale, 0),
        \dur, 2.5,
        \sawari, 0.65,
        \amp, 0.28
    ]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
