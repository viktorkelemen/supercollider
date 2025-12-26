// ============================================================================
// DUDÁS STYLE DANCE - Hungarian Bagpipe (Duda) Studies
// ============================================================================
// Exploration of the duda (Hungarian bagpipe) tradition from the Palóc
// and Matyó regions. The duda is characterized by its continuous drone,
// nasal buzzing chanter, and percussive "cut" ornaments (quick finger lifts).
//
// The instrument typically plays in either Hungarian minor or Phrygian-
// dominant (gypsy) scale, with the drone providing a constant tonal anchor.
// Dance accompaniment features heavy stomping and heel-click rhythms.
//
// Key acoustic features:
// - Drone pipes: usually tuned in fifths (tonic + fifth)
// - Chanter: nasal buzz from double reed, strong harmonics 600-1800 Hz
// - Cuts: brief pitch spikes from momentary finger lifts
// - Circular breathing allows continuous sound
// ============================================================================

(
// Hungarian minor: 1 2 b3 #4 5 b6 7 (characteristic augmented second)
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Phrygian-dominant (gypsy scale): 1 b2 3 4 5 b6 b7
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

// Dorian for comparison (used in some regions)
~dorianScale = [0, 2, 3, 5, 7, 9, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SYNTHDEFS: Duda drone, chanter variants, cuts, stomps, heel-clicks
// ---------------------------------------------------------------------------
(
// Primary drone - continuous bass with fifth
SynthDef(\dudaDrone, {
    |out = 0, freq = 110, amp = 0.28, pan = -0.1, gate = 1|
    var env = EnvGen.kr(Env.asr(0.3, 1, 0.8), gate: gate, doneAction: 2);
    var fundamental = Saw.ar(freq) * 0.6 + Pulse.ar(freq, 0.45) * 0.25;
    var fifth = Saw.ar(freq * 1.5) * 0.35 + Pulse.ar(freq * 1.5, 0.4) * 0.15;
    var sig = fundamental + fifth;
    sig = LPF.ar(sig, 800);
    sig = (sig * 2).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Deep drone - octave below for weight
SynthDef(\dudaDeepDrone, {
    |out = 0, freq = 55, amp = 0.22, pan = 0, gate = 1|
    var env = EnvGen.kr(Env.asr(0.5, 1, 1.0), gate: gate, doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.7 + Saw.ar(freq) * 0.3;
    sig = LPF.ar(sig, 400);
    sig = (sig * 1.5).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Main chanter - nasal buzzing tone
SynthDef(\dudaChanter, {
    |out = 0, freq = 440, amp = 0.28, dur = 0.4, pan = 0.1,
     buzz = 0.5, nasal = 0.6, vibrato = 0.0|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    var vib = SinOsc.kr(6).range(-vibrato, vibrato) * freq;
    var sig = Saw.ar(freq + vib) * (0.7 + buzz) + Pulse.ar(freq * 2, 0.4) * 0.3;
    // Nasal resonance bands characteristic of duda
    sig = BPF.ar(sig, 600, 0.3) * 2 + BPF.ar(sig, 1800, 0.2) * nasal + sig * 0.3;
    sig = (sig * 1.6).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Long chanter - for sustained melodic phrases
SynthDef(\dudaChanterLong, {
    |out = 0, freq = 440, amp = 0.26, dur = 1.0, pan = 0.1,
     buzz = 0.5, nasal = 0.6, vibrato = 0.008|
    var env = EnvGen.kr(Env.linen(0.02, dur - 0.15, 0.12, 1, -3), doneAction: 2);
    var vib = SinOsc.kr(5.5).range(-vibrato, vibrato) * freq;
    var sig = Saw.ar(freq + vib) * (0.7 + buzz) + Pulse.ar(freq * 2, 0.42) * 0.28;
    sig = BPF.ar(sig, 620, 0.32) * 2.2 + BPF.ar(sig, 1750, 0.22) * nasal + sig * 0.28;
    sig = (sig * 1.5).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Staccato chanter - for quick dance notes
SynthDef(\dudaChanterStaccato, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.15, pan = 0.1, buzz = 0.6|
    var env = EnvGen.kr(Env.perc(0.005, dur, 1, -6), doneAction: 2);
    var sig = Saw.ar(freq) * (0.8 + buzz) + Pulse.ar(freq * 2, 0.5) * 0.35;
    sig = BPF.ar(sig, 650, 0.35) * 2.5 + BPF.ar(sig, 1900, 0.25) * 0.7 + sig * 0.25;
    sig = (sig * 1.8).tanh * 0.55;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Cut ornament - brief pitch spike from finger lift
SynthDef(\dudaCut, {
    |out = 0, freq = 440, amp = 0.18, dur = 0.05, pan = 0.1|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    var sig = Pulse.ar(freq * 1.01, 0.5) + HPF.ar(WhiteNoise.ar, 2000) * 0.3;
    sig = LPF.ar(sig, 3000);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Double cut - two rapid ornaments
SynthDef(\dudaDoubleCut, {
    |out = 0, freq = 440, amp = 0.16, pan = 0.1|
    var env1 = EnvGen.kr(Env.perc(0.002, 0.035, 1, -8));
    var env2 = EnvGen.kr(Env.perc(0.002, 0.035, 1, -8), TDelay.kr(Impulse.kr(0), 0.04), doneAction: 2);
    var sig1 = Pulse.ar(freq * 1.02, 0.5) * env1;
    var sig2 = Pulse.ar(freq * 0.99, 0.48) * env2;
    var sig = (sig1 + sig2) + HPF.ar(WhiteNoise.ar, 2200) * 0.2 * (env1 + env2);
    sig = LPF.ar(sig, 3200);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Triplet cut - three rapid ornaments for emphasis
SynthDef(\dudaTripletCut, {
    |out = 0, freq = 440, amp = 0.14, pan = 0.1|
    var trig = Impulse.kr(0);
    var env1 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8));
    var env2 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8), TDelay.kr(trig, 0.035));
    var env3 = EnvGen.kr(Env.perc(0.002, 0.03, 1, -8), TDelay.kr(trig, 0.07), doneAction: 2);
    var sig1 = Pulse.ar(freq * 1.03, 0.5) * env1;
    var sig2 = Pulse.ar(freq, 0.48) * env2;
    var sig3 = Pulse.ar(freq * 0.97, 0.52) * env3;
    var sig = (sig1 + sig2 + sig3) * 0.7;
    sig = LPF.ar(sig, 3500);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Foot stomp - heavy downbeat
SynthDef(\dudaStomp, {
    |out = 0, freq = 70, amp = 0.5|
    var env = EnvGen.kr(Env.perc(0.005, 0.18, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.25;
    sig = LPF.ar(sig, 300);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Heel click - lighter accent
SynthDef(\dudaHeel, {
    |out = 0, freq = 1200, amp = 0.25|
    var env = EnvGen.kr(Env.perc(0.001, 0.04), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.6 + BPF.ar(WhiteNoise.ar, freq * 1.5, 0.3) * 0.4;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Boot slap - shuffle step sound
SynthDef(\dudaBootSlap, {
    |out = 0, amp = 0.2, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.08, 1, -8), doneAction: 2);
    var sig = LPF.ar(WhiteNoise.ar, 600) + HPF.ar(WhiteNoise.ar, 2000) * 0.3;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Breath pulse - simulates bag pressure variation
SynthDef(\dudaBreathPulse, {
    |out = 0, freq = 0.8, depth = 0.1, amp = 1|
    var pulse = SinOsc.kr(freq, 0, depth, 1 - (depth * 0.5));
    Out.kr(out, pulse * amp);
}).add;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 1: Scale Exploration
// Compare the characteristic scales used in duda music
// ---------------------------------------------------------------------------
(
var root = 55; // G below middle C - common duda tuning
var tempo = 0.35;

Routine({
    var drone;
    "Experiment 1: Scale Exploration".postln;
    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.25]);
    0.5.wait;

    // Hungarian minor ascending and descending
    "Hungarian Minor scale:".postln;
    (0..7).do { |deg|
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, tempo * 0.9,
            \amp, 0.28,
            \buzz, 0.55
        ]);
        tempo.wait;
    };
    (6..0).do { |deg|
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, tempo * 0.9,
            \amp, 0.26
        ]);
        tempo.wait;
    };

    0.8.wait;

    // Gypsy scale (Phrygian-dominant)
    "Gypsy (Phrygian-dominant) scale:".postln;
    (0..7).do { |deg|
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, ~gypsyScale, deg),
            \dur, tempo * 0.9,
            \amp, 0.28,
            \buzz, 0.6,
            \nasal, 0.7
        ]);
        tempo.wait;
    };
    (6..0).do { |deg|
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, ~gypsyScale, deg),
            \dur, tempo * 0.9,
            \amp, 0.26
        ]);
        tempo.wait;
    };

    0.5.wait;
    drone.free;
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 2: Drone Harmonics & Combinations
// Layer different drone voices for rich harmonic bed
// ---------------------------------------------------------------------------
(
var root = 55;

Routine({
    var drone1, drone2, deepDrone;
    "Experiment 2: Drone Harmonics".postln;

    // Start with deep bass
    "Adding deep drone...".postln;
    deepDrone = Synth(\dudaDeepDrone, [\freq, root.midicps * 0.5, \amp, 0.2]);
    1.0.wait;

    // Add main drone with fifth
    "Adding main drone with fifth...".postln;
    drone1 = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.25, \pan, -0.15]);
    1.5.wait;

    // Brief melodic fragment over drones
    "Melodic fragment:".postln;
    [0, 2, 4, 5, 4, 2, 0].do { |deg, i|
        Synth(\dudaChanterLong, [
            \freq, ~scaleToFreq.(root, ~hungarianMinor, deg),
            \dur, 0.5,
            \amp, 0.26
        ]);
        0.45.wait;
    };

    1.0.wait;
    deepDrone.set(\gate, 0);
    drone1.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 3: Cut Ornament Variations
// Different types of cuts and their musical application
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var tempo = 0.3;

Routine({
    var drone;
    "Experiment 3: Cut Ornament Variations".postln;
    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.24]);
    0.4.wait;

    // Single cuts on offbeats
    "Single cuts:".postln;
    [0, 1, 4, 5, 4, 1, 0].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.15]);
        };
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.1,
            \amp, 0.28
        ]);
        tempo.wait;
    };

    0.5.wait;

    // Double cuts for emphasis
    "Double cuts:".postln;
    [0, 4, 3, 2, 1, 0].do { |deg, i|
        if([1, 4].includes(i)) {
            Synth(\dudaDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.1,
            \amp, 0.28
        ]);
        tempo.wait;
    };

    0.5.wait;

    // Triplet cuts at phrase climax
    "Triplet cuts:".postln;
    [0, 1, 4, 5, 4, 3, 2, 0].do { |deg, i|
        if(i == 3) { // Triplet at the peak
            Synth(\dudaTripletCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.13]);
        };
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.1,
            \amp, if(i == 3, 0.32, 0.27)
        ]);
        tempo.wait;
    };

    0.5.wait;
    drone.free;
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 4: Slow Lament (Lassú)
// Slower, more expressive playing with long notes and subtle vibrato
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 6, 5, 3, 2, 0, -1, 0];
var durs = [1.0, 0.6, 0.8, 1.2, 0.7, 0.6, 0.8, 1.0, 0.9, 1.5];

Routine({
    var drone, deepDrone;
    "Experiment 4: Slow Lament (Lassú)".postln;

    deepDrone = Synth(\dudaDeepDrone, [\freq, root.midicps * 0.5, \amp, 0.18]);
    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.22]);
    1.0.wait;

    "Lament melody:".postln;
    melody.do { |deg, i|
        // Occasional cut before important notes
        if([2, 5, 8].includes(i)) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.12]);
        };

        Synth(\dudaChanterLong, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 0.85,
            \amp, 0.28,
            \vibrato, 0.01,  // Subtle vibrato
            \nasal, 0.55
        ]);

        (durs[i] * rrand(0.95, 1.05)).wait;  // Slight rubato
    };

    1.5.wait;
    deepDrone.set(\gate, 0);
    drone.set(\gate, 0);
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 5: Fast Dance (Friss)
// Quick 2/4 dance with stomps and heel clicks
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var tempo = 0.18;
var melody = [0, 1, 4, 4, 3, 2, 1, 0, 0, 1, 4, 5, 4, 3, 2, 1];

