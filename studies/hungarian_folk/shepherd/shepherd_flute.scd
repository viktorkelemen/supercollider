// ============================================================================
// SHEPHERD FLUTE (FURULYA / TILINKÓ) - Pastoral Hungarian Tradition
// ============================================================================
// The shepherd's flute is perhaps the oldest solo instrument in Hungarian
// folk music, played in the fields while tending animals. Its music reflects
// the solitude, space, and natural environment of pastoral life.
//
// Instrument Types:
// - Furulya: 6-hole recorder-like flute, most common
// - Tilinkó: overtone flute with no finger holes, pitch from overblowing
// - Hosszú furulya: long flute with deeper, mellower tone
// - Pásztorsíp: simple shepherd's whistle
//
// Musical Characteristics:
// - Free, improvisatory melodies (not for dancing)
// - Pentatonic scales (archaic) or modes with augmented seconds
// - Wide melodic leaps exploiting overtones
// - Breathy, airy timbre with wind noise
// - Natural reverb from outdoor performance (valleys, hills)
// - Glissandi and pitch bends from half-holing
// - Ornamental "hiccups" (breath accents)
// - Connection to animal calls and nature sounds
//
// Performance Context:
// - Solo, outdoors, while tending sheep/cattle
// - Dawn and dusk (traditional times)
// - Communication across distances
// - Personal meditation and expression
// ============================================================================

(
// Scales used in shepherd music
~pentatonic = [0, 2, 4, 7, 9];
~lydianPentatonic = [0, 2, 4, 6, 9];  // With raised 4th
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR SHEPHERD FLUTES
// ============================================================================
(
// Furulya - standard shepherd's flute (6-hole, recorder-like)
SynthDef(\shepFurulya, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.8, pan = 0,
     breath = 0.35, vibRate = 4.5, vibDepth = 0.01,
     attack = 0.04, brightness = 0.6|
    var env, breathNoise, vibrato, sig;

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0], [attack, dur * 0.7, dur * 0.26], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.4).range(-0.3, 0.3)) * freq * vibDepth;

    // Warm, rounded flute tone
    sig = SinOsc.ar(freq + vibrato) * 0.65 +
          SinOsc.ar((freq + vibrato) * 2, 0, 0.22) +
          SinOsc.ar((freq + vibrato) * 3, 0, 0.08) +
          SinOsc.ar((freq + vibrato) * 4, 0, 0.03);

    // Breath noise (wind through tube)
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 6000) * 0.4;
    breathNoise = breathNoise + HPF.ar(PinkNoise.ar * breath * 0.2, 3000);

    sig = sig + breathNoise;

    // Body resonance
    sig = BPF.ar(sig, 900, 0.35) * 1.5 + sig * 0.55;
    sig = LPF.ar(sig, freq * (3 + brightness * 5));

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Tilinkó - overtone flute (no finger holes)
SynthDef(\shepTilinko, {
    |out = 0, freq = 440, amp = 0.28, dur = 1.0, pan = 0,
     breath = 0.4, overblowMix = 0.35, formant = 1500|
    var env, breathNoise, fundamental, overtones, sig;

    env = EnvGen.kr(Env.perc(0.05, dur * 0.95, 1, -4), doneAction: 2);

    // Breath noise
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 7000) * 0.45;

    // Fundamental with natural instability
    fundamental = SinOsc.ar(freq * (1 + LFNoise1.kr(2.5).range(-0.004, 0.004)));

    // Overtone content
    overtones = SinOsc.ar(freq * 2, 0, 0.4) +
                SinOsc.ar(freq * 3, 0, 0.22) +
                SinOsc.ar(freq * 4, 0, 0.1);

    sig = (fundamental * (1 - overblowMix)) + (overtones * overblowMix);

    // Tube resonance
    sig = BPF.ar(sig, formant, 0.22) * 2 + sig * 0.5;
    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 6);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hosszú furulya - long flute (deeper, mellower)
