// ============================================================================
// BAGPIPE VERBUNK / BALLAD CROSSOVER - Studies in Pastoral-Military Fusion
// ============================================================================
// Exploration of the intersection between two Hungarian folk traditions:
// the pastoral bagpipe (duda) tradition and the verbunk (recruiting dance).
//
// The verbunk originated as a military recruitment dance in the 18th-19th
// centuries, characterized by proud strutting movements, heel clicks, and
// a distinctive two-part structure: slow (lassú) opening followed by fast
// (friss) dance. When played on bagpipe, it creates an unusual fusion of
// the instrument's inherently mournful, pastoral character with the martial
// swagger of the dance.
//
// Musical characteristics:
// - Phrygian-dominant (gypsy) scale for exotic color
// - Hungarian minor for dramatic augmented seconds
// - Continuous drone anchoring the harmony
// - Cut ornaments (finger lifts) replacing bowed ornaments
// - Heel clicks and boot slaps marking the rhythm
// - Lament-to-dance arc common in both traditions
// ============================================================================

(
// Hungarian minor: 1 2 b3 #4 5 b6 7 (characteristic augmented second between 3 and 4)
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Phrygian-dominant (gypsy/freygish): 1 b2 3 4 5 b6 b7
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

// Mixolydian b2 (for certain regional variations)
~mixoB2 = [0, 1, 4, 5, 7, 9, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SYNTHDEFS: Bagpipe voices, footwork sounds, reverb
// ---------------------------------------------------------------------------
(
// Main drone - fundamental with fifth
SynthDef(\bpDrone, {
    |out = 0, freq = 110, amp = 0.3, pan = -0.1, gate = 1|
    var env = EnvGen.kr(Env.asr(0.2, 1, 0.8), gate: gate, doneAction: 2);
    var fundamental = Saw.ar(freq) * 0.7 + Pulse.ar(freq, 0.45) * 0.2;
    var fifth = Saw.ar(freq * 1.5) * 0.3 + Pulse.ar(freq * 1.5, 0.4) * 0.15;
    var sig = fundamental + fifth;
    sig = LPF.ar(sig, 700);
    sig = (sig * 1.8).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Deep bass drone - octave below for weight
SynthDef(\bpBassDrone, {
    |out = 0, freq = 55, amp = 0.2, pan = 0, gate = 1|
    var env = EnvGen.kr(Env.asr(0.4, 1, 1.0), gate: gate, doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.7 + Saw.ar(freq) * 0.25 + Pulse.ar(freq * 0.5, 0.5) * 0.15;
    sig = LPF.ar(sig, 350);
    sig = (sig * 1.6).tanh * 0.55;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Main chanter - nasal buzzing tone
SynthDef(\bpChanter, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.6, pan = 0.1,
     nasal = 0.6, buzz = 0.6|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    var sig = Saw.ar(freq) * (0.8 + buzz) + Pulse.ar(freq * 2, 0.4) * 0.3;
    sig = BPF.ar(sig, 650, 0.35) * 2 + BPF.ar(sig, 1800, 0.2) * nasal + sig * 0.3;
    sig = (sig * 1.7).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Long chanter - for sustained lament notes
SynthDef(\bpChanterLong, {
    |out = 0, freq = 440, amp = 0.28, dur = 1.2, pan = 0.1,
     nasal = 0.55, buzz = 0.5, vibrato = 0.01|
    var env = EnvGen.kr(Env.linen(0.02, dur - 0.2, 0.18, 1, -3), doneAction: 2);
    var vib = SinOsc.kr(5.2).range(-vibrato, vibrato) * freq;
    var sig = Saw.ar(freq + vib) * (0.75 + buzz) + Pulse.ar(freq * 2, 0.42) * 0.28;
    sig = BPF.ar(sig, 630, 0.33) * 2.2 + BPF.ar(sig, 1750, 0.22) * nasal + sig * 0.28;
    sig = (sig * 1.6).tanh * 0.58;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Staccato chanter - for quick dance notes
SynthDef(\bpChanterStaccato, {
    |out = 0, freq = 440, amp = 0.32, dur = 0.12, pan = 0.1, buzz = 0.65|
    var env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);
    var sig = Saw.ar(freq) * (0.85 + buzz) + Pulse.ar(freq * 2, 0.5) * 0.35;
    sig = BPF.ar(sig, 680, 0.38) * 2.5 + BPF.ar(sig, 1900, 0.25) * 0.7 + sig * 0.25;
    sig = (sig * 1.85).tanh * 0.55;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Wail chanter - for dramatic ascending cries
SynthDef(\bpChanterWail, {
    |out = 0, freq = 440, freqEnd = 550, amp = 0.26, dur = 0.8, pan = 0.1|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -3), doneAction: 2);
    var freqEnv = EnvGen.kr(Env([freq, freqEnd], [dur], [2]));
    var sig = Saw.ar(freqEnv) * 1.1 + Pulse.ar(freqEnv * 2, 0.45) * 0.35;
    sig = BPF.ar(sig, 700, 0.4) * 2.5 + BPF.ar(sig, 1850, 0.25) * 0.75 + sig * 0.2;
    sig = (sig * 1.7).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Single cut ornament
SynthDef(\bpCut, {
    |out = 0, freq = 440, amp = 0.18, dur = 0.06, pan = 0.1|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    var sig = Pulse.ar(freq * 1.01, 0.5) + HPF.ar(WhiteNoise.ar, 2200) * 0.3;
    sig = LPF.ar(sig, 3200);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Double cut - rapid pair
SynthDef(\bpDoubleCut, {
    |out = 0, freq = 440, amp = 0.15, pan = 0.1|
    var trig = Impulse.kr(0);
    var env1 = EnvGen.kr(Env.perc(0.002, 0.04, 1, -8));
    var env2 = EnvGen.kr(Env.perc(0.002, 0.04, 1, -8), TDelay.kr(trig, 0.045), doneAction: 2);
    var sig1 = Pulse.ar(freq * 1.02, 0.5) * env1;
    var sig2 = Pulse.ar(freq * 0.98, 0.48) * env2;
    var sig = (sig1 + sig2) + HPF.ar(WhiteNoise.ar, 2400) * 0.2 * (env1 + env2);
    sig = LPF.ar(sig, 3400);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Triplet cut - for strong emphasis
SynthDef(\bpTripletCut, {
    |out = 0, freq = 440, amp = 0.13, pan = 0.1|
    var trig = Impulse.kr(0);
    var env1 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8));
    var env2 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8), TDelay.kr(trig, 0.035));
    var env3 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8), TDelay.kr(trig, 0.07), doneAction: 2);
    var sig = (Pulse.ar(freq * 1.03, 0.5) * env1) +
              (Pulse.ar(freq, 0.48) * env2) +
              (Pulse.ar(freq * 0.97, 0.52) * env3);
    sig = sig * 0.7;
    sig = LPF.ar(sig, 3600);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Heel click - sharp military accent
SynthDef(\bpHeel, {
    |out = 0, freq = 1000, amp = 0.28, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, 0.05), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.7 + (SinOsc.ar(freq * 0.35) * EnvGen.kr(Env.perc(0.001, 0.02)));
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Boot stomp - heavy downbeat
SynthDef(\bpStomp, {
    |out = 0, freq = 75, amp = 0.45, pan = 0|
    var env = EnvGen.kr(Env.perc(0.004, 0.16, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.3 + LPF.ar(WhiteNoise.ar, 200) * 0.2;
    sig = LPF.ar(sig, 280);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Boot slap - lighter shuffle step
SynthDef(\bpBootSlap, {
    |out = 0, amp = 0.18, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.07, 1, -8), doneAction: 2);
    var sig = LPF.ar(WhiteNoise.ar, 550) + HPF.ar(WhiteNoise.ar, 1800) * 0.35;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Spur jingle - for virtuosic moments
SynthDef(\bpSpur, {
    |out = 0, freq = 3500, amp = 0.12, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, 0.1, 1, -4), doneAction: 2);
    var sig = BPF.ar(WhiteNoise.ar, freq, 0.15) + BPF.ar(WhiteNoise.ar, freq * 0.7, 0.2) * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Room verb for atmosphere
SynthDef(\bpVerb, {
    |in, out = 0, mix = 0.15, room = 0.6, damp = 0.5|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 1: Scale Comparison
// Explore the two main scales used in verbunk bagpipe music
// ---------------------------------------------------------------------------
(
var root = 55; // G - common bagpipe tuning
var tempo = 0.38;

Routine({
    var drone;
    "Experiment 1: Scale Comparison".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.26]);
    0.5.wait;

    // Hungarian minor - dramatic, exotic
    "Hungarian Minor:".postln;
    (0..7).do { |deg|
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, tempo * 0.85,
            \amp, 0.28
        ]);
        tempo.wait;
    };
    (6..0).do { |deg|
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, tempo * 0.85,
            \amp, 0.26
        ]);
        tempo.wait;
    };

    0.8.wait;

    // Phrygian-dominant (gypsy) - more Eastern flavor
    "Gypsy Scale (Phrygian-dominant):".postln;
    (0..7).do { |deg|
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, ~gypsyScale, deg),
            \dur, tempo * 0.85,
            \amp, 0.28,
            \nasal, 0.7
        ]);
        tempo.wait;
    };
    (6..0).do { |deg|
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, ~gypsyScale, deg),
            \dur, tempo * 0.85,
            \amp, 0.26
        ]);
        tempo.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 2: Drone Textures
// Layer different drone voices for atmospheric depth
// ---------------------------------------------------------------------------
(
var root = 55;

Routine({
    var drone, bassDrone;
    "Experiment 2: Drone Textures".postln;

    // Bass first
    "Deep bass drone...".postln;
    bassDrone = Synth(\bpBassDrone, [\freq, root.midicps * 0.5, \amp, 0.18]);
    1.2.wait;

    // Main drone with fifth
    "Adding main drone...".postln;
    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.24]);
    1.5.wait;

    // Floating melody over thick drones
    "Melody over drones:".postln;
    [0, 3, 6, 7, 6, 5, 3, 2, 0].do { |deg, i|
        Synth(\bpChanterLong, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, 0.65,
            \amp, 0.25,
            \vibrato, 0.012
        ]);
        0.6.wait;
    };

    1.0.wait;
    drone.set(\gate, 0);
    bassDrone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 3: Cut Ornament Vocabulary
// Different ornaments and their musical functions
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var tempo = 0.32;

Routine({
    var drone;
    "Experiment 3: Cut Ornament Vocabulary".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.24]);
    0.4.wait;

    // Single cuts - basic articulation
    "Single cuts:".postln;
    [0, 1, 4, 5, 4, 1, 0].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.16]);
        };
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.0,
            \amp, 0.28
        ]);
        tempo.wait;
    };

    0.5.wait;

    // Double cuts - for emphasis
    "Double cuts:".postln;
    [0, 4, 5, 4, 3, 2, 0].do { |deg, i|
        if([1, 4].includes(i)) {
            Synth(\bpDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.0,
            \amp, 0.28
        ]);
        tempo.wait;
    };

    0.5.wait;

    // Triplet cuts - at climactic moments
    "Triplet cuts at climax:".postln;
    [0, 1, 4, 5, 6, 5, 4, 0].do { |deg, i|
        if(i == 4) { // Peak note gets triplet
            Synth(\bpTripletCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.13]);
        };
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, if(i == 4, tempo * 1.4, tempo * 0.95),
            \amp, if(i == 4, 0.33, 0.27)
        ]);
        tempo.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 4: Lament (Ballad) Style
// Slow, rubato-like phrasing with expressive ornamentation
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var melody = [0, 1, 4, 5, 4, 3, 2, 1, 0, -1, 0];
var durs = [1.0, 0.7, 0.9, 1.2, 0.8, 0.6, 0.7, 0.8, 1.0, 0.9, 1.5];

Routine({
    var drone, bassDrone;
    "Experiment 4: Lament (Ballad) Style".postln;

    bassDrone = Synth(\bpBassDrone, [\freq, root.midicps * 0.5, \amp, 0.15]);
    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.25]);
    1.2.wait;

    "Lament melody:".postln;
    melody.do { |deg, i|
        // Occasional cuts on important notes
        if([2, 5, 8].includes(i)) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };

        Synth(\bpChanterLong, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 0.9,
            \amp, 0.27,
            \vibrato, 0.012,
            \nasal, 0.55
        ]);

        // Rubato - slight random variation
        (durs[i] * rrand(0.88, 1.12)).wait;
    };

    1.5.wait;

    // Wailing close
    "Closing wail:".postln;
    Synth(\bpChanterWail, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \freqEnd, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \amp, 0.26
    ]);
    1.2.wait;

    Synth(\bpChanterLong, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.8,
        \amp, 0.28
    ]);

    2.0.wait;
    drone.set(\gate, 0);
    bassDrone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 5: Verbunk Dance Patterns
