// ============================================================================
// ORNAMENT COMPARISON - Verbunkos vs Kobushi
// ============================================================================
// Hungarian verbunkos: ADDITIVE - grace notes, runs, trills between pitches
// Japanese kobushi: TRANSFORMATIVE - inflecting single notes (rise-fall-settle)
//
// Both traditions describe their ornamentation as creating a "crying" sound.
// ============================================================================

// Shared scales
(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~inScale = [0, 1, 5, 7, 8];

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
// SYNTHDEFS
// ============================================================================
(
// Plain tone (unornamented baseline)
SynthDef(\plainTone, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0|

    var env, sig;

    env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
    sig = LPF.ar(sig, freq * 4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hungarian violin with vibrato
SynthDef(\hungViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     vibRate = 5.5, vibDepth = 0.018|

    var env, vibrato, sig;
    var formant1, formant2;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.05, dur - 0.12, 0.07], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.4, 0.4))
              * freq * vibDepth;

    sig = LFSaw.ar(freq + vibrato);
    formant1 = BPF.ar(sig, 460, 0.25) * 2.5;
    formant2 = BPF.ar(sig, 2500, 0.2) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, freq * 6);
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hungarian grace note (előke)
SynthDef(\hungGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.04, pan = 0|

    var env, sig;

    env = EnvGen.kr(Env.perc(0.003, dur), doneAction: 2);
    sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 800, 0.5) * 2 + (sig * 0.4);
    sig = LPF.ar(sig, freq * 5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hungarian slide (csúsztatás)
SynthDef(\hungSlide, {
    |out = 0, startFreq = 440, endFreq = 494, amp = 0.3, dur = 0.4,
     slideTime = 0.1, pan = 0, vibRate = 5, vibDepth = 0.015|

    var env, freqEnv, vibrato, sig;
    var formant1, formant2, currentFreq;

    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.01, slideTime], \exp));
    currentFreq = freqEnv;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.04, dur - 0.1, 0.06], [2, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate) * currentFreq * vibDepth;

    sig = LFSaw.ar(currentFreq + vibrato);
    formant1 = BPF.ar(sig, 460, 0.25) * 2.5;
    formant2 = BPF.ar(sig, 2500, 0.2) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * 6);
    sig = (sig * 1.3).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Hungarian trill (trilla)