Routine({
    var drone;
    "Experiment 5: Fast Dance (Friss)".postln;

    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.26]);
    0.3.wait;

    "Fast dance:".postln;
    melody.do { |deg, i|
        // Cuts on offbeats
        if(i % 2 == 1) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.15]);
        };

        Synth(\dudaChanterStaccato, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 0.8,
            \amp, 0.3,
            \buzz, 0.65
        ]);

        // Stomps on beat 1 of each bar
        if(i % 4 == 0) {
            Synth(\dudaStomp, [\amp, 0.5]);
        };

        // Heel clicks on beat 2
        if(i % 4 == 2) {
            Synth(\dudaHeel, [\amp, 0.22]);
        };

        tempo.wait;
    };

    // Repeat with more intensity
    0.2.wait;
    "Repeat with intensity:".postln;
    melody.do { |deg, i|
        if(i % 2 == 1) {
            Synth(\dudaDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };

        Synth(\dudaChanterStaccato, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 0.75,
            \amp, 0.32,
            \buzz, 0.7
        ]);

        // More active footwork
        if(i % 4 == 0) { Synth(\dudaStomp, [\amp, 0.55]); };
        if(i % 4 == 1) { Synth(\dudaBootSlap, [\amp, 0.18]); };
        if(i % 4 == 2) { Synth(\dudaHeel, [\amp, 0.25]); };
        if(i % 4 == 3) { Synth(\dudaBootSlap, [\amp, 0.15, \pan, 0.2]); };

        tempo.wait;
    };

    0.5.wait;
    drone.free;
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 6: Regional Variation - Matyó Style
// More ornamented, virtuosic playing from the Matyó region
// ---------------------------------------------------------------------------
(
var root = 57; // Slightly higher tuning
var scale = ~gypsyScale;
var tempo = 0.25;

Routine({
    var drone;
    "Experiment 6: Matyó Regional Style".postln;

    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.25]);
    0.4.wait;

    // Matyó characteristic: heavy ornamentation
    "Ornamented phrase 1:".postln;
    [
        [0, \single], [1, \double], [4, \single], [5, \triplet],
        [4, \single], [3, \double], [2, \single], [1, \none], [0, \single]
    ].do { |pair|
        var deg = pair[0];
        var ornament = pair[1];

        switch(ornament,
            \single, { Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]); },
            \double, { Synth(\dudaDoubleCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.13]); },
            \triplet, { Synth(\dudaTripletCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.12]); }
        );

        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.0,
            \amp, 0.29,
            \buzz, 0.6,
            \nasal, 0.7
        ]);

        tempo.wait;
    };

    0.4.wait;

    // Faster virtuosic passage
    "Virtuosic run:".postln;
    [0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0].do { |deg, i|
        Synth(\dudaChanterStaccato, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.1,
            \amp, 0.28
        ]);
        if(i % 3 == 0) { Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.12]); };
        0.12.wait;
    };

    0.6.wait;
    drone.free;
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 7: Verbunk Rhythm (Recruiting Dance)
// The verbunk was a recruiting dance - martial, proud character
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~hungarianMinor;
var tempo = 0.28;

