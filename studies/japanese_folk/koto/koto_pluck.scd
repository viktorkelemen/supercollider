// ============================================================================
// KOTO PLUCK - Japanese Zither Synthesis
// ============================================================================
// The koto is a 13-string zither, the national instrument of Japan.
// Its distinctive bright, shimmering tone comes from silk/nylon strings
// plucked with ivory picks (tsume) worn on three fingers.
//
// Key characteristics:
// - Bright, metallic attack with resonant decay
// - Aftertouch pitch bends (oshide) - pressing string after plucking
// - Slides (hikiiro) - pulling string sideways
// - Vibrato by pressing/releasing string
// - Characteristic tunings: hirajoshi, kumoijoshi
// - Range approximately 2 octaves (13 strings)
//
// Load core library first:
// "/path/to/studies/japanese_folk/lib/japanese_core.scd".load;
// ============================================================================

// Local scale definitions (if core library not loaded)
(
~hirajoshi = [0, 2, 3, 7, 8];     // C D Eb G Ab - contemplative
~kumoijoshi = [0, 1, 5, 7, 8];   // D Eb G A Bb - ethereal
~yoScale = [0, 2, 5, 7, 9];      // D E G A B - bright folk
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
// KOTO SYNTHDEFS
// ============================================================================
(
// Main koto synth - plucked string with body resonance
SynthDef(\koto, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.5, pan = 0,
     brightness = 0.7, resonance = 0.6,
     attack = 0.003, decay = 0.1|

    var env, pluck, string, body, sig;
    var exciter, combFreq, formant1, formant2, formant3;

    // Plucked envelope - sharp attack, gradual decay
    env = EnvGen.kr(
        Env.perc(attack, dur, 1, -6),
        doneAction: 2
    );

    // Pluck excitation - impulse filtered through body
    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.005)));

    // Karplus-Strong style plucked string
    combFreq = freq.reciprocal;
    string = CombL.ar(exciter, 0.05, combFreq, dur * resonance);

    // Add harmonics for brightness
    string = string + (CombL.ar(exciter, 0.025, combFreq * 0.5, dur * 0.7) * 0.3);
    string = string + (CombL.ar(exciter, 0.017, combFreq * 0.333, dur * 0.5) * 0.15);

    // Koto body formants (paulownia wood resonance)
    formant1 = BPF.ar(string, 250, 0.3) * 2;    // Low body resonance
    formant2 = BPF.ar(string, 800, 0.25) * 2.5; // Mid resonance
    formant3 = BPF.ar(string, 3500, 0.2) * 2;   // Bridge brightness

    body = string + formant1 + formant2 + formant3;

    // Brightness control
    sig = LPF.ar(body, freq * (3 + (brightness * 10)));

    // Gentle saturation for warmth
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Koto with oshide (aftertouch pitch bend upward)
SynthDef(\kotoOshide, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.5, pan = 0,
     bendDepth = 1.0, bendDelay = 0.15, bendTime = 0.2,
     brightness = 0.7, resonance = 0.6|

    var env, bendEnv, currentFreq, exciter, string, sig;
    var formant1, formant2, formant3;

    // Pitch bend envelope - delayed onset, gradual rise
    bendEnv = EnvGen.kr(
        Env([0, 0, bendDepth, bendDepth * 0.8],
            [bendDelay, bendTime, dur - bendDelay - bendTime],
            [0, 3, -2])
    );
    currentFreq = freq * (2 ** (bendEnv / 12));

    env = EnvGen.kr(Env.perc(0.003, dur, 1, -6), doneAction: 2);

    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.005)));
    string = CombL.ar(exciter, 0.05, currentFreq.reciprocal, dur * resonance);
    string = string + (CombL.ar(exciter, 0.025, (currentFreq * 0.5).reciprocal, dur * 0.7) * 0.3);

    formant1 = BPF.ar(string, 250, 0.3) * 2;
    formant2 = BPF.ar(string, 800, 0.25) * 2.5;
    formant3 = BPF.ar(string, 3500, 0.2) * 2;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, currentFreq * (3 + (brightness * 10)));
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Koto with hikiiro (lateral slide between pitches)
SynthDef(\kotoSlide, {
    |out = 0, startFreq = 440, endFreq = 494, amp = 0.3, dur = 1.0, pan = 0,
     slideTime = 0.15, brightness = 0.7, resonance = 0.6|

    var env, freqEnv, exciter, string, sig;
    var formant1, formant2, formant3;

    // Slide envelope - smooth transition
    freqEnv = EnvGen.kr(
        Env([startFreq, startFreq, endFreq], [0.01, slideTime], [\lin, 3])
    );

    env = EnvGen.kr(Env.perc(0.003, dur, 1, -6), doneAction: 2);

    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.005)));
    string = CombL.ar(exciter, 0.05, freqEnv.reciprocal, dur * resonance);
    string = string + (CombL.ar(exciter, 0.025, (freqEnv * 0.5).reciprocal, dur * 0.7) * 0.3);

    formant1 = BPF.ar(string, 250, 0.3) * 2;
    formant2 = BPF.ar(string, 800, 0.25) * 2.5;
    formant3 = BPF.ar(string, 3500, 0.2) * 2;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freqEnv * (3 + (brightness * 10)));
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Koto with vibrato (yuri - pressing/releasing string)
SynthDef(\kotoVibrato, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.5, pan = 0,
     vibRate = 5, vibDepth = 0.3, vibDelay = 0.2,
     brightness = 0.7, resonance = 0.6|

    var env, vibEnv, vibrato, exciter, string, sig;
    var formant1, formant2, formant3, currentFreq;

    // Delayed vibrato envelope
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.1]));
    vibrato = SinOsc.kr(vibRate) * vibDepth * vibEnv;
    currentFreq = freq * (2 ** (vibrato / 12));

    env = EnvGen.kr(Env.perc(0.003, dur, 1, -6), doneAction: 2);

    exciter = Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.005)));
    string = CombL.ar(exciter, 0.05, currentFreq.reciprocal, dur * resonance);
    string = string + (CombL.ar(exciter, 0.025, (currentFreq * 0.5).reciprocal, dur * 0.7) * 0.3);

    formant1 = BPF.ar(string, 250, 0.3) * 2;
    formant2 = BPF.ar(string, 800, 0.25) * 2.5;
    formant3 = BPF.ar(string, 3500, 0.2) * 2;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, currentFreq * (3 + (brightness * 10)));
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Koto tremolo (repeated plucks - kakite/sukuite pattern)
SynthDef(\kotoTremolo, {
    |out = 0, freq = 440, amp = 0.25, dur = 1.0, pan = 0,
     rate = 8, brightness = 0.7|

    var env, trigger, exciter, string, sig;
    var formant1, formant2, formant3;

    env = EnvGen.kr(Env.linen(0.02, dur * 0.85, dur * 0.13), doneAction: 2);

    // Repeated triggers for tremolo
    trigger = Impulse.ar(rate);
    exciter = trigger + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.001, 0.003), trigger));

    string = CombL.ar(exciter, 0.05, freq.reciprocal, 0.3);
    string = string + (CombL.ar(exciter, 0.025, (freq * 0.5).reciprocal, 0.2) * 0.3);

    formant1 = BPF.ar(string, 250, 0.3) * 2;
    formant2 = BPF.ar(string, 800, 0.25) * 2.5;
    formant3 = BPF.ar(string, 3500, 0.2) * 1.5;

    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.1).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Quick grace note pluck