SynthDef(\hungTrill, {
    |out = 0, freq = 440, trillFreq = 466, amp = 0.3, dur = 0.5,
     trillRate = 9, pan = 0|

    var env, trill, currentFreq, sig;
    var formant1, formant2;

    trill = LFPulse.kr(trillRate + LFNoise1.kr(1).range(-1, 1));
    currentFreq = trill.linlin(0, 1, freq, trillFreq);

    env = EnvGen.kr(Env.linen(0.02, dur * 0.85, dur * 0.13), doneAction: 2);

    sig = LFSaw.ar(currentFreq);
    formant1 = BPF.ar(sig, 460, 0.25) * 2.5;
    formant2 = BPF.ar(sig, 2500, 0.2) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * 5);
    sig = (sig * 1.2).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Japanese voice/shakuhachi with kobushi
SynthDef(\japKobushi, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     kobushiDepth = 0.03, kobushiTime = 0.12, kobushiDelay = 0.15,
     breathiness = 0.35|

    var env, kobushiEnv, currentFreq, breath, tone, sig;
    var formant1, formant2;

    // Kobushi envelope: rise -> fall -> settle (the "crying" shape)
    kobushiEnv = EnvGen.kr(
        Env(
            [0, kobushiDepth, kobushiDepth.neg * 0.7, kobushiDepth * 0.3, 0],
            [0.02, 0.04, 0.03, 0.03].normalizeSum * kobushiTime,
            \sine
        ),
        EnvGen.kr(Env([0, 0, 1], [kobushiDelay, 0.01]))  // Delayed trigger
    );

    currentFreq = freq * (1 + kobushiEnv);

    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.8, 0], [0.1, 0.08, dur - 0.3, 0.12], [2, 1, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2, 0.5) * breathiness;

    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.3)
         + (SinOsc.ar(currentFreq * 3) * 0.15);

    formant1 = BPF.ar(tone + breath, 800, 0.4) * 2;
    formant2 = BPF.ar(tone + breath, 2200, 0.3) * 1.5;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * 5);
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Japanese with multiple kobushi (melismatic)
SynthDef(\japMelisma, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.5, pan = 0,
     breathiness = 0.35|

    var env, kobushi1, kobushi2, kobushi3, currentFreq, breath, tone, sig;
    var formant1, formant2;
    var depth = 0.025;

    // Multiple kobushi in sequence
    kobushi1 = EnvGen.kr(
        Env([0, depth, depth.neg * 0.6, 0], [0.05, 0.04, 0.03], \sine),
        EnvGen.kr(Env([0, 0, 1], [0.1, 0.01]))
    );

    kobushi2 = EnvGen.kr(
        Env([0, depth * 0.8, depth.neg * 0.5, 0], [0.04, 0.035, 0.025], \sine),
        EnvGen.kr(Env([0, 0, 1], [0.35, 0.01]))
    );

    kobushi3 = EnvGen.kr(
        Env([0, depth * 1.2, depth.neg * 0.8, depth * 0.2, 0], [0.05, 0.05, 0.03, 0.03], \sine),
        EnvGen.kr(Env([0, 0, 1], [0.6, 0.01]))
    );

    currentFreq = freq * (1 + kobushi1 + kobushi2 + kobushi3);

    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.9, 0.7, 0], [0.1, 0.1, dur * 0.5, dur * 0.2, 0.1], [2, 1, -1, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2, 0.5) * breathiness;
    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.3)
         + (SinOsc.ar(currentFreq * 3) * 0.12);

    formant1 = BPF.ar(tone + breath, 800, 0.4) * 2;
    formant2 = BPF.ar(tone + breath, 2200, 0.3) * 1.5;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * 5);
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Japanese meri (pitch bend down with timbre change)
SynthDef(\japMeri, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     meriDepth = 1.0, meriTime = 0.25, breathiness = 0.4|

    var env, meriEnv, currentFreq, brightnessEnv, breath, tone, sig;
    var formant1, formant2;

    // Meri: pitch down + darker timbre
    meriEnv = EnvGen.kr(
        Env([0, meriDepth.neg, meriDepth.neg * 0.8], [meriTime * 0.4, meriTime * 0.6], \sine)
    );
    currentFreq = freq * (2 ** (meriEnv / 12));

    brightnessEnv = EnvGen.kr(
        Env([1, 0.5, 0.6], [meriTime * 0.5, dur - meriTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.1, dur - 0.2, 0.1], [2, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 1.5, 0.6) * breathiness;
    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.25)
         + (SinOsc.ar(currentFreq * 3) * 0.1);

    formant1 = BPF.ar(tone + breath, 700, 0.5) * 2;
    formant2 = BPF.ar(tone + breath, 1800, 0.4) * 1.2;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * (1.5 + (brightnessEnv * 4)));
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Plain note (baseline)
// ============================================================================
(
Routine({
    var freq = 440;

    "PLAIN NOTE (no ornamentation):".postln;
    Synth(\plainTone, [\freq, freq, \dur, 1.2, \amp, 0.35]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Hungarian additive ornamentation
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "=== HUNGARIAN ADDITIVE ORNAMENTATION ===".postln;
    "Grace notes, runs, and trills ADD notes to the melody".postln;
    "".postln;

    // Single note with grace note from below (előke)
    "Grace note (előke) from below:".postln;
    Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04, \amp, 0.2]);
    0.03.wait;
    Synth(\hungViolin, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.8, \amp, 0.36]);

    1.2.wait;

    // Single note with grace note from above
    "Grace note from above:".postln;
    Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.04, \amp, 0.2]);
    0.03.wait;
    Synth(\hungViolin, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.8, \amp, 0.36]);

    1.2.wait;

    // Turn (double grace)
    "Turn (gruppetto):".postln;
    Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.035, \amp, 0.18]);
    0.03.wait;
    Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.035, \amp, 0.18]);
    0.03.wait;
    Synth(\hungViolin, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.8, \amp, 0.36]);

    1.2.wait;

    // Trill
    "Trill (trilla):".postln;
    Synth(\hungTrill, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \trillFreq, ~scaleToFreq.(root, scale, 5),
        \dur, 1.0,
        \trillRate, 10,
        \amp, 0.35
    ]);

    1.3.wait;

    // Slide (csúsztatás)
    "Slide (csúsztatás):".postln;
    Synth(\hungSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 2),
        \endFreq, ~scaleToFreq.(root, scale, 4),
        \dur, 0.8,
        \slideTime, 0.15,
        \amp, 0.36
    ]);

    1.2.wait;

    // Scalar run (cifrázás)
    "Scalar run (cifrázás):".postln;
    [2, 3, 4, 5, 4].do { |deg, i|
        var dur = [0.08, 0.08, 0.08, 0.08, 0.5][i];
        Synth(\hungViolin, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.2,
            \amp, if(i < 4, 0.25, 0.36),
            \vibRate, if(dur > 0.3, 5, 0)
        ]);
        dur.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Japanese transformative ornamentation
