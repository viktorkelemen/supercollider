// ============================================================================
// RUBATO VS MA - Comparing Time Concepts
// ============================================================================
// Hungarian rubato: Flexible time, stretching/compressing the beat
// Japanese ma: Intentional silence as positive musical space
//
// This experiment demonstrates both concepts with similar melodic material.
// ============================================================================

// Shared scales
(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];  // With augmented 2nd
~inScale = [0, 1, 5, 7, 8];                 // Japanese dark scale

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
// SYNTHDEFS
// ============================================================================
(
// Hungarian violin - for rubato demonstration
SynthDef(\compViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     vibRate = 5, vibDepth = 0.015|

    var env, vibrato, sig;
    var formant1, formant2;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.06, dur - 0.15, 0.09], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3))
              * freq * vibDepth;

    sig = LFSaw.ar(freq + vibrato);
    formant1 = BPF.ar(sig, 460, 0.25) * 2.5;
    formant2 = BPF.ar(sig, 2500, 0.2) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * 6);
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Japanese shakuhachi - for ma demonstration
SynthDef(\compShakuhachi, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     breathiness = 0.4, vibRate = 4.5, vibDepth = 0.008|

    var env, vibrato, breath, tone, sig;
    var formant1, formant2;

    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.8, 0], [0.12, 0.08, dur - 0.35, 0.15], [2, 1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;

    breath = BPF.ar(WhiteNoise.ar, freq * 2, 0.5) * breathiness;

    tone = SinOsc.ar(freq + vibrato)
         + (SinOsc.ar((freq + vibrato) * 2) * 0.3)
         + (SinOsc.ar((freq + vibrato) * 3) * 0.15);

    formant1 = BPF.ar(tone + breath, 800, 0.4) * 2;
    formant2 = BPF.ar(tone + breath, 2200, 0.3) * 1.5;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Strict time (baseline for comparison)
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 4, 3, 2, 0];
var baseDur = 0.5;