Routine({
    var drone;
    "Experiment 7: Verbunk (Recruiting Dance)".postln;

    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.26]);
    0.5.wait;

    // Verbunk has a proud, strutting quality
    // Phrase A - statement
    "Phrase A:".postln;
    [
        [0, 0.3], [2, 0.3], [3, 0.6], [6, 0.3],
        [5, 0.3], [3, 0.3], [2, 0.6], [0, 0.5]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 6].includes(i)) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.15]);
        };

        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 0.9,
            \amp, 0.29
        ]);

        // Proud stomps on long notes
        if(dur > 0.4) { Synth(\dudaStomp, [\amp, 0.45]); };

        dur.wait;
    };

    0.3.wait;

    // Phrase B - response with more motion
    "Phrase B:".postln;
    [
        [0, 0.2], [2, 0.2], [3, 0.2], [6, 0.2],
        [7, 0.4], [6, 0.2], [5, 0.2], [3, 0.2],
        [2, 0.3], [0, 0.5]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if(i % 3 == 1) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.14]);
        };

        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 0.9,
            \amp, 0.28
        ]);

        if(i % 2 == 0) { Synth(\dudaHeel, [\amp, 0.2]); };

        dur.wait;
    };

    0.5.wait;
    drone.free;
}).play;
)

// ---------------------------------------------------------------------------
// EXPERIMENT 8: Full Traditional Dance Piece
// Complete structure: introduction, slow section, transition, fast dance
// ---------------------------------------------------------------------------
(
var root = 55;
var hungarianScale = ~hungarianMinor;
var gypsyScale = ~gypsyScale;

Routine({
    var drone, deepDrone;
    "Experiment 8: Full Traditional Dance Piece".postln;

    // =========================================
    // INTRODUCTION - drone builds
    // =========================================
    "Introduction...".postln;
    deepDrone = Synth(\dudaDeepDrone, [\freq, root.midicps * 0.5, \amp, 0.15]);
    0.8.wait;
    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.2]);
    1.0.wait;

    // Opening phrase
    [0, 3, 6, 7, 6, 3, 0].do { |deg, i|
        Synth(\dudaChanterLong, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, 0.6,
            \amp, 0.25,
            \vibrato, 0.008
        ]);
        0.55.wait;
    };

    0.8.wait;

    // =========================================
    // LASSÚ (Slow) - expressive, ornamented
    // =========================================
    "Lassú section...".postln;
    drone.set(\amp, 0.24);

    [
        [0, 0.8], [2, 0.5], [3, 0.7], [6, 1.0],
        [5, 0.6], [3, 0.5], [2, 0.7], [0, 1.2],
        [-1, 0.6], [0, 0.8]
    ].do { |pair, i|
        var deg = pair[0];
        var dur = pair[1];

        if([2, 5, 8].includes(i)) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, hungarianScale, deg + 1), \amp, 0.13]);
        };

        Synth(\dudaChanterLong, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, dur * 0.85,
            \amp, 0.27,
            \vibrato, 0.01,
            \nasal, 0.6
        ]);

        (dur * rrand(0.93, 1.07)).wait;
    };

    1.0.wait;

    // =========================================
    // TRANSITION - accelerating
    // =========================================
    "Transition...".postln;
    [0.45, 0.4, 0.35, 0.3, 0.25, 0.22].do { |tempo, i|
        var deg = [0, 2, 4, 5, 4, 2][i];
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, hungarianScale, deg),
            \dur, tempo * 0.9,
            \amp, 0.28 + (i * 0.01)
        ]);
        if(i > 2) { Synth(\dudaStomp, [\amp, 0.35 + (i * 0.03)]); };
        tempo.wait;
    };

    0.3.wait;

    // =========================================
    // FRISS (Fast) - energetic dance
    // =========================================
    "Friss section...".postln;
    drone.set(\amp, 0.27);

    // First pass - establishing rhythm
    [0, 1, 4, 4, 3, 2, 1, 0, 0, 1, 4, 5, 4, 3, 2, 1].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.14]);
        };

        Synth(\dudaChanterStaccato, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.14,
            \amp, 0.3,
            \buzz, 0.65
        ]);

        if(i % 4 == 0) { Synth(\dudaStomp, [\amp, 0.5]); };
        if(i % 4 == 2) { Synth(\dudaHeel, [\amp, 0.22]); };

        0.18.wait;
    };

    0.2.wait;

    // Second pass - more intense
    [0, 1, 4, 5, 6, 5, 4, 3, 2, 1, 0, 1, 4, 3, 2, 0].do { |deg, i|
        if(i % 2 == 1) {
            Synth(\dudaDoubleCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.13]);
        };

        Synth(\dudaChanterStaccato, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.12,
            \amp, 0.32,
            \buzz, 0.7
        ]);

        // Full footwork pattern
        if(i % 4 == 0) { Synth(\dudaStomp, [\amp, 0.55]); };
        if(i % 4 == 1) { Synth(\dudaBootSlap, [\amp, 0.18]); };
        if(i % 4 == 2) { Synth(\dudaHeel, [\amp, 0.25]); };
        if(i % 4 == 3) { Synth(\dudaBootSlap, [\amp, 0.16, \pan, 0.15]); };

        0.16.wait;
    };

    // =========================================
    // CODA - triumphant ending
    // =========================================
    0.3.wait;
    "Coda...".postln;

    // Final flourish
    [0, 4, 5, 6, 7].do { |deg, i|
        Synth(\dudaTripletCut, [\freq, ~scaleToFreq.(root, gypsyScale, deg + 1), \amp, 0.12]);
        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, gypsyScale, deg),
            \dur, 0.25,
            \amp, 0.33
        ]);
        Synth(\dudaStomp, [\amp, 0.5]);
        0.22.wait;
    };

    // Final note with big stomp
    Synth(\dudaTripletCut, [\freq, ~scaleToFreq.(root, gypsyScale, 1), \amp, 0.14]);
    Synth(\dudaChanterLong, [
        \freq, ~scaleToFreq.(root, gypsyScale, 0),
        \dur, 1.5,
        \amp, 0.35,
        \nasal, 0.75
    ]);
    Synth(\dudaStomp, [\amp, 0.65]);

    1.8.wait;

    // Drones fade
    drone.set(\gate, 0);
    0.5.wait;
    deepDrone.set(\gate, 0);

    "Piece complete.".postln;
}).play;
)