// Martial, proud character with heel clicks and stomps
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~hungarianMinor;
var tempo = 0.26;

Routine({
    var drone;
    "Experiment 5: Verbunk Dance Patterns".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.26]);
    0.4.wait;

    // Phrase A - dignified statement
    "Phrase A (dignified):".postln;
    [
        [0, 0.3], [2, 0.3], [3, 0.5], [6, 0.35],
        [5, 0.3], [3, 0.3], [2, 0.5], [0, 0.55]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 6].includes(i)) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.15]);
        };

        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 0.9,
            \amp, 0.29
        ]);

        // Stomp on long notes
        if(dur > 0.45) { Synth(\bpStomp, [\amp, 0.4]); };
        // Heel on short notes
        if(dur < 0.35) { Synth(\bpHeel, [\amp, 0.22]); };

        dur.wait;
    };

    0.4.wait;

    // Phrase B - more animated
    "Phrase B (animated):".postln;
    [
        [0, 0.22], [2, 0.22], [3, 0.22], [6, 0.22],
        [7, 0.35], [6, 0.22], [5, 0.22], [3, 0.22],
        [2, 0.28], [0, 0.45]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if(i % 3 == 1) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };

        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 0.85,
            \amp, 0.28
        ]);

        if(i % 2 == 0) { Synth(\bpHeel, [\amp, 0.2]); };
        if(i == 4) { Synth(\bpStomp, [\amp, 0.45]); };

        dur.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 6: Fast Friss Section
