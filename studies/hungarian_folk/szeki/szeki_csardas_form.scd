// ============================================================================
// SZÉKI CSÁRDÁS - Studies in Transylvanian Village Style
// ============================================================================
// Exploration of the music from Szék (Sic in Romanian), a famous
// Transylvanian Hungarian village that maintained exceptional preservation
// of archaic folk traditions due to its relative isolation.
//
// The Széki csárdás has two main variants:
// - Ritka ("sparse"): Slower tempo, heavier bow pressure, more ornamental
//   space. The music breathes with a weighty, earthy quality.
// - Sűrű ("dense"): Fast, driving tempo with tight rhythmic interlock.
//   The music becomes an urgent, propulsive force.
//
// A characteristic feature is the accelerando bridge that transitions
// from ritka to sűrű, building dramatic tension as the tempo increases.
//
// Distinctive ensemble sound:
// - Violin: nasal tone with rough bow noise, strong 1-2 kHz emphasis
// - Brácsa: scratchy attack, percussive chord stabs, slightly flat fifth
// - Ütőgardon: struck with stick for percussive thump + plucked bass
// - Heel clicks: dancers' boots adding rhythmic accents
//
// The Széki sound is rawer and earthier than the polished táncház revival
// style, reflecting its village origins and preserved archaic elements.
// ============================================================================

