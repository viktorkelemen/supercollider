// ============================================================================
// CSANGO OVERTONE SONG - Archaic Moldavian Hungarian Tradition
// ============================================================================
// The Csango (Csango) are a Hungarian-speaking community in Moldova, Romania,
// preserving some of the oldest Hungarian musical traditions dating back
// centuries before the verbunkos era.
//
// Musical Characteristics:
// - Anhemitonic pentatonic scales (no semitones) - archaic "old style"
// - Overtone-based melodies from the tilinkó (overtone flute)
// - Descending melodic contours (characteristic of old Hungarian song)
// - Monophonic or simple drone accompaniment
// - Parlando-rubato singing style (speech-like rhythm)
// - Call-and-response between voice and instruments
// - Strong connection to pastoral/shepherd life
// - Lament traditions (sirató) for funerals and grief
//
// Instruments:
// - Tilinkó: end-blown overtone flute (no finger holes, pitch from overblowing)
// - Furulya: shepherd's flute with finger holes
// - Gardon: struck cello providing rhythmic drone
// - Voice: often solo, sometimes responsorial
//
// This file explores the distinctive breathy, ethereal quality of Csango music.
// ============================================================================

(
// Anhemitonic pentatonic (the "old style" Hungarian scale)
~pentatonic = [0, 2, 4, 7, 9];

// Minor pentatonic variant (also common)
~minorPentatonic = [0, 3, 5, 7, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ============================================================================
// SYNTHDEFS FOR CSANGO MUSIC
// ============================================================================
(
// Tilinkó - overtone flute (no finger holes, pitch from breath pressure)
// Breathy, airy, with strong overtone content
SynthDef(\csangoTilinko, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     breath = 0.4, overblowMix = 0.3, formant = 1600|
    var env, breathNoise, fundamental, overtones, sig;

    env = EnvGen.kr(Env.perc(0.06, dur * 0.94, 1, -4), doneAction: 2);

    // Breath noise (wind through tube)
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 7000) * 0.5;
    breathNoise = breathNoise + (HPF.ar(PinkNoise.ar * breath * 0.3, 2000));

    // Fundamental with slight instability
    fundamental = SinOsc.ar(freq * (1 + LFNoise1.kr(3).range(-0.003, 0.003)));

    // Overtone series (natural harmonics from overblowing)
    overtones = SinOsc.ar(freq * 2, 0, 0.35) +
                SinOsc.ar(freq * 3, 0, 0.2) +
                SinOsc.ar(freq * 4, 0, 0.1);

    sig = (fundamental * (1 - overblowMix)) + (overtones * overblowMix);

    // Formant filtering (tube resonance)
    sig = BPF.ar(sig, formant, 0.25) * 2 + sig * 0.5;

    // Mix with breath
    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 6);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Furulya - shepherd's flute with finger holes (warmer, less overtone-focused)
SynthDef(\csangoFurulya, {
    |out = 0, freq = 440, amp = 0.28, dur = 0.8, pan = 0,
     breath = 0.3, vibRate = 4, vibDepth = 0.008|
    var env, breathNoise, vibrato, sig;

    env = EnvGen.kr(
        Env([0, 1, 0.8, 0], [0.04, dur * 0.7, dur * 0.26], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3)) * freq * vibDepth;

    // Warmer, more rounded tone
    sig = SinOsc.ar(freq + vibrato) * 0.7 +
          SinOsc.ar((freq + vibrato) * 2, 0, 0.2) +
          SinOsc.ar((freq + vibrato) * 3, 0, 0.08);

    breathNoise = LPF.ar(WhiteNoise.ar * breath, 5000) * 0.4;

    sig = sig + breathNoise;
    sig = BPF.ar(sig, 800, 0.4) * 1.5 + sig * 0.5;
    sig = LPF.ar(sig, freq * 5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Csango voice - nasal, archaic quality
SynthDef(\csangoVoice, {
    |out = 0, freq = 220, amp = 0.35, dur = 1.0, pan = 0,
     vibRate = 5, vibDepth = 0.015, nasality = 0.6,
     attack = 0.08, vowel = 0.5|
    var env, vibrato, sig, formant1, formant2, formant3;

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0.7, 0], [attack, dur * 0.3, dur * 0.4, dur * 0.22], [3, -1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.4, 0.4)) * freq * vibDepth;

    // Vocal source (slightly rough)
    sig = LFSaw.ar(freq + vibrato) * 0.6 + Pulse.ar(freq + vibrato, 0.4) * 0.4;

    // Vowel formants (interpolate between "ah" and "eh")
    formant1 = BPF.ar(sig, vowel.linlin(0, 1, 700, 500), 0.15) * 3;
    formant2 = BPF.ar(sig, vowel.linlin(0, 1, 1200, 1800), 0.12) * 2;
    formant3 = BPF.ar(sig, 2500, 0.1) * nasality * 1.5;

    sig = formant1 + formant2 + formant3;
    sig = LPF.ar(sig, 4000);
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Gardon - struck cello drone (rhythmic pulse)
SynthDef(\csangoGardon, {
    |out = 0, freq = 90, amp = 0.32, pan = 0|
    var env, body, slap, sig;

    env = EnvGen.kr(Env.perc(0.002, 0.16, 1, -8), doneAction: 2);

    // Low string body
    body = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.35 + SinOsc.ar(freq * 3) * 0.12;

    // Percussive slap on strings
    slap = HPF.ar(WhiteNoise.ar, 350) * EnvGen.kr(Env.perc(0.001, 0.025)) * 0.5;

    sig = LPF.ar(body + slap, 500);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Sustained drone (for under melodic passages)
SynthDef(\csangoDrone, {
    |out = 0, freq = 110, amp = 0.15, gate = 1, pan = 0|
    var env, sig;

    env = EnvGen.kr(Env.asr(0.8, 1, 1.5), gate, doneAction: 2);

    // Simple fifth drone (common in folk music)
    sig = SinOsc.ar([freq, freq * 1.5], 0, [0.7, 0.3]).sum;
    sig = sig + (LFTri.ar(freq) * 0.15);
    sig = LPF.ar(sig, 400);

    // Subtle movement
    sig = sig * (1 + SinOsc.kr(0.08).range(-0.03, 0.03));

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Grace note for ornaments
SynthDef(\csangoGrace, {
    |out = 0, freq = 440, amp = 0.18, dur = 0.04, pan = 0|
    var env, sig;

    env = EnvGen.kr(Env.perc(0.003, dur), doneAction: 2);
    sig = SinOsc.ar(freq) * 0.7 + SinOsc.ar(freq * 2) * 0.2;
    sig = LPF.ar(sig, freq * 4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic tilinkó overtone series
// ============================================================================
(
var root = 55; // Low A (shepherd's pitch)

Routine({
    "Tilinkó overtone series (natural harmonics):".postln;

    // Overtone series demonstration
    [1, 2, 3, 4, 5, 6].do { |harmonic, i|
        Synth(\csangoTilinko, [
            \freq, root.midicps * harmonic,
            \dur, 1.0,
            \amp, 0.3 - (i * 0.03),
            \breath, 0.35,
            \overblowMix, i.linlin(0, 5, 0.1, 0.6)
        ]);
        0.9.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Pentatonic melody with ornaments
// ============================================================================
(
var root = 60;
var scale = ~pentatonic;

// Descending melodic contour (old Hungarian style)
var melody = [4, 3, 4, 2, 1, 2, 0, -1, 0];
var durs = [0.8, 0.4, 0.6, 0.5, 0.7, 0.4, 0.6, 0.3, 1.2];
var hasGrace = [false, false, true, false, true, false, false, false, false];

Routine({
    "Pentatonic melody with grace note ornaments:".postln;

    melody.do { |deg, i|
        // Grace note (from above)
        if(hasGrace[i]) {
            Synth(\csangoGrace, [
                \freq, ~scaleToFreq.(root, scale, deg + 1),
                \amp, 0.15
            ]);
            0.03.wait;
        };

        Synth(\csangoFurulya, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, 0.32,
            \vibRate, if(durs[i] > 0.5, 4.5, 0),
            \vibDepth, 0.01
        ]);

        (durs[i] + rrand(-0.03, 0.05)).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Voice with gardon pulse
// ============================================================================
(
var root = 48;
var melodyRoot = 60;
var scale = ~pentatonic;

var melody = [4, 3, 2, 4, 2, 1, 0, -1, 0];
var durs = [1.0, 0.5, 0.7, 0.8, 0.5, 0.6, 0.7, 0.4, 1.5];

Routine({
    var gardonPulse;

    "Csángó voice with gardon accompaniment:".postln;

    // Start gardon pulse
    gardonPulse = {
        loop {
            Synth(\csangoGardon, [\freq, root.midicps, \amp, 0.28]);
            0.55.wait;
        }
    }.fork;

    0.3.wait;

    // Vocal melody
    melody.do { |deg, i|
        Synth(\csangoVoice, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, 0.38,
            \vibRate, 5,
            \vibDepth, 0.018,
            \nasality, 0.55
        ]);
        (durs[i] + rrand(-0.05, 0.08)).wait;
    };

    0.8.wait;
    gardonPulse.stop;
}).play;
)

// ============================================================================
// EXPERIMENT 4: Call and response (voice and flute)
// ============================================================================
(
var root = 55;
var scale = ~pentatonic;

Routine({
    "Call and response (voice calls, flute answers):".postln;

    2.do { |phrase|
        // CALL: Voice
        "  Voice:".postln;
        [4, 3, 2, 0].do { |deg, i|
            Synth(\csangoVoice, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, [0.6, 0.4, 0.5, 0.9].at(i),
                \amp, 0.36,
                \nasality, 0.5
            ]);
            [0.5, 0.35, 0.45, 0.7].at(i).wait;
        };

        0.4.wait;

        // RESPONSE: Tilinkó
        "  Flute:".postln;
        [4, 3, 2, 1, 0].do { |deg, i|
            Synth(\csangoTilinko, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, [0.5, 0.35, 0.4, 0.35, 0.8].at(i),
                \amp, 0.3,
                \breath, 0.38
            ]);
            [0.4, 0.3, 0.35, 0.3, 0.6].at(i).wait;
        };

        0.6.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 5: Lament style (sirató - funeral song)
// ============================================================================
(
var root = 55;
var scale = ~minorPentatonic;  // Minor pentatonic for lament

Routine({
    var drone;

    "Sirató (lament) - descending, mournful:".postln;

    // Quiet drone underneath
    drone = Synth(\csangoDrone, [\freq, root.midicps, \amp, 0.1]);

    0.8.wait;

    // Lament melody - lots of descending motion, long notes, wide vibrato
    [
        [7, 1.3, 0.42],  // [degree, duration, amplitude]
        [6, 0.6, 0.38],
        [4, 0.9, 0.4],
        [3, 0.5, 0.36],
        [4, 0.7, 0.38],
        [2, 0.8, 0.35],
        [1, 0.6, 0.33],
        [0, 1.5, 0.36],
        [-1, 0.5, 0.3],
        [0, 2.0, 0.32]
    ].do { |note|
        Synth(\csangoVoice, [
            \freq, ~scaleToFreq.(root, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, note[2],
            \vibRate, 4,
            \vibDepth, 0.025,  // Wide vibrato for emotion
            \nasality, 0.65,
            \attack, 0.12
        ]);
        (note[1] + rrand(-0.08, 0.1)).wait;
    };

    1.0.wait;
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 6: Pastoral scene (flute with wind-like drone)
// ============================================================================
(
var root = 55;
var scale = ~pentatonic;

Routine({
    var drone;

    "Pastoral scene (shepherd on hillside):".postln;

    // Sustained drone (like wind or distant singing)
    drone = Synth(\csangoDrone, [\freq, root.midicps, \amp, 0.12]);

    1.0.wait;

    // Free, improvisatory flute phrases with pauses
    [
        // [degree, duration, pause_after]
        [0, 0.6, 0.3],
        [2, 0.5, 0.1],
        [4, 1.0, 0.5],
        [4, 0.4, 0.1],
        [2, 0.6, 0.8],  // Long pause
        [4, 0.5, 0.1],
        [7, 0.8, 0.2],
        [4, 0.6, 0.1],
        [2, 0.5, 0.1],
        [0, 1.2, 1.0],  // Rest
        [2, 0.7, 0.2],
        [4, 0.5, 0.1],
        [2, 0.6, 0.1],
        [0, 1.5, 0.5]
    ].do { |note|
        Synth(\csangoTilinko, [
            \freq, ~scaleToFreq.(root + 12, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, 0.28,
            \breath, 0.4,
            \overblowMix, note[0].linlin(0, 7, 0.2, 0.5)
        ]);
        (note[1] + note[2]).wait;
    };

    1.5.wait;
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 7: Dance tune (livelier, with gardon drive)
// ============================================================================
(
var tempo = 0.28;
var root = 48;
var melodyRoot = 60;
var scale = ~pentatonic;

var melody = [0, 2, 4, 4, 2, 0, 2, 4, 7, 4, 2, 0, -1, 0, 0, 0];

Routine({
    "Csángó dance tune:".postln;

    melody.do { |deg, i|
        // Melody
        Synth(\csangoFurulya, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.4,
            \amp, 0.32,
            \vibRate, 0,  // No vibrato on dance tunes
            \breath, 0.25
        ]);

        // Gardon on each beat
        Synth(\csangoGardon, [
            \freq, ~scaleToFreq.(root, scale, 0),
            \amp, if(i % 4 == 0, 0.38, 0.28)
        ]);

        tempo.wait;
    };

    // Final accent
    Synth(\csangoFurulya, [\freq, ~scaleToFreq.(melodyRoot, scale, 0), \dur, 0.8, \amp, 0.38]);
    Synth(\csangoGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.42]);
}).play;
)

// ============================================================================
// EXPERIMENT 8: Full piece - Lament to Dance arc
// ============================================================================
(
var root = 55;
var melodyRoot = 60;
var scale = ~pentatonic;

Routine({
    var drone, gardonPulse;

    "=== Full Csángó Piece: Lament to Dance ===".postln;

    // ---- SECTION 1: Lament (free, rubato) ----
    "".postln;
    "--- Lament (sirató) ---".postln;

    drone = Synth(\csangoDrone, [\freq, root.midicps, \amp, 0.1]);
    0.8.wait;

    // Solo voice lament
    [
        [4, 1.0, 0.4],
        [3, 0.5, 0.36],
        [4, 0.7, 0.38],
        [2, 0.9, 0.35],
        [0, 1.3, 0.38]
    ].do { |note|
        Synth(\csangoVoice, [
            \freq, ~scaleToFreq.(melodyRoot, scale, note[0]),
            \dur, note[1] * 1.1,
            \amp, note[2],
            \vibRate, 4.5,
            \vibDepth, 0.022,
            \nasality, 0.6
        ]);
        (note[1] * rrand(0.9, 1.15)).wait;
    };

    1.5.wait;

    // ---- SECTION 2: Transition (flute enters) ----
    "".postln;
    "--- Transition ---".postln;

    [0, 2, 4, 2, 0].do { |deg, i|
        Synth(\csangoTilinko, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, 0.6,
            \amp, 0.26,
            \breath, 0.35
        ]);
        0.5.wait;
    };

    0.8.wait;
    drone.release;

    // ---- SECTION 3: Dance (with gardon) ----
    "".postln;
    "--- Dance ---".postln;

    gardonPulse = {
        loop {
            Synth(\csangoGardon, [\freq, root.midicps, \amp, 0.32]);
            0.3.wait;
        }
    }.fork;

    0.2.wait;

    // Dance melody - two phrases
    2.do { |rep|
        [0, 2, 4, 4, 2, 0, 2, 4, 7, 4, 2, 0].do { |deg, i|
            Synth(\csangoFurulya, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, 0.35,
                \amp, 0.3 + (rep * 0.03),
                \vibRate, 0,
                \breath, 0.22
            ]);
            0.25.wait;
        };
        0.3.wait;
    };

    // ---- ENDING ----
    "".postln;
    "--- Ending ---".postln;

    gardonPulse.stop;

    // Final phrase slowing down
    [4, 2, 0, -1, 0].do { |deg, i|
        var dur = [0.4, 0.45, 0.5, 0.4, 1.0].at(i);
        Synth(\csangoFurulya, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, dur * 1.2,
            \amp, 0.32
        ]);
        Synth(\csangoGardon, [\freq, root.midicps, \amp, 0.25]);
        dur.wait;
    };

    // Final chord
    Synth(\csangoGardon, [\freq, root.midicps, \amp, 0.4]);

    "".postln;
    "=== End ===".postln;
}).play;
)

// ============================================================================
// IMPROVED VOCAL SYNTHESIS (using formant data from hungarian_folk_core.scd)
// ============================================================================
// Load the core library first: "../lib/hungarian_folk_core.scd".load;
// These experiments use 5-formant synthesis for more realistic vocals.

// Formant data (from Csound/Vowel quark) - inline for standalone use
(
~csangoFormants = (
    tenor: (
        a: (freqs: [650, 1080, 2650, 2900, 3250], amps: [0, -6, -7, -8, -22].dbamp, bws: [80, 90, 120, 130, 140]),
        e: (freqs: [400, 1700, 2600, 3200, 3580], amps: [0, -14, -12, -14, -20].dbamp, bws: [70, 80, 100, 120, 120]),
        i: (freqs: [290, 1870, 2800, 3250, 3540], amps: [0, -15, -18, -20, -30].dbamp, bws: [40, 90, 100, 120, 120]),
        o: (freqs: [400, 800, 2600, 2800, 3000], amps: [0, -10, -12, -12, -26].dbamp, bws: [40, 80, 100, 120, 120]),
        u: (freqs: [350, 600, 2700, 2900, 3300], amps: [0, -20, -17, -14, -26].dbamp, bws: [40, 60, 100, 120, 120])
    ),
    alto: (
        a: (freqs: [800, 1150, 2800, 3500, 4950], amps: [0, -4, -20, -36, -60].dbamp, bws: [80, 90, 120, 130, 140]),
        e: (freqs: [400, 1600, 2700, 3300, 4950], amps: [0, -24, -30, -35, -60].dbamp, bws: [60, 80, 120, 150, 200]),
        i: (freqs: [350, 1700, 2700, 3700, 4950], amps: [0, -20, -30, -36, -60].dbamp, bws: [50, 100, 120, 150, 200])
    )
);

// Blend two vowel formant sets
~blendFormants = { |v1, v2, blend|
    (
        freqs: v1.freqs.blend(v2.freqs, blend),
        amps: v1.amps.blend(v2.amps, blend),
        bws: v1.bws.blend(v2.bws, blend)
    )
};

// 5-formant vocal synth
SynthDef(\csangoVoice5F, {
    |out = 0, freq = 220, amp = 0.35, dur = 1.0, pan = 0,
     vibRate = 5, vibDepth = 0.018, attack = 0.1, roughness = 0.25,
     f1 = 650, f2 = 1080, f3 = 2650, f4 = 2900, f5 = 3250,
     a1 = 1, a2 = 0.5, a3 = 0.45, a4 = 0.4, a5 = 0.08,
     bw1 = 80, bw2 = 90, bw3 = 120, bw4 = 130, bw5 = 140|

    var env, vibrato, source, formants, sig;

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0.7, 0], [attack, dur * 0.3, dur * 0.4, dur * 0.22], [3, -1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.5, 0.5)) * freq * vibDepth;

    // Glottal source - mix of periodic and noisy components
    source = (LFSaw.ar(freq + vibrato) * (1 - roughness)) +
             (Pulse.ar(freq + vibrato, 0.4 + LFNoise1.kr(1.5).range(-0.05, 0.05)) * roughness * 0.8) +
             (LFNoise1.ar(freq * 2) * roughness * 0.15);

    // 5 parallel formant filters
    formants = [
        BPF.ar(source, f1, bw1.reciprocal) * a1,
        BPF.ar(source, f2, bw2.reciprocal) * a2,
        BPF.ar(source, f3, bw3.reciprocal) * a3,
        BPF.ar(source, f4, bw4.reciprocal) * a4,
        BPF.ar(source, f5, bw5.reciprocal) * a5
    ].sum * 4;

    sig = formants;
    sig = LPF.ar(sig, 5500);
    sig = (sig * 1.4).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 9: Vowel comparison (a, e, i, o, u)
// ============================================================================
(
var root = 55;

Routine({
    "Experiment 9: 5-Formant Vowel Comparison".postln;

    [\a, \e, \i, \o, \u].do { |vowel|
        var v = ~csangoFormants.tenor[vowel];
        ("  Vowel: " ++ vowel).postln;

        Synth(\csangoVoice5F, [
            \freq, (root + 12).midicps,
            \dur, 1.2,
            \amp, 0.38,
            \vibRate, 5,
            \vibDepth, 0.02,
            \f1, v.freqs[0], \f2, v.freqs[1], \f3, v.freqs[2], \f4, v.freqs[3], \f5, v.freqs[4],
            \a1, v.amps[0], \a2, v.amps[1], \a3, v.amps[2], \a4, v.amps[3], \a5, v.amps[4],
            \bw1, v.bws[0], \bw2, v.bws[1], \bw3, v.bws[2], \bw4, v.bws[3], \bw5, v.bws[4]
        ]);
        1.1.wait;
    };

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 10: Vowel morphing (a -> e -> i)
// ============================================================================
(
var root = 55;

Routine({
    var vowels = [\a, \e, \i];

    "Experiment 10: Vowel Morphing".postln;

    vowels.do { |vowel, vi|
        if(vi < (vowels.size - 1)) {
            var v1 = ~csangoFormants.tenor[vowel];
            var v2 = ~csangoFormants.tenor[vowels[vi + 1]];

            ("  Morphing: " ++ vowel ++ " -> " ++ vowels[vi + 1]).postln;

            // 5 steps of morphing
            5.do { |step|
                var blend = step / 4;
                var v = ~blendFormants.(v1, v2, blend);

                Synth(\csangoVoice5F, [
                    \freq, (root + 12).midicps,
                    \dur, 0.5,
                    \amp, 0.36,
                    \vibRate, 4.5,
                    \f1, v.freqs[0], \f2, v.freqs[1], \f3, v.freqs[2], \f4, v.freqs[3], \f5, v.freqs[4],
                    \a1, v.amps[0], \a2, v.amps[1], \a3, v.amps[2], \a4, v.amps[3], \a5, v.amps[4],
                    \bw1, v.bws[0], \bw2, v.bws[1], \bw3, v.bws[2], \bw4, v.bws[3], \bw5, v.bws[4]
                ]);
                0.45.wait;
            };
            0.3.wait;
        };
    };

    "Done.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 11: Improved Lament (sirató) with 5-formant voice
// ============================================================================
(
var root = 55;
var scale = ~minorPentatonic;

Routine({
    var drone;

    "Experiment 11: Improved Lament with 5-Formant Voice".postln;

    drone = Synth(\csangoDrone, [\freq, root.midicps, \amp, 0.1]);
    0.8.wait;

    // Lament melody with varying vowels for text-like quality
    [
        [7, 1.3, \a],   // [degree, duration, vowel]
        [6, 0.6, \e],
        [4, 0.9, \a],
        [3, 0.5, \i],
        [4, 0.7, \o],
        [2, 0.9, \a],
        [1, 0.6, \e],
        [0, 1.5, \a],
        [-1, 0.5, \u],
        [0, 2.0, \a]
    ].do { |note|
        var deg = note[0];
        var dur = note[1];
        var vowel = note[2];
        var v = ~csangoFormants.tenor[vowel];

        Synth(\csangoVoice5F, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.1,
            \amp, 0.4,
            \vibRate, 4,
            \vibDepth, 0.025,
            \roughness, 0.3,
            \attack, 0.12,
            \f1, v.freqs[0], \f2, v.freqs[1], \f3, v.freqs[2], \f4, v.freqs[3], \f5, v.freqs[4],
            \a1, v.amps[0], \a2, v.amps[1], \a3, v.amps[2], \a4, v.amps[3], \a5, v.amps[4],
            \bw1, v.bws[0], \bw2, v.bws[1], \bw3, v.bws[2], \bw4, v.bws[3], \bw5, v.bws[4]
        ]);

        (dur * rrand(0.92, 1.1)).wait;
    };

    1.0.wait;
    drone.release;

    "Lament complete.".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 12: Male/Female call and response with formants
// ============================================================================
(
var root = 55;
var scale = ~pentatonic;

Routine({
    "Experiment 12: Male/Female Call and Response".postln;

    2.do { |phrase|
        var tenorVowel = ~csangoFormants.tenor.a;
        var altoVowel = ~csangoFormants.alto.a;

        // Male call (tenor, lower)
        "  Tenor call:".postln;
        [4, 3, 2, 0].do { |deg, i|
            Synth(\csangoVoice5F, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, [0.6, 0.4, 0.5, 0.9].at(i),
                \amp, 0.38,
                \vibRate, 5,
                \vibDepth, 0.02,
                \roughness, 0.3,
                \f1, tenorVowel.freqs[0], \f2, tenorVowel.freqs[1], \f3, tenorVowel.freqs[2],
                \f4, tenorVowel.freqs[3], \f5, tenorVowel.freqs[4],
                \a1, tenorVowel.amps[0], \a2, tenorVowel.amps[1], \a3, tenorVowel.amps[2],
                \a4, tenorVowel.amps[3], \a5, tenorVowel.amps[4],
                \bw1, tenorVowel.bws[0], \bw2, tenorVowel.bws[1], \bw3, tenorVowel.bws[2],
                \bw4, tenorVowel.bws[3], \bw5, tenorVowel.bws[4]
            ]);
            [0.5, 0.35, 0.45, 0.8].at(i).wait;
        };

        0.4.wait;

        // Female response (alto, higher)
        "  Alto response:".postln;
        [4, 3, 2, 1, 0].do { |deg, i|
            Synth(\csangoVoice5F, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, [0.5, 0.35, 0.4, 0.35, 0.8].at(i),
                \amp, 0.35,
                \vibRate, 5.5,
                \vibDepth, 0.018,
                \roughness, 0.15,
                \f1, altoVowel.freqs[0], \f2, altoVowel.freqs[1], \f3, altoVowel.freqs[2],
                \f4, altoVowel.freqs[3], \f5, altoVowel.freqs[4],
                \a1, altoVowel.amps[0], \a2, altoVowel.amps[1], \a3, altoVowel.amps[2],
                \a4, altoVowel.amps[3], \a5, altoVowel.amps[4],
                \bw1, altoVowel.bws[0], \bw2, altoVowel.bws[1], \bw3, altoVowel.bws[2],
                \bw4, altoVowel.bws[3], \bw5, altoVowel.bws[4]
            ]);
            [0.4, 0.3, 0.35, 0.3, 0.7].at(i).wait;
        };

        0.6.wait;
    };

    "Done.".postln;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