// Quick dance with full footwork pattern
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var tempo = 0.18;
var melody = [0, 1, 4, 4, 3, 2, 1, 0, 0, 1, 4, 5, 4, 3, 2, 1];

Routine({
    var drone;
    "Experiment 6: Fast Friss Section".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.27]);
    0.3.wait;

    // First pass
    "First pass:".postln;
    melody.do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.15]);
        };

        Synth(\bpChanterStaccato, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 0.8,
            \amp, 0.31,
            \buzz, 0.65
        ]);

        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.45]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.24]); };

        tempo.wait;
    };

    0.2.wait;

    // Second pass - intensified
    "Intensified:".postln;
    melody.do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.13]);
        };

        Synth(\bpChanterStaccato, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 0.75,
            \amp, 0.33,
            \buzz, 0.7
        ]);

        // Full footwork
        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.5]); };
        if(i % 4 == 1) { Synth(\bpBootSlap, [\amp, 0.16]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.26]); };
        if(i % 4 == 3) { Synth(\bpBootSlap, [\amp, 0.14, \pan, 0.15]); };

        // Occasional spur jingle
        if(i % 8 == 7) { Synth(\bpSpur, [\amp, 0.1]); };

        tempo.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 7: Call and Response
// Antiphonal phrases typical of verbunk recruiting
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~hungarianMinor;
var tempo = 0.28;