(
// Hungarian minor: 1 2 b3 #4 5 b6 7
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Transylvanian mode (natural minor with flat 6): 1 2 b3 4 5 b6 b7
~transylvanianMode = [0, 2, 3, 5, 7, 8, 10];

// Mixolydian (common in some Széki repertoire)
~mixolydian = [0, 2, 4, 5, 7, 9, 10];

// Dorian (for certain dance tunes)
~dorian = [0, 2, 3, 5, 7, 9, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SYNTHDEFS: Nasal violin, rough brácsa, ütőgardon, percussion
// ---------------------------------------------------------------------------
(
// Main violin - nasal, earthy tone
SynthDef(\szekViolin, {
    |out = 0, freq = 440, amp = 0.35, dur = 0.35, pan = -0.2,
     attack = 0.02, vibRate = 4.5, vibDepth = 0.012, brightness = 0.55|
    var env = EnvGen.kr(Env.perc(attack, dur - attack, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.6).range(-0.4, 0.4)) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    // Nasal body (1-2 kHz emphasis)
    sig = BPF.ar(sig, 600, 0.35) * 2 + BPF.ar(sig, 1600, 0.25) * 1.6 + sig * 0.4;
    sig = LPF.ar(sig, freq * (3 + brightness * 6));
    sig = (sig * 1.4).tanh * 0.75;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Long violin - for sustained phrases in ritka
SynthDef(\szekViolinLong, {
    |out = 0, freq = 440, amp = 0.33, dur = 1.0, pan = -0.2,
     vibRate = 4.2, vibDepth = 0.015, brightness = 0.5|
    var env = EnvGen.kr(Env.linen(0.03, dur - 0.18, 0.15, 1, -3), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3)) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 620, 0.33) * 2.1 + BPF.ar(sig, 1550, 0.24) * 1.7 + sig * 0.38;
    sig = LPF.ar(sig, freq * (3 + brightness * 5));
    sig = (sig * 1.35).tanh * 0.72;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Staccato violin - for fast sűrű passages
SynthDef(\szekViolinStaccato, {
    |out = 0, freq = 440, amp = 0.36, dur = 0.12, pan = -0.2, brightness = 0.6|
    var env = EnvGen.kr(Env.perc(0.008, dur, 1, -6), doneAction: 2);
    var sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 650, 0.38) * 2.3 + BPF.ar(sig, 1700, 0.22) * 1.5 + sig * 0.35;
    sig = LPF.ar(sig, freq * (3 + brightness * 5));
    sig = (sig * 1.5).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Rough bow - heavy attack with bow noise
SynthDef(\szekViolinRough, {
    |out = 0, freq = 440, amp = 0.34, dur = 0.4, pan = -0.2, roughness = 0.4|
    var env = EnvGen.kr(Env.perc(0.015, dur, 1, -4), doneAction: 2);
    var bowNoise = HPF.ar(WhiteNoise.ar, 1800) * EnvGen.kr(Env.perc(0.01, 0.05)) * roughness;
    var vibrato = SinOsc.kr(4.5) * freq * 0.01;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 600, 0.35) * 2 + BPF.ar(sig, 1600, 0.25) * 1.6 + sig * 0.4;
    sig = sig + bowNoise;
    sig = (sig * 1.4).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Grace note
SynthDef(\szekGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.05, pan = -0.2|
    var env = EnvGen.kr(Env.perc(0.003, dur, 1, -8), doneAction: 2);
    var sig = LFSaw.ar(freq * 1.01);
    sig = BPF.ar(sig, 650, 0.4) * 2 + sig * 0.3;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Slide/portamento
SynthDef(\szekSlide, {
    |out = 0, freqStart = 440, freqEnd = 550, amp = 0.3, dur = 0.25, pan = -0.2|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    var freqEnv = EnvGen.kr(Env([freqStart, freqEnd], [dur], [3]));
    var vibrato = SinOsc.kr(4.5) * freqEnv * 0.008;
    var sig = LFSaw.ar(freqEnv + vibrato);
    sig = BPF.ar(sig, 600, 0.35) * 2 + BPF.ar(sig, 1600, 0.25) * 1.6 + sig * 0.4;
    sig = (sig * 1.4).tanh * 0.75;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Rough brácsa - scratchy attack, slightly flat fifth
SynthDef(\szekBracsa, {
    |out = 0, freq = 200, amp = 0.32, pan = 0.2, len = 0.08|
    var env = EnvGen.kr(Env.perc(0.004, len, 1, -8), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.002]),
        LFSaw.ar(freq * 1.49 * [1, 1.001]),  // Slightly flat fifth
        LFSaw.ar(freq * 2.0)
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1700) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.35;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 420, 0.6) * 2 + sig * 0.4;
    sig = LPF.ar(sig, 2200);
    sig = (sig * 1.6).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Brácsa accent - harder attack
SynthDef(\szekBracsaAccent, {
    |out = 0, freq = 200, amp = 0.36, pan = 0.2, len = 0.1|
    var env = EnvGen.kr(Env.perc(0.002, len, 1, -7), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.003]),
        LFSaw.ar(freq * 1.48 * [1, 1.002]),
        LFSaw.ar(freq * 2.0 * [1, 1.001])
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.025)) * 0.45;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 450, 0.55) * 2.2 + sig * 0.45;
    sig = LPF.ar(sig, 2400);
    sig = (sig * 1.7).tanh * 0.68;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Brácsa ghost - very light chop for texture
SynthDef(\szekBracsaGhost, {
    |out = 0, freq = 200, amp = 0.18, pan = 0.2|
    var env = EnvGen.kr(Env.perc(0.003, 0.04, 1, -10), doneAction: 2);
    var chord = LFSaw.ar(freq * [1, 1.5, 2]).sum * 0.5;
    var scratch = HPF.ar(WhiteNoise.ar, 2000) * 0.5;
    var sig = (chord + scratch) * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Ütőgardon - struck with stick
SynthDef(\szekGardon, {
    |out = 0, freq = 90, amp = 0.45, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);
    var thump = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var slap = HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.02));
    var sig = LPF.ar(thump + slap * 0.5, 450);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Gardon bass - plucked low string
SynthDef(\szekGardonBass, {
    |out = 0, freq = 55, amp = 0.38, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.2, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.8 + SinOsc.ar(freq * 2) * 0.2;
    sig = LPF.ar(sig, 280);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Gardon rim - stick hitting edge
SynthDef(\szekGardonRim, {
    |out = 0, amp = 0.22, pan = 0.05|
    var env = EnvGen.kr(Env.perc(0.001, 0.05, 1, -10), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, 1300) * 0.5 + BPF.ar(WhiteNoise.ar, 2800, 0.25) * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Heel click - dancer's boots
SynthDef(\szekClick, {
    |out = 0, freq = 1100, amp = 0.28|
    var env = EnvGen.kr(Env.perc(0.001, 0.04), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.7 + (SinOsc.ar(freq * 0.3) * EnvGen.kr(Env.perc(0.001, 0.02)));
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Foot stomp
SynthDef(\szekStomp, {
    |out = 0, amp = 0.22, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.1, 1, -7), doneAction: 2);
    var sig = SinOsc.ar(55) * 0.6 + LPF.ar(WhiteNoise.ar, 180) * 0.4;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Boot slap
SynthDef(\szekBootSlap, {
    |out = 0, amp = 0.16, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.06, 1, -8), doneAction: 2);
    var sig = LPF.ar(WhiteNoise.ar, 500) + HPF.ar(WhiteNoise.ar, 1600) * 0.35;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 1: Violin Tone Exploration
// Different violin articulations and timbres
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.4;

Routine({
    "Experiment 1: Violin Tone Exploration".postln;

    // Standard tone
    "Standard nasal tone:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg|
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.34
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Rough bow attack
    "Rough bow attack:".postln;
    [0, 3, 6, 5, 3, 2, 0].do { |deg|
        Synth(\szekViolinRough, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.0,
            \amp, 0.33,
            \roughness, 0.5
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Long sustained
    "Long sustained notes:".postln;
    [0, 3, 6, 7, 6, 3, 0].do { |deg|
        Synth(\szekViolinLong, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.4,
            \amp, 0.32,
            \vibDepth, 0.018
        ]);
        (tempo * 1.3).wait;
    };

    0.6.wait;

    // Staccato
    "Staccato:".postln;
    [0, 2, 3, 4, 3, 2, 0, 2, 3, 4, 5, 4, 3, 2, 0].do { |deg|
        Synth(\szekViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.12,
            \amp, 0.35
        ]);
        0.16.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 2: Brácsa and Gardon Textures
// The rhythmic foundation of Széki style
// ---------------------------------------------------------------------------
(
var root = 48;
var scale = ~hungarianMinor;
var tempo = 0.28;

Routine({
    "Experiment 2: Brácsa and Gardon Textures".postln;

    // Gardon alone
    "Gardon beat:".postln;
    12.do { |i|
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.45]);
        } {
            Synth(\szekGardonRim, [\amp, 0.2]);
        };
        tempo.wait;
    };

    0.5.wait;

    // Brácsa alone
    "Brácsa chops:".postln;
    12.do { |i|
        if(i % 2 == 1) {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        };
        if(i % 4 == 3) {
            Synth(\szekBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
        };
        tempo.wait;
    };

    0.5.wait;

    // Combined texture
    "Combined rhythm:".postln;
    16.do { |i|
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.45]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };
        // Ghost notes fill texture
        if(i % 4 == 1) {
            Synth(\szekBracsaGhost, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.15]);
        };
        tempo.wait;
    };

    0.5.wait;

    // With bass plucks
    "With bass plucks:".postln;
    16.do { |i|
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.42]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };
        if(i % 8 == 0) {
            Synth(\szekGardonBass, [\freq, ~scaleToFreq.(root - 12, scale, 0), \amp, 0.35]);
        };
        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 3: Ornamentation - Széki Style
// Grace notes and slides characteristic of the region
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.38;

Routine({
    "Experiment 3: Ornamentation - Széki Style".postln;

    // Grace notes
    "Grace notes:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        if([1, 3, 5].includes(i)) {
            Synth(\szekGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.18
            ]);
        };
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.33
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Slides
    "Slides:".postln;
    [[0, 3], [3, 6], [6, 7], [7, 5], [5, 3], [3, 0]].do { |pair|
        Synth(\szekSlide, [
            \freqStart, ~scaleToFreq.(melodyRoot, scale, pair[0]),
            \freqEnd, ~scaleToFreq.(melodyRoot, scale, pair[1]),
            \dur, tempo * 0.7,
            \amp, 0.3
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Combined with accompaniment
    "Ornamented phrase with rhythm:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        if([1, 4, 6].includes(i)) {
            Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, scale, deg + 1), \amp, 0.16]);
        };
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.32
        ]);
        if(i % 2 == 0) { Synth(\szekGardon, [\amp, 0.42]); };
        if(i % 2 == 1) { Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.26]); };
        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 4: Ritka Csárdás (Sparse/Slow)
// Heavy, breathing style with space for ornamentation
// ---------------------------------------------------------------------------
(
var tempo = 0.55;  // Slow tempo
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 6, 5, 3, 2, 0, -1, 0];
var durs = [1.0, 0.6, 0.8, 1.2, 0.7, 0.6, 0.7, 0.9, 0.8, 1.4];

Routine({
    "Experiment 4: Ritka Csárdás (Sparse/Slow)".postln;

    melody.do { |deg, i|
        var dur = durs[i] * tempo;

        // Occasional grace notes
        if([2, 5, 8].includes(i)) {
            Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, scale, deg + 1), \amp, 0.16]);
        };

        // Heavy rough bow on important notes
        if([0, 3, 7, 9].includes(i)) {
            Synth(\szekViolinRough, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, dur * 0.9,
                \amp, 0.35,
                \roughness, 0.45
            ]);
        } {
            Synth(\szekViolinLong, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, dur * 0.85,
                \amp, 0.33,
                \vibDepth, 0.016
            ]);
        };

        // Sparse brácsa on offbeats
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.24]);
        (dur * 0.5).wait;
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 4), \amp, 0.2]);

        (dur * 0.5).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 5: Sűrű Csárdás (Dense/Fast)
// Driving, tight rhythm
// ---------------------------------------------------------------------------
(
var tempo = 0.18;
var root = 48;
var melodyRoot = 60;
var scale = ~transylvanianMode;
var melody = [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 5, 4, 3, 2, 0];

Routine({
    "Experiment 5: Sűrű Csárdás (Dense/Fast)".postln;

    melody.do { |deg, i|
        Synth(\szekViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.85,
            \amp, 0.35
        ]);

        // Tight gardon/brácsa alternation
        if(i % 2 == 0) {
            Synth(\szekGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.48]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        };

        // Heel clicks on phrase ends
        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.3]); };

        tempo.wait;
    };

    0.15.wait;

    // Repeat intensified
    "Intensified:".postln;
    melody.do { |deg, i|
        if(i % 3 == 0) {
            Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, scale, deg + 1), \amp, 0.14]);
        };

        Synth(\szekViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.75,
            \amp, 0.37
        ]);

        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.52]);
        } {
            Synth(\szekBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
        };

        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.32]); };
        if(i % 4 == 1) { Synth(\szekBootSlap, [\amp, 0.14]); };

        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 6: Accelerando Bridge
