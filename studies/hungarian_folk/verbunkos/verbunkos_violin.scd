// ============================================================================
// VERBUNKOS VIOLIN - Bowed String Synthesis for Hungarian Folk Melody
// ============================================================================
// The violin (hegedű) is the primary melody instrument in verbunkos.
// The prímás (first violinist) plays ornate, expressive melodic lines.
//
// This file creates violin-like synthesis suitable for verbunkos melody,
// with support for:
// - Bowed string timbre with formant filtering
// - Expressive vibrato (variable rate and depth)
// - Portamento/slides between notes
// - Bow attack variations
// - Integration with ornaments from verbunkos_ornaments.scd
// ============================================================================

// Load core library first
// "/path/to/folk/hungarian/lib/verbunkos_core.scd".load;

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// VIOLIN SYNTHDEFS
// ============================================================================
(
// Main violin synth - bowed string with body resonance
SynthDef(\verbViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     attack = 0.08, release = 0.15,
     vibRate = 5, vibDepth = 0.015, vibDelay = 0.1,
     bowPressure = 0.5, bowPosition = 0.12,
     brightness = 0.6|

    var env, vibEnv, vibrato, exciter, string, body, sig;
    var bowNoise, formant1, formant2, formant3;

    // Amplitude envelope with violin-like attack
    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, dur - attack - release, release], [2, -2, -4]),
        doneAction: 2
    );

    // Delayed vibrato (violinists add vibrato after note starts)
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.1]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3))
              * freq * vibDepth * vibEnv;

    // Bowed string excitation (saw-like with bow noise)
    exciter = LFSaw.ar(freq + vibrato);

    // Add subtle bow noise (rosin sound)
    bowNoise = HPF.ar(
        PinkNoise.ar * EnvGen.kr(Env([1, 0.3, 0.2], [0.05, 0.1])),
        2000
    ) * bowPressure * 0.15;

    // Simple waveguide-inspired string resonance
    string = exciter + bowNoise;
    string = CombL.ar(string, 0.05, 1/freq * bowPosition, 0.1) * 0.3 + (string * 0.7);

    // Violin body formants (approximating wood resonance)
    // Main air resonance ~280 Hz
    formant1 = BPF.ar(string, 280, 0.3) * 3;
    // Wood resonance ~460 Hz
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    // Bridge resonance ~2500 Hz
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;

    sig = string + formant1 + formant2 + formant3;

    // Brightness control
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));

    // Gentle saturation for warmth
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Violin with portamento (for slides between notes)
SynthDef(\verbViolinSlide, {
    |out = 0, startFreq = 440, endFreq = 440, amp = 0.3, dur = 0.5,
     slideTime = 0.1, pan = 0,
     attack = 0.05, release = 0.15,
     vibRate = 5, vibDepth = 0.015,
     brightness = 0.6|

    var env, freqEnv, vibrato, exciter, string, body, sig;
    var formant1, formant2, formant3, freq;

    // Frequency glide
    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.01, slideTime], \exp));
    freq = freqEnv;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, dur - attack - release, release], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;

    exciter = LFSaw.ar(freq + vibrato);
    string = exciter;
    string = CombL.ar(string, 0.05, 1/freq * 0.12, 0.08) * 0.25 + (string * 0.75);

    formant1 = BPF.ar(string, 280, 0.3) * 3;
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Violin with trill
SynthDef(\verbViolinTrill, {
    |out = 0, freq = 440, trillFreq = 466, amp = 0.3, dur = 0.5,
     trillRate = 8, pan = 0, brightness = 0.6|

    var env, trill, exciter, string, sig;
    var formant1, formant2, formant3, currentFreq;

    // Trill oscillates between two pitches
    trill = LFPulse.kr(trillRate + LFNoise1.kr(1).range(-1, 1));
    currentFreq = trill.linlin(0, 1, freq, trillFreq);

    env = EnvGen.kr(
        Env.linen(0.03, dur * 0.85, dur * 0.12),
        doneAction: 2
    );

    exciter = LFSaw.ar(currentFreq);
    string = CombL.ar(exciter, 0.05, 1/currentFreq * 0.12, 0.06) * 0.2 + (exciter * 0.8);

    formant1 = BPF.ar(string, 280, 0.3) * 3;
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, currentFreq * (3 + (brightness * 8)));
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Sustained violin with gate (for long held notes)
SynthDef(\verbViolinSustain, {
    |out = 0, freq = 440, amp = 0.3, gate = 1, pan = 0,
     vibRate = 5, vibDepth = 0.02,
     bowPressure = 0.5, brightness = 0.6|

    var env, vibrato, exciter, string, sig;
    var bowNoise, formant1, formant2, formant3;

    env = EnvGen.kr(Env.asr(0.1, 1, 0.2), gate, doneAction: 2);

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * freq * vibDepth;

    exciter = LFSaw.ar(freq + vibrato);
    bowNoise = HPF.ar(PinkNoise.ar, 2000) * bowPressure * 0.1;

    string = exciter + bowNoise;
    string = CombL.ar(string, 0.05, 1/freq * 0.12, 0.1) * 0.25 + (string * 0.75);

    formant1 = BPF.ar(string, 280, 0.3) * 3;
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Quick grace note violin (very short, less body resonance)
SynthDef(\verbViolinGrace, {
    |out = 0, freq = 440, amp = 0.25, dur = 0.05, pan = 0|

    var env, sig;

    env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);

    sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 460, 0.4) * 2 + (sig * 0.5);
    sig = LPF.ar(sig, freq * 4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic violin tone comparison
// ============================================================================
(
Routine({
    var root = 60;
    var scale = ~hungarianMinor;

    "Violin tone with vibrato:".postln;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 4),  // G
        \dur, 1.5,
        \vibRate, 5,
        \vibDepth, 0.018,
        \amp, 0.4
    ]);

    2.0.wait;

    "Violin without vibrato:".postln;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.5,
        \vibRate, 0,
        \vibDepth, 0,
        \amp, 0.4
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Violin phrase with dynamics
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 4, 4, 3, 2, 0];
var durations = [0.4, 0.3, 0.3, 0.5, 0.3, 0.3, 0.3, 0.6];
var dynamics = [0.3, 0.35, 0.4, 0.45, 0.4, 0.35, 0.3, 0.35]; // arch shape

Routine({
    "Violin phrase with dynamic shaping:".postln;

    melody.do { |deg, i|
        Synth(\verbViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durations[i] * 1.3,
            \amp, dynamics[i],
            \vibRate, if(durations[i] > 0.4, 5, 0), // vibrato on longer notes
            \vibDepth, 0.015
        ]);
        durations[i].wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Ornamented melody (grace notes + main notes)
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Ornamented violin melody:".postln;

    // Phrase 1: grace note into held note
    Synth(\verbViolinGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04]);
    0.03.wait;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.8,
        \vibRate, 5,
        \amp, 0.4
    ]);
    0.7.wait;

    // Phrase 2: slide down
    Synth(\verbViolinSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.5,
        \slideTime, 0.12,
        \amp, 0.35
    ]);
    0.45.wait;

    // Phrase 3: quick turn
    [3, 2, 1, 2].do { |deg|
        Synth(\verbViolinGrace, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.06,
            \amp, 0.25
        ]);
        0.05.wait;
    };

    // Phrase 4: trill on resolution
    Synth(\verbViolinTrill, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \trillFreq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.6,
        \trillRate, 9,
        \amp, 0.35
    ]);
    0.5.wait;

    // Final held note
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.2,
        \vibRate, 4.5,
        \vibDepth, 0.02,
        \amp, 0.4
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Dotted rhythm with violin
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;
var tempo = 0.4;

