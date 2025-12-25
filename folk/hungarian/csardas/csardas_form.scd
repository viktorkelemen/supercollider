// ============================================================================
// CSÁRDÁS - The Hungarian National Dance
// ============================================================================
// The csárdás is characterized by tempo variation:
// - Lassú (slow): ~60-80 BPM, melancholic, expressive
// - Friss (fast): ~140-200 BPM, energetic, driving
//
// Structure: Slow introduction → gradual acceleration → fast climax
// Time signature: 2/4 or 4/4
// Ensemble: Violin (prímás), brácsa, bass, often cimbalom
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
// SYNTHDEFS (reuse from other experiments or define locally)
// ============================================================================
(
// Violin
SynthDef(\csardViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = -0.3,
     vibRate = 5, vibDepth = 0.015, attack = 0.05|
    var env, vibrato, sig, formant1, formant2;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, dur * 0.6, dur * 0.35], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    sig = LFSaw.ar(freq + vibrato);

    formant1 = BPF.ar(sig, 460, 0.3) * 2.5;
    formant2 = BPF.ar(sig, 2500, 0.2) * 1.5;
    sig = sig + formant1 + formant2;

    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Brácsa chop
SynthDef(\csardBracsa, {
    |out = 0, freq = 220, amp = 0.3, pan = 0.3|
    var env, sig, scratch;

    env = EnvGen.kr(Env.perc(0.005, 0.08, 1, -8), doneAction: 2);

    sig = [
        LFSaw.ar(freq * [1, 1.002]),
        LFSaw.ar(freq * 1.5 * [1, 1.001]),
        LFSaw.ar(freq * 2.01)
    ].sum;

    scratch = HPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.25;
    sig = sig + scratch;
    sig = BPF.ar(sig, 350, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, 2500);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Bass
SynthDef(\csardBass, {
    |out = 0, freq = 55, amp = 0.4, dur = 0.25|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.25);
    sig = LPF.ar(sig, 350);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Cimbalom
SynthDef(\csardCimbalom, {
    |out = 0, freq = 440, amp = 0.25, dur = 0.8, pan = 0|
    var env, partials, sig, attack;

    env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

    partials = [1, 2.001, 3.002, 4.005, 5.01];
    sig = Mix(partials.collect { |p, i|
        SinOsc.ar(freq * p, 0, 1 / (i + 1))
    });

    attack = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.kr(Env.perc(0.0001, 0.01)) * 0.15;
    sig = sig + attack;
    sig = LPF.ar(sig, freq * 6);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Lassú (slow section)
// ============================================================================
(
var tempo = 0.5;  // Slow tempo
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Melancholic melody
var melody = [4, 3, 4, 6, 4, 3, 2, 0];
var durations = [1.0, 0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 1.5];

Routine({
    "Csárdás Lassú (slow, melancholic):".postln;

    melody.do { |deg, i|
        var dur = durations[i] * tempo;
        var bassNote = [0, 0, 0, 4, 0, 0, 0, 0].at(i);

        // Violin melody
        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 0.95,
            \amp, 0.35,
            \vibRate, 5,
            \vibDepth, 0.02
        ]);

        // Sparse accompaniment
        if(i % 2 == 0) {
            Synth(\csardBass, [
                \freq, ~scaleToFreq.(root, scale, bassNote),
                \amp, 0.3,
                \dur, 0.4
            ]);
        };

        if(i % 2 == 1) {
            Synth(\csardBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, 0.2
            ]);
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Friss (fast section)
// ============================================================================
(
var tempo = 0.15;  // Fast tempo
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Energetic melody
var melody = [0, 2, 4, 4, 3, 2, 0, 0, 4, 4, 3, 2, 0, -1, 0, 0];

Routine({
    "Csárdás Friss (fast, energetic):".postln;

    melody.do { |deg, i|
        // Violin
        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.8,
            \amp, 0.32,
            \vibRate, 0,  // No vibrato on fast notes
            \attack, 0.01
        ]);

        // Driving accompaniment
        if(i % 2 == 0) {
            Synth(\csardBass, [
                \freq, ~scaleToFreq.(root, scale, 0),
                \amp, 0.38
            ]);
        } {
            Synth(\csardBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, 0.3
            ]);
        };

        tempo.wait;
    };

    // Final accent
    Synth(\csardViolin, [\freq, ~scaleToFreq.(melodyRoot, scale, 0), \dur, 0.5, \amp, 0.45]);
    Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.5]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Accelerando transition (lassú → friss)
// ============================================================================
(
var startTempo = 0.45;
var endTempo = 0.12;
var steps = 24;
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

var melodyPattern = [0, 2, 4, 4, 3, 2];

Routine({
    "Csárdás accelerando (slow → fast):".postln;

    steps.do { |i|
        var tempo = startTempo.blend(endTempo, i / (steps - 1));
        var deg = melodyPattern.wrapAt(i);
        var intensity = i.linlin(0, steps - 1, 0.3, 0.42);

        // Melody
        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.5,
            \amp, intensity,
            \vibRate, if(tempo > 0.3, 5, 0),
            \attack, tempo.linlin(0.12, 0.45, 0.01, 0.05)
        ]);

        // Accompaniment intensifies
        if(i % 2 == 0) {
            Synth(\csardBass, [
                \freq, ~scaleToFreq.(root, scale, 0),
                \amp, intensity + 0.05
            ]);
        } {
            Synth(\csardBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, intensity - 0.05
            ]);
        };

        tempo.wait;
    };

    // Climactic ending
    3.do { |i|
        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, 0),
            \dur, 0.15,
            \amp, 0.45
        ]);
        Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.5]);
        Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.4]);
        0.12.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Full csárdás form (complete piece)
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Melody phrases
var lassuMelody = [4, 3, 4, 6, 4, 3, 2, 0, 2, 3, 4, 3, 2, 1, 0, 0];
var lassuDurs = [1, 0.5, 0.5, 1.5, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 1, 0.5, 0.5, 0.5, 1.5, 0.5];

var frissMelody = [0, 2, 4, 4, 3, 2, 0, 0, 0, 4, 3, 2, 0, -1, 0, 0];

Routine({
    "=== CSÁRDÁS - Complete Form ===".postln;

    // ---- LASSÚ (slow) ----
    "".postln;
    "--- Lassú (slow, expressive) ---".postln;

    var lassuTempo = 0.4;

    lassuMelody.do { |deg, i|
        var dur = lassuDurs[i] * lassuTempo;
        var bassNote = if([0, 4, 8, 12].includes(i), 0, nil);

        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 0.9,
            \amp, 0.35 + (sin(i * 0.4) * 0.05),
            \vibRate, if(lassuDurs[i] > 0.7, 5, 3),
            \vibDepth, 0.018
        ]);

        if(bassNote.notNil) {
            Synth(\csardBass, [
                \freq, ~scaleToFreq.(root, scale, bassNote),
                \amp, 0.32,
                \dur, 0.5
            ]);
        };

        if(i % 2 == 1) {
            Synth(\csardBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, 0.18
            ]);
        };

        dur.wait;
    };

    1.0.wait;

    // ---- TRANSITION (accelerando) ----
    "".postln;
    "--- Transition (accelerando) ---".postln;

    var transSteps = 16;
    var startTempo = 0.35;
    var midTempo = 0.15;

    transSteps.do { |i|
        var tempo = startTempo.blend(midTempo, i / (transSteps - 1));
        var deg = [0, 4, 3, 4].wrapAt(i);

        Synth(\csardViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.3,
            \amp, 0.32 + (i * 0.008),
            \vibRate, 0,
            \attack, 0.02
        ]);

        if(i % 2 == 0) {
            Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.35 + (i * 0.005)]);
        } {
            Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.25 + (i * 0.008)]);
        };

        tempo.wait;
    };

    0.3.wait;

    // ---- FRISS (fast) ----
    "".postln;
    "--- Friss (fast, driving) ---".postln;

    var frissTempo = 0.13;

    2.do { |repeat|
        frissMelody.do { |deg, i|
            Synth(\csardViolin, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, frissTempo * 1.8,
                \amp, 0.35,
                \vibRate, 0,
                \attack, 0.008
            ]);

            if(i % 2 == 0) {
                Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.42]);
            } {
                Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.35]);
            };

            // Add cimbalom flourishes
            if([3, 7, 11, 15].includes(i)) {
                Synth(\csardCimbalom, [
                    \freq, ~scaleToFreq.(root + 24, scale, deg),
                    \amp, 0.2,
                    \dur, 0.3
                ]);
            };

            frissTempo.wait;
        };
    };

    // ---- ENDING ----
    "".postln;
    "--- Finale ---".postln;

    4.do { |i|
        Synth(\csardViolin, [\freq, ~scaleToFreq.(melodyRoot, scale, 0), \dur, 0.12, \amp, 0.45, \attack, 0.005]);
        Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.5]);
        Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.42]);
        0.1.wait;
    };

    // Final chord
    Synth(\csardViolin, [\freq, ~scaleToFreq.(melodyRoot, scale, 0), \dur, 0.8, \amp, 0.5, \vibRate, 5]);
    Synth(\csardCimbalom, [\freq, ~scaleToFreq.(root + 12, scale, 0), \dur, 1.5, \amp, 0.35]);
    Synth(\csardCimbalom, [\freq, ~scaleToFreq.(root + 12, scale, 4), \dur, 1.5, \amp, 0.3]);
    Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.55, \dur, 1.0]);

    "".postln;
    "=== End ===".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 5: Csárdás variants
// ============================================================================
(
// Ritka csárdás (sparse) - slower, more space
var tempo = 0.35;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Ritka csárdás (sparse):".postln;

    8.do { |bar|
        // Long bass note
        Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.35, \dur, 0.6]);
        (tempo * 2).wait;

        // Single brácsa chop
        Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.25]);
        (tempo * 2).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Sűrű csárdás (dense)
// ============================================================================
(
var tempo = 0.1;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Sűrű csárdás (dense, rapid):".postln;

    32.do { |i|
        if(i % 2 == 0) {
            Synth(\csardBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.4]);
        } {
            Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.35]);
        };

        // Extra chops for density
        if(i % 4 == 3) {
            0.05.wait;
            Synth(\csardBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.2]);
            0.05.wait;
        } {
            tempo.wait;
        };
    };
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