// Transition from ritka to sűrű
// ---------------------------------------------------------------------------
(
var steps = 24;
var startTempo = 0.5;
var endTempo = 0.18;
var root = 48;
var melodyRoot = 60;
var pattern = [0, 2, 3, 6, 5, 3, 2, 0];

Routine({
    "Experiment 6: Accelerando Bridge (ritka → sűrű)".postln;

    steps.do { |i|
        var t = startTempo.blend(endTempo, i / (steps - 1));
        var deg = pattern.wrapAt(i);
        var amp = i.linlin(0, steps - 1, 0.3, 0.38);
        var attack = t.linlin(endTempo, startTempo, 0.008, 0.04);

        // Transition from rough long notes to staccato
        if(i < (steps * 0.6)) {
            Synth(\szekViolin, [
                \freq, ~scaleToFreq.(melodyRoot, ~hungarianMinor, deg),
                \dur, t * 1.1,
                \amp, amp,
                \attack, attack
            ]);
        } {
            Synth(\szekViolinStaccato, [
                \freq, ~scaleToFreq.(melodyRoot, ~transylvanianMode, deg),
                \dur, t * 0.85,
                \amp, amp
            ]);
        };

        // Rhythm becomes tighter
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.4 + (i * 0.005)]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.25 + (i * 0.003)]);
        };

        // Add clicks in later section
        if((i > steps * 0.5) && (i % 4 == 3)) {
            Synth(\szekClick, [\amp, 0.25]);
        };

        t.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 7: Dance Patterns