Routine({
    "Violin with dotted verbunkos rhythm:".postln;

    // Verbunkos pattern: dotted eighth + sixteenth
    4.do { |bar|
        var deg1 = [0, 4, 3, 0].at(bar);
        var deg2 = [2, 3, 2, -1].at(bar);

        // Long note (dotted)
        Synth(\verbViolin, [
            \freq, ~scaleToFreq.(root, scale, deg1),
            \dur, tempo * 0.9,
            \amp, 0.4,
            \attack, 0.05,
            \vibRate, 4
        ]);
        (tempo * 0.75).wait;

        // Short note
        Synth(\verbViolin, [
            \freq, ~scaleToFreq.(root, scale, deg2),
            \dur, tempo * 0.3,
            \amp, 0.3,
            \attack, 0.02,
            \vibRate, 0
        ]);
        (tempo * 0.25).wait;
    };

    // Final resolution
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.0,
        \vibRate, 5,
        \vibDepth, 0.02,
        \amp, 0.45
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Slow expressive hallgató-style passage
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Slow, expressive violin (hallgató character):".postln;

    // Wide vibrato, rubato timing, slides
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, 6),  // High B
        \dur, 1.0,
        \vibRate, 4,
        \vibDepth, 0.03,  // Wide vibrato
        \amp, 0.35,
        \brightness, 0.7
    ]);
    0.9.wait;

    // Slide down with yearning
    Synth(\verbViolinSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 6),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.8,
        \slideTime, 0.2,  // Slow slide
        \vibRate, 4,
        \amp, 0.38
    ]);
    0.7.wait;

    // Brief pause (rubato)
    0.3.wait;

    // Descending phrase
    [4, 3, 2, 1, 0].do { |deg, i|
        var dur = [0.5, 0.4, 0.5, 0.3, 1.2].at(i);
        Synth(\verbViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \vibRate, if(dur > 0.4, 4.5, 0),
            \vibDepth, 0.025,
            \amp, 0.32 + (0.02 * (4-i).max(0)),  // decrescendo
            \brightness, 0.5 + (i * 0.05)
        ]);
        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Fast virtuosic run
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Virtuosic ascending run:".postln;

    // Fast scale with occasional grace notes
    (0..10).do { |deg, i|
        var hasGrace = [3, 6, 9].includes(i);
        var dur = 0.08;

        if(hasGrace) {
            Synth(\verbViolinGrace, [
                \freq, ~scaleToFreq.(root, scale, deg - 1),
                \dur, 0.025,
                \amp, 0.15
            ]);
            0.02.wait;
        };

        Synth(\verbViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.3,
            \amp, 0.25 + (i * 0.015),
            \attack, 0.01,
            \vibRate, 0  // no vibrato on fast notes
        ]);
        dur.wait;
    };

    // Top note with trill
    Synth(\verbViolinTrill, [
        \freq, ~scaleToFreq.(root, scale, 11),
        \trillFreq, ~scaleToFreq.(root, scale, 12),
        \dur, 0.8,
        \trillRate, 11,
        \amp, 0.4
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Violin with accompaniment sketch
// ============================================================================
(
// Simple drone + violin melody
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Quick drone synth for this experiment
SynthDef(\quickDrone, {
    |out = 0, freq = 110, amp = 0.12, gate = 1|
    var env = EnvGen.kr(Env.asr(0.3, 1, 0.5), gate, doneAction: 2);
    var sig = LPF.ar(Saw.ar([freq, freq*1.5]) * [0.6, 0.4], 600).sum;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

s.sync;

Routine({
    var drone;

    "Violin melody with drone:".postln;

    // Start drone
    drone = Synth(\quickDrone, [\freq, root.midicps]);

    0.5.wait;

    // Melody
    var melody = [0, 2, 3, 4, 3, 2, 0, -1, 0];
    var durs = [0.5, 0.3, 0.3, 0.6, 0.3, 0.3, 0.4, 0.2, 0.8];

    melody.do { |deg, i|
        var hasSlide = [4, 5].includes(i);

        if(hasSlide && (i > 0)) {
            Synth(\verbViolinSlide, [
                \startFreq, ~scaleToFreq.(melodyRoot, scale, melody[i-1]),
                \endFreq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, durs[i] * 1.2,
                \slideTime, 0.08,
                \amp, 0.35
            ]);
        } {
            Synth(\verbViolin, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, durs[i] * 1.2,
                \amp, 0.35,
                \vibRate, if(durs[i] > 0.4, 5, 0),
                \vibDepth, 0.015
            ]);
        };

        durs[i].wait;
    };

    0.5.wait;
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 8: Comparing bow articulations
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;
var note = 4; // G

Routine({
    "Bow pressure comparison:".postln;

    "Light bow (chamber music):".postln;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, note),
        \dur, 1.0,
        \bowPressure, 0.2,
        \brightness, 0.4,
        \amp, 0.3
    ]);

    1.5.wait;

    "Heavy bow (passionate):".postln;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, note),
        \dur, 1.0,
        \bowPressure, 0.8,
        \brightness, 0.8,
        \amp, 0.4
    ]);

    1.5.wait;

    "Accented attack:".postln;
    Synth(\verbViolin, [
        \freq, ~scaleToFreq.(root, scale, note),
        \dur, 0.8,
        \attack, 0.01,  // Very fast attack
        \bowPressure, 0.9,
        \amp, 0.45
    ]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
