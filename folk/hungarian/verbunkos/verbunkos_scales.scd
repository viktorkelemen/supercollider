// ============================================================================
// VERBUNKOS SCALES - Hungarian Minor and Gypsy Scale Exploration
// ============================================================================
// The Hungarian minor scale (double harmonic minor) is the soul of Verbunkos.
// Key intervals: augmented 2nds between b3-#4 and b6-7 create the exotic sound.
//
// Scale degrees: 1 - 2 - b3 - #4 - 5 - b6 - 7
// In C: C - D - Eb - F# - G - Ab - B
// ============================================================================

(
// Hungarian minor scale intervals (in semitones from root)
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Alternative: Gypsy scale (Freygish/Phrygian dominant - common in klezmer too)
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

// Convert scale degree to frequency
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// EXPERIMENT 1: Simple scale ascending/descending
// ============================================================================
(
SynthDef(\verbScale, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.3|
    var env = EnvGen.kr(Env.perc(0.01, dur * 0.9), doneAction: 2);
    var sig = Saw.ar(freq) + Pulse.ar(freq * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, freq * 4);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// Play Hungarian minor ascending
(
var root = 60; // C4
var scale = ~hungarianMinor;
Routine({
    // Ascending
    (0..7).do { |deg|
        Synth(\verbScale, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.4
        ]);
        0.3.wait;
    };
    0.5.wait;
    // Descending
    (7..0).do { |deg|
        Synth(\verbScale, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.4
        ]);
        0.3.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Emphasize the augmented 2nds (the "exotic" intervals)
// ============================================================================
(
// The augmented 2nd intervals: b3 to #4, and b6 to 7
Routine({
    var root = 60;
    var scale = ~hungarianMinor;

    "Playing augmented 2nd: Eb -> F#".postln;
    Synth(\verbScale, [\freq, ~scaleToFreq.(root, scale, 2), \dur, 0.8]);
    0.6.wait;
    Synth(\verbScale, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.8]);
    1.0.wait;

    "Playing augmented 2nd: Ab -> B".postln;
    Synth(\verbScale, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.8]);
    0.6.wait;
    Synth(\verbScale, [\freq, ~scaleToFreq.(root, scale, 6), \dur, 0.8]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Characteristic melodic fragments
// ============================================================================
(
// Common Verbunkos melodic gesture: descending from 5th with chromatic inflection
Routine({
    var root = 60;
    var scale = ~hungarianMinor;
    var melody = [4, 3, 2, 1, 0, -1, 0]; // 5-#4-b3-2-1-7(below)-1
    var durs = [0.3, 0.3, 0.3, 0.3, 0.6, 0.2, 0.8];

    melody.do { |deg, i|
        Synth(\verbScale, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 1.2,
            \amp, 0.35
        ]);
        durs[i].wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Drone + melody (typical texture)
// ============================================================================
(
SynthDef(\verbDrone, {
    |out = 0, freq = 110, amp = 0.15, gate = 1|
    var env = EnvGen.kr(Env.asr(0.5, 1, 1), gate, doneAction: 2);
    var sig = LPF.ar(Saw.ar([freq, freq * 1.5, freq * 2], [0.5, 0.3, 0.2]).sum, 800);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// Play drone with melody over it
(
var root = 48; // C3 drone
var melodyRoot = 60;
var scale = ~hungarianMinor;
var drone;

drone = Synth(\verbDrone, [\freq, root.midicps]);

Routine({
    var melody = [0, 2, 3, 4, 4, 3, 2, 0, -1, 0];
    var durs = [0.4, 0.3, 0.3, 0.5, 0.3, 0.3, 0.3, 0.5, 0.3, 0.8];

    1.0.wait; // Let drone establish

    melody.do { |deg, i|
        Synth(\verbScale, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * 1.5,
            \amp, 0.3
        ]);
        durs[i].wait;
    };

    1.0.wait;
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 5: Modal comparison - Hungarian minor vs Gypsy scale
// ============================================================================
(
Routine({
    var root = 60;

    "Hungarian Minor (double harmonic minor):".postln;
    ~hungarianMinor.do { |interval, i|
        Synth(\verbScale, [\freq, (root + interval).midicps, \dur, 0.35]);
        0.25.wait;
    };
    Synth(\verbScale, [\freq, (root + 12).midicps, \dur, 0.6]);
    1.5.wait;

    "Gypsy Scale (Phrygian dominant):".postln;
    ~gypsyScale.do { |interval, i|
        Synth(\verbScale, [\freq, (root + interval).midicps, \dur, 0.35]);
        0.25.wait;
    };
    Synth(\verbScale, [\freq, (root + 12).midicps, \dur, 0.6]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