Routine({
    "STRICT TIME (baseline - metronomic):".postln;
    "Each note exactly 0.5 seconds".postln;

    melody.do { |deg|
        Synth(\compViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, baseDur * 0.9,
            \amp, 0.35,
            \vibRate, 5
        ]);
        baseDur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Hungarian rubato - time stretching
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 4, 3, 2, 0];
// Rubato: emotional peaks get more time, transitions compressed
// Total time borrowed must equal time returned
var rubatoFactors = [1.0, 0.8, 0.9, 1.4, 1.1, 0.9, 0.9];  // Sum ≈ 7.0
var baseDur = 0.5;

Routine({
    "HUNGARIAN RUBATO (elastic time):".postln;
    "Peak note (4th) stretched, others compressed".postln;

    melody.do { |deg, i|
        var dur = baseDur * rubatoFactors[i];
        var amp = 0.32 + (rubatoFactors[i] - 1 * 0.1);  // Louder when stretched

        Synth(\compViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 0.95,
            \amp, amp,
            \vibRate, if(dur > 0.55, 5, 0),  // Vibrato on longer notes
            \vibDepth, 0.018
        ]);
        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Japanese ma - intentional silence
// ============================================================================
(
var root = 62;  // D for shakuhachi
var scale = ~inScale;
var melody = [0, 1, 2, 3, 2, 1, 0];
var noteDurs = [0.8, 0.6, 0.7, 1.0, 0.7, 0.6, 1.2];
// Ma: silence ADDED between phrases, not stolen from notes
var maAfter = [0.4, 0.2, 0.0, 0.8, 0.0, 0.3, 0.0];  // Silence after each note

Routine({
    "JAPANESE MA (intentional silence):".postln;
    "Silence added between notes, especially after phrase peaks".postln;

    melody.do { |deg, i|
        var dur = noteDurs[i];
        var ma = maAfter[i];

        Synth(\compShakuhachi, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur,
            \amp, 0.35,
            \breathiness, 0.4
        ]);

        // Note duration + ma (silence)
        (dur + ma).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Side-by-side comparison - same melody
// ============================================================================
(
var melody = [0, 2, 3, 4, 3, 2, 0];

Routine({
    "=== SIDE-BY-SIDE COMPARISON ===".postln;

    // Hungarian rubato version
    "".postln;
    "Hungarian (rubato - elastic time):".postln;
    {
        var root = 60;
        var scale = ~hungarianMinor;
        var rubatoFactors = [1.0, 0.8, 0.9, 1.5, 1.0, 0.9, 0.9];
        var baseDur = 0.45;

        melody.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\compViolin, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 0.95,
                \amp, 0.35,
                \vibRate, if(dur > 0.5, 5, 0)
            ]);
            dur.wait;
        };
    }.value;

    1.5.wait;

    // Japanese ma version
    "".postln;
    "Japanese (ma - added silence):".postln;
    {
        var root = 62;
        var scale = ~inScale;
        var noteDurs = [0.6, 0.5, 0.55, 0.8, 0.55, 0.5, 0.9];
        var maAfter = [0.3, 0.15, 0.0, 0.6, 0.0, 0.2, 0.0];

        melody.do { |deg, i|
            var dur = noteDurs[i];
            var ma = maAfter[i];

            Synth(\compShakuhachi, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur,
                \amp, 0.35
            ]);
            (dur + ma).wait;
        };
    }.value;
}).play;
)

// ============================================================================
// EXPERIMENT 5: Hybrid - rubato WITHIN phrases, ma BETWEEN phrases
// ============================================================================
(
var root = 60;

Routine({
    "=== HYBRID: Rubato within phrases, Ma between phrases ===".postln;

    // Phrase 1 with rubato
    "Phrase 1 (rubato):".postln;
    {
        var scale = ~hungarianMinor;
        var phrase = [0, 2, 3, 4];
        var rubatoFactors = [0.9, 0.8, 1.0, 1.3];
        var baseDur = 0.4;

        phrase.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\compViolin, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 0.95,
                \amp, 0.35
            ]);
            dur.wait;
        };
    }.value;

    // MA - substantial silence between phrases
    "... ma ...".postln;
    0.9.wait;

    // Phrase 2 with rubato
    "Phrase 2 (rubato):".postln;
    {
        var scale = ~hungarianMinor;
        var phrase = [4, 3, 2, 0];
        var rubatoFactors = [1.1, 0.9, 0.85, 1.15];
        var baseDur = 0.4;

        phrase.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\compViolin, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 0.95,
                \amp, 0.34
            ]);
            dur.wait;
        };
    }.value;

    // MA
    "... ma ...".postln;
    1.2.wait;

    // Final sustained note
    "Resolution:".postln;
    Synth(\compViolin, [
        \freq, ~scaleToFreq.(root, ~hungarianMinor, 0),
        \dur, 1.5,
        \amp, 0.36,
        \vibRate, 4.5,
        \vibDepth, 0.02
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 6: Quantifying the difference
// ============================================================================
(
Routine({
    var strictTotal = 7 * 0.5;  // 3.5 seconds
    var rubatoTotal = [1.0, 0.8, 0.9, 1.5, 1.0, 0.9, 0.9].sum * 0.45;  // ~3.15 seconds
    var maTotal = [0.6, 0.5, 0.55, 0.8, 0.55, 0.5, 0.9].sum +
                  [0.3, 0.15, 0.0, 0.6, 0.0, 0.2, 0.0].sum;  // ~5.65 seconds

    "=== TIME ANALYSIS ===".postln;
    "".postln;
    "Strict time total: % seconds".format(strictTotal.round(0.01)).postln;
    "Rubato total: % seconds (time redistributed, similar total)".format(rubatoTotal.round(0.01)).postln;
    "Ma total: % seconds (silence ADDED, longer total)".format(maTotal.round(0.01)).postln;
    "".postln;
    "Key insight:".postln;
    "- Rubato REDISTRIBUTES time (elastic, total preserved)".postln;
    "- Ma ADDS time (silence as positive space, total increases)".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 7: Extreme versions for clarity
// ============================================================================
(
Routine({
    var melody = [0, 2, 4, 2, 0];

    "=== EXTREME RUBATO ===".postln;
    "Very dramatic stretching and compression:".postln;
    {
        var root = 60;
        var scale = ~hungarianMinor;
        var rubatoFactors = [0.6, 0.5, 2.0, 0.5, 1.4];  // Peak extremely stretched
        var baseDur = 0.4;

        melody.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\compViolin, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur.max(0.15),
                \amp, 0.3 + (rubatoFactors[i] - 1 * 0.08),
                \vibRate, if(dur > 0.5, 5, 0),
                \vibDepth, 0.02
            ]);
            dur.wait;
        };
    }.value;

    2.5.wait;

    "=== EXTREME MA ===".postln;
    "Very long silences between notes:".postln;
    {
        var root = 62;
        var scale = ~inScale;
        var noteDurs = [1.0, 0.8, 1.2, 0.8, 1.5];
        var maAfter = [1.0, 0.8, 1.5, 0.6, 0.0];  // Long silences

        melody.do { |deg, i|
            Synth(\compShakuhachi, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, noteDurs[i],
                \amp, 0.35
            ]);
            (noteDurs[i] + maAfter[i]).wait;
        };
    }.value;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
