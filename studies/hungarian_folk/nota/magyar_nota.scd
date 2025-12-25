// ============================================================================
// MAGYAR NÓTA - Hungarian Popular Song
// ============================================================================
// Magyar nóta is a 19th-century urban popular song tradition, often
// performed by Roma (Gypsy) musicians in restaurants and taverns.
//
// Characteristics:
// - Sentimental, romantic, sometimes melancholic themes
// - Combines verbunkos with Italian-Viennese influences
// - Performed by "Gypsy bands" (prímás-led ensembles)
// - Tempo rubato on slow sections, strict on dance sections
// - Rich ornamentation, expressive violin
// - Cimbalom provides shimmering accompaniment
// - Often features dramatic tempo and dynamic contrasts
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR MAGYAR NÓTA
// ============================================================================
(
// Expressive prímás violin (lead)
SynthDef(\notaViolin, {
    |out = 0, freq = 440, amp = 0.38, dur = 0.5, pan = -0.25,
     vibRate = 5.5, vibDepth = 0.02, vibDelay = 0.08,
     attack = 0.04, brightness = 0.6|

    var env, vibEnv, vibrato, sig, formant1, formant2, formant3;

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0.7, 0],
            [attack, dur * 0.25, dur * 0.45, dur * 0.26],
            [3, -1, -2, -4]),
        doneAction: 2
    );

    vibEnv = EnvGen.kr(Env([0, 0, 1, 1.1], [vibDelay, 0.1, dur * 0.5]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.4, 0.4))
              * freq * vibDepth * vibEnv;

    sig = LFSaw.ar(freq + vibrato);

    // Rich, warm body
    formant1 = BPF.ar(sig, 300, 0.3) * 2.5;
    formant2 = BPF.ar(sig, 550, 0.25) * 2;
    formant3 = BPF.ar(sig, 2800, 0.18) * 1.5;

    sig = sig + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));
    sig = (sig * 1.4).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Slide for expressive portamento