SynthDef(\kotoGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.08, pan = 0|

    var env, exciter, string, sig;

    env = EnvGen.kr(Env.perc(0.002, dur), doneAction: 2);

    exciter = Impulse.ar(0);
    string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 2);

    sig = LPF.ar(string, freq * 6);
    sig = BPF.ar(string, 800, 0.4) * 3 + (sig * 0.5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Arpeggio sweep across strings (sararin/nagashizume)
SynthDef(\kotoSweep, {
    |out = 0, baseFreq = 220, amp = 0.3, dur = 0.5, pan = 0,
     numStrings = 5, spread = 0.05, direction = 1|

    var env, sigs;

    env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);

    sigs = numStrings.collect { |i|
        var delay = i * spread * (1 - (direction * 2).abs.sign + direction.sign);
        var freq = baseFreq * (2 ** ((i * 2) / 12)); // Stacked 2nds
        var exciter, string;

        exciter = DelayN.ar(
            Impulse.ar(0) + (WhiteNoise.ar * EnvGen.kr(Env.perc(0.001, 0.004))),
            0.5,
            delay.abs
        );
        string = CombL.ar(exciter, 0.05, freq.reciprocal, dur * 0.8);
        string = BPF.ar(string, 800, 0.4) * 2 + string;
        LPF.ar(string, freq * 6) * (1 - (i * 0.1))
    }.sum;

    sigs = (sigs * 1.2).tanh * 0.6;

    Out.ar(out, Pan2.ar(sigs * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic koto tone comparison
// ============================================================================
(
Routine({
    var root = 60;  // C4
    var scale = ~hirajoshi;

    "Basic koto pluck:".postln;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \brightness, 0.7,
        \amp, 0.35
    ]);

    3.0.wait;

    "Darker tone (lower brightness):".postln;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \brightness, 0.3,
        \amp, 0.35
    ]);

    3.0.wait;

    "Brighter tone (higher brightness):".postln;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \brightness, 0.9,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Oshide (aftertouch pitch bend)
// ============================================================================
(
Routine({
    var root = 60;
    var scale = ~hirajoshi;

    "Oshide - aftertouch pitch bend:".postln;

    "Small bend (semitone):".postln;
    Synth(\kotoOshide, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 2.0,
        \bendDepth, 1.0,
        \bendDelay, 0.2,
        \bendTime, 0.25,
        \amp, 0.35
    ]);

    2.5.wait;

    "Large bend (whole tone):".postln;
    Synth(\kotoOshide, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 2.0,
        \bendDepth, 2.0,
        \bendDelay, 0.15,
        \bendTime, 0.3,
        \amp, 0.35
    ]);

    2.5.wait;

    "Quick bend (ornamental):".postln;
    Synth(\kotoOshide, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \bendDepth, 0.5,
        \bendDelay, 0.08,
        \bendTime, 0.1,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Hikiiro (slides between notes)
// ============================================================================
(
Routine({
    var root = 60;
    var scale = ~hirajoshi;

    "Hikiiro - lateral slides:".postln;

    "Ascending slide:".postln;
    Synth(\kotoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 1),
        \endFreq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.8,
        \slideTime, 0.2,
        \amp, 0.35
    ]);

    2.3.wait;

    "Descending slide:".postln;
    Synth(\kotoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.8,
        \slideTime, 0.25,
        \amp, 0.35
    ]);

    2.3.wait;

    "Quick ornamental slide:".postln;
    Synth(\kotoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 2),
        \endFreq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.2,
        \slideTime, 0.08,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Hirajoshi scale melody
// ============================================================================
(
var root = 60;
var scale = ~hirajoshi;
// Hirajoshi: C D Eb G Ab - contemplative, melancholic
var melody = [0, 1, 2, 3, 4, 3, 2, 1, 0];
var durations = [0.6, 0.4, 0.5, 0.8, 0.6, 0.5, 0.4, 0.5, 1.2];
var hasOshide = [false, false, true, false, true, false, false, true, false];

Routine({
    "Hirajoshi scale melody:".postln;

    melody.do { |deg, i|
        var dur = durations[i];

        if(hasOshide[i]) {
            Synth(\kotoOshide, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.3,
                \bendDepth, 0.7,
                \bendDelay, 0.12,
                \amp, 0.34
            ]);
        } {
            Synth(\koto, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.3,
                \amp, 0.34
            ]);
        };

        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 5: Koto tremolo (kakite/sukuite)
// ============================================================================
(
Routine({
    var root = 60;
    var scale = ~hirajoshi;

    "Koto tremolo techniques:".postln;

    "Slow tremolo:".postln;
    Synth(\kotoTremolo, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 2.0,
        \rate, 5,
        \amp, 0.3
    ]);

    2.5.wait;

    "Fast tremolo:".postln;
    Synth(\kotoTremolo, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.5,
        \rate, 12,
        \amp, 0.3
    ]);

    2.0.wait;

    "Accelerating tremolo:".postln;
    [6, 9, 12, 15].do { |rate, i|
        Synth(\kotoTremolo, [
            \freq, ~scaleToFreq.(root, scale, 3),
            \dur, 0.4,
            \rate, rate,
            \amp, 0.28
        ]);
        0.35.wait;
    };

    // Sustained tremolo at end
    Synth(\kotoTremolo, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.5,
        \rate, 18,
        \amp, 0.32
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 6: Arpeggio sweeps (sararin)
// ============================================================================
(
Routine({
    var root = 48;  // Lower starting point for fuller sound

    "Arpeggio sweeps:".postln;

    "Upward sweep:".postln;
    Synth(\kotoSweep, [
        \baseFreq, root.midicps,
        \dur, 1.5,
        \numStrings, 6,
        \spread, 0.06,
        \direction, 1,
        \amp, 0.38
    ]);

    2.0.wait;

    "Downward sweep:".postln;
    Synth(\kotoSweep, [
        \baseFreq, root.midicps,
        \dur, 1.5,
        \numStrings, 6,
        \spread, 0.06,
        \direction, -1,
        \amp, 0.38
    ]);

    2.0.wait;

    "Quick flourish:".postln;
    Synth(\kotoSweep, [
        \baseFreq, root.midicps,
        \dur, 0.8,
        \numStrings, 5,
        \spread, 0.03,
        \direction, 1,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Grace notes with main notes
// ============================================================================
(
var root = 60;
var scale = ~hirajoshi;

Routine({
    "Grace notes ornamentation:".postln;

    // Grace note from below
    Synth(\kotoGrace, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.06,
        \amp, 0.2
    ]);
    0.04.wait;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.2,
        \amp, 0.35
    ]);

    1.5.wait;

    // Grace note from above
    Synth(\kotoGrace, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.06,
        \amp, 0.2
    ]);
    0.04.wait;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.2,
        \amp, 0.35
    ]);

    1.5.wait;

    // Double grace (turn)
    Synth(\kotoGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.05, \amp, 0.18]);
    0.04.wait;
    Synth(\kotoGrace, [\freq, ~scaleToFreq.(root, scale, 1), \dur, 0.05, \amp, 0.18]);
    0.04.wait;
    Synth(\koto, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 8: Koto vibrato (yuri)
// ============================================================================
(
Routine({
    var root = 60;
    var scale = ~hirajoshi;

    "Koto vibrato (yuri):".postln;

    "Subtle vibrato:".postln;
    Synth(\kotoVibrato, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 2.0,
        \vibRate, 4,
        \vibDepth, 0.2,
        \vibDelay, 0.3,
        \amp, 0.35
    ]);

    2.5.wait;

    "Wide vibrato (expressive):".postln;
    Synth(\kotoVibrato, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 2.0,
        \vibRate, 5,
        \vibDepth, 0.5,
        \vibDelay, 0.25,
        \amp, 0.35
    ]);

    2.5.wait;

    "Fast vibrato:".postln;
    Synth(\kotoVibrato, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.8,
        \vibRate, 7,
        \vibDepth, 0.3,
        \vibDelay, 0.2,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 9: Kumoijoshi tuning comparison
// ============================================================================
(
var root = 62;  // D for kumoijoshi

Routine({
    "Scale comparison - Hirajoshi vs Kumoijoshi:".postln;

    "Hirajoshi (C D Eb G Ab):".postln;
    (0..4).do { |deg|
        Synth(\koto, [
            \freq, ~scaleToFreq.(60, ~hirajoshi, deg),
            \dur, 0.8,
            \amp, 0.32
        ]);
        0.5.wait;
    };

    1.0.wait;

    "Kumoijoshi (D Eb G A Bb):".postln;
    (0..4).do { |deg|
        Synth(\koto, [
            \freq, ~scaleToFreq.(62, ~kumoijoshi, deg),
            \dur, 0.8,
            \amp, 0.32
        ]);
        0.5.wait;
    };

    1.0.wait;

    "Kumoijoshi melody:".postln;
    [0, 1, 2, 3, 2, 1, 0].do { |deg, i|
        var hasOshide = [2, 4].includes(i);

        if(hasOshide) {
            Synth(\kotoOshide, [
                \freq, ~scaleToFreq.(62, ~kumoijoshi, deg),
                \dur, 0.9,
                \bendDepth, 0.6,
                \amp, 0.34
            ]);
        } {
            Synth(\koto, [
                \freq, ~scaleToFreq.(62, ~kumoijoshi, deg),
                \dur, 0.8,
                \amp, 0.34
            ]);
        };
        0.55.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 10: Full ornamented phrase with all techniques
// ============================================================================
(
var root = 60;
var scale = ~hirajoshi;

Routine({
    "Full ornamented koto phrase:".postln;

    // Opening sweep
    Synth(\kotoSweep, [
        \baseFreq, (root - 12).midicps,
        \dur, 0.6,
        \numStrings, 4,
        \spread, 0.04,
        \amp, 0.3
    ]);
    0.5.wait;

    // First melodic note with oshide
    Synth(\kotoOshide, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.5,
        \bendDepth, 0.8,
        \bendDelay, 0.15,
        \amp, 0.36
    ]);
    1.3.wait;

    // Grace note into slide
    Synth(\kotoGrace, [\freq, ~scaleToFreq.(root, scale, 2), \dur, 0.05, \amp, 0.18]);
    0.04.wait;
    Synth(\kotoSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 3),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \slideTime, 0.18,
        \amp, 0.35
    ]);
    1.0.wait;

    // Tremolo peak
    Synth(\kotoTremolo, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \rate, 10,
        \amp, 0.32
    ]);
    0.9.wait;

    // Descending phrase with vibrato
    [3, 2, 1].do { |deg, i|
        if(i == 1) {
            Synth(\kotoVibrato, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, 1.0,
                \vibRate, 5,
                \vibDepth, 0.4,
                \vibDelay, 0.2,
                \amp, 0.34
            ]);
        } {
            Synth(\koto, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, 0.7,
                \amp, 0.34
            ]);
        };
        0.6.wait;
    };

    // Final note with oshide resolving
    Synth(\kotoOshide, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \bendDepth, 0.5,
        \bendDelay, 0.3,
        \bendTime, 0.4,
        \amp, 0.38
    ]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