// ============================================================================
(
var root = 62;
var scale = ~inScale;

Routine({
    "=== JAPANESE TRANSFORMATIVE ORNAMENTATION ===".postln;
    "Kobushi and meri TRANSFORM the note itself".postln;
    "".postln;

    // Single kobushi
    "Single kobushi (rise-fall-settle):".postln;
    Synth(\japKobushi, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \kobushiDepth, 0.03,
        \kobushiTime, 0.12,
        \kobushiDelay, 0.2,
        \amp, 0.36
    ]);

    2.0.wait;

    // Deeper kobushi
    "Deeper kobushi (more emotional):".postln;
    Synth(\japKobushi, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \kobushiDepth, 0.05,
        \kobushiTime, 0.15,
        \kobushiDelay, 0.15,
        \amp, 0.36
    ]);

    2.0.wait;

    // Multiple kobushi (melismatic)
    "Multiple kobushi (melismatic singing):".postln;
    Synth(\japMelisma, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 2.0,
        \amp, 0.36
    ]);

    2.5.wait;

    // Meri (pitch + timbre change)
    "Meri (pitch down + darker timbre):".postln;
    Synth(\japMeri, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \meriDepth, 1.2,
        \meriTime, 0.3,
        \amp, 0.36
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Side-by-side - same target note, different ornamentation
// ============================================================================
(
Routine({
    var hungRoot = 60;
    var japRoot = 62;
    var targetNote = 4;  // 4th scale degree

    "=== SIDE-BY-SIDE COMPARISON ===".postln;
    "Same melodic intent, different ornament philosophy".postln;
    "".postln;

    // Plain note
    "Plain (unornamented):".postln;
    Synth(\plainTone, [
        \freq, ~scaleToFreq.(hungRoot, ~hungarianMinor, targetNote),
        \dur, 1.0,
        \amp, 0.35
    ]);

    1.5.wait;

    // Hungarian: adds notes before
    "Hungarian (adds grace note before):".postln;
    Synth(\hungGrace, [\freq, ~scaleToFreq.(hungRoot, ~hungarianMinor, targetNote - 1), \dur, 0.04]);
    0.03.wait;
    Synth(\hungViolin, [
        \freq, ~scaleToFreq.(hungRoot, ~hungarianMinor, targetNote),
        \dur, 1.0,
        \amp, 0.36
    ]);

    1.5.wait;

    // Japanese: transforms the note itself
    "Japanese (transforms the note with kobushi):".postln;
    Synth(\japKobushi, [
        \freq, ~scaleToFreq.(japRoot, ~inScale, targetNote.min(4)),
        \dur, 1.2,
        \kobushiDepth, 0.035,
        \amp, 0.36
    ]);

    2.0.wait;

    "".postln;
    "Key difference:".postln;
    "- Hungarian ADDED a grace note (more notes)".postln;
    "- Japanese TRANSFORMED the main note (same note, inflected)".postln;
}).play;
)

// ============================================================================
// EXPERIMENT 5: The "crying" quality comparison
// ============================================================================
(
Routine({
    var hungRoot = 60;
    var japRoot = 62;

    "=== THE 'CRYING' QUALITY ===".postln;
    "Both traditions describe their ornaments as creating weeping/crying sounds".postln;
    "".postln;

    // Hungarian crying: vibrato + slides + grace notes
    "Hungarian 'sírva' (weeping):".postln;
    "Wide vibrato, descending slides, crushing grace notes".postln;
    {
        // Grace-slide-vibrato phrase
        Synth(\hungGrace, [\freq, ~scaleToFreq.(hungRoot, ~hungarianMinor, 5), \dur, 0.04, \amp, 0.2]);
        0.03.wait;
        Synth(\hungSlide, [
            \startFreq, ~scaleToFreq.(hungRoot, ~hungarianMinor, 4),
            \endFreq, ~scaleToFreq.(hungRoot, ~hungarianMinor, 3),
            \dur, 0.9,
            \slideTime, 0.2,
            \vibDepth, 0.025,  // Wide vibrato
            \amp, 0.36
        ]);
        0.8.wait;

        Synth(\hungViolin, [
            \freq, ~scaleToFreq.(hungRoot, ~hungarianMinor, 2),
            \dur, 1.2,
            \vibRate, 5,
            \vibDepth, 0.022,
            \amp, 0.34
        ]);
    }.value;

    2.5.wait;

    // Japanese crying: kobushi
    "Japanese 'crying' (kobushi):".postln;
    "The rise-fall-settle contour mimics a sob".postln;
    {
        Synth(\japKobushi, [
            \freq, ~scaleToFreq.(japRoot, ~inScale, 3),
            \dur, 1.5,
            \kobushiDepth, 0.045,  // Deep for emotional effect
            \kobushiTime, 0.14,
            \kobushiDelay, 0.12,
            \amp, 0.36
        ]);
        1.6.wait;

        Synth(\japMeri, [
            \freq, ~scaleToFreq.(japRoot, ~inScale, 2),
            \dur, 1.3,
            \meriDepth, 1.0,
            \amp, 0.34
        ]);
    }.value;
}).play;
)

// ============================================================================
// EXPERIMENT 6: Hybrid - kobushi inflection + Hungarian connections
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "=== HYBRID EXPERIMENT ===".postln;
    "Kobushi-style inflection on notes, Hungarian-style runs between them".postln;
    "".postln;

    // Note 1: with kobushi-like inflection
    Synth(\japKobushi, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \kobushiDepth, 0.025,
        \kobushiDelay, 0.15,
        \breathiness, 0,
        \amp, 0.35
    ]);
    0.9.wait;

    // Hungarian run connecting to next note
    [5, 4, 3].do { |deg|
        Synth(\hungGrace, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.05,
            \amp, 0.22
        ]);
        0.04.wait;
    };

    // Note 2: with kobushi
    Synth(\japKobushi, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.2,
        \kobushiDepth, 0.03,
        \kobushiDelay, 0.12,
        \breathiness, 0,
        \amp, 0.36
    ]);
    1.0.wait;

    // Slide to final note
    Synth(\hungSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 2),
        \endFreq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.0,
        \slideTime, 0.15,
        \amp, 0.34
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Ornamented phrase comparison
// ============================================================================
(
Routine({
    var melody = [4, 3, 2, 0];

    "=== FULL ORNAMENTED PHRASE COMPARISON ===".postln;
    "".postln;

    // Hungarian ornamented phrase
    "Hungarian ornamented phrase:".postln;
    {
        var root = 60;
        var scale = ~hungarianMinor;

        // Note 1 with grace
        Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04, \amp, 0.2]);
        0.03.wait;
        Synth(\hungViolin, [\freq, ~scaleToFreq.(root, scale, 4), \dur, 0.7, \amp, 0.36]);
        0.6.wait;

        // Note 2 with trill
        Synth(\hungTrill, [
            \freq, ~scaleToFreq.(root, scale, 3),
            \trillFreq, ~scaleToFreq.(root, scale, 4),
            \dur, 0.5,
            \trillRate, 9,
            \amp, 0.34
        ]);
        0.45.wait;

        // Note 3 with slide from above
        Synth(\hungSlide, [
            \startFreq, ~scaleToFreq.(root, scale, 3),
            \endFreq, ~scaleToFreq.(root, scale, 2),
            \dur, 0.6,
            \slideTime, 0.12,
            \amp, 0.35
        ]);
        0.55.wait;

        // Final note with turn
        Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, 1), \dur, 0.035, \amp, 0.18]);
        0.03.wait;
        Synth(\hungGrace, [\freq, ~scaleToFreq.(root, scale, -1), \dur, 0.035, \amp, 0.18]);
        0.03.wait;
        Synth(\hungViolin, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 1.2, \amp, 0.38, \vibDepth, 0.02]);
    }.value;

    2.5.wait;

    // Japanese ornamented phrase
    "Japanese ornamented phrase:".postln;
    {
        var root = 62;
        var scale = ~inScale;

        // Note 1 with kobushi
        Synth(\japKobushi, [
            \freq, ~scaleToFreq.(root, scale, 3),
            \dur, 1.0,
            \kobushiDepth, 0.03,
            \amp, 0.36
        ]);
        1.1.wait;

        // Note 2 with meri
        Synth(\japMeri, [
            \freq, ~scaleToFreq.(root, scale, 2),
            \dur, 0.9,
            \meriDepth, 0.8,
            \amp, 0.35
        ]);
        1.0.wait;

        // Note 3 with deeper kobushi
        Synth(\japKobushi, [
            \freq, ~scaleToFreq.(root, scale, 1),
            \dur, 0.8,
            \kobushiDepth, 0.04,
            \amp, 0.35
        ]);
        0.9.wait;

        // Final note with melisma
        Synth(\japMelisma, [
            \freq, ~scaleToFreq.(root, scale, 0),
            \dur, 1.8,
            \amp, 0.38
        ]);
    }.value;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