SynthDef(\shepLongFlute, {
    |out = 0, freq = 220, amp = 0.32, dur = 1.2, pan = 0,
     breath = 0.3, vibRate = 3.5, vibDepth = 0.012|
    var env, breathNoise, vibrato, sig;

    env = EnvGen.kr(
        Env([0, 1, 0.9, 0.7, 0], [0.06, dur * 0.4, dur * 0.35, dur * 0.19], [2, -1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;

    // Darker, more fundamental-heavy tone
    sig = SinOsc.ar(freq + vibrato) * 0.75 +
          SinOsc.ar((freq + vibrato) * 2, 0, 0.15) +
          SinOsc.ar((freq + vibrato) * 3, 0, 0.05);

    breathNoise = LPF.ar(WhiteNoise.ar * breath, 4000) * 0.35;

    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Flute with glissando (half-holing technique)
SynthDef(\shepGliss, {
    |out = 0, startFreq = 440, endFreq = 400, amp = 0.3, dur = 0.6,
     glissTime = 0.15, breath = 0.32, pan = 0|
    var env, freqEnv, sig, breathNoise;

    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.02, glissTime], \exp));

    env = EnvGen.kr(
        Env([0, 1, 0.8, 0], [0.04, dur * 0.7, dur * 0.26], [2, -2, -4]),
        doneAction: 2
    );

    sig = SinOsc.ar(freqEnv) * 0.65 +
          SinOsc.ar(freqEnv * 2, 0, 0.2) +
          SinOsc.ar(freqEnv * 3, 0, 0.08);

    breathNoise = LPF.ar(WhiteNoise.ar * breath, 5500) * 0.4;

    sig = sig + breathNoise;
    sig = BPF.ar(sig, 850, 0.4) * 1.4 + sig * 0.5;
    sig = LPF.ar(sig, freqEnv * 5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Breath accent / "hiccup" ornament
SynthDef(\shepHiccup, {
    |out = 0, freq = 440, amp = 0.22, pan = 0|
    var env, sig, breathBurst;

    env = EnvGen.kr(Env.perc(0.003, 0.06), doneAction: 2);

    // Quick pitch dip
    sig = SinOsc.ar(freq * EnvGen.kr(Env([1, 0.92, 1], [0.01, 0.03])));

    // Breath burst
    breathBurst = HPF.ar(WhiteNoise.ar, 2000) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.5;

    sig = sig + breathBurst;
    sig = LPF.ar(sig, freq * 4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Wind bed (ambient outdoor sound)
SynthDef(\shepWind, {
    |out = 0, amp = 0.06, gate = 1|
    var env, sig;

    env = EnvGen.kr(Env.asr(2.0, 1, 3.0), gate, doneAction: 2);

    // Layered wind textures
    sig = LPF.ar(WhiteNoise.ar, 400) * 0.4;
    sig = sig + BPF.ar(PinkNoise.ar, 200, 0.5) * 0.3;
    sig = sig + HPF.ar(ClipNoise.ar * 0.1, 4000);

    // Slow movement
    sig = sig * (1 + SinOsc.kr(0.1).range(-0.3, 0.3));

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Simple reverb for outdoor echo effect
SynthDef(\shepReverb, {
    |in, out = 0, mix = 0.35, room = 0.8, damp = 0.3|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;

// Soft drum/heartbeat (occasional pulse)
SynthDef(\shepPulse, {
    |out = 0, freq = 60, amp = 0.15|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.01, 0.25, 1, -6), doneAction: 2);
    sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.2;
    sig = LPF.ar(sig, 200);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic furulya tone and articulations
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Furulya basic tones and articulations:".postln;

    // Legato phrase
    "  Legato:".postln;
    [0, 2, 4, 7, 4, 2, 0].do { |deg, i|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.5,
            \amp, 0.32,
            \vibRate, 4.5
        ]);
        0.45.wait;
    };

    0.8.wait;

    // Staccato phrase
    "  Staccato:".postln;
    [0, 2, 4, 7, 4, 2, 0].do { |deg, i|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.2,
            \amp, 0.3,
            \attack, 0.02,
            \vibRate, 0
        ]);
        0.25.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Tilinkó overtone melody
// ============================================================================
(
var root = 55; // Low fundamental

Routine({
    "Tilinkó overtone melody (natural harmonics):".postln;

    // Melody using overtone series
    [1, 2, 3, 4, 3, 2, 3, 4, 5, 4, 3, 2, 1].do { |harmonic, i|
        Synth(\shepTilinko, [
            \freq, root.midicps * harmonic,
            \dur, [0.8, 0.5, 0.6, 0.9, 0.4, 0.5, 0.6, 0.7, 1.0, 0.5, 0.5, 0.6, 1.2].at(i),
            \amp, 0.28,
            \breath, 0.38,
            \overblowMix, harmonic.linlin(1, 5, 0.15, 0.5)
        ]);
        [0.7, 0.4, 0.5, 0.8, 0.35, 0.45, 0.5, 0.6, 0.9, 0.45, 0.45, 0.55, 1.0].at(i).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Glissandi and half-holing
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Glissandi and pitch bends:".postln;

    // Upward gliss
    "  Upward gliss:".postln;
    Synth(\shepGliss, [
        \startFreq, ~scaleToFreq.(root, scale, 0),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.9,
        \glissTime, 0.25,
        \amp, 0.32
    ]);
    0.85.wait;

    // Downward gliss (yearning)
    "  Downward gliss:".postln;
    Synth(\shepGliss, [
        \startFreq, ~scaleToFreq.(root, scale, 7),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \glissTime, 0.3,
        \amp, 0.32
    ]);
    0.95.wait;

    // Quick ornamental slides
    "  Quick ornamental slides:".postln;
    [
        [2, 0, 0.4, 0.08],  // [start, end, dur, glissTime]
        [0, 2, 0.5, 0.06],
        [4, 2, 0.6, 0.1],
        [2, 4, 0.8, 0.12],
        [4, 0, 1.0, 0.2]
    ].do { |slide|
        Synth(\shepGliss, [
            \startFreq, ~scaleToFreq.(root, scale, slide[0]),
            \endFreq, ~scaleToFreq.(root, scale, slide[1]),
            \dur, slide[2],
            \glissTime, slide[3],
            \amp, 0.3
        ]);
        (slide[2] * 0.9).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Breath accents and ornaments
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Breath accents (hiccups) as ornaments:".postln;

    // Melody with hiccup ornaments
    [
        [4, 0.7, true],   // [degree, duration, hasHiccup]
        [2, 0.4, false],
        [4, 0.6, true],
        [7, 0.9, false],
        [4, 0.5, true],
        [2, 0.6, false],
        [0, 1.2, false]
    ].do { |note|
        // Hiccup before main note
        if(note[2]) {
            Synth(\shepHiccup, [
                \freq, ~scaleToFreq.(root, scale, note[0]),
                \amp, 0.18
            ]);
            0.04.wait;
        };

        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, 0.32,
            \vibRate, if(note[1] > 0.5, 4.5, 0)
        ]);

        note[1].wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 5: Pastoral scene with wind ambience
// ============================================================================
(
var root = 55;
var scale = ~pentatonic;

Routine({
    var wind;

    "Pastoral scene (with wind ambience):".postln;

    // Start wind
    wind = Synth(\shepWind, [\amp, 0.07]);

    1.5.wait;

    // Free, improvisatory melody with pauses (like thinking)
    [
        [0, 0.6, 0.4],   // [degree, duration, pause]
        [2, 0.5, 0.2],
        [4, 0.9, 0.8],   // Long note, pause
        [4, 0.4, 0.15],
        [2, 0.5, 0.1],
        [0, 0.7, 1.2],   // Rest (shepherd looking at view)
        [4, 0.5, 0.1],
        [7, 1.0, 0.3],
        [9, 0.6, 0.2],
        [7, 0.7, 0.15],
        [4, 0.6, 0.1],
        [2, 0.8, 0.2],
        [0, 1.5, 0.5]
    ].do { |note|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root + 12, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, 0.28,
            \breath, 0.38,
            \vibRate, if(note[1] > 0.6, 4, 0),
            \vibDepth, 0.012
        ]);
        (note[1] + note[2]).wait;
    };

    2.0.wait;
    wind.release;
}).play;
)

// ============================================================================
// EXPERIMENT 6: Echo effect (mountain/valley acoustics)
// ============================================================================
(
~shepReverbBus = Bus.audio(s, 2);

s.sync;

// Start reverb
Synth(\shepReverb, [\in, ~shepReverbBus, \mix, 0.5, \room, 0.9, \damp, 0.2]);

Routine({
    var root = 60;
    var scale = ~pentatonic;

    "Mountain echo effect:".postln;

    // Play phrases that exploit echo
    [
        [4, 1.0],
        [7, 0.8],
        [4, 0.6]
    ].do { |note|
        // Dry signal
        Synth(\shepTilinko, [
            \freq, ~scaleToFreq.(root, scale, note[0]),
            \dur, note[1],
            \amp, 0.32,
            \out, 0  // Direct out
        ]);

        // Wet signal (to reverb bus)
        Synth(\shepTilinko, [
            \freq, ~scaleToFreq.(root, scale, note[0]),
            \dur, note[1],
            \amp, 0.25,
            \out, ~shepReverbBus  // To reverb
        ]);

        (note[1] + 0.6).wait;  // Space for echo
    };

    2.0.wait;

    // Call across valley (long notes, lots of echo)
    "  Long call with echo:".postln;
    Synth(\shepLongFlute, [
        \freq, ~scaleToFreq.(root - 12, scale, 0),
        \dur, 2.5,
        \amp, 0.35,
        \out, 0
    ]);
    Synth(\shepLongFlute, [
        \freq, ~scaleToFreq.(root - 12, scale, 0),
        \dur, 2.5,
        \amp, 0.28,
        \out, ~shepReverbBus
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Dawn melody (traditional time for shepherds)
// ============================================================================
(
var root = 55;
var scale = ~lydianPentatonic;  // Raised 4th for morning brightness

Routine({
    var wind;

    "Dawn melody (as the sun rises):".postln;

    wind = Synth(\shepWind, [\amp, 0.05]);

    1.0.wait;

    // Quiet, contemplative opening
    [0, 2, 4].do { |deg|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 1.0,
            \amp, 0.22,
            \breath, 0.4,
            \vibRate, 3.5
        ]);
        0.9.wait;
    };

    0.5.wait;

    // Building energy as sun rises
    [
        [4, 0.6, 0.26],
        [6, 0.5, 0.28],  // Raised 4th (lydian color)
        [4, 0.4, 0.26],
        [2, 0.5, 0.28],
        [4, 0.7, 0.3],
        [6, 0.6, 0.3],
        [9, 1.0, 0.34],  // High point
        [6, 0.5, 0.3],
        [4, 0.6, 0.28],
        [2, 0.5, 0.26],
        [0, 1.5, 0.3]
    ].do { |note|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root + 12, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, note[2],
            \vibRate, 4.5
        ]);
        note[1].wait;
    };

    1.5.wait;
    wind.release;
}).play;
)

// ============================================================================
// EXPERIMENT 8: Full pastoral piece
// ============================================================================
(
var root = 55;
var melodyRoot = 67;  // Higher register
var scale = ~pentatonic;

Routine({
    var wind;

    "=== Full Pastoral Piece ===".postln;

    // ---- Ambient opening ----
    "".postln;
    "--- Dawn ambience ---".postln;

    wind = Synth(\shepWind, [\amp, 0.06]);
    2.0.wait;

    // ---- Solo furulya, free rhythm ----
    "".postln;
    "--- Solo furulya ---".postln;

    // Opening call
    Synth(\shepTilinko, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.5,
        \amp, 0.3,
        \overblowMix, 0.2
    ]);
    1.3.wait;

    // Response (higher)
    Synth(\shepTilinko, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \amp, 0.28,
        \overblowMix, 0.35
    ]);
    1.5.wait;

    // ---- Main melody ----
    "".postln;
    "--- Main melody ---".postln;

    [
        [4, 0.7, false],
        [2, 0.4, false],
        [4, 0.6, true],   // gliss to next
        [7, 0.9, false],
        [4, 0.5, false],
        [2, 0.6, true],   // gliss
        [0, 0.8, false],
        [-1, 0.4, false],
        [0, 1.2, false]
    ].do { |note, i|
        if(note[2] && (i < 8)) {
            // Gliss to next note
            var nextDeg = [[4, 0.7, false], [2, 0.4, false], [4, 0.6, true],
                           [7, 0.9, false], [4, 0.5, false], [2, 0.6, true],
                           [0, 0.8, false], [-1, 0.4, false], [0, 1.2, false]][i+1][0];
            Synth(\shepGliss, [
                \startFreq, ~scaleToFreq.(melodyRoot, scale, note[0]),
                \endFreq, ~scaleToFreq.(melodyRoot, scale, nextDeg),
                \dur, note[1],
                \glissTime, 0.12,
                \amp, 0.32
            ]);
        } {
            Synth(\shepFurulya, [
                \freq, ~scaleToFreq.(melodyRoot, scale, note[0]),
                \dur, note[1] * 1.1,
                \amp, 0.32,
                \vibRate, if(note[1] > 0.5, 4.5, 0)
            ]);
        };
        (note[1] + rrand(-0.03, 0.06)).wait;
    };

    1.0.wait;

    // ---- Livelier section ----
    "".postln;
    "--- Livelier section ---".postln;

    [0, 2, 4, 7, 4, 2, 0, 2, 4, 7, 9, 7, 4, 2, 0].do { |deg, i|
        // Occasional hiccup
        if([2, 6, 10].includes(i)) {
            Synth(\shepHiccup, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \amp, 0.16
            ]);
            0.03.wait;
        };

        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.35,
            \amp, 0.3,
            \vibRate, 0,
            \attack, 0.02
        ]);
        0.28.wait;
    };

    // Occasional soft pulse (heartbeat of the land)
    Synth(\shepPulse, [\amp, 0.12]);

    0.8.wait;

    // ---- Closing ----
    "".postln;
    "--- Closing ---".postln;

    // Slowing down, returning to peace
    [4, 2, 0, -1, 0].do { |deg, i|
        var dur = [0.6, 0.7, 0.8, 0.5, 1.8].at(i);

        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 1.2,
            \amp, 0.28 - (i * 0.02),
            \vibRate, 4,
            \vibDepth, 0.015
        ]);
        dur.wait;
    };

    2.5.wait;
    wind.release;

    "".postln;
    "=== End ===".postln;
}).play;
)

// ============================================================================
// WAVEGUIDE FLUTE (Physical Modeling)
// ============================================================================
// Based on waveguide synthesis - more realistic than additive synthesis.
// The waveguide models the actual physics of air column vibration in a tube.
// Load from: "../lib/hungarian_folk_core.scd".load;

(
// Waveguide flute - physical modeling for cleaner, more realistic tone
SynthDef(\shepWaveguideFlute, {
    |out = 0, freq = 440, amp = 0.3, dur = 1, pan = 0,
     ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4|

    var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
    var aflow1, asum1, asum2, afqc, ax, apoly, asum3, avalue, aflute1;
    var fdbckArray, signalOut, ifqc;

    sr = SampleRate.ir;
    cr = ControlRate.ir;
    block = cr.reciprocal;
    ifqc = freq;

    // Noise envelope (breath attack)
    kenv1 = EnvGen.kr(Env.new(
        [0.0, 1.1 * ipress, ipress, ipress, 0.0],
        [0.06, 0.2, dur - 0.46, 0.2], \linear
    ));

    // Overall envelope
    kenv2 = EnvGen.kr(Env.new(
        [0.0, amp, amp, 0.0],
        [0.1, dur - 0.02, 0.1], \linear
    ), doneAction: 2);

    // Vibrato envelope (delayed onset)
    kenvibr = EnvGen.kr(Env.new(
        [0.0, 0.0, 1, 1, 0.0],
        [0.5, 0.5, dur - 1.5, 0.5], \linear
    ));

    // Air flow and vibrato
    aflow1 = LFClipNoise.ar(sr, kenv1);
    kvibr = SinOsc.ar(5, 0, 0.1 * kenvibr);

    asum1 = (ibreath * aflow1) + kenv1 + kvibr;
    afqc = ifqc.reciprocal - (asum1 / 20000) - (9 / sr) + (ifqc / 12000000) - block;

    fdbckArray = LocalIn.ar(1);
    aflute1 = fdbckArray;
    asum2 = asum1 + (aflute1 * ifeedbk1);

    ax = DelayC.ar(asum2, ifqc.reciprocal - (block * 0.5), (afqc * 0.5) - (asum1 / ifqc / cr) + 0.001);
    apoly = ax - ax.cubed;
    asum3 = apoly + (aflute1 * ifeedbk2);
    avalue = LPF.ar(asum3, 2000);
    aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);

    LocalOut.ar([aflute1]);
    signalOut = avalue;

    Out.ar(out, Pan2.ar(signalOut * kenv2, pan));
}).add;

// Long flute variant (hosszú furulya) - deeper, mellower waveguide
SynthDef(\shepWaveguideLong, {
    |out = 0, freq = 220, amp = 0.32, dur = 1.5, pan = 0,
     ipress = 0.75, ibreath = 0.12, ifeedbk1 = 0.5, ifeedbk2 = 0.45|

    var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
    var aflow1, asum1, asum2, afqc, ax, apoly, asum3, avalue, aflute1;
    var fdbckArray, signalOut, ifqc;

    sr = SampleRate.ir;
    cr = ControlRate.ir;
    block = cr.reciprocal;
    ifqc = freq;

    // Softer attack for deeper flute
    kenv1 = EnvGen.kr(Env.new(
        [0.0, 1.0 * ipress, ipress * 0.9, ipress * 0.85, 0.0],
        [0.1, 0.3, dur - 0.65, 0.25], \sine
    ));

    kenv2 = EnvGen.kr(Env.new(
        [0.0, amp, amp, 0.0],
        [0.15, dur - 0.1, 0.15], \sine
    ), doneAction: 2);

    kenvibr = EnvGen.kr(Env.new(
        [0.0, 0.0, 1, 1, 0.0],
        [0.6, 0.4, dur - 1.5, 0.5], \linear
    ));

    aflow1 = LFClipNoise.ar(sr, kenv1);
    kvibr = SinOsc.ar(4, 0, 0.08 * kenvibr);  // Slower, gentler vibrato

    asum1 = (ibreath * aflow1) + kenv1 + kvibr;
    afqc = ifqc.reciprocal - (asum1 / 20000) - (9 / sr) + (ifqc / 12000000) - block;

    fdbckArray = LocalIn.ar(1);
    aflute1 = fdbckArray;
    asum2 = asum1 + (aflute1 * ifeedbk1);

    ax = DelayC.ar(asum2, ifqc.reciprocal - (block * 0.5), (afqc * 0.5) - (asum1 / ifqc / cr) + 0.001);
    apoly = ax - ax.cubed;
    asum3 = apoly + (aflute1 * ifeedbk2);
    avalue = LPF.ar(asum3, 1500);  // Lower cutoff for mellower tone
    aflute1 = DelayC.ar(avalue, ifqc.reciprocal - block, afqc);

    LocalOut.ar([aflute1]);
    signalOut = avalue;

    Out.ar(out, Pan2.ar(signalOut * kenv2, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 9: Waveguide vs Additive Flute Comparison
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Experiment 9: Waveguide vs Additive Flute Comparison".postln;

    // Additive synthesis flute (original)
    "  Additive synthesis (shepFurulya):".postln;
    [0, 2, 4, 7, 4, 2, 0].do { |deg|
        Synth(\shepFurulya, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.55,
            \amp, 0.32,
            \vibRate, 4.5
        ]);
        0.5.wait;
    };

    0.8.wait;

    // Waveguide flute (new)
    "  Waveguide synthesis (shepWaveguideFlute):".postln;
    [0, 2, 4, 7, 4, 2, 0].do { |deg|
        Synth(\shepWaveguideFlute, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.55,
            \amp, 0.3,
            \ibreath, 0.08
        ]);
        0.5.wait;
    };

    "Done - notice the waveguide has more realistic attack transients.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 10: Waveguide breath pressure exploration
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

Routine({
    "Experiment 10: Breath Pressure Effects on Waveguide".postln;

    // Light breath (soft, airy)
    "  Light breath (ipress=0.5, ibreath=0.05):".postln;
    [0, 4, 7].do { |deg|
        Synth(\shepWaveguideFlute, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.8,
            \amp, 0.28,
            \ipress, 0.5,
            \ibreath, 0.05
        ]);
        0.7.wait;
    };

    0.5.wait;

    // Medium breath (normal)
    "  Medium breath (ipress=0.8, ibreath=0.09):".postln;
    [0, 4, 7].do { |deg|
        Synth(\shepWaveguideFlute, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.8,
            \amp, 0.3,
            \ipress, 0.8,
            \ibreath, 0.09
        ]);
        0.7.wait;
    };

    0.5.wait;

    // Strong breath (intense, overblown quality)
    "  Strong breath (ipress=1.0, ibreath=0.15):".postln;
    [0, 4, 7].do { |deg|
        Synth(\shepWaveguideFlute, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.8,
            \amp, 0.32,
            \ipress, 1.0,
            \ibreath, 0.15
        ]);
        0.7.wait;
    };

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 11: Hosszú Furulya (Long Flute) Waveguide
// ============================================================================
(
var root = 48;  // Lower register
var scale = ~pentatonic;

Routine({
    var wind;

    "Experiment 11: Hosszú Furulya (Long Flute) Waveguide".postln;

    wind = Synth(\shepWind, [\amp, 0.05]);
    1.0.wait;

    // Deep, mellow melody
    [0, 2, 4, 2, 0, -1, 0, 2, 4, 7, 4, 2, 0].do { |deg, i|
        var dur = [0.9, 0.6, 0.8, 0.6, 1.0, 0.5, 0.7, 0.6, 0.8, 1.2, 0.7, 0.6, 1.5].at(i);

        Synth(\shepWaveguideLong, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur,
            \amp, 0.32,
            \ipress, 0.7,
            \ibreath, 0.1
        ]);

        (dur * 0.9).wait;
    };

    1.5.wait;
    wind.release;

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 12: Full Pastoral with Waveguide Flute
// ============================================================================
(
var root = 55;
var melodyRoot = 67;
var scale = ~pentatonic;

Routine({
    var wind;

    "Experiment 12: Full Pastoral Scene with Waveguide Flute".postln;

    // ---- Ambient opening ----
    "".postln;
    "--- Dawn ambience ---".postln;

    wind = Synth(\shepWind, [\amp, 0.06]);
    1.5.wait;

    // ---- Opening calls (waveguide long flute - distant) ----
    "".postln;
    "--- Distant call (waveguide long flute) ---".postln;

    Synth(\shepWaveguideLong, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.8,
        \amp, 0.25,
        \ipress, 0.65
    ]);
    1.6.wait;

    Synth(\shepWaveguideLong, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.5,
        \amp, 0.28,
        \ipress, 0.7
    ]);
    1.8.wait;

    // ---- Main melody (waveguide standard flute) ----
    "".postln;
    "--- Main melody (waveguide flute) ---".postln;

    [
        [4, 0.7],
        [2, 0.4],
        [4, 0.6],
        [7, 0.9],
        [4, 0.5],
        [2, 0.6],
        [0, 0.8],
        [-1, 0.4],
        [0, 1.2]
    ].do { |note|
        Synth(\shepWaveguideFlute, [
            \freq, ~scaleToFreq.(melodyRoot, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, 0.32,
            \ipress, 0.85,
            \ibreath, 0.08
        ]);
        (note[1] + rrand(-0.03, 0.05)).wait;
    };

    0.8.wait;

    // ---- Livelier section (mix of additive and waveguide) ----
    "".postln;
    "--- Livelier section ---".postln;

    [0, 2, 4, 7, 4, 2, 0, 2, 4, 7, 9, 7, 4, 2, 0].do { |deg, i|
        // Alternate between synths for variety
        if(i % 3 == 0) {
            Synth(\shepWaveguideFlute, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, 0.38,
                \amp, 0.3,
                \ipress, 0.9
            ]);
        } {
            Synth(\shepFurulya, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, 0.35,
                \amp, 0.3,
                \vibRate, 0,
                \attack, 0.02
            ]);
        };
        0.28.wait;
    };

    // ---- Closing (waveguide long flute) ----
    "".postln;
    "--- Closing ---".postln;

    [4, 2, 0, -1, 0].do { |deg, i|
        var dur = [0.7, 0.8, 0.9, 0.6, 2.0].at(i);

        Synth(\shepWaveguideLong, [
            \freq, ~scaleToFreq.(melodyRoot - 12, scale, deg),
            \dur, dur * 1.2,
            \amp, 0.3 - (i * 0.03),
            \ipress, 0.65
        ]);
        dur.wait;
    };

    2.5.wait;
    wind.release;

    "".postln;
    "=== End ===".postln;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