// Different rhythmic accompaniment patterns
// ---------------------------------------------------------------------------
(
var root = 48;
var tempo = 0.22;

Routine({
    "Experiment 7: Dance Patterns".postln;

    // Basic csárdás pattern
    "Basic csárdás:".postln;
    16.do { |i|
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.45]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.28]);
        };
        tempo.wait;
    };

    0.5.wait;

    // Syncopated pattern
    "Syncopated:".postln;
    16.do { |i|
        var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1];
        if(pattern[i] == 1) {
            Synth(\szekGardon, [\amp, 0.44]);
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.26]);
        } {
            Synth(\szekGardonRim, [\amp, 0.18]);
        };
        tempo.wait;
    };

    0.5.wait;

    // Heavy downbeat pattern
    "Heavy downbeats:".postln;
    16.do { |i|
        if(i % 4 == 0) {
            Synth(\szekGardon, [\amp, 0.55]);
            Synth(\szekStomp, [\amp, 0.2]);
        };
        if(i % 4 == 2) {
            Synth(\szekGardon, [\amp, 0.4]);
        };
        if([1, 3].includes(i % 4)) {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.28]);
        };
        tempo.wait;
    };

    0.5.wait;

    // With heel clicks
    "With heel clicks:".postln;
    16.do { |i|
        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.45]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.28]);
        };
        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.28]); };
        if(i % 8 == 7) { Synth(\szekBootSlap, [\amp, 0.15]); };
        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 8: Full Széki Csárdás Form