SynthDef(\notaSlide, {
    |out = 0, startFreq = 440, endFreq = 400, amp = 0.35, dur = 0.6,
     slideTime = 0.15, vibRate = 5, vibDepth = 0.018, pan = -0.25|

    var env, freqEnv, vibrato, sig, formant1, formant2, freq;

    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.03, slideTime], \exp));
    freq = freqEnv;

    env = EnvGen.kr(
        Env([0, 1, 0.8, 0], [0.05, dur * 0.65, dur * 0.3], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    sig = LFSaw.ar(freq + vibrato);

    formant1 = BPF.ar(sig, 300, 0.3) * 2.5;
    formant2 = BPF.ar(sig, 550, 0.25) * 2;
    sig = sig + formant1 + formant2;

    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.4).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Cimbalom - shimmering accompaniment
SynthDef(\notaCimbalom, {
    |out = 0, freq = 440, amp = 0.25, dur = 1.0, pan = 0.2|
    var env, partials, sig, attack;

    env = EnvGen.kr(Env.perc(0.001, dur, 1, -5), doneAction: 2);

    partials = [1, 2.002, 3.003, 4.006, 5.01, 6.015];
    sig = Mix(partials.collect { |p, i|
        SinOsc.ar(freq * p + LFNoise1.kr(0.3).range(-0.5, 0.5), 0, 1 / (i + 1).sqrt)
    });

    attack = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.kr(Env.perc(0.0001, 0.008)) * 0.12;
    sig = sig + attack;
    sig = LPF.ar(sig, freq * 7);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Cimbalom tremolo (for sustained passages)
SynthDef(\notaCimbTrem, {
    |out = 0, freq = 440, amp = 0.22, dur = 1.0, rate = 14, pan = 0.2|
    var env, trem, sig;

    env = EnvGen.kr(Env.linen(0.02, dur * 0.8, dur * 0.18), doneAction: 2);
    trem = LFPulse.kr(rate, 0, 0.4);

    sig = Mix([1, 2.002, 3.003, 4.006].collect { |p, i|
        SinOsc.ar(freq * p, 0, 1 / (i + 1))
    });

    sig = sig * (trem * 0.6 + 0.4);
    sig = LPF.ar(sig, freq * 6);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Romantic bass (softer, more legato)
SynthDef(\notaBass, {
    |out = 0, freq = 55, amp = 0.35, dur = 0.4|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);

    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.2) + (SinOsc.ar(freq * 3) * 0.08);
    sig = LPF.ar(sig, 400);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Secondo violin (harmony)
SynthDef(\notaSecondo, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.3, pan = 0.1|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.02, dur, 1, -5), doneAction: 2);

    sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 450, 0.4) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, freq * 3);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Grace note
SynthDef(\notaGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.04|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);
    sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 500, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, freq * 3);

    Out.ar(out, Pan2.ar(sig * env * amp, -0.25));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Sentimental melody (slow, rubato)
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

// Romantic, sighing phrase
var melody = [4, 6, 4, 3, 4, 2, 1, 0];
var durations = [0.8, 0.5, 0.7, 0.4, 1.0, 0.5, 0.4, 1.2];
var dynamics = [0.38, 0.42, 0.40, 0.36, 0.44, 0.38, 0.34, 0.38];

Routine({
    "Sentimental magyar nóta melody:".postln;

    melody.do { |deg, i|
        var dur = durations[i];

        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \amp, dynamics[i],
            \vibRate, 5.5,
            \vibDepth, if(dur > 0.6, 0.025, 0.015),
            \attack, if(dur > 0.6, 0.06, 0.03)
        ]);

        // Light cimbalom on some notes
        if([0, 2, 4, 7].includes(i)) {
            Synth(\notaCimbalom, [
                \freq, ~scaleToFreq.(root - 12, scale, 0),
                \amp, 0.18,
                \dur, 0.8
            ]);
        };

        (dur + rrand(-0.03, 0.05)).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: With cimbalom accompaniment
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

var melody = [0, 2, 4, 4, 3, 2, 0, -1, 0];
var durs = [0.6, 0.4, 0.5, 0.8, 0.4, 0.4, 0.5, 0.3, 1.2];

Routine({
    "Magyar nóta with cimbalom:".postln;

    melody.do { |deg, i|
        var dur = durs[i];

        // Melody
        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 1.1,
            \amp, 0.4,
            \vibRate, 5
        ]);

        // Cimbalom arpeggiated chord
        if(i % 2 == 0) {
            [0, 2, 4].do { |chordDeg, j|
                Synth(\notaCimbalom, [
                    \freq, ~scaleToFreq.(root + 12, scale, chordDeg),
                    \amp, 0.15,
                    \dur, 0.6
                ]);
                0.03.wait;
            };
            (dur - 0.09).wait;
        } {
            dur.wait;
        };
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Dramatic contrast (slow → fast)
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    var slowMelody = [4, 6, 4, 3, 2, 0];
    var slowDurs = [1.0, 0.6, 0.8, 0.5, 0.6, 1.5];
    var fastTempo = 0.18;
    var fastMelody = [0, 2, 4, 4, 3, 2, 0, 0, 2, 4, 3, 2, 0, -1, 0, 0];

    "Dramatic nóta contrast:".postln;

    // SLOW, expressive section
    "  Slow, expressive:".postln;

    slowMelody.do { |deg, i|
        if(i == 1) {
            // Slide to high note
            Synth(\notaSlide, [
                \startFreq, ~scaleToFreq.(melodyRoot, scale, 4),
                \endFreq, ~scaleToFreq.(melodyRoot, scale, 6),
                \dur, slowDurs[i],
                \slideTime, 0.2,
                \amp, 0.45
            ]);
        } {
            Synth(\notaViolin, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, slowDurs[i],
                \amp, 0.42,
                \vibDepth, 0.028
            ]);
        };

        if(i % 2 == 0) {
            Synth(\notaCimbTrem, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \dur, slowDurs[i] * 0.8,
                \amp, 0.18
            ]);
        };

        slowDurs[i].wait;
    };

    0.5.wait;

    // FAST, dance section
    "  Fast, dance:".postln;

    fastMelody.do { |deg, i|
        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, fastTempo * 1.5,
            \amp, 0.38,
            \vibRate, 0,
            \attack, 0.01
        ]);

        if(i % 2 == 0) {
            Synth(\notaBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.35]);
        } {
            Synth(\notaCimbalom, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, 0.2,
                \dur, 0.25
            ]);
        };

        fastTempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Restaurant scene (prímás virtuosity)
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    "Restaurant prímás solo:".postln;

    // Opening flourish
    "  Flourish:".postln;
    (0..6).do { |deg|
        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.12,
            \amp, 0.3 + (deg * 0.02),
            \vibRate, 0,
            \attack, 0.008
        ]);
        0.08.wait;
    };

    // High held note
    Synth(\notaViolin, [
        \freq, ~scaleToFreq.(melodyRoot, scale, 7),
        \dur, 1.5,
        \amp, 0.48,
        \vibRate, 6,
        \vibDepth, 0.03
    ]);
    1.3.wait;

    // Descending phrase with ornaments
    "  Ornamented descent:".postln;
    [6, 4, 3, 2, 0].do { |deg, i|
        var dur = [0.6, 0.5, 0.7, 0.4, 1.2].at(i);

        // Grace note on some
        if([0, 2].includes(i)) {
            Synth(\notaGrace, [\freq, ~scaleToFreq.(melodyRoot, scale, deg + 1), \dur, 0.035]);
            0.03.wait;
        };

        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur,
            \amp, 0.42 - (i * 0.02),
            \vibDepth, 0.022
        ]);

        // Cimbalom support
        if(i % 2 == 0) {
            Synth(\notaCimbalom, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \amp, 0.16,
                \dur, 0.5
            ]);
        };

        dur.wait;
    };

    // Final cadence
    "  Cadence:".postln;
    Synth(\notaSlide, [
        \startFreq, ~scaleToFreq.(melodyRoot, scale, 1),
        \endFreq, ~scaleToFreq.(melodyRoot, scale, 0),
        \dur, 0.8,
        \slideTime, 0.1,
        \amp, 0.4
    ]);
    Synth(\notaBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.4, \dur, 1.0]);
    Synth(\notaCimbalom, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.25, \dur, 1.5]);
    Synth(\notaCimbalom, [\freq, ~scaleToFreq.(root + 12, scale, 4), \amp, 0.2, \dur, 1.5]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Full ensemble texture
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.35;

var melody = [0, 2, 4, 6, 4, 3, 4, 2, 0, -1, 0, 0];
var durs = [0.8, 0.4, 0.5, 1.0, 0.5, 0.4, 0.6, 0.4, 0.5, 0.3, 1.0, 0.5];

Routine({
    "Full magyar nóta ensemble:".postln;

    melody.do { |deg, i|
        var dur = durs[i] * tempo * 2;

        // Prímás (lead violin)
        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 1.1,
            \amp, 0.4,
            \vibRate, if(dur > 0.5, 5.5, 0),
            \vibDepth, 0.02
        ]);

        // Secondo (harmony violin) on some notes
        if([2, 4, 6, 8].includes(i)) {
            Synth(\notaSecondo, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg - 2),
                \dur, dur * 0.8,
                \amp, 0.18
            ]);
        };

        // Bass on beats
        if(i % 2 == 0) {
            var bassDeg = if([4, 5, 6].includes(i), 4, 0);
            Synth(\notaBass, [
                \freq, ~scaleToFreq.(root, scale, bassDeg),
                \amp, 0.32,
                \dur, tempo * 0.8
            ]);
        };

        // Cimbalom arpeggio
        if(i % 3 == 0) {
            fork {
                [0, 2, 4].do { |cd, j|
                    Synth(\notaCimbalom, [
                        \freq, ~scaleToFreq.(root + 12, scale, cd),
                        \amp, 0.14,
                        \dur, 0.5
                    ]);
                    0.025.wait;
                };
            };
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Gypsy scale version (Phrygian dominant)
// ============================================================================
(
var root = 60;
var scale = ~gypsyScale;  // Different scale flavor

var melody = [0, 1, 4, 4, 2, 1, 0, -1, 0];
var durs = [0.7, 0.4, 0.8, 0.5, 0.6, 0.4, 0.5, 0.3, 1.2];

Routine({
    "Magyar nóta with Gypsy scale:".postln;

    melody.do { |deg, i|
        var dur = durs[i];

        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \amp, 0.4,
            \vibRate, 5.5,
            \vibDepth, 0.022
        ]);

        (dur + rrand(-0.02, 0.04)).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 7: Romantic swell
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    // Building phrase with crescendo
    var melody = [0, 2, 4, 6, 7, 6, 4, 2, 0];
    var durs = [0.4, 0.3, 0.4, 0.5, 1.2, 0.5, 0.4, 0.4, 1.5];
    var dynamics = [0.28, 0.32, 0.36, 0.42, 0.5, 0.45, 0.38, 0.32, 0.35];

    "Romantic swell:".postln;

    // Cimbalom tremolo underneath
    Synth(\notaCimbTrem, [
        \freq, ~scaleToFreq.(root + 12, scale, 0),
        \dur, 5.0,
        \amp, 0.15,
        \rate, 12
    ]);

    melody.do { |deg, i|
        Synth(\notaViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, dynamics[i],
            \vibRate, 5,
            \vibDepth, dynamics[i] * 0.05,  // Vibrato increases with dynamics
            \attack, if(i == 4, 0.1, 0.04)  // Slow attack on climax
        ]);

        durs[i].wait;
    };
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
