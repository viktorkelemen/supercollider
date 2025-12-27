// ============================================================================
// FUSION EXPERIMENT - Combining Hungarian and Japanese Techniques
// ============================================================================
// What happens when we blend:
// - Hungarian rubato with Japanese ma
// - Verbunkos ornamentation with kobushi inflection
// - Hungarian minor scale with Japanese modal color
// - The "crying" quality of both traditions
//
// This is not historically accurate - it's an exploration of what these
// two distant traditions might sound like in conversation.
// ============================================================================

(
// Hybrid scale: Hungarian minor with In scale tendencies
// Keeps the augmented 2nd but adds the characteristic semitone at bottom
~fusionScale = [0, 1, 3, 6, 7, 8, 11];  // A Bb C F# G Ab B

// Also keep originals for comparison
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
// FUSION SYNTHDEFS
// ============================================================================
(
// Fusion instrument: violin body + shakuhachi breath
SynthDef(\fusionMelody, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     vibRate = 4.5, vibDepth = 0.012, vibDelay = 0.2,
     breathiness = 0.2, brightness = 0.6,
     kobushiDepth = 0, kobushiDelay = 0.15|

    var env, vibEnv, kobushiEnv, vibrato, breath, tone, string, sig;
    var formant1, formant2, formant3, currentFreq;

    // Envelope combining both characters
    env = EnvGen.kr(
        Env([0, 0.4, 1, 0.8, 0],
            [dur * 0.1, dur * 0.1, dur * 0.6, dur * 0.2],
            [3, 1, -2, -4]),
        doneAction: 2
    );

    // Kobushi inflection (Japanese)
    kobushiEnv = EnvGen.kr(
        Env(
            [0, kobushiDepth, kobushiDepth.neg * 0.7, kobushiDepth * 0.3, 0],
            [0.02, 0.04, 0.03, 0.03],
            \sine
        ),
        EnvGen.kr(Env([0, 0, 1], [kobushiDelay, 0.01]))
    );

    // Delayed vibrato (both traditions do this)
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.1]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.4).range(-0.3, 0.3))
              * freq * vibDepth * vibEnv;

    currentFreq = freq * (1 + kobushiEnv) + vibrato;

    // Breath component (Japanese)
    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2, 0.5) * breathiness;

    // String component (Hungarian) - saw wave with harmonics
    string = LFSaw.ar(currentFreq) * 0.6;

    // Sine component (Japanese purity)
    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.25)
         + (SinOsc.ar(currentFreq * 3) * 0.1);

    // Blend
    sig = (string * 0.4) + (tone * 0.4) + breath;

    // Body resonance - blend of violin and shakuhachi formants
    formant1 = BPF.ar(sig, 380, 0.35) * 2;    // Between 280 (violin) and 800 (shaku)
    formant2 = BPF.ar(sig, 1200, 0.28) * 2;   // Mid
    formant3 = BPF.ar(sig, 2800, 0.22) * 1.5; // Bright

    sig = sig + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, currentFreq * (2 + (brightness * 6)));
    sig = (sig * 1.1).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Fusion with meri-style bend
SynthDef(\fusionMeri, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     bendDepth = 1.0, bendTime = 0.25,
     breathiness = 0.25, brightness = 0.5|

    var env, bendEnv, brightnessEnv, currentFreq, breath, tone, string, sig;
    var formant1, formant2;

    bendEnv = EnvGen.kr(
        Env([0, bendDepth.neg, bendDepth.neg * 0.8], [bendTime * 0.4, bendTime * 0.6], \sine)
    );
    currentFreq = freq * (2 ** (bendEnv / 12));

    brightnessEnv = EnvGen.kr(
        Env([1, 0.5, 0.6], [bendTime * 0.5, dur - bendTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.08, dur - 0.18, 0.1], [2, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 1.5, 0.6) * breathiness;
    string = LFSaw.ar(currentFreq) * 0.5;
    tone = SinOsc.ar(currentFreq) + (SinOsc.ar(currentFreq * 2) * 0.2);

    sig = (string * 0.35) + (tone * 0.45) + breath;

    formant1 = BPF.ar(sig, 400, 0.4) * 2;
    formant2 = BPF.ar(sig, 1500, 0.3) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * (1.5 + (brightnessEnv * 4)));
    sig = (sig * 1.1).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Fusion slide (combining Hungarian slide with Japanese timbre)
SynthDef(\fusionSlide, {
    |out = 0, startFreq = 440, endFreq = 494, amp = 0.3, dur = 0.6, pan = 0,
     slideTime = 0.12, breathiness = 0.15|

    var env, freqEnv, breath, tone, string, sig;
    var formant1, formant2, currentFreq;

    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.01, slideTime], \exp));
    currentFreq = freqEnv;

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [0.05, dur - 0.12, 0.07], [2, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2, 0.5) * breathiness;
    string = LFSaw.ar(currentFreq) * 0.5;
    tone = SinOsc.ar(currentFreq) + (SinOsc.ar(currentFreq * 2) * 0.25);

    sig = (string * 0.4) + (tone * 0.4) + breath;

    formant1 = BPF.ar(sig, 400, 0.35) * 2;
    formant2 = BPF.ar(sig, 1800, 0.28) * 1.5;

    sig = sig + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * 5);
    sig = (sig * 1.1).tanh * 0.8;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Grace note