// Complete structure: opening, ritka, accelerando, sűrű, finale
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var hungarianScale = ~hungarianMinor;
var transylScale = ~transylvanianMode;

Routine({
    "Experiment 8: Full Széki Csárdás Form".postln;

    // =========================================
    // OPENING - establishing the mood
    // =========================================
    "Opening...".postln;

    // Gardon establishes pulse
    4.do { |i|
        Synth(\szekGardon, [\amp, 0.38 + (i * 0.02)]);
        0.5.wait;
    };

    // Opening violin phrase
    [0, 3, 6, 7, 6, 3, 0].do { |deg, i|
        if(i == 0) { Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, hungarianScale, 1), \amp, 0.15]); };
        Synth(\szekViolinRough, [
            \freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg),
            \dur, 0.5,
            \amp, 0.32,
            \roughness, 0.4
        ]);
        Synth(\szekGardon, [\amp, 0.4]);
        0.2.wait;
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 0), \amp, 0.24]);
        0.3.wait;
    };

    0.6.wait;

    // =========================================
    // RITKA (Sparse/Slow section)
    // =========================================
    "Ritka csárdás...".postln;

    [
        [0, 1.0], [2, 0.6], [3, 0.8], [6, 1.1],
        [5, 0.7], [3, 0.6], [2, 0.7], [0, 1.2]
    ].do { |pair, i|
        var deg = pair[0];
        var durMult = pair[1];
        var dur = durMult * 0.5;

        if([2, 5].includes(i)) {
            Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg + 1), \amp, 0.15]);
        };

        if([0, 3, 7].includes(i)) {
            Synth(\szekViolinRough, [
                \freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg),
                \dur, dur * 0.9,
                \amp, 0.34,
                \roughness, 0.4
            ]);
        } {
            Synth(\szekViolinLong, [
                \freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg),
                \dur, dur * 0.85,
                \amp, 0.32,
                \vibDepth, 0.016
            ]);
        };

        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 0), \amp, 0.22]);
        (dur * 0.5).wait;
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 4), \amp, 0.18]);
        (dur * 0.5).wait;
    };

    0.6.wait;

    // =========================================
    // ACCELERANDO - building momentum
    // =========================================
    "Accelerando...".postln;

    20.do { |i|
        var t = 0.45.blend(0.18, i / 19);
        var deg = [0, 2, 3, 6, 5, 3, 2, 0].wrapAt(i);
        var amp = i.linlin(0, 19, 0.3, 0.36);

        if(i < 12) {
            Synth(\szekViolin, [
                \freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg),
                \dur, t * 1.0,
                \amp, amp
            ]);
        } {
            Synth(\szekViolinStaccato, [
                \freq, ~scaleToFreq.(melodyRoot, transylScale, deg),
                \dur, t * 0.85,
                \amp, amp
            ]);
        };

        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.4 + (i * 0.005)]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 0), \amp, 0.26 + (i * 0.002)]);
        };

        if((i > 10) && (i % 4 == 3)) { Synth(\szekClick, [\amp, 0.22]); };

        t.wait;
    };

    0.25.wait;

    // =========================================
    // SŰRŰ (Dense/Fast section)
    // =========================================
    "Sűrű csárdás...".postln;

    // First phrase
    [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 5, 4, 3, 2, 0].do { |deg, i|
        Synth(\szekViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, transylScale, deg),
            \dur, 0.14,
            \amp, 0.35
        ]);

        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.48]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, transylScale, 0), \amp, 0.3]);
        };

        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.28]); };

        0.18.wait;
    };

    0.12.wait;

    // Intensified second phrase
    [0, 2, 4, 5, 6, 5, 4, 3, 2, 0, 2, 4, 3, 2, 0, -1, 0].do { |deg, i|
        if(i % 3 == 0) {
            Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, transylScale, deg + 1), \amp, 0.13]);
        };

        Synth(\szekViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, transylScale, deg),
            \dur, 0.12,
            \amp, 0.37
        ]);

        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.52]);
        } {
            Synth(\szekBracsaAccent, [\freq, ~scaleToFreq.(root + 12, transylScale, 0), \amp, 0.32]);
        };

        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.3]); };
        if(i % 4 == 1) { Synth(\szekBootSlap, [\amp, 0.14]); };

        0.16.wait;
    };

    // =========================================
    // FINALE - triumphant ending
    // =========================================
    0.2.wait;
    "Finale...".postln;

    // Ascending flourish
    [0, 3, 5, 6, 7, 8].do { |deg, i|
        Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg + 1), \amp, 0.14]);
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(melodyRoot, hungarianScale, deg),
            \dur, 0.2,
            \amp, 0.36
        ]);
        Synth(\szekGardon, [\amp, 0.48]);
        Synth(\szekBracsaAccent, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 0), \amp, 0.3]);
        Synth(\szekClick, [\amp, 0.25]);
        0.18.wait;
    };

    // Final held note with big ending
    Synth(\szekGrace, [\freq, ~scaleToFreq.(melodyRoot, hungarianScale, 1), \amp, 0.16]);
    Synth(\szekViolinLong, [
        \freq, ~scaleToFreq.(melodyRoot, hungarianScale, 0),
        \dur, 1.8,
        \amp, 0.38,
        \vibDepth, 0.02
    ]);
    Synth(\szekGardon, [\amp, 0.6]);
    Synth(\szekGardonBass, [\freq, ~scaleToFreq.(root - 12, hungarianScale, 0), \amp, 0.4]);
    Synth(\szekBracsaAccent, [\freq, ~scaleToFreq.(root + 12, hungarianScale, 0), \amp, 0.35]);
    Synth(\szekClick, [\amp, 0.35]);
    Synth(\szekStomp, [\amp, 0.25]);

    2.0.wait;
    "Csárdás complete.".postln;
}).play;
)