Routine({
    var drone;
    "Experiment 7: Call and Response".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.25]);
    0.5.wait;

    3.do { |round|
        var callMelody, responseMelody;

        // Different call/response pairs each round
        callMelody = [
            [0, 2, 3, 6],
            [0, 3, 6, 7],
            [0, 2, 6, 5]
        ][round];

        responseMelody = [
            [5, 3, 2, 0],
            [6, 5, 3, 0],
            [3, 2, 0, -1, 0]
        ][round];

        // Call - assertive
        ("Round " ++ (round + 1) ++ " - Call:").postln;
        callMelody.do { |deg, i|
            if(i > 0) { Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]); };
            Synth(\bpChanter, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, tempo * 1.1,
                \amp, 0.3,
                \nasal, 0.65
            ]);
            Synth(\bpHeel, [\amp, 0.22]);
            tempo.wait;
        };

        0.2.wait;

        // Response - answering
        "Response:".postln;
        responseMelody.do { |deg, i|
            if(i % 2 == 0) { Synth(\bpDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.12]); };
            Synth(\bpChanter, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, tempo * 1.0,
                \amp, 0.28
            ]);
            if(i == (responseMelody.size - 1)) {
                Synth(\bpStomp, [\amp, 0.45]);
            } {
                Synth(\bpBootSlap, [\amp, 0.15]);
            };
            tempo.wait;
        };

        0.5.wait;
    };

    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 8: Full Piece - Lament to Dance Arc