SynthDef(\fusionGrace, {
    |out = 0, freq = 440, amp = 0.2, dur = 0.04, pan = 0|

    var env, sig;

    env = EnvGen.kr(Env.perc(0.003, dur), doneAction: 2);
    sig = LFSaw.ar(freq) * 0.5 + SinOsc.ar(freq) * 0.5;
    sig = BPF.ar(sig, 800, 0.5) * 2 + (sig * 0.4);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Drone combining both characters
SynthDef(\fusionDrone, {
    |out = 0, freq = 110, amp = 0.15, gate = 1, pan = 0|

    var env, string, breath, sig;

    env = EnvGen.kr(Env.asr(0.5, 1, 0.8), gate, doneAction: 2);

    // String drone (Hungarian)
    string = LFSaw.ar([freq, freq * 1.5]) * [0.5, 0.3];
    string = LPF.ar(string, 500).sum;

    // Breath drone (Japanese sho-like)
    breath = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
    breath = breath + BPF.ar(WhiteNoise.ar * 0.1, freq * 3, 0.3);
    breath = LPF.ar(breath, 800);

    sig = (string * 0.5) + (breath * 0.5);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Fusion scale exploration
// ============================================================================
(
Routine({
    var root = 60;

    "=== FUSION SCALE ===".postln;
    "Hybrid: Hungarian augmented 2nd + Japanese semitone at bottom".postln;
    "Scale: 0-1-3-6-7-8-11 (A Bb C F# G Ab B)".postln;
    "".postln;

    (0..7).do { |deg|
        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(root, ~fusionScale, deg),
            \dur, 0.6,
            \kobushiDepth, 0.015,
            \breathiness, 0.2,
            \amp, 0.34
        ]);
        0.5.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 2: Rubato + Ma combined
// ============================================================================
(
var root = 60;
var scale = ~fusionScale;

Routine({
    "=== RUBATO WITHIN PHRASES, MA BETWEEN ===".postln;
    "Hungarian elastic time + Japanese intentional silence".postln;
    "".postln;

    // Phrase 1 with rubato (stretched/compressed)
    "Phrase 1 (rubato):".postln;
    {
        var phrase = [0, 1, 3, 4];
        var rubatoFactors = [0.9, 0.7, 1.0, 1.4];
        var baseDur = 0.4;

        phrase.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\fusionMelody, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.1,
                \kobushiDepth, if(dur > 0.5, 0.02, 0),
                \amp, 0.34 + (rubatoFactors[i] - 1 * 0.05)
            ]);
            dur.wait;
        };
    }.value;

    // MA - meaningful silence
    "... ma ...".postln;
    1.0.wait;

    // Phrase 2 with rubato
    "Phrase 2 (rubato):".postln;
    {
        var phrase = [4, 3, 1, 0];
        var rubatoFactors = [1.2, 0.85, 0.8, 1.15];
        var baseDur = 0.4;

        phrase.do { |deg, i|
            var dur = baseDur * rubatoFactors[i];
            Synth(\fusionMelody, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.1,
                \kobushiDepth, if(dur > 0.45, 0.018, 0),
                \amp, 0.33
            ]);
            dur.wait;
        };
    }.value;

    // Longer MA
    "... ma ...".postln;
    1.4.wait;

    // Final note
    "Resolution:".postln;
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \kobushiDepth, 0.025,
        \kobushiDelay, 0.3,
        \vibRate, 4.5,
        \vibDepth, 0.015,
        \amp, 0.36
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Hybrid ornamentation
// ============================================================================
(
var root = 60;
var scale = ~fusionScale;

Routine({
    "=== HYBRID ORNAMENTATION ===".postln;
    "Hungarian grace notes + Japanese kobushi on sustained notes".postln;
    "".postln;

    // Grace note (Hungarian) into kobushi note (Japanese)
    "Grace → Kobushi:".postln;
    Synth(\fusionGrace, [\freq, ~scaleToFreq.(root, scale, 3), \dur, 0.04, \amp, 0.2]);
    0.03.wait;
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.2,
        \kobushiDepth, 0.03,
        \kobushiDelay, 0.15,
        \amp, 0.36
    ]);

    1.5.wait;

    // Slide (Hungarian) into meri (Japanese)
    "Slide → Meri:".postln;
    Synth(\fusionSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.5,
        \slideTime, 0.12,
        \amp, 0.35
    ]);
    0.45.wait;
    Synth(\fusionMeri, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.0,
        \bendDepth, 0.8,
        \amp, 0.35
    ]);

    1.5.wait;

    // Double grace (Hungarian turn) into melismatic kobushi
    "Turn → Multiple kobushi:".postln;
    Synth(\fusionGrace, [\freq, ~scaleToFreq.(root, scale, 2), \dur, 0.035, \amp, 0.18]);
    0.03.wait;
    Synth(\fusionGrace, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 0.035, \amp, 0.18]);
    0.03.wait;
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 1.5,
        \kobushiDepth, 0.035,
        \kobushiDelay, 0.1,
        \amp, 0.36
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: Dual "crying" quality
// ============================================================================
(
var root = 60;
var scale = ~fusionScale;

Routine({
    "=== DUAL 'CRYING' QUALITY ===".postln;
    "Both traditions' weeping combined".postln;
    "".postln;

    // The phrase: descending with combined emotional techniques
    Synth(\fusionGrace, [\freq, ~scaleToFreq.(root, scale, 5), \dur, 0.04, \amp, 0.2]);
    0.03.wait;

    // High note with wide vibrato + kobushi
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.0,
        \vibRate, 5,
        \vibDepth, 0.02,  // Wide vibrato (Hungarian)
        \kobushiDepth, 0.025,  // + kobushi (Japanese)
        \kobushiDelay, 0.2,
        \amp, 0.36
    ]);
    0.9.wait;

    // Crying slide down
    Synth(\fusionSlide, [
        \startFreq, ~scaleToFreq.(root, scale, 4),
        \endFreq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.7,
        \slideTime, 0.2,  // Slow, yearning slide
        \amp, 0.35
    ]);
    0.65.wait;

    // Ma (let it breathe)
    0.5.wait;

    // Continue descent with meri
    Synth(\fusionMeri, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.9,
        \bendDepth, 1.0,
        \amp, 0.34
    ]);
    0.85.wait;

    // Final sob
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 0.8,
        \kobushiDepth, 0.04,  // Deep kobushi = sob
        \kobushiDelay, 0.08,
        \amp, 0.35
    ]);
    0.75.wait;

    // Resolution
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \vibRate, 4,
        \vibDepth, 0.015,
        \kobushiDepth, 0.02,
        \kobushiDelay, 0.4,
        \amp, 0.36
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Full fusion piece with drone
// ============================================================================
(
var root = 48;  // Lower for drone
var melodyRoot = 60;
var scale = ~fusionScale;

Routine({
    var drone;

    "=== FULL FUSION PIECE ===".postln;
    "Drone + melody combining both traditions".postln;
    "".postln;

    // Start drone
    drone = Synth(\fusionDrone, [\freq, root.midicps, \amp, 0.18]);

    0.8.wait;

    // Opening phrase (jo - slow introduction)
    "Opening (jo-like):".postln;
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(melodyRoot, scale, 0),
        \dur, 1.8,
        \kobushiDepth, 0.02,
        \kobushiDelay, 0.5,
        \amp, 0.32
    ]);
    2.2.wait;  // Ma

    Synth(\fusionMeri, [
        \freq, ~scaleToFreq.(melodyRoot, scale, 3),
        \dur, 1.5,
        \bendDepth, 0.8,
        \amp, 0.34
    ]);
    2.0.wait;  // Ma

    // Development (ha - breaking)
    "Development (ha-like):".postln;
    {
        var phrase = [1, 3, 4, 3, 1, 3, 4, 5];
        var durs = [0.5, 0.4, 0.7, 0.35, 0.4, 0.35, 0.5, 0.8];
        var rubatoFactors = [1.0, 0.85, 1.3, 0.8, 0.9, 0.8, 1.0, 1.35];

        phrase.do { |deg, i|
            var dur = durs[i] * rubatoFactors[i];
            var hasGrace = [0, 3, 6].includes(i);
            var hasKobushi = dur > 0.55;

            if(hasGrace) {
                Synth(\fusionGrace, [
                    \freq, ~scaleToFreq.(melodyRoot, scale, deg - 1),
                    \dur, 0.04,
                    \amp, 0.18
                ]);
                0.03.wait;
            };

            Synth(\fusionMelody, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, dur * 1.1,
                \kobushiDepth, if(hasKobushi, 0.02, 0),
                \amp, 0.34
            ]);
            dur.wait;
        };
    }.value;

    // Ma before conclusion
    0.8.wait;

    // Conclusion (kyu - rapid)
    "Conclusion (kyu-like):".postln;
    {
        var phrase = [5, 4, 3, 1, 0];
        var durs = [0.25, 0.22, 0.2, 0.18, 0.5];

        phrase.do { |deg, i|
            Synth(\fusionMelody, [
                \freq, ~scaleToFreq.(melodyRoot, scale, deg),
                \dur, durs[i] * 1.5,
                \kobushiDepth, 0,
                \amp, 0.35
            ]);
            durs[i].wait;
        };
    }.value;

    // Final sustained note with full expression
    Synth(\fusionMelody, [
        \freq, ~scaleToFreq.(melodyRoot, scale, 0),
        \dur, 3.0,
        \vibRate, 4.5,
        \vibDepth, 0.018,
        \vibDelay, 0.4,
        \kobushiDepth, 0.025,
        \kobushiDelay, 0.8,
        \amp, 0.38
    ]);

    3.5.wait;

    // Release drone
    drone.release;
}).play;
)

