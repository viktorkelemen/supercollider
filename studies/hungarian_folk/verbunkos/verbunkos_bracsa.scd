// ============================================================================
// VERBUNKOS BRÁCSA - Rhythmic Viola Accompaniment
// ============================================================================
// The brácsa (3-stringed viola) provides the rhythmic backbone of Hungarian
// folk ensembles. It plays short, percussive chord "chops" on off-beats,
// creating the driving pulse under the melody.
//
// Characteristics:
// - Very short, dampened strokes
// - 2-3 note chords
// - Off-beat emphasis (the "and" of each beat)
// - Mid-range viola timbre
// - Percussive attack, minimal sustain
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
// BRÁCSA SYNTHDEFS
// ============================================================================
(
// Single brácsa chop (one chord stroke)
SynthDef(\bracsa, {
    |out = 0, freq = 220, amp = 0.3, pan = 0.2|
    var env, sig, chord, scratch;

    // Very short percussive envelope
    env = EnvGen.kr(Env.perc(0.005, 0.08, 1, -8), doneAction: 2);

    // 3-note chord (root, fifth, octave) with slight detuning
    chord = [
        LFSaw.ar(freq * [1, 1.002]),
        LFSaw.ar(freq * 1.498 * [1, 1.001]),  // Fifth (slightly flat for folk character)
        LFSaw.ar(freq * 2.01)                  // Octave
    ].sum;

    // Bow scratch noise on attack
    scratch = HPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.3;

    sig = chord + scratch;

    // Viola body resonance
    sig = BPF.ar(sig, 350, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, 2500);

    // Slight saturation
    sig = (sig * 1.5).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Brácsa with variable chord voicing
SynthDef(\bracsaChord, {
    |out = 0, freq1 = 220, freq2 = 330, freq3 = 440, amp = 0.3, pan = 0.2|
    var env, sig, scratch;

    env = EnvGen.kr(Env.perc(0.005, 0.08, 1, -8), doneAction: 2);

    // Custom 3-note chord
    sig = [
        LFSaw.ar(freq1 * [1, 1.002]),
        LFSaw.ar(freq2 * [1, 1.001]),
        LFSaw.ar(freq3 * [1, 0.999])
    ].sum;

    scratch = HPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.25;
    sig = sig + scratch;

    sig = BPF.ar(sig, 350, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, 2500);
    sig = (sig * 1.5).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Accented brácsa (for strong beats when needed)
SynthDef(\bracsaAccent, {
    |out = 0, freq = 220, amp = 0.4, pan = 0.2|
    var env, sig, chord, scratch;

    // Slightly longer for accent
    env = EnvGen.kr(Env.perc(0.003, 0.12, 1, -6), doneAction: 2);

    chord = [
        LFSaw.ar(freq * [1, 1.003]),
        LFSaw.ar(freq * 1.498 * [1, 1.002]),
        LFSaw.ar(freq * 2.01 * [1, 0.998])
    ].sum;

    scratch = HPF.ar(WhiteNoise.ar, 1200) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.4;
    sig = chord + scratch;

    sig = BPF.ar(sig, 350, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, 3000);
    sig = (sig * 1.8).tanh * 0.65;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Ghost chop (very quiet, for subtle groove)
SynthDef(\bracsaGhost, {
    |out = 0, freq = 220, amp = 0.12, pan = 0.2|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.008, 0.05, 1, -10), doneAction: 2);

    sig = LFSaw.ar(freq * [1, 1.5, 2]).sum;
    sig = BPF.ar(sig, 400, 0.6) * 2;
    sig = LPF.ar(sig, 1800);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Simple bass for accompaniment demos
SynthDef(\bracsaBass, {
    |out = 0, freq = 55, amp = 0.4, dur = 0.3|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
    sig = LPF.ar(sig, 300);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic off-beat chops
// ============================================================================
(
var tempo = 0.25; // sixteenth note

Routine({
    "Basic brácsa off-beat pattern:".postln;

    8.do {
        // Beat 1 - bass only
        Synth(\bracsaBass, [\freq, 48.midicps, \amp, 0.4]);
        tempo.wait;

        // & of 1 - brácsa chop
        Synth(\bracsa, [\freq, 60.midicps, \amp, 0.3]);
        tempo.wait;

        // Beat 2 - bass
        Synth(\bracsaBass, [\freq, 48.midicps, \amp, 0.3]);
        tempo.wait;

        // & of 2 - brácsa chop
        Synth(\bracsa, [\freq, 60.midicps, \amp, 0.35]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Chord changes following harmony
// ============================================================================
(
var tempo = 0.25;
var root = 48;
var scale = ~hungarianMinor;

// Chord progression: i - iv - V - i
var chordRoots = [0, 3, 4, 0];  // C minor context
var bassNotes = [0, 3, 4, 0];

Routine({
    "Brácsa with chord changes:".postln;

    chordRoots.do { |chordRoot, bar|
        var chordFreq = ~scaleToFreq.(root + 12, scale, chordRoot);
        var bassFreq = ~scaleToFreq.(root, scale, bassNotes[bar]);

        2.do {
            // Beat 1
            Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.4]);
            tempo.wait;

            // & of 1
            Synth(\bracsa, [\freq, chordFreq, \amp, 0.3]);
            tempo.wait;

            // Beat 2
            Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.3]);
            tempo.wait;

            // & of 2
            Synth(\bracsa, [\freq, chordFreq, \amp, 0.32]);
            tempo.wait;
        };
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Dotted rhythm pattern (verbunkos style)
// ============================================================================
(
var tempo = 0.2;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Brácsa with dotted verbunkos rhythm:".postln;

    4.do { |bar|
        var chordFreq = ~scaleToFreq.(root + 12, scale, 0);
        var bassFreq = ~scaleToFreq.(root, scale, 0);

        // Beat 1: dotted (bass)
        Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.45]);
        (tempo * 1.5).wait;  // dotted eighth

        // Sixteenth: brácsa
        Synth(\bracsa, [\freq, chordFreq, \amp, 0.25]);
        (tempo * 0.5).wait;

        // Beat 2: brácsa accent
        Synth(\bracsaAccent, [\freq, chordFreq, \amp, 0.35]);
        tempo.wait;

        // & of 2: ghost
        Synth(\bracsaGhost, [\freq, chordFreq, \amp, 0.15]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Accelerando groove (csárdás style)
// ============================================================================
(
var startTempo = 0.3;
var endTempo = 0.12;
var bars = 8;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Accelerating csárdás groove:".postln;

    bars.do { |bar|
        var tempo = startTempo.blend(endTempo, bar / (bars - 1));
        var chordFreq = ~scaleToFreq.(root + 12, scale, 0);
        var bassFreq = ~scaleToFreq.(root, scale, 0);
        var intensity = 0.25 + (bar * 0.02);

        // Beat 1
        Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.4 + (bar * 0.01)]);
        tempo.wait;

        // & of 1
        Synth(\bracsa, [\freq, chordFreq, \amp, intensity]);
        tempo.wait;

        // Beat 2
        Synth(\bracsaBass, [\freq, bassFreq * 1.5, \amp, 0.3]);
        tempo.wait;

        // & of 2
        Synth(\bracsa, [\freq, chordFreq, \amp, intensity + 0.05]);
        tempo.wait;
    };

    // Final accent
    Synth(\bracsaBass, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.5]);
    Synth(\bracsaAccent, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.45]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Full texture (bass + brácsa + simple melody hint)
// ============================================================================
(
SynthDef(\simpleViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.3|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    var sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 500, 0.5) * 2 + (sig * 0.5);
    sig = LPF.ar(sig, freq * 4);
    Out.ar(out, Pan2.ar(sig * env * amp, -0.3));
}).add;
)

(
var tempo = 0.22;
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

var melody = [0, 0, 2, 3, 4, 4, 3, 2, 0, 0, -1, 0];
var melodyDurs = [0.75, 0.25, 0.5, 0.5, 0.75, 0.25, 0.5, 0.5, 0.75, 0.25, 0.5, 1.0];

Routine({
    "Full accompaniment texture:".postln;

    var beatCount = 0;

    melody.do { |deg, i|
        var dur = melodyDurs[i];
        var beats = (dur / 0.5).round.asInteger.max(1);

        // Play melody note
        Synth(\simpleViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * tempo * 2 * 0.9,
            \amp, 0.32
        ]);

        // Accompaniment pattern for duration
        beats.do { |beat|
            var chordFreq = ~scaleToFreq.(root + 12, scale, 0);
            var bassFreq = ~scaleToFreq.(root, scale, 0);

            // Beat
            Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.35]);
            tempo.wait;

            // Off-beat
            Synth(\bracsa, [\freq, chordFreq, \amp, 0.28]);
            tempo.wait;
        };
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Syncopated pattern
// ============================================================================
(
var tempo = 0.15;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Syncopated brácsa pattern:".postln;

    4.do {
        var chordFreq = ~scaleToFreq.(root + 12, scale, 0);
        var bassFreq = ~scaleToFreq.(root, scale, 0);

        // 1
        Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.4]);
        tempo.wait;

        // &
        Synth(\bracsa, [\freq, chordFreq, \amp, 0.3]);
        tempo.wait;

        // 2 - REST (syncopation)
        tempo.wait;

        // & of 2 - accented (syncopation emphasis)
        Synth(\bracsaAccent, [\freq, chordFreq, \amp, 0.4]);
        tempo.wait;

        // 3
        Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.35]);
        tempo.wait;

        // &
        Synth(\bracsa, [\freq, chordFreq, \amp, 0.28]);
        tempo.wait;

        // 4
        Synth(\bracsaGhost, [\freq, chordFreq, \amp, 0.15]);
        tempo.wait;

        // &
        Synth(\bracsa, [\freq, chordFreq, \amp, 0.32]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 7: Three-string voicings
// ============================================================================
(
var tempo = 0.25;
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Different chord voicings:".postln;

    // i chord - root position
    "i chord (root, b3, 5):".postln;
    4.do {
        Synth(\bracsaBass, [\freq, ~scaleToFreq.(root, scale, 0)]);
        tempo.wait;
        Synth(\bracsaChord, [
            \freq1, ~scaleToFreq.(root + 12, scale, 0),
            \freq2, ~scaleToFreq.(root + 12, scale, 2),
            \freq3, ~scaleToFreq.(root + 12, scale, 4),
            \amp, 0.3
        ]);
        tempo.wait;
    };

    0.3.wait;

    // iv chord
    "iv chord:".postln;
    4.do {
        Synth(\bracsaBass, [\freq, ~scaleToFreq.(root, scale, 3)]);
        tempo.wait;
        Synth(\bracsaChord, [
            \freq1, ~scaleToFreq.(root + 12, scale, 3),
            \freq2, ~scaleToFreq.(root + 12, scale, 5),
            \freq3, ~scaleToFreq.(root + 12, scale, 7),
            \amp, 0.3
        ]);
        tempo.wait;
    };

    0.3.wait;

    // V chord (dominant)
    "V chord:".postln;
    4.do {
        Synth(\bracsaBass, [\freq, ~scaleToFreq.(root, scale, 4)]);
        tempo.wait;
        Synth(\bracsaChord, [
            \freq1, ~scaleToFreq.(root + 12, scale, 4),
            \freq2, ~scaleToFreq.(root + 12, scale, 6),
            \freq3, ~scaleToFreq.(root + 12, scale, 8),
            \amp, 0.32
        ]);
        tempo.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 8: Lassú vs Friss comparison
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;

Routine({
    var chordFreq = ~scaleToFreq.(root + 12, scale, 0);
    var bassFreq = ~scaleToFreq.(root, scale, 0);

    // LASSÚ (slow, sparse)
    "Lassú (slow) - sparse accompaniment:".postln;
    4.do {
        Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.35, \dur, 0.5]);
        0.4.wait;
        Synth(\bracsa, [\freq, chordFreq, \amp, 0.25]);
        0.5.wait;
    };

    1.0.wait;

    // FRISS (fast, driving)
    "Friss (fast) - driving accompaniment:".postln;
    16.do { |i|
        var tempo = 0.12;
        var accent = (i % 4 == 0);

        if(i % 2 == 0) {
            Synth(\bracsaBass, [\freq, bassFreq, \amp, if(accent, 0.45, 0.35)]);
        } {
            if(accent) {
                Synth(\bracsaAccent, [\freq, chordFreq, \amp, 0.38]);
            } {
                Synth(\bracsa, [\freq, chordFreq, \amp, 0.3]);
            };
        };
        tempo.wait;
    };

    // Final
    Synth(\bracsaBass, [\freq, bassFreq, \amp, 0.5]);
    Synth(\bracsaAccent, [\freq, chordFreq, \amp, 0.45]);
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