// Complete structure: Introduction, Lament (Lassú), Transition, Dance (Friss), Coda
// ---------------------------------------------------------------------------
(
var root = 55;
var hungarianScale = ~hungarianMinor;
var gypsyScale = ~gypsyScale;

Routine({
    var drone, bassDrone;
    "Experiment 8: Full Piece - Lament to Dance Arc".postln;

    // =========================================
    // INTRODUCTION - drones emerge
    // =========================================
    "Introduction...".postln;
    bassDrone = Synth(\bpBassDrone, [\freq, root.midicps * 0.5, \amp, 0.14]);
    1.0.wait;
    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.2]);
    1.2.wait;

    // Opening call
    [0, 3, 6, 7, 6, 3, 0].do { |deg, i|
        Synth(\bpChanterLong, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, 0.55,
            \amp, 0.24,
            \vibrato, 0.01
        ]);
        0.5.wait;
    };

    0.8.wait;

    // =========================================
    // LAMENT (Lassú) - mournful, rubato
    // =========================================
    "Lament section...".postln;
    drone.set(\amp, 0.24);

    [
        [0, 1.0], [1, 0.7], [4, 0.9], [5, 1.2],
        [4, 0.7], [3, 0.6], [2, 0.7], [1, 0.8],
        [0, 1.1], [-1, 0.9], [0, 1.4]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 5, 9].includes(i)) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.13]);
        };

        Synth(\bpChanterLong, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, dur * 0.85,
            \amp, 0.27,
            \vibrato, 0.012,
            \nasal, 0.55
        ]);

        (dur * rrand(0.9, 1.1)).wait;
    };

    // Wailing transition
    Synth(\bpChanterWail, [
        \freq, ~scaleToFreq.(root, gypsyScale, 0),
        \freqEnd, ~scaleToFreq.(root, gypsyScale, 5),
        \dur, 1.2,
        \amp, 0.25
    ]);

    1.5.wait;

    // =========================================
    // TRANSITION - accelerating to dance
    // =========================================
    "Transition...".postln;
    [0.5, 0.45, 0.38, 0.32, 0.26, 0.22].do { |tempo, i|
        var deg = [0, 2, 3, 6, 5, 3][i];
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, tempo * 0.9,
            \amp, 0.27 + (i * 0.01)
        ]);
        if(i > 2) {
            Synth(\bpHeel, [\amp, 0.2 + (i * 0.02)]);
        };
        tempo.wait;
    };

    0.3.wait;

    // =========================================
    // FRISS (Fast Dance) - energetic
    // =========================================
    "Friss section...".postln;
    drone.set(\amp, 0.27);
    bassDrone.set(\amp, 0.18);

    // First dance phrase
    [0, 1, 4, 4, 3, 2, 1, 0, 0, 1, 4, 5, 4, 3, 2, 1].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.14]);
        };

        Synth(\bpChanterStaccato, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.14,
            \amp, 0.3,
            \buzz, 0.65
        ]);

        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.45]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.24]); };

        0.18.wait;
    };

    0.2.wait;

    // Intensified repeat
    [0, 1, 4, 5, 6, 5, 4, 3, 2, 1, 0, 1, 4, 3, 2, 0].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpDoubleCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.13]);
        };

        Synth(\bpChanterStaccato, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.12,
            \amp, 0.32,
            \buzz, 0.7
        ]);

        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.5]); };
        if(i % 4 == 1) { Synth(\bpBootSlap, [\amp, 0.16]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.26]); };
        if(i % 4 == 3) { Synth(\bpBootSlap, [\amp, 0.14]); };
        if(i % 8 == 7) { Synth(\bpSpur, [\amp, 0.1]); };

        0.16.wait;
    };

    // =========================================
    // CODA - triumphant finish
    // =========================================
    0.3.wait;
    "Coda...".postln;

    // Ascending flourish
    [0, 4, 5, 6, 7, 8].do { |deg, i|
        Synth(\bpTripletCut, [\freq, ~scaleToFreq.(root, hungarianScale, deg + 1), \amp, 0.12]);
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, 0.22,
            \amp, 0.32 + (i * 0.01)
        ]);
        Synth(\bpStomp, [\amp, 0.4 + (i * 0.03)]);
        0.2.wait;
    };

    // Final held note with big stomp
    Synth(\bpTripletCut, [\freq, ~scaleToFreq.(root, hungarianScale, 1), \amp, 0.14]);
    Synth(\bpChanterLong, [
        \freq, ~scaleToFreq.(root, hungarianScale, 0),
        \dur, 2.0,
        \amp, 0.35,
        \nasal, 0.7
    ]);
    Synth(\bpStomp, [\amp, 0.6]);
    Synth(\bpSpur, [\amp, 0.12]);

    2.2.wait;

    // Drones fade
    drone.set(\gate, 0);
    0.6.wait;
    bassDrone.set(\gate, 0);

    "Piece complete.".postln;
}).play;
)

