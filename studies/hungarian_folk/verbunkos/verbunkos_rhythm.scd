// ============================================================================
// VERBUNKOS RHYTHM - Dotted Patterns and Bokázó Accents
// ============================================================================
// Verbunkos rhythm is characterized by:
// - Dotted rhythms (long-short): the "swagger" of the recruitment dance
// - Bokázó: heel-clicking accents, often syncopated
// - Rubato in slow sections, strict pulse in fast sections
// - 2/4 and 4/4 time signatures predominate
// ============================================================================

(
// Hungarian minor scale for melodic material
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR RHYTHM EXPLORATION
// ============================================================================
(
// Melodic voice
SynthDef(\verbMelody, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.3, pan = 0|
    var env = EnvGen.kr(Env.perc(0.01, dur * 0.9), doneAction: 2);
    var sig = Saw.ar(freq) + Pulse.ar(freq * 1.001, 0.3, 0.3);
    sig = LPF.ar(sig, freq * 3 + 500);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Percussive accent (bokázó heel click)
SynthDef(\verbClick, {
    |out = 0, freq = 800, amp = 0.4|
    var env = EnvGen.kr(Env.perc(0.001, 0.08), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * env;
    sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.kr(Env.perc(0.001, 0.03)));
    Out.ar(out, Pan2.ar(sig * amp, 0));
}).add;

// Bass drum thump
SynthDef(\verbBass, {
    |out = 0, freq = 60, amp = 0.5|
    var env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);
    var pitch = EnvGen.kr(Env([freq * 2, freq, freq * 0.8], [0.02, 0.1]));
    var sig = SinOsc.ar(pitch) * env;
    Out.ar(out, Pan2.ar(sig * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic dotted rhythm (long-short pattern)
// ============================================================================
(
// The quintessential Verbunkos "swagger"
// Dotted eighth + sixteenth in 2/4
var tempo = 1.0; // seconds per beat

Routine({
    8.do {
        // Long note (dotted eighth = 0.75 beat)
        Synth(\verbMelody, [\freq, 60.midicps, \dur, 0.5, \amp, 0.35]);
        Synth(\verbBass, [\amp, 0.4]);
        (tempo * 0.75).wait;

        // Short note (sixteenth = 0.25 beat)
        Synth(\verbMelody, [\freq, 62.midicps, \dur, 0.15, \amp, 0.25]);
        (tempo * 0.25).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Bokázó (heel-clicking) pattern
// ============================================================================
(
// Syncopated accents simulating the boot clicks of dancers
var tempo = 0.5;

Routine({
    4.do {
        // Beat 1 - strong
        Synth(\verbBass, [\amp, 0.5]);
        Synth(\verbClick, [\freq, 1000, \amp, 0.3]);
        tempo.wait;

        // And of 1 - click
        Synth(\verbClick, [\freq, 1200, \amp, 0.4]);
        (tempo * 0.5).wait;

        // Beat 2 - lighter
        Synth(\verbClick, [\freq, 900, \amp, 0.25]);
        (tempo * 0.5).wait;

        // And of 2 - strong click
        Synth(\verbClick, [\freq, 1100, \amp, 0.45]);
        Synth(\verbBass, [\freq, 50, \amp, 0.3]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Combined melody with dotted rhythm
// ============================================================================
(
var tempo = 0.4;
var root = 60;
var scale = ~hungarianMinor;

// Melodic phrase with characteristic rhythm
var melody = [0, 2, 3, 4, 4, 3, 2, 0];
var durations = [0.75, 0.25, 0.75, 0.25, 0.5, 0.5, 0.75, 0.25]; // dotted patterns

Routine({
    2.do {
        melody.do { |deg, i|
            var dur = durations[i] * tempo;
            var freq = ~scaleToFreq.(root, scale, deg);

            Synth(\verbMelody, [\freq, freq, \dur, dur * 1.2, \amp, 0.3]);

            // Add bass on strong beats
            if(i % 2 == 0) {
                Synth(\verbBass, [\amp, 0.35]);
            };

            dur.wait;
        };
        (tempo * 0.5).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Accelerando pattern (building excitement)
// ============================================================================
(
// Verbunkos often accelerates toward climactic moments
var startTempo = 0.5;
var endTempo = 0.15;
var steps = 16;
var root = 60;
var scale = ~hungarianMinor;

Routine({
    steps.do { |i|
        var tempo = startTempo.blend(endTempo, i / (steps - 1));
        var deg = [0, 4, 3, 4].wrapAt(i);
        var freq = ~scaleToFreq.(root, scale, deg);

        Synth(\verbMelody, [\freq, freq, \dur, tempo * 1.5, \amp, 0.3]);
        Synth(\verbClick, [\amp, 0.2 + (i * 0.02)]);

        if(i % 2 == 0) {
            Synth(\verbBass, [\amp, 0.3]);
        };

        tempo.wait;
    };

    // Final accent
    Synth(\verbMelody, [\freq, ~scaleToFreq.(root, scale, 0, 1), \dur, 0.8, \amp, 0.5]);
    Synth(\verbBass, [\amp, 0.6]);
    Synth(\verbClick, [\freq, 1500, \amp, 0.5]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Rubato section (free timing)
// ============================================================================
(
// Slow, expressive rubato - timing stretches and contracts
var root = 60;
var scale = ~hungarianMinor;
var melody = [4, 3, 2, 3, 2, 1, 0, -1, 0];

// Rubato timing: some notes linger, others rush
var durations = [0.8, 0.3, 0.6, 0.25, 0.5, 0.7, 0.4, 0.3, 1.2];

Routine({
    melody.do { |deg, i|
        var freq = ~scaleToFreq.(root, scale, deg);
        var dur = durations[i];

        Synth(\verbMelody, [\freq, freq, \dur, dur * 1.5, \amp, 0.35]);

        // Sparse bass, only on certain notes
        if([0, 3, 6, 8].includes(i)) {
            Synth(\verbBass, [\amp, 0.25]);
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Full rhythmic groove (2/4 Verbunkos)
// ============================================================================
(
var tempo = 0.25; // sixteenth note duration
var root = 60;
var scale = ~hungarianMinor;
var bar = 0;

Routine({
    4.do { |bar|
        // Beat 1: bass + melody
        Synth(\verbBass, [\amp, 0.5]);
        Synth(\verbMelody, [
            \freq, ~scaleToFreq.(root, scale, [0, 0, 4, 4].at(bar)),
            \dur, tempo * 3,
            \amp, 0.35
        ]);
        (tempo * 3).wait; // dotted eighth

        // Sixteenth pickup
        Synth(\verbMelody, [
            \freq, ~scaleToFreq.(root, scale, [2, 2, 3, 3].at(bar)),
            \dur, tempo * 0.8,
            \amp, 0.25
        ]);
        tempo.wait;

        // Beat 2: click accent
        Synth(\verbClick, [\amp, 0.35]);
        Synth(\verbMelody, [
            \freq, ~scaleToFreq.(root, scale, [3, 4, 2, 0].at(bar)),
            \dur, tempo * 2,
            \amp, 0.3
        ]);
        (tempo * 2).wait;

        // And of 2
        Synth(\verbClick, [\freq, 1100, \amp, 0.4]);
        (tempo * 2).wait;
    };

    // Final cadence
    Synth(\verbBass, [\amp, 0.6]);
    Synth(\verbMelody, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 0.8, \amp, 0.4]);
    Synth(\verbClick, [\amp, 0.5]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
