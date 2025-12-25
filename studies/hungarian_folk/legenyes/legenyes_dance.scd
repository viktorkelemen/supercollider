// ============================================================================
// LEGÉNYES - Transylvanian Men's Solo Dance
// ============================================================================
// Legényes ("lad's dance") is the most virtuosic Eastern European dance.
// Performed solo by men in front of the band, showcasing athletic ability.
//
// Characteristics:
// - Improvised, freestyle structure
// - Complex rhythmic patterns with syncopation
// - Athletic movements: jumping, spinning, heel-clicking, thigh-slapping
// - Fast tempo, driving energy
// - Transylvanian origin (Kalotaszeg, Mezőség regions)
// - Women stand aside singing verses
// - Call-and-response between dancer and band
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
// Transylvanian mode (slightly different character)
~transylvanianMode = [0, 2, 3, 5, 7, 8, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR LEGÉNYES
// ============================================================================
(
// Driving violin - short, punchy, rhythmic
SynthDef(\legenyViolin, {
    |out = 0, freq = 440, amp = 0.35, dur = 0.15, pan = -0.2|
    var env, sig, formant;

    env = EnvGen.kr(Env.perc(0.008, dur, 1, -6), doneAction: 2);

    sig = LFSaw.ar(freq);
    formant = BPF.ar(sig, 500, 0.4) * 2;
    sig = sig + formant;
    sig = LPF.ar(sig, freq * 4);
    sig = (sig * 1.5).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Accented violin (for rhythmic emphasis)
SynthDef(\legenyAccent, {
    |out = 0, freq = 440, amp = 0.4, dur = 0.2, pan = -0.2|
    var env, sig, formant;

    env = EnvGen.kr(Env.perc(0.003, dur, 1, -4), doneAction: 2);

    sig = LFSaw.ar(freq) + (Pulse.ar(freq, 0.3) * 0.3);
    formant = BPF.ar(sig, 500, 0.35) * 2.5;
    sig = sig + formant;
    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.8).tanh * 0.65;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Brácsa - heavy rhythmic chop (Transylvanian style)
SynthDef(\legenyBracsa, {
    |out = 0, freq = 220, amp = 0.35, pan = 0.3|
    var env, sig, scratch;

    env = EnvGen.kr(Env.perc(0.003, 0.06, 1, -10), doneAction: 2);

    sig = [
        LFSaw.ar(freq * [1, 1.003]),
        LFSaw.ar(freq * 1.5),
        LFSaw.ar(freq * 2.02)
    ].sum;

    scratch = HPF.ar(WhiteNoise.ar, 2000) * EnvGen.kr(Env.perc(0.001, 0.015)) * 0.4;
    sig = sig + scratch;
    sig = BPF.ar(sig, 400, 0.5) * 2 + (sig * 0.3);
    sig = LPF.ar(sig, 2200);
    sig = (sig * 2).tanh * 0.6;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Gardon (struck cello) - percussive, Transylvanian
SynthDef(\legenyGardon, {
    |out = 0, freq = 80, amp = 0.45|
    var env, sig, strike;

    env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);

    // Low string thump
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.4);

    // Percussive strike
    strike = HPF.ar(WhiteNoise.ar, 300) * EnvGen.kr(Env.perc(0.001, 0.02));
    sig = sig + (strike * 0.5);

    sig = LPF.ar(sig, 400);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Boot stomp / heel click
SynthDef(\legenyClick, {
    |out = 0, freq = 1200, amp = 0.3|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.001, 0.04), doneAction: 2);

    sig = HPF.ar(WhiteNoise.ar, freq) * 0.7;
    sig = sig + (SinOsc.ar(freq * 0.3) * EnvGen.kr(Env.perc(0.001, 0.02)));

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Thigh slap
SynthDef(\legenySlap, {
    |out = 0, amp = 0.35|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.001, 0.06), doneAction: 2);

    sig = LPF.ar(WhiteNoise.ar, 800) * 0.6;
    sig = sig + (SinOsc.ar(150) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.4);

    Out.ar(out, Pan2.ar(sig * env * amp, rrand(-0.2, 0.2)));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic legényes rhythm
// ============================================================================
(
var tempo = 0.12;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Basic legényes rhythm:".postln;

    16.do { |i|
        var accent = (i % 4 == 0);

        // Violin melody
        if(accent) {
            Synth(\legenyAccent, [
                \freq, ~scaleToFreq.(root + 12, scale, [0, 4, 0, 4].wrapAt(i/4)),
                \amp, 0.4
            ]);
        } {
            Synth(\legenyViolin, [
                \freq, ~scaleToFreq.(root + 12, scale, [0, 2, 4, 2].wrapAt(i)),
                \amp, 0.3
            ]);
        };

        // Gardon on beats
        if(i % 2 == 0) {
            Synth(\legenyGardon, [\amp, if(accent, 0.5, 0.4)]);
        };

        // Brácsa on off-beats
        if(i % 2 == 1) {
            Synth(\legenyBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, 0.32
            ]);
        };

        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Syncopated pattern with heel clicks
// ============================================================================
(
var tempo = 0.1;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Syncopated legényes with heel clicks:".postln;

    4.do { |bar|
        // 1
        Synth(\legenyAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.42]);
        Synth(\legenyGardon, [\amp, 0.5]);
        tempo.wait;

        // &
        Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        tempo.wait;

        // 2 - syncopated accent
        Synth(\legenyClick, [\freq, 1400, \amp, 0.35]);
        (tempo * 0.5).wait;
        Synth(\legenyViolin, [\freq, ~scaleToFreq.(root + 12, scale, 2), \amp, 0.35]);
        (tempo * 0.5).wait;

        // &
        Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
        Synth(\legenyClick, [\freq, 1200, \amp, 0.28]);
        tempo.wait;

        // 3
        Synth(\legenyViolin, [\freq, ~scaleToFreq.(root + 12, scale, 4), \amp, 0.38]);
        Synth(\legenyGardon, [\amp, 0.45]);
        tempo.wait;

        // &
        Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        tempo.wait;

        // 4
        Synth(\legenySlap, [\amp, 0.38]);
        tempo.wait;

        // &
        Synth(\legenyClick, [\freq, 1300, \amp, 0.32]);
        Synth(\legenyClick, [\freq, 1100, \amp, 0.25]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Virtuosic melodic phrase
// ============================================================================
(
var tempo = 0.08;
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Fast, intricate melody
var melody = [0, 2, 4, 4, 3, 4, 6, 4, 3, 2, 0, 0, 2, 4, 3, 2, 0, -1, 0, 0];
var accents = [0, 4, 8, 12, 16];

Routine({
    "Virtuosic legényes melody:".postln;

    melody.do { |deg, i|
        var isAccent = accents.includes(i);

        if(isAccent) {
            Synth(\legenyAccent, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \amp, 0.42,
                \dur, tempo * 2
            ]);
            Synth(\legenyGardon, [\amp, 0.48]);
        } {
            Synth(\legenyViolin, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \amp, 0.32,
                \dur, tempo * 1.5
            ]);
        };

        if(i % 2 == 1) {
            Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.28]);
        };

        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Call and response (dancer vs band)
// ============================================================================
(
var tempo = 0.11;
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    "Call and response:".postln;

    2.do {
        // CALL: Dancer's phrase (clicks, slaps, stomps)
        "  Dancer:".postln;
        Synth(\legenyClick, [\freq, 1400, \amp, 0.4]);
        tempo.wait;
        Synth(\legenyClick, [\freq, 1200, \amp, 0.35]);
        tempo.wait;
        Synth(\legenySlap, [\amp, 0.4]);
        tempo.wait;
        Synth(\legenyClick, [\freq, 1300, \amp, 0.38]);
        Synth(\legenyClick, [\freq, 1100, \amp, 0.3]);
        tempo.wait;

        // RESPONSE: Band's phrase
        "  Band:".postln;
        4.do { |i|
            Synth(\legenyAccent, [
                \freq, ~scaleToFreq.(melodyRoot, scale, [4, 3, 2, 0].at(i)),
                \amp, 0.4
            ]);
            Synth(\legenyGardon, [\amp, 0.45]);
            (tempo * 0.5).wait;
            Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
            (tempo * 0.5).wait;
        };

        0.2.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 5: Acceleration towards climax
// ============================================================================
(
var startTempo = 0.14;
var endTempo = 0.07;
var steps = 24;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Legényes acceleration:".postln;

    steps.do { |i|
        var tempo = startTempo.blend(endTempo, i / (steps - 1));
        var intensity = i.linlin(0, steps - 1, 0.3, 0.5);
        var deg = [0, 4, 3, 4, 0, 2].wrapAt(i);

        // Violin
        if(i % 4 == 0) {
            Synth(\legenyAccent, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \amp, intensity + 0.08
            ]);
        } {
            Synth(\legenyViolin, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \amp, intensity
            ]);
        };

        // Gardon
        if(i % 2 == 0) {
            Synth(\legenyGardon, [\amp, intensity + 0.1]);
        } {
            Synth(\legenyBracsa, [
                \freq, ~scaleToFreq.(root + 12, scale, 0),
                \amp, intensity - 0.05
            ]);
        };

        // Add clicks as intensity builds
        if(i > 16 && (i % 3 == 0)) {
            Synth(\legenyClick, [\freq, rrand(1000, 1400), \amp, 0.3]);
        };

        tempo.wait;
    };

    // Final flourish
    4.do {
        Synth(\legenyAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.5]);
        Synth(\legenyGardon, [\amp, 0.55]);
        Synth(\legenyClick, [\freq, 1300, \amp, 0.4]);
        0.06.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Athletic sequence (jumps, spins, clicks)
// ============================================================================
(
var tempo = 0.09;

Routine({
    "Athletic dance sequence:".postln;

    // Jump preparation
    "  Preparation...".postln;
    3.do {
        Synth(\legenyGardon, [\amp, 0.4]);
        tempo.wait;
        Synth(\legenyBracsa, [\freq, 220, \amp, 0.3]);
        tempo.wait;
    };

    // JUMP (silence then stomp)
    "  Jump!".postln;
    (tempo * 2).wait;  // Airborne - silence
    Synth(\legenyGardon, [\freq, 60, \amp, 0.6]);  // Landing
    Synth(\legenySlap, [\amp, 0.5]);
    tempo.wait;

    // Rapid heel clicks (spinning)
    "  Spin with clicks...".postln;
    8.do { |i|
        Synth(\legenyClick, [\freq, 1000 + (i * 50), \amp, 0.35]);
        (tempo * 0.5).wait;
    };

    // Finale clicks
    "  Finale!".postln;
    Synth(\legenyClick, [\freq, 1400, \amp, 0.45]);
    Synth(\legenyClick, [\freq, 1200, \amp, 0.4]);
    0.05.wait;
    Synth(\legenyClick, [\freq, 1300, \amp, 0.42]);
    0.05.wait;
    Synth(\legenyGardon, [\freq, 50, \amp, 0.6]);
    Synth(\legenySlap, [\amp, 0.5]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Full legényes phrase
// ============================================================================
(
var tempo = 0.1;
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

Routine({
    "=== Full Legényes Phrase ===".postln;

    // Opening: Band sets the groove
    "Opening groove:".postln;
    8.do { |i|
        if(i % 2 == 0) {
            Synth(\legenyGardon, [\amp, 0.45]);
            if(i % 4 == 0) {
                Synth(\legenyAccent, [
                    \freq, ~scaleToFreq.(melodyRoot, scale, 0),
                    \amp, 0.4
                ]);
            };
        } {
            Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
        };
        tempo.wait;
    };

    // Dancer enters with clicks
    "Dancer enters:".postln;
    4.do { |i|
        Synth(\legenyClick, [\freq, [1200, 1400, 1100, 1300].at(i), \amp, 0.38]);
        Synth(\legenyGardon, [\amp, 0.4]);
        tempo.wait;
        Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        tempo.wait;
    };

    // Virtuosic passage
    "Virtuosic passage:".postln;
    var melody = [0, 2, 4, 6, 4, 3, 2, 0, 4, 3, 2, 0];
    melody.do { |deg, i|
        Synth(\legenyViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \amp, 0.35
        ]);
        if(i % 2 == 0) { Synth(\legenyGardon, [\amp, 0.42]) };
        (tempo * 0.8).wait;
    };

    // Building intensity
    "Building:".postln;
    8.do { |i|
        var fast = tempo * (1 - (i * 0.05));
        Synth(\legenyAccent, [
            \freq, ~scaleToFreq.(melodyRoot, scale, [0, 4].wrapAt(i)),
            \amp, 0.4 + (i * 0.01)
        ]);
        Synth(\legenyGardon, [\amp, 0.45 + (i * 0.01)]);
        if(i > 4) { Synth(\legenyClick, [\freq, rrand(1100, 1400), \amp, 0.3]) };
        fast.wait;
    };

    // Climax
    "Climax!".postln;
    4.do {
        Synth(\legenyAccent, [\freq, ~scaleToFreq.(melodyRoot, scale, 0), \amp, 0.5]);
        Synth(\legenyGardon, [\amp, 0.55]);
        Synth(\legenyBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.4]);
        Synth(\legenyClick, [\freq, 1300, \amp, 0.4]);
        0.08.wait;
    };

    // Final pose
    Synth(\legenySlap, [\amp, 0.5]);
    Synth(\legenyGardon, [\freq, 50, \amp, 0.6]);

    "=== End ===".postln;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