// ============================================================================
// BOWED STRING (Folk Violin / Hegedű) - Physical Modeling
// ============================================================================
// The hegedű (folk violin) is central to Hungarian verbunk music.
// This physical model captures the scratchy, earthy quality of folk bowing.
// Load from: "../lib/hungarian_folk_core.scd".load;

(
// Physical model bowed string
SynthDef(\verbunkViolin, {
    |out = 0, freq = 420, amp = 0.3, dur = 1, pan = 0, gate = 1,
     bowOffset = 0.0, bowSlope = 0.5, bowPosition = 0.75,
     vibFreq = 5.5, vibGain = 0.008|

    var betaRatio, baseDelay, lastOut, vibrato;
    var neckDelay, neck, bridge, stringFilter, adsr;
    var bridgeRefl, nutRefl, stringVel, velDiff, slope, bowtable, newVel;
    var sig;

    betaRatio = 0.027236 + (0.2 * bowPosition);
    baseDelay = freq.reciprocal;
    lastOut = LocalIn.ar(2);

    vibrato = SinOsc.ar(vibFreq, 0, vibGain);

    neckDelay = (baseDelay * (1.0 - betaRatio)) + (baseDelay * vibrato);
    neck = DelayL.ar(lastOut[0], 0.05, neckDelay);
    bridge = DelayL.ar(lastOut[1], 0.025, baseDelay * betaRatio);

    stringFilter = OnePole.ar(bridge * 0.95, 0.55);

    adsr = amp * EnvGen.kr(
        Env.adsr(0.04, 0.01, 0.9, 0.12),
        gate,
        doneAction: 2
    );

    bridgeRefl = stringFilter.neg;
    nutRefl = neck.neg;
    stringVel = bridgeRefl + nutRefl;
    velDiff = adsr - stringVel;

    slope = 5.0 - (4.0 * bowSlope);
    bowtable = ((((velDiff + bowOffset) * slope) + 0.75).abs).pow(-4).clip(0, 1);
    newVel = velDiff * bowtable;

    LocalOut.ar([bridgeRefl, nutRefl] + newVel);

    // Body resonances for folk violin character
    sig = Resonz.ar(bridge, 500, 0.85) * 0.5;
    sig = sig + Resonz.ar(bridge, 1200, 0.7) * 0.3;
    sig = sig + Resonz.ar(bridge, 3000, 0.5) * 0.15;

    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Sustained bowed string (simpler, for longer notes)
SynthDef(\verbunkViolinSustain, {
    |out = 0, freq = 420, amp = 0.3, pan = 0, gate = 1,
     bowPressure = 0.5, vibRate = 5, vibDepth = 0.01|

    var env, vibrato, sig, body1, body2;

    env = EnvGen.kr(Env.asr(0.08, 1, 0.15), gate, doneAction: 2);

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3)) * freq * vibDepth;

    // Bowed string approximation using filtered saw
    sig = LFSaw.ar(freq + vibrato);
    sig = sig + (LFSaw.ar(freq + vibrato + 0.3) * 0.15);

    // Bow pressure affects brightness
    sig = LPF.ar(sig, freq * (3 + (bowPressure * 5)));

    // Body resonances (folk violin)
    body1 = BPF.ar(sig, 450, 0.4) * 2;
    body2 = BPF.ar(sig, 1100, 0.35) * 1.5;
    sig = sig * 0.4 + body1 + body2;

    // Rosiny scratch texture
    sig = sig + (HPF.ar(PinkNoise.ar, 3000) * 0.02 * bowPressure);

    sig = (sig * 1.4).tanh * 0.65;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Short, percussive bowed attack (for dance rhythms)
SynthDef(\verbunkViolinShort, {
    |out = 0, freq = 420, amp = 0.32, dur = 0.25, pan = 0,
     bowPressure = 0.6, attack = 0.02|

    var env, sig, body1, body2;

    env = EnvGen.kr(Env.perc(attack, dur, 1, -6), doneAction: 2);

    sig = LFSaw.ar(freq);
    sig = sig + (LFSaw.ar(freq * 1.002) * 0.2);

    sig = LPF.ar(sig, freq * (3 + (bowPressure * 4)));

    body1 = BPF.ar(sig, 480, 0.45) * 2.2;
    body2 = BPF.ar(sig, 1150, 0.4) * 1.6;
    sig = sig * 0.35 + body1 + body2;

    // Scratch on attack
    sig = sig + (HPF.ar(WhiteNoise.ar, 2500) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.15);

    sig = (sig * 1.5).tanh * 0.6;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 9: Bowed String Tone Comparison
// ============================================================================
(
var root = 55;
var scale = ~hungarianMinor;

Routine({
    "Experiment 9: Bowed String Tone Comparison".postln;

    // Physical model violin
    "  Physical model (verbunkViolin):".postln;
    [0, 2, 3, 6, 7, 6, 3, 2, 0].do { |deg|
        var synth = Synth(\verbunkViolin, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \amp, 0.3,
            \bowPosition, 0.7
        ]);
        0.4.wait;
        synth.set(\gate, 0);
        0.1.wait;
    };

    0.6.wait;

    // Sustained model
    "  Sustained model (verbunkViolinSustain):".postln;
    [0, 2, 3, 6, 7, 6, 3, 2, 0].do { |deg|
        var synth = Synth(\verbunkViolinSustain, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \amp, 0.3,
            \bowPressure, 0.55,
            \vibRate, 5
        ]);
        0.4.wait;
        synth.set(\gate, 0);
        0.1.wait;
    };

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 10: Violin + Bagpipe Drone Duet
// ============================================================================
(
var root = 55;
var scale = ~hungarianMinor;
var tempo = 0.35;

Routine({
    var drone;

    "Experiment 10: Violin + Bagpipe Drone Duet".postln;

    // Bagpipe drone
    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.2]);
    0.5.wait;

    // Violin melody over drone
    [0, 2, 3, 6, 7, 6, 5, 3, 2, 0, -1, 0].do { |deg, i|
        var dur = [0.4, 0.35, 0.5, 0.6, 0.4, 0.35, 0.4, 0.35, 0.4, 0.5, 0.35, 0.8].at(i);

        Synth(\verbunkViolinShort, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, dur,
            \amp, 0.32,
            \bowPressure, 0.55
        ]);

        dur.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 11: Verbunk Violin Dance Rhythm
// ============================================================================
(
var root = 55;
var scale = ~hungarianMinor;
var tempo = 0.22;

Routine({
    var drone;

    "Experiment 11: Verbunk Violin Dance Rhythm".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.22]);
    Synth(\bpBassDrone, [\freq, root.midicps * 0.5, \amp, 0.15]);
    0.4.wait;

    // Dance phrase with stomps and heel clicks
    2.do { |rep|
        [
            [0, 0.22], [2, 0.22], [3, 0.22], [6, 0.22],
            [7, 0.35], [6, 0.22], [5, 0.22], [3, 0.22],
            [2, 0.28], [0, 0.45]
        ].do { |pair, i|
            var deg = pair[0];
            var dur = pair[1];

            Synth(\verbunkViolinShort, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, dur * 0.9,
                \amp, 0.33 + (rep * 0.02),
                \bowPressure, 0.6
            ]);

            // Footwork
            if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.4]); };
            if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.22]); };

            dur.wait;
        };

        0.2.wait;
    };

    0.5.wait;
    drone.set(\gate, 0);

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 12: Full Verbunk with Violin, Bagpipe, and Footwork
// ============================================================================
(
var root = 55;
var hungarianScale = ~hungarianMinor;
var gypsyScale = ~gypsyScale;

Routine({
    var drone, bassDrone, violin;

    "Experiment 12: Full Verbunk with Violin Accompaniment".postln;

    // =========================================
    // INTRODUCTION - violin and bagpipe together
    // =========================================
    "Introduction...".postln;

    bassDrone = Synth(\bpBassDrone, [\freq, root.midicps * 0.5, \amp, 0.14]);
    0.5.wait;
    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.22]);
    0.8.wait;

    // Violin introduces the theme
    [0, 3, 6, 7, 6, 3, 0].do { |deg, i|
        var synth = Synth(\verbunkViolinSustain, [
            \freq, ~scaleToFreq.(root + 12, hungarianScale, deg),
            \amp, 0.28,
            \vibRate, 5.5,
            \vibDepth, 0.012,
            \bowPressure, 0.5
        ]);
        0.5.wait;
        synth.set(\gate, 0);
        0.08.wait;
    };

    0.6.wait;

    // =========================================
    // LASSÚ - Bagpipe leads, violin sustains drone notes
    // =========================================
    "Lassú section...".postln;

    // Sustained violin drone on tonic
    violin = Synth(\verbunkViolinSustain, [
        \freq, ~scaleToFreq.(root + 12, hungarianScale, 0),
        \amp, 0.18,
        \bowPressure, 0.3,
        \vibRate, 4
    ]);

    [
        [0, 1.0], [1, 0.7], [4, 0.9], [5, 1.2],
        [4, 0.7], [3, 0.6], [2, 0.7], [0, 1.2]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 5].includes(i)) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.13]);
        };

        Synth(\bpChanterLong, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, dur * 0.85,
            \amp, 0.26,
            \vibrato, 0.011,
            \nasal, 0.55
        ]);

        (dur * rrand(0.9, 1.1)).wait;
    };

    violin.set(\gate, 0);
    0.8.wait;

    // =========================================
    // FRISS - Violin and bagpipe alternate
    // =========================================
    "Friss section...".postln;

    drone.set(\amp, 0.25);

    // Violin phrase
    [0, 1, 4, 4, 3, 2, 1, 0].do { |deg, i|
        Synth(\verbunkViolinShort, [
            \freq, ~scaleToFreq.(root + 12, gypsyScale, deg),
            \dur, 0.15,
            \amp, 0.32,
            \bowPressure, 0.6
        ]);

        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.45]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.22]); };

        0.18.wait;
    };

    0.15.wait;

    // Bagpipe response
    [0, 1, 4, 5, 4, 3, 2, 0].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\bpCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.14]);
        };

        Synth(\bpChanterStaccato, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.14,
            \amp, 0.3,
            \buzz, 0.65
        ]);

        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.48]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.24]); };

        0.17.wait;
    };

    0.15.wait;

    // Both together!
    "Violin and bagpipe together:".postln;
    [0, 1, 4, 5, 6, 5, 4, 3, 2, 1, 0].do { |deg, i|
        // Violin
        Synth(\verbunkViolinShort, [
            \freq, ~scaleToFreq.(root + 12, gypsyScale, deg),
            \dur, 0.12,
            \amp, 0.28
        ]);

        // Bagpipe (octave lower, slightly delayed)
        {
            0.02.wait;
            Synth(\bpChanterStaccato, [
                \freq, ~scaleToFreq.(root, gypsyScale, deg),
                \dur, 0.12,
                \amp, 0.26
            ]);
        }.fork;

        // Full footwork
        if(i % 4 == 0) { Synth(\bpStomp, [\amp, 0.5]); };
        if(i % 4 == 1) { Synth(\bpBootSlap, [\amp, 0.16]); };
        if(i % 4 == 2) { Synth(\bpHeel, [\amp, 0.25]); };
        if(i % 4 == 3) { Synth(\bpBootSlap, [\amp, 0.14]); };

        0.16.wait;
    };

    // =========================================
    // CODA - triumphant finish
    // =========================================
    0.3.wait;
    "Coda...".postln;

    // Final flourish - violin leads
    [0, 4, 5, 6, 7].do { |deg, i|
        var synth = Synth(\verbunkViolinSustain, [
            \freq, ~scaleToFreq.(root + 12, hungarianScale, deg),
            \amp, 0.34,
            \bowPressure, 0.7
        ]);

        Synth(\bpStomp, [\amp, 0.45 + (i * 0.03)]);

        0.25.wait;
        synth.set(\gate, 0);
    };

    // Final chord - violin and bagpipe unison
    Synth(\bpTripletCut, [\freq, ~scaleToFreq.(root, hungarianScale, 1), \amp, 0.14]);

    Synth(\verbunkViolinSustain, [
        \freq, ~scaleToFreq.(root + 12, hungarianScale, 0),
        \amp, 0.35,
        \bowPressure, 0.6
    ]);

    Synth(\bpChanterLong, [
        \freq, ~scaleToFreq.(root, hungarianScale, 0),
        \dur, 2.0,
        \amp, 0.32,
        \nasal, 0.7
    ]);

    Synth(\bpStomp, [\amp, 0.6]);
    Synth(\bpSpur, [\amp, 0.12]);

    2.2.wait;

    // Drones fade
    drone.set(\gate, 0);
    0.6.wait;
    bassDrone.set(\gate, 0);

    "Piece complete.".postln;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