// ============================================================================
// EXPERIMENT 6: Call and response - Hungarian vs Japanese
// ============================================================================
(
var hungRoot = 60;
var japRoot = 62;

Routine({
    "=== CALL AND RESPONSE ===".postln;
    "Hungarian phrase answered by Japanese phrase".postln;
    "".postln;

    // Hungarian call (violin character, rubato, grace notes)
    "Hungarian call:".postln;
    {
        var scale = ~hungarianMinor;

        Synth(\fusionGrace, [\freq, ~scaleToFreq.(hungRoot, scale, 3), \dur, 0.04, \amp, 0.2]);
        0.03.wait;
        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(hungRoot, scale, 4),
            \dur, 0.7,
            \breathiness, 0.1,  // Less breath = more violin
            \kobushiDepth, 0,
            \vibDepth, 0.018,
            \amp, 0.36
        ]);
        0.55.wait;

        Synth(\fusionSlide, [
            \startFreq, ~scaleToFreq.(hungRoot, scale, 4),
            \endFreq, ~scaleToFreq.(hungRoot, scale, 2),
            \slideTime, 0.1,
            \dur, 0.5,
            \breathiness, 0.1,
            \amp, 0.34
        ]);
        0.45.wait;

        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(hungRoot, scale, 0),
            \dur, 0.8,
            \breathiness, 0.1,
            \vibDepth, 0.02,
            \amp, 0.35
        ]);
    }.value;

    // Ma (transition)
    1.2.wait;

    // Japanese response (shakuhachi character, ma, kobushi)
    "Japanese response:".postln;
    {
        var scale = ~inScale;

        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(japRoot, scale, 3),
            \dur, 1.0,
            \breathiness, 0.35,  // More breath = more shakuhachi
            \kobushiDepth, 0.03,
            \kobushiDelay, 0.15,
            \vibDepth, 0.008,
            \amp, 0.35
        ]);
        1.3.wait;  // Note + ma

        Synth(\fusionMeri, [
            \freq, ~scaleToFreq.(japRoot, scale, 2),
            \dur, 0.9,
            \bendDepth, 1.0,
            \breathiness, 0.3,
            \amp, 0.34
        ]);
        1.2.wait;

        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(japRoot, scale, 0),
            \dur, 1.5,
            \breathiness, 0.3,
            \kobushiDepth, 0.025,
            \kobushiDelay, 0.2,
            \amp, 0.35
        ]);
    }.value;

    2.0.wait;

    // Together (fusion)
    "Together (fusion):".postln;
    {
        Synth(\fusionMelody, [
            \freq, ~scaleToFreq.(60, ~fusionScale, 0),
            \dur, 2.5,
            \breathiness, 0.2,
            \kobushiDepth, 0.02,
            \vibDepth, 0.015,
            \amp, 0.38
        ]);
    }.value;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
