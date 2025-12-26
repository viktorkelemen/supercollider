// ============================================================================
// TÁNCHÁZ BAND AESTHETIC - Modern Revival Studies
// ============================================================================
// Exploration of the táncház (dance house) revival movement that began in
// 1970s Budapest. This movement brought traditional Hungarian and
// Transylvanian village music to urban settings, creating a vibrant
// folk dance scene that continues today.
//
// The táncház sound differs from archival field recordings in several ways:
// - Cleaner intonation and more precise ensemble playing
// - Light room ambience rather than raw outdoor sound
// - Traditional core instruments with occasional modern additions
// - Focus on supporting actual dancing rather than pure listening
//
// Core ensemble:
// - Prímás (lead violin): carries the melody with characteristic ornaments
// - Brácsa (kontra): 3-string viola playing percussive chord stabs
// - Gardon: cello-like instrument struck with a stick + plucked bass string
//
// Modern additions:
// - Acoustic guitar: harmonic support, sometimes replacing/augmenting brácsa
// - Cajón/bass drum: additional rhythmic drive for larger venues
// - Double bass: in some ensembles for fuller sound
// ============================================================================

(
// Hungarian minor: 1 2 b3 #4 5 b6 7
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Mixolydian (common in Transylvanian dance music)
~mixolydian = [0, 2, 4, 5, 7, 9, 10];

// Dorian (used in some regional styles)
~dorian = [0, 2, 3, 5, 7, 9, 10];

// Lydian dominant (Bartók scale)
~lydianDom = [0, 2, 4, 6, 7, 9, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// Shared reverb bus for ensemble cohesion
// ---------------------------------------------------------------------------
(
~tanchazVerbBus = Bus.audio(s, 2);

SynthDef(\tanchazVerb, {
    |in, out = 0, mix = 0.2, room = 0.7, damp = 0.5|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;
)

// ---------------------------------------------------------------------------
// SYNTHDEFS: Violin variants, brácsa, gardon, guitar, bass, percussion
// ---------------------------------------------------------------------------
(
// Lead violin - main melodic voice with vibrato
SynthDef(\tzViolin, {
    |out = 0, freq = 440, amp = 0.32, dur = 0.4, pan = -0.2,
     vibRate = 5, vibDepth = 0.012, attack = 0.02, send = 0.25|
    var env = EnvGen.kr(Env.perc(attack, dur - attack, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 500, 0.35) * 2 + BPF.ar(sig, 2500, 0.2) * 1.4 + sig * 0.4;
    sig = LPF.ar(sig, freq * 6);
    sig = (sig * 1.2).tanh * 0.8;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Long violin - for sustained melodic phrases
SynthDef(\tzViolinLong, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = -0.2,
     vibRate = 5.5, vibDepth = 0.015, send = 0.28|
    var env = EnvGen.kr(Env.linen(0.03, dur - 0.15, 0.12, 1, -3), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 520, 0.33) * 2.1 + BPF.ar(sig, 2400, 0.22) * 1.5 + sig * 0.38;
    sig = LPF.ar(sig, freq * 5.5);
    sig = (sig * 1.15).tanh * 0.78;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Staccato violin - for fast dance passages
SynthDef(\tzViolinStaccato, {
    |out = 0, freq = 440, amp = 0.34, dur = 0.12, pan = -0.2, send = 0.22|
    var env = EnvGen.kr(Env.perc(0.008, dur, 1, -6), doneAction: 2);
    var sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 550, 0.38) * 2.3 + BPF.ar(sig, 2600, 0.2) * 1.3 + sig * 0.35;
    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.3).tanh * 0.75;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Violin ornament - quick grace note
SynthDef(\tzViolinGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.05, pan = -0.2, send = 0.18|
    var env = EnvGen.kr(Env.perc(0.003, dur, 1, -8), doneAction: 2);
    var sig = LFSaw.ar(freq * 1.01);
    sig = BPF.ar(sig, 600, 0.4) * 2 + sig * 0.3;
    sig = LPF.ar(sig, 4000);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Violin slide - portamento between notes
SynthDef(\tzViolinSlide, {
    |out = 0, freqStart = 440, freqEnd = 550, amp = 0.28, dur = 0.3, pan = -0.2, send = 0.25|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    var freqEnv = EnvGen.kr(Env([freqStart, freqEnd], [dur], [3]));
    var vibrato = SinOsc.kr(5) * freqEnv * 0.01;
    var sig = LFSaw.ar(freqEnv + vibrato);
    sig = BPF.ar(sig, 500, 0.35) * 2 + BPF.ar(sig, 2500, 0.2) * 1.4 + sig * 0.4;
    sig = (sig * 1.2).tanh * 0.8;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Brácsa (kontra) - percussive chord stabs
SynthDef(\tzBracsa, {
    |out = 0, freq = 200, amp = 0.28, pan = 0.2, send = 0.15|
    var env = EnvGen.kr(Env.perc(0.004, 0.08, 1, -8), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.001]),
        LFSaw.ar(freq * 1.5 * [1, 1.001]),
        LFSaw.ar(freq * 2.0)
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1600) * EnvGen.kr(Env.perc(0.001, 0.015)) * 0.25;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 380, 0.55) * 2 + sig * 0.4;
    sig = LPF.ar(sig, 2300);
    sig = (sig * 1.4).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Brácsa accent - harder attack for emphasis
SynthDef(\tzBracsaAccent, {
    |out = 0, freq = 200, amp = 0.32, pan = 0.2, send = 0.15|
    var env = EnvGen.kr(Env.perc(0.002, 0.1, 1, -7), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.002]),
        LFSaw.ar(freq * 1.5 * [1, 1.002]),
        LFSaw.ar(freq * 2.0 * [1, 1.001])
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1400) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.35;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 400, 0.5) * 2.2 + sig * 0.45;
    sig = LPF.ar(sig, 2500);
    sig = (sig * 1.5).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Gardon - struck cello body + plucked bass
SynthDef(\tzGardon, {
    |out = 0, freq = 90, amp = 0.38, pan = 0, send = 0.1|
    var env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);
    var thump = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.3;
    var slap = HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.02));
    var sig = LPF.ar(thump + slap * 0.4, 450);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Gardon bass pluck - deeper pizzicato
SynthDef(\tzGardonBass, {
    |out = 0, freq = 55, amp = 0.35, pan = 0, send = 0.12|
    var env = EnvGen.kr(Env.perc(0.002, 0.2, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.8 + SinOsc.ar(freq * 2) * 0.2;
    sig = LPF.ar(sig, 300);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Gardon rim - stick hitting the body edge
SynthDef(\tzGardonRim, {
    |out = 0, amp = 0.25, pan = 0.05, send = 0.08|
    var env = EnvGen.kr(Env.perc(0.001, 0.06, 1, -10), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, 1200) * 0.5 + BPF.ar(WhiteNoise.ar, 2500, 0.3) * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Acoustic guitar - harmonic support
SynthDef(\tzGuitar, {
    |out = 0, freq = 220, amp = 0.22, dur = 0.35, pan = 0.25, send = 0.2|
    var env = EnvGen.kr(Env.perc(0.005, dur, 1, -5), doneAction: 2);
    var body = LPF.ar(Pluck.ar(WhiteNoise.ar(0.4), 1, 1/freq, 1/freq, 4, 0.4), 3500);
    var sig = body * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;

// Guitar chord - strummed harmony
SynthDef(\tzGuitarChord, {
    |out = 0, freq = 110, amp = 0.2, dur = 0.5, pan = 0.25, send = 0.22|
    var env = EnvGen.kr(Env.perc(0.008, dur, 1, -4), doneAction: 2);
    var notes = [freq, freq * 1.5, freq * 2, freq * 2.5];
    var strings = notes.collect { |f, i|
        LPF.ar(Pluck.ar(WhiteNoise.ar(0.3), Impulse.kr(0), 1/f, 1/f, 3.5, 0.35), 3000) *
        EnvGen.kr(Env.perc(0.003 + (i * 0.008), dur - (i * 0.008)))
    }.sum;
    var sig = strings * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;

// Double bass - pizzicato foundation
SynthDef(\tzBass, {
    |out = 0, freq = 55, amp = 0.3, dur = 0.25, pan = 0, send = 0.15|
    var env = EnvGen.kr(Env.perc(0.003, dur, 1, -5), doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.7 + LFTri.ar(freq) * 0.2 + Saw.ar(freq) * 0.1;
    sig = LPF.ar(sig, 400);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

// Cajón - modern addition for larger venues
SynthDef(\tzCajon, {
    |out = 0, amp = 0.25, pan = 0, send = 0.1|
    var env = EnvGen.kr(Env.perc(0.003, 0.12, 1, -6), doneAction: 2);
    var low = LPF.ar(WhiteNoise.ar, 200) * 1.2;
    var slap = HPF.ar(WhiteNoise.ar, 1500) * 0.4;
    var sig = (low + slap) * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;

// Cajón tone - deeper hit
SynthDef(\tzCajonTone, {
    |out = 0, freq = 80, amp = 0.28, pan = 0, send = 0.1|
    var env = EnvGen.kr(Env.perc(0.002, 0.15, 1, -6), doneAction: 2);
    var low = SinOsc.ar(freq) * 0.6 + LPF.ar(WhiteNoise.ar, 150) * 0.4;
    var sig = low * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;

// Foot stomp - dancer's feet
SynthDef(\tzFootStomp, {
    |out = 0, amp = 0.2, pan = 0, send = 0.08|
    var env = EnvGen.kr(Env.perc(0.002, 0.1, 1, -7), doneAction: 2);
    var sig = SinOsc.ar(60) * 0.6 + LPF.ar(WhiteNoise.ar, 180) * 0.4;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;
)

// ---------------------------------------------------------------------------
// VERB FOR ALL
// ---------------------------------------------------------------------------
(
Synth(\tanchazVerb, [\in, ~tanchazVerbBus]);
)

// ---------------------------------------------------------------------------
// EXPERIMENT 1: Core Ensemble Textures
// Violin, brácsa, gardon - the essential triangle
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.35;

Routine({
    "Experiment 1: Core Ensemble Textures".postln;

    // Demonstrate each instrument
    "Violin melody:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.32
        ]);
        tempo.wait;
    };

    0.5.wait;

    "Brácsa rhythmic pattern:".postln;
    8.do { |i|
        if(i % 2 == 1) {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };
        (tempo * 0.5).wait;
    };

    0.5.wait;

    "Gardon beat:".postln;
    8.do { |i|
        if(i % 2 == 0) {
            Synth(\tzGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.4]);
        } {
            Synth(\tzGardonRim, [\amp, 0.22]);
        };
        (tempo * 0.5).wait;
    };

    0.5.wait;

    // Combined texture
    "Full ensemble:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.3
        ]);
        Synth(\tzGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.38]);
        0.15.wait;
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.26]);
        (tempo - 0.15).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 2: Modern Additions
// Guitar, bass, cajón integration
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~mixolydian;
var tempo = 0.3;

Routine({
    "Experiment 2: Modern Additions".postln;

    // Guitar chords
    "Guitar chords:".postln;
    4.do { |i|
        Synth(\tzGuitarChord, [
            \freq, ~scaleToFreq.(root, scale, [0, 4, 0, 3][i]),
            \dur, tempo * 2,
            \amp, 0.22
        ]);
        (tempo * 2).wait;
    };

    0.5.wait;

    // Bass line
    "Bass foundation:".postln;
    [0, 0, 4, 4, 3, 3, 0, 0].do { |deg, i|
        Synth(\tzBass, [
            \freq, ~scaleToFreq.(root - 12, scale, deg),
            \dur, tempo * 0.8,
            \amp, 0.3
        ]);
        tempo.wait;
    };

    0.5.wait;

    // Cajón patterns
    "Cajón rhythm:".postln;
    8.do { |i|
        if(i % 4 == 0) {
            Synth(\tzCajonTone, [\amp, 0.28]);
        };
        if(i % 4 == 2) {
            Synth(\tzCajon, [\amp, 0.24]);
        };
        if([1, 3].includes(i % 4)) {
            Synth(\tzCajon, [\amp, 0.18]);
        };
        (tempo * 0.5).wait;
    };

    0.5.wait;

    // Modern + traditional combined
    "Mixed ensemble:".postln;
    [0, 2, 4, 5, 4, 2, 0, -1, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.28
        ]);
        if(i % 2 == 0) {
            Synth(\tzGardon, [\amp, 0.35]);
            Synth(\tzCajonTone, [\amp, 0.2]);
        } {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.24]);
        };
        if(i % 4 == 0) {
            Synth(\tzBass, [\freq, ~scaleToFreq.(root - 12, scale, 0), \amp, 0.25]);
        };
        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 3: Violin Ornamentation
// Grace notes, slides, and vibrato variations
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.4;

Routine({
    "Experiment 3: Violin Ornamentation".postln;

    // Grace notes
    "Grace notes:".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        if([1, 3, 5].includes(i)) {
            Synth(\tzViolinGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.18
            ]);
        };
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.85,
            \amp, 0.3
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Slides between notes
    "Slides:".postln;
    [[0, 3], [3, 6], [6, 5], [5, 2], [2, 0]].do { |pair|
        Synth(\tzViolinSlide, [
            \freqStart, ~scaleToFreq.(melodyRoot, scale, pair[0]),
            \freqEnd, ~scaleToFreq.(melodyRoot, scale, pair[1]),
            \dur, tempo * 0.7,
            \amp, 0.28
        ]);
        tempo.wait;
    };

    0.6.wait;

    // Vibrato variations
    "Vibrato depth:".postln;
    [0.005, 0.01, 0.015, 0.02, 0.015, 0.01, 0.005].do { |depth, i|
        Synth(\tzViolinLong, [
            \freq, ~scaleToFreq.(melodyRoot, scale, [0, 2, 3, 6, 5, 3, 0][i]),
            \dur, tempo * 1.2,
            \amp, 0.28,
            \vibDepth, depth
        ]);
        (tempo * 1.1).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 4: Lassú (Slow Dance)
// Gentle tempo with expressive phrasing
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 6, 5, 3, 2, 0, -1, 0];
var durs = [1.0, 0.6, 0.8, 1.2, 0.7, 0.6, 0.7, 0.9, 0.8, 1.4];

Routine({
    "Experiment 4: Lassú (Slow Dance)".postln;

    melody.do { |deg, i|
        // Occasional grace notes
        if([2, 5, 8].includes(i)) {
            Synth(\tzViolinGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.16
            ]);
        };

        Synth(\tzViolinLong, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * 0.48,
            \amp, 0.32,
            \vibDepth, 0.015
        ]);

        // Gentle accompaniment
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.2]);
        if(i % 2 == 0) {
            Synth(\tzGuitar, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.16]);
        };

        (durs[i] * 0.5).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 5: Friss (Fast Dance)
// Energetic tempo with tight rhythm section
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;
var tempo = 0.18;
var melody = [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 6, 5, 3, 2, 0];

Routine({
    "Experiment 5: Friss (Fast Dance)".postln;

    melody.do { |deg, i|
        Synth(\tzViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.8,
            \amp, 0.32
        ]);

        // Classic táncház groove: gardon on beats, brácsa on offbeats
        if(i % 2 == 0) {
            Synth(\tzGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.4]);
        } {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };

        // Optional cajón accents
        if(i % 4 == 2) { Synth(\tzCajon, [\amp, 0.2]); };

        tempo.wait;
    };

    0.2.wait;

    // Repeat with more intensity
    "Intensified:".postln;
    melody.do { |deg, i|
        if(i % 3 == 0) {
            Synth(\tzViolinGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.15
            ]);
        };

        Synth(\tzViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.75,
            \amp, 0.34
        ]);

        if(i % 2 == 0) {
            Synth(\tzGardon, [\amp, 0.45]);
            Synth(\tzCajonTone, [\amp, 0.22]);
        } {
            Synth(\tzBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        };

        Synth(\tzFootStomp, [\amp, 0.15]);

        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 6: Regional Contrast - Transylvanian Styles
// Compare different regional scales and feels
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var tempo = 0.28;

Routine({
    "Experiment 6: Regional Contrast".postln;

    // Székely style (Hungarian minor)
    "Székely (Hungarian minor):".postln;
    [0, 2, 3, 6, 5, 3, 2, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, ~hungarianMinor, deg),
            \dur, tempo * 0.9,
            \amp, 0.3
        ]);
        if(i % 2 == 0) { Synth(\tzGardon, [\amp, 0.38]); };
        if(i % 2 == 1) { Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.25]); };
        tempo.wait;
    };

    0.8.wait;

    // Mezőség style (Mixolydian)
    "Mezőség (Mixolydian):".postln;
    [0, 2, 4, 6, 5, 4, 2, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, ~mixolydian, deg),
            \dur, tempo * 0.9,
            \amp, 0.3,
            \vibDepth, 0.008
        ]);
        if(i % 2 == 0) { Synth(\tzGardon, [\amp, 0.38]); };
        if(i % 2 == 1) { Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~mixolydian, 0), \amp, 0.25]); };
        tempo.wait;
    };

    0.8.wait;

    // Kalotaszeg style (Dorian)
    "Kalotaszeg (Dorian):".postln;
    [0, 2, 3, 5, 4, 3, 2, 0].do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, ~dorian, deg),
            \dur, tempo * 0.9,
            \amp, 0.3,
            \vibDepth, 0.01
        ]);
        if(i % 2 == 0) { Synth(\tzGardon, [\amp, 0.38]); };
        if(i % 2 == 1) { Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~dorian, 0), \amp, 0.25]); };
        tempo.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 7: Dance Accompaniment Patterns
// Different rhythmic patterns for various dance types
// ---------------------------------------------------------------------------
(
var root = 48;
var tempo = 0.22;

Routine({
    "Experiment 7: Dance Accompaniment Patterns".postln;

    // Legényes (men's solo) - syncopated
    "Legényes pattern:".postln;
    16.do { |i|
        var pattern = [1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0];
        if(pattern[i] == 1) {
            Synth(\tzGardon, [\amp, 0.42]);
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.26]);
        } {
            Synth(\tzGardonRim, [\amp, 0.2]);
        };
        tempo.wait;
    };

    0.6.wait;

    // Csárdás - even alternation
    "Csárdás pattern:".postln;
    16.do { |i|
        if(i % 2 == 0) {
            Synth(\tzGardon, [\amp, 0.4]);
        } {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.28]);
        };
        tempo.wait;
    };

    0.6.wait;

    // Pontozó (dotted) - long-short pattern
    "Pontozó pattern:".postln;
    8.do { |i|
        Synth(\tzGardon, [\amp, 0.45]);
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.22]);
        (tempo * 1.5).wait;
        Synth(\tzBracsaAccent, [\freq, ~scaleToFreq.(root + 12, ~hungarianMinor, 0), \amp, 0.28]);
        (tempo * 0.5).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 8: Full Táncház Set
// Complete structure: opening, lassú, transition, friss, finale
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    "Experiment 8: Full Táncház Set".postln;

    // =========================================
    // OPENING - instruments enter
    // =========================================
    "Opening...".postln;

    // Gardon establishes pulse
    4.do { |i|
        Synth(\tzGardon, [\amp, 0.35 + (i * 0.02)]);
        0.4.wait;
    };

    // Brácsa joins
    4.do { |i|
        Synth(\tzGardon, [\amp, 0.38]);
        0.15.wait;
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.22 + (i * 0.02)]);
        0.25.wait;
    };

    // Violin enters with opening phrase
    [0, 3, 6, 7, 6, 3, 0].do { |deg, i|
        Synth(\tzViolinLong, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.5,
            \amp, 0.28
        ]);
        Synth(\tzGardon, [\amp, 0.38]);
        0.15.wait;
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.24]);
        0.35.wait;
    };

    0.5.wait;

    // =========================================
    // LASSÚ (Slow section)
    // =========================================
    "Lassú...".postln;

    [
        [0, 1.0], [2, 0.6], [3, 0.8], [6, 1.1],
        [5, 0.7], [3, 0.6], [2, 0.7], [0, 1.2]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 5].includes(i)) {
            Synth(\tzViolinGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.16
            ]);
        };

        Synth(\tzViolinLong, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 0.45,
            \amp, 0.3,
            \vibDepth, 0.014
        ]);

        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.22]);
        if(i % 2 == 0) {
            Synth(\tzGuitar, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.16]);
        };

        (dur * 0.5).wait;
    };

    0.8.wait;

    // =========================================
    // TRANSITION - accelerating
    // =========================================
    "Transition...".postln;

    [0.45, 0.38, 0.32, 0.26, 0.22, 0.2].do { |tempo, i|
        var deg = [0, 2, 3, 6, 5, 3][i];
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 0.9,
            \amp, 0.3
        ]);
        Synth(\tzGardon, [\amp, 0.38 + (i * 0.01)]);
        (tempo * 0.4).wait;
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.24 + (i * 0.01)]);
        (tempo * 0.6).wait;
    };

    0.3.wait;

    // =========================================
    // FRISS (Fast section)
    // =========================================
    "Friss...".postln;

    // First phrase
    [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 6, 5, 3, 2, 0].do { |deg, i|
        Synth(\tzViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.14,
            \amp, 0.32
        ]);

        if(i % 2 == 0) {
            Synth(\tzGardon, [\amp, 0.42]);
        } {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };

        if(i % 4 == 2) { Synth(\tzCajon, [\amp, 0.2]); };

        0.18.wait;
    };

    0.15.wait;

    // Intensified second phrase
    [0, 2, 4, 6, 5, 4, 3, 2, 0, 2, 4, 5, 4, 3, 2, 0].do { |deg, i|
        if(i % 3 == 0) {
            Synth(\tzViolinGrace, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
                \amp, 0.14
            ]);
        };

        Synth(\tzViolinStaccato, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.12,
            \amp, 0.34
        ]);

        if(i % 2 == 0) {
            Synth(\tzGardon, [\amp, 0.45]);
            Synth(\tzCajonTone, [\amp, 0.18]);
        } {
            Synth(\tzBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        };

        Synth(\tzFootStomp, [\amp, 0.12]);

        0.16.wait;
    };

    // =========================================
    // FINALE - triumphant ending
    // =========================================
    0.25.wait;
    "Finale...".postln;

    // Ascending flourish
    [0, 3, 5, 6, 7, 8].do { |deg, i|
        Synth(\tzViolinGrace, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg + 1),
            \amp, 0.15
        ]);
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.22,
            \amp, 0.33
        ]);
        Synth(\tzGardon, [\amp, 0.45]);
        Synth(\tzBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        0.2.wait;
    };

    // Final held note
    Synth(\tzViolinLong, [
        \freq, ~scaleToFreq.(melodyRoot, scale, 0),
        \dur, 1.5,
        \amp, 0.35,
        \vibDepth, 0.018
    ]);
    Synth(\tzGardon, [\amp, 0.5]);
    Synth(\tzBracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
    Synth(\tzCajonTone, [\amp, 0.25]);
    Synth(\tzGuitarChord, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 1.5, \amp, 0.22]);

    1.8.wait;
    "Set complete.".postln;
}).play;
)
