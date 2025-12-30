// ============================================================================
// SHAKUHACHI BREATH - Bamboo Flute Synthesis for Japanese Folk
// ============================================================================
// The shakuhachi is a bamboo flute central to Japanese traditional music.
// Its distinctive breathy tone comes from air rushing across the blowing edge.
//
// Key characteristics:
// - Soft, breathy attack with gradual tone development
// - Pitch bending via head position: meri (down) and kari (up)
// - Timbre changes with pitch bending (meri = darker, kari = brighter)
// - Emphasis on ma (silence) between phrases
// - Range approximately D4 to D6 (standard 1.8 shaku length)
//
// Load core library first:
// "/path/to/studies/japanese_folk/lib/japanese_core.scd".load;
// ============================================================================

// Local scale definitions (if core library not loaded)
(
~inScale = [0, 1, 5, 7, 8];  // A Bb D E F - dark, contemplative
~hirajoshi = [0, 2, 3, 7, 8];  // C D Eb G Ab - koto tuning
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
// SHAKUHACHI SYNTHDEFS
// ============================================================================
(
// Main shakuhachi synth - breathy bamboo flute with body resonance
SynthDef(\shakuhachi, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     attack = 0.15, release = 0.3,
     breathiness = 0.4, brightness = 0.5,
     vibRate = 4.5, vibDepth = 0.008, vibDelay = 0.3|

    var env, vibEnv, vibrato, breath, tone, body, sig;
    var breathEnv, formant1, formant2;

    // Amplitude envelope - slow attack characteristic of shakuhachi
    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.8, 0],
            [attack * 0.3, attack * 0.7, dur - attack - release, release],
            [2, 1, -2, -4]),
        doneAction: 2
    );

    // Breath noise envelope (stronger at attack, fades)
    breathEnv = EnvGen.kr(
        Env([0.8, 1, 0.5, 0.3], [attack, dur * 0.3, dur * 0.5], [2, -2, -3])
    );

    // Delayed vibrato (shakuhachi players add vibrato after tone establishes)
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.15]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * freq * vibDepth * vibEnv;

    // Breath noise component (wind rushing over edge)
    breath = BPF.ar(
        WhiteNoise.ar,
        freq * 2,  // Noise centered around second harmonic
        0.5
    ) * breathiness * breathEnv;

    // Pure tone with slight harmonic content
    tone = SinOsc.ar(freq + vibrato)
         + (SinOsc.ar((freq + vibrato) * 2) * 0.3)   // 2nd harmonic
         + (SinOsc.ar((freq + vibrato) * 3) * 0.15)  // 3rd harmonic
         + (SinOsc.ar((freq + vibrato) * 4) * 0.05); // 4th harmonic (weak)

    // Bamboo body resonance (formants)
    formant1 = BPF.ar(tone + breath, 800, 0.4) * 2;   // Main resonance
    formant2 = BPF.ar(tone + breath, 2200, 0.3) * 1.5; // Upper resonance

    sig = tone + breath + formant1 + formant2;

    // Brightness control via low-pass filter
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));

    // Gentle soft-clip for warmth
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi with meri (downward pitch bend + darker timbre)
SynthDef(\shakuhachiMeri, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     meriDepth = 1.0, meriTime = 0.25,
     attack = 0.12, release = 0.25,
     breathiness = 0.5|

    var env, meriEnv, currentFreq, breath, tone, sig;
    var brightnessEnv, formant1, formant2;

    // Meri pitch envelope - bend down and settle
    meriEnv = EnvGen.kr(
        Env([0, meriDepth.neg, meriDepth.neg * 0.8],
            [meriTime * 0.4, meriTime * 0.6],
            \sine)
    );
    currentFreq = freq * (2 ** (meriEnv / 12)); // Convert semitones to ratio

    // Brightness decreases with meri (head tilted = darker sound)
    brightnessEnv = EnvGen.kr(
        Env([1, 0.5, 0.6], [meriTime * 0.5, dur - meriTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, dur - attack - release, release], [2, -2, -4]),
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

// Shakuhachi with kari (upward pitch bend + brighter timbre)
SynthDef(\shakuhachiKari, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.8, pan = 0,
     kariDepth = 0.5, kariTime = 0.15,
     attack = 0.08, release = 0.2,
     breathiness = 0.35|

    var env, kariEnv, currentFreq, breath, tone, sig;
    var brightnessEnv, formant1, formant2;

    // Kari pitch envelope - bend up and settle
    kariEnv = EnvGen.kr(
        Env([0, kariDepth, kariDepth * 0.6],
            [kariTime * 0.4, kariTime * 0.6],
            \sine)
    );
    currentFreq = freq * (2 ** (kariEnv / 12));

    // Brightness increases with kari (chin raised = brighter sound)
    brightnessEnv = EnvGen.kr(
        Env([1, 1.4, 1.2], [kariTime * 0.5, dur - kariTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 1, 0.8, 0], [attack, dur - attack - release, release], [3, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2.5, 0.4) * breathiness;

    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.35)  // Stronger harmonics for kari
         + (SinOsc.ar(currentFreq * 3) * 0.2)
         + (SinOsc.ar(currentFreq * 4) * 0.08);

    formant1 = BPF.ar(tone + breath, 900, 0.4) * 2;
    formant2 = BPF.ar(tone + breath, 2800, 0.3) * 1.8;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * (2 + (brightnessEnv * 6)));
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Meri-Kari cadence - characteristic phrase ending gesture
SynthDef(\shakuhachiMeriKari, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.6, pan = 0,
     breathiness = 0.4|

    var env, bendEnv, currentFreq, breath, tone, sig;
    var brightnessEnv, formant1, formant2;

    // Meri-kari envelope: down -> up -> settle
    bendEnv = EnvGen.kr(
        Env([0, -0.8, 0.2, -0.3, 0],
            [0.15, 0.08, 0.1, 0.08].normalizeSum * dur,
            \sine)
    );
    currentFreq = freq * (2 ** (bendEnv / 12));

    // Brightness follows bend
    brightnessEnv = 0.7 + (bendEnv * 0.15);

    env = EnvGen.kr(
        Env([0, 1, 0.9, 0.7, 0], [0.08, dur * 0.4, dur * 0.35, dur * 0.17], [2, -1, -2, -4]),
        doneAction: 2
    );

    breath = BPF.ar(WhiteNoise.ar, currentFreq * 2, 0.5) * breathiness;

    tone = SinOsc.ar(currentFreq)
         + (SinOsc.ar(currentFreq * 2) * 0.28)
         + (SinOsc.ar(currentFreq * 3) * 0.12);

    formant1 = BPF.ar(tone + breath, 800, 0.45) * 2;
    formant2 = BPF.ar(tone + breath, 2200, 0.35) * 1.4;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, currentFreq * (1.5 + (brightnessEnv * 5)));
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Sustained shakuhachi with gate control (for long held notes)
SynthDef(\shakuhachiSustain, {
    |out = 0, freq = 440, amp = 0.3, gate = 1, pan = 0,
     breathiness = 0.4, brightness = 0.5,
     vibRate = 4.5, vibDepth = 0.01|

    var env, vibrato, breath, tone, sig;
    var formant1, formant2;

    env = EnvGen.kr(Env.asr(0.2, 1, 0.4), gate, doneAction: 2);

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.2).range(-0.15, 0.15))
              * freq * vibDepth;

    breath = BPF.ar(WhiteNoise.ar, (freq + vibrato) * 2, 0.5) * breathiness *
             LFNoise1.kr(2).range(0.7, 1);  // Subtle breath variation

    tone = SinOsc.ar(freq + vibrato)
         + (SinOsc.ar((freq + vibrato) * 2) * 0.3)
         + (SinOsc.ar((freq + vibrato) * 3) * 0.15);

    formant1 = BPF.ar(tone + breath, 800, 0.4) * 2;
    formant2 = BPF.ar(tone + breath, 2200, 0.3) * 1.5;

    sig = tone + breath + formant1 + formant2;
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));
    sig = (sig * 0.8).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Muraiki - explosive breath attack (dramatic effect)
SynthDef(\shakuhachiMuraiki, {
    |out = 0, freq = 440, amp = 0.4, dur = 0.3, pan = 0|

    var env, breathEnv, breath, tone, sig;

    // Sharp attack, quick decay
    env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

    // Strong initial breath burst
    breathEnv = EnvGen.kr(Env.perc(0.005, dur * 0.5, 1, -8));
    breath = BPF.ar(WhiteNoise.ar, freq * 3, 0.8) * breathEnv;

    tone = SinOsc.ar(freq)
         + (SinOsc.ar(freq * 2) * 0.4)
         + (SinOsc.ar(freq * 3) * 0.25);

    sig = (tone * 0.6) + (breath * 0.8);
    sig = HPF.ar(sig, 200);  // Remove low rumble
    sig = (sig * 1.5).clip2(0.8);  // Harder clip for percussive effect

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi V3 - based on spectral analysis of real sample
// Analysis of Alesis Fusion sample showed:
// - H1: 100%, H2: 44%, H3: 1.2%, H4: 4.9%, H5: 2.1%, H6: 1.2%
// - Strong 2nd harmonic is the key shakuhachi characteristic
// - Weak odd harmonics (unlike clarinet)
SynthDef(\shakuhachiV3, {
    |out = 0, freq = 261, amp = 0.3, dur = 2.0, pan = 0,
     breathiness = 0.4, brightness = 0.6,
     vibRate = 4.5, vibDepth = 0.006, vibDelay = 0.5|

    var env, vibEnv, vibrato, sig;
    var h1, h2, h3, h4, h5, h6;
    var noise, breathEnv;

    // Main envelope
    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.9, 0],
            [0.08, 0.12, dur - 0.4, 0.2],
            [3, 1, -2, -4]),
        doneAction: 2
    );

    // Breath envelope - present throughout
    breathEnv = EnvGen.kr(
        Env([0.7, 1, 0.6, 0.4],
            [0.06, dur * 0.3, dur * 0.6],
            [2, -2, -3])
    );

    // Delayed vibrato
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.15]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * freq * vibDepth * vibEnv;

    // Harmonics based on real sample analysis
    h1 = SinOsc.ar(freq + vibrato) * 1.0;
    h2 = SinOsc.ar((freq * 2) + (vibrato * 2)) * 0.44;
    h3 = SinOsc.ar((freq * 3) + (vibrato * 3)) * 0.012;
    h4 = SinOsc.ar((freq * 4) + (vibrato * 4)) * 0.049;
    h5 = SinOsc.ar((freq * 5) + (vibrato * 5)) * 0.021;
    h6 = SinOsc.ar((freq * 6) + (vibrato * 6)) * 0.012;

    sig = h1 + h2 + h3 + h4 + h5 + h6;

    // Breath noise - bandpass around 2nd harmonic area
    noise = BPF.ar(PinkNoise.ar, freq * 2, 0.7) * breathiness * breathEnv;
    sig = sig + noise;

    // Gentle body resonance
    sig = sig + (BPF.ar(sig, 800, 0.4) * 0.3);

    // Brightness control
    sig = LPF.ar(sig, freq * (2 + (brightness * 8)));

    // Soft saturation
    sig = (sig * 0.7).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi V4 - evolving harmonics + constant breath
// Based on analysis showing:
// - H2 grows from 17% (attack) to 44% (sustain)
// - Noise stays constant at ~53% throughout (doesn't fade!)
// - H4 grows from 1.8% to 4.9%
SynthDef(\shakuhachiV4, {
    |out = 0, freq = 261, amp = 0.3, dur = 2.0, pan = 0,
     breathiness = 0.5, brightness = 0.6,
     vibRate = 4.5, vibDepth = 0.006, vibDelay = 0.5|

    var env, vibEnv, vibrato, sig;
    var h1, h2, h3, h4, h5, h6;
    var h2Env, h4Env;
    var noise, breathEnv;

    // Main amplitude envelope
    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.9, 0],
            [0.06, 0.12, dur - 0.38, 0.2],
            [3, 1, -2, -4]),
        doneAction: 2
    );

    // H2 develops over time: 17% at attack -> 44% at sustain
    h2Env = EnvGen.kr(
        Env([0.17, 0.17, 0.44, 0.44],
            [0.05, 0.25, dur - 0.3],
            [0, 3, 0])
    );

    // H4 also develops slightly: 1.8% -> 4.9%
    h4Env = EnvGen.kr(
        Env([0.018, 0.018, 0.049, 0.049],
            [0.05, 0.25, dur - 0.3],
            [0, 2, 0])
    );

    // Breath stays constant throughout (not fading!)
    breathEnv = EnvGen.kr(
        Env([0.8, 1, 1, 0.9],
            [0.04, dur - 0.24, 0.2],
            [2, 0, -2])
    );

    // Delayed vibrato
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.15]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * freq * vibDepth * vibEnv;

    // Harmonics with evolving levels
    h1 = SinOsc.ar(freq + vibrato) * 1.0;
    h2 = SinOsc.ar((freq * 2) + (vibrato * 2)) * h2Env;
    h3 = SinOsc.ar((freq * 3) + (vibrato * 3)) * 0.015;
    h4 = SinOsc.ar((freq * 4) + (vibrato * 4)) * h4Env;
    h5 = SinOsc.ar((freq * 5) + (vibrato * 5)) * 0.02;
    h6 = SinOsc.ar((freq * 6) + (vibrato * 6)) * 0.012;

    sig = h1 + h2 + h3 + h4 + h5 + h6;

    // Strong constant breath noise (~50% energy)
    noise = BPF.ar(PinkNoise.ar, freq * 1.5, 1.2) * breathiness * breathEnv;
    noise = noise + (BPF.ar(WhiteNoise.ar, freq * 3, 0.8) * breathiness * 0.3 * breathEnv);
    sig = sig + noise;

    // Gentle body resonance
    sig = sig + (BPF.ar(sig, 800, 0.4) * 0.2);

    // Brightness control
    sig = LPF.ar(sig, freq * (2 + (brightness * 8)));

    // Soft saturation
    sig = (sig * 0.6).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi V4 Meri - downward pitch bend with darker timbre
SynthDef(\shakuhachiV4Meri, {
    |out = 0, freq = 261, amp = 0.3, dur = 2.0, pan = 0,
     meriDepth = 1.0, meriTime = 0.25,
     breathiness = 0.55, brightness = 0.4,
     vibRate = 4.5, vibDepth = 0.006, vibDelay = 0.5|

    var env, vibEnv, vibrato, sig;
    var h1, h2, h3, h4, h5, h6;
    var h2Env, h4Env;
    var noise, breathEnv;
    var meriEnv, currentFreq, brightnessEnv;

    // Meri pitch envelope - bend down and settle
    meriEnv = EnvGen.kr(
        Env([0, meriDepth.neg, meriDepth.neg * 0.85],
            [meriTime * 0.4, meriTime * 0.6],
            \sine)
    );
    currentFreq = freq * (2 ** (meriEnv / 12));

    // Brightness decreases with meri (darker sound)
    brightnessEnv = EnvGen.kr(
        Env([1, 0.5, 0.6], [meriTime * 0.5, dur - meriTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 0.3, 1, 0.9, 0],
            [0.06, 0.12, dur - 0.38, 0.2],
            [3, 1, -2, -4]),
        doneAction: 2
    );

    h2Env = EnvGen.kr(
        Env([0.17, 0.17, 0.44, 0.44], [0.05, 0.25, dur - 0.3], [0, 3, 0])
    );
    h4Env = EnvGen.kr(
        Env([0.018, 0.018, 0.049, 0.049], [0.05, 0.25, dur - 0.3], [0, 2, 0])
    );

    breathEnv = EnvGen.kr(
        Env([0.8, 1, 1, 0.9], [0.04, dur - 0.24, 0.2], [2, 0, -2])
    );

    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.15]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * currentFreq * vibDepth * vibEnv;

    h1 = SinOsc.ar(currentFreq + vibrato) * 1.0;
    h2 = SinOsc.ar((currentFreq * 2) + (vibrato * 2)) * h2Env;
    h3 = SinOsc.ar((currentFreq * 3) + (vibrato * 3)) * 0.015;
    h4 = SinOsc.ar((currentFreq * 4) + (vibrato * 4)) * h4Env;
    h5 = SinOsc.ar((currentFreq * 5) + (vibrato * 5)) * 0.02;
    h6 = SinOsc.ar((currentFreq * 6) + (vibrato * 6)) * 0.012;

    sig = h1 + h2 + h3 + h4 + h5 + h6;

    noise = BPF.ar(PinkNoise.ar, currentFreq * 1.5, 1.2) * breathiness * breathEnv;
    noise = noise + (BPF.ar(WhiteNoise.ar, currentFreq * 2.5, 0.8) * breathiness * 0.35 * breathEnv);
    sig = sig + noise;

    sig = sig + (BPF.ar(sig, 700, 0.45) * 0.25);
    sig = LPF.ar(sig, currentFreq * (1.5 + (brightness * brightnessEnv * 6)));
    sig = (sig * 0.6).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi V4 Kari - upward pitch bend with brighter timbre
SynthDef(\shakuhachiV4Kari, {
    |out = 0, freq = 261, amp = 0.3, dur = 1.5, pan = 0,
     kariDepth = 0.5, kariTime = 0.15,
     breathiness = 0.45, brightness = 0.7,
     vibRate = 4.5, vibDepth = 0.006, vibDelay = 0.4|

    var env, vibEnv, vibrato, sig;
    var h1, h2, h3, h4, h5, h6;
    var h2Env, h4Env;
    var noise, breathEnv;
    var kariEnv, currentFreq, brightnessEnv;

    // Kari pitch envelope - bend up and settle
    kariEnv = EnvGen.kr(
        Env([0, kariDepth, kariDepth * 0.7],
            [kariTime * 0.4, kariTime * 0.6],
            \sine)
    );
    currentFreq = freq * (2 ** (kariEnv / 12));

    // Brightness increases with kari
    brightnessEnv = EnvGen.kr(
        Env([1, 1.4, 1.25], [kariTime * 0.5, dur - kariTime], \sine)
    );

    env = EnvGen.kr(
        Env([0, 0.4, 1, 0.85, 0],
            [0.04, 0.1, dur - 0.34, 0.2],
            [4, 1, -2, -4]),
        doneAction: 2
    );

    h2Env = EnvGen.kr(
        Env([0.2, 0.2, 0.46, 0.46], [0.03, 0.18, dur - 0.21], [0, 3, 0])
    );
    h4Env = EnvGen.kr(
        Env([0.025, 0.025, 0.06, 0.06], [0.03, 0.18, dur - 0.21], [0, 2, 0])
    );

    breathEnv = EnvGen.kr(
        Env([0.7, 0.95, 0.95, 0.85], [0.03, dur - 0.23, 0.2], [2, 0, -2])
    );

    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.12]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.2, 0.2))
              * currentFreq * vibDepth * vibEnv;

    h1 = SinOsc.ar(currentFreq + vibrato) * 1.0;
    h2 = SinOsc.ar((currentFreq * 2) + (vibrato * 2)) * h2Env;
    h3 = SinOsc.ar((currentFreq * 3) + (vibrato * 3)) * 0.02;
    h4 = SinOsc.ar((currentFreq * 4) + (vibrato * 4)) * h4Env;
    h5 = SinOsc.ar((currentFreq * 5) + (vibrato * 5)) * 0.028;
    h6 = SinOsc.ar((currentFreq * 6) + (vibrato * 6)) * 0.018;

    sig = h1 + h2 + h3 + h4 + h5 + h6;

    noise = BPF.ar(PinkNoise.ar, currentFreq * 2, 1.0) * breathiness * breathEnv;
    noise = noise + (BPF.ar(WhiteNoise.ar, currentFreq * 3.5, 0.7) * breathiness * 0.25 * breathEnv);
    sig = sig + noise;

    sig = sig + (BPF.ar(sig, 900, 0.4) * 0.2);
    sig = sig + (BPF.ar(sig, 2400, 0.35) * 0.15);
    sig = LPF.ar(sig, currentFreq * (2 + (brightness * brightnessEnv * 7)));
    sig = (sig * 0.6).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Shakuhachi V4 Meri-Kari - cadential gesture (down -> up -> settle)
SynthDef(\shakuhachiV4MeriKari, {
    |out = 0, freq = 261, amp = 0.3, dur = 0.8, pan = 0,
     breathiness = 0.5, brightness = 0.55|

    var env, sig;
    var h1, h2, h3, h4, h5, h6;
    var h2Level, noise, breathEnv;
    var bendEnv, currentFreq, brightnessEnv;

    // Meri-kari bend: down -> up -> settle
    bendEnv = EnvGen.kr(
        Env([0, -0.9, 0.25, -0.2, 0],
            [0.12, 0.08, 0.1, 0.08].normalizeSum * dur,
            \sine)
    );
    currentFreq = freq * (2 ** (bendEnv / 12));

    // Brightness follows bend
    brightnessEnv = 0.7 + (bendEnv * 0.12);

    env = EnvGen.kr(
        Env([0, 1, 0.92, 0.8, 0],
            [0.06, dur * 0.35, dur * 0.4, dur * 0.19],
            [3, -1, -2, -4]),
        doneAction: 2
    );

    h2Level = 0.40;

    breathEnv = EnvGen.kr(
        Env([0.85, 1, 1, 0.85], [0.04, dur - 0.14, 0.1], [2, 0, -2])
    );

    h1 = SinOsc.ar(currentFreq) * 1.0;
    h2 = SinOsc.ar(currentFreq * 2) * h2Level;
    h3 = SinOsc.ar(currentFreq * 3) * 0.015;
    h4 = SinOsc.ar(currentFreq * 4) * 0.045;
    h5 = SinOsc.ar(currentFreq * 5) * 0.02;
    h6 = SinOsc.ar(currentFreq * 6) * 0.012;

    sig = h1 + h2 + h3 + h4 + h5 + h6;

    noise = BPF.ar(PinkNoise.ar, currentFreq * 1.8, 1.1) * breathiness * breathEnv;
    noise = noise + (BPF.ar(WhiteNoise.ar, currentFreq * 3, 0.8) * breathiness * 0.3 * breathEnv);
    sig = sig + noise;

    sig = sig + (BPF.ar(sig, 800, 0.45) * 0.2);
    sig = LPF.ar(sig, currentFreq * (1.5 + (brightness * brightnessEnv * 5)));
    sig = (sig * 0.6).tanh;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic shakuhachi tone with vibrato
// ============================================================================
(
Routine({
    var root = 62;  // D4 - standard shakuhachi root
    var scale = ~inScale;

    "Basic shakuhachi tone with delayed vibrato:".postln;
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \vibRate, 4.5,
        \vibDepth, 0.01,
        \vibDelay, 0.4,
        \breathiness, 0.4,
        \amp, 0.35
    ]);

    3.0.wait;

    "Without vibrato (pure tone):".postln;
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.0,
        \vibRate, 0,
        \vibDepth, 0,
        \breathiness, 0.35,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Meri and Kari comparison
// ============================================================================
(
Routine({
    var root = 62;
    var scale = ~inScale;
    var note = ~scaleToFreq.(root, scale, 2);  // D (5th degree)

    "Meri (downward bend, darker):".postln;
    Synth(\shakuhachiV4Meri, [
        \freq, note,
        \dur, 1.8,
        \meriDepth, 1.2,
        \meriTime, 0.3,
        \amp, 0.35
    ]);

    2.5.wait;

    "Kari (upward bend, brighter):".postln;
    Synth(\shakuhachiV4Kari, [
        \freq, note,
        \dur, 1.5,
        \kariDepth, 0.5,
        \kariTime, 0.18,
        \amp, 0.35
    ]);

    2.0.wait;

    "Meri-Kari cadence gesture:".postln;
    Synth(\shakuhachiV4MeriKari, [
        \freq, note,
        \dur, 0.8,
        \amp, 0.38
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 3: Simple phrase with ma (silence)
// ============================================================================
(
Routine({
    var root = 62;
    var scale = ~inScale;

    "Shakuhachi phrase with ma (intentional silence):".postln;

    // First note - establish
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \vibDelay, 0.5,
        \amp, 0.35
    ]);
    1.8.wait;

    // Ma (silence) - let the note breathe
    0.8.wait;

    // Second note - respond
    Synth(\shakuhachiV4Meri, [
        \freq, ~scaleToFreq.(root, scale, 1),
        \dur, 1.2,
        \meriDepth, 0.8,
        \amp, 0.33
    ]);
    1.5.wait;

    // Longer ma
    1.2.wait;

    // Third note - conclude with cadence
    Synth(\shakuhachiV4MeriKari, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 1.0,
        \amp, 0.36
    ]);
    1.3.wait;

    // Final rest
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \vibRate, 4,
        \vibDepth, 0.012,
        \breathiness, 0.3,
        \amp, 0.32
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 4: In scale melody (dark, contemplative)
// ============================================================================
(
var root = 62;
var scale = ~inScale;
// In scale: A Bb D E F - intervals emphasize semitone tension
var melody = [0, 1, 2, 3, 2, 1, 0, -1, 0];
var durations = [0.8, 0.5, 0.7, 1.2, 0.6, 0.5, 0.8, 0.4, 1.5];
var hasMeri = [false, true, false, false, true, false, false, true, false];

Routine({
    "In scale melody (dark character):".postln;

    melody.do { |deg, i|
        var dur = durations[i];

        if(hasMeri[i]) {
            Synth(\shakuhachiV4Meri, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.1,
                \meriDepth, 0.7,
                \meriTime, 0.2,
                \amp, 0.34
            ]);
        } {
            Synth(\shakuhachiV4, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.1,
                \vibRate, if(dur > 0.8, 4.5, 0),
                \vibDepth, 0.008,
                \breathiness, 0.4,
                \amp, 0.34
            ]);
        };

        // Add ma after longer notes
        if(dur > 0.9) {
            (dur + rrand(0.3, 0.6)).wait;
        } {
            dur.wait;
        };
    };
}).play;
)

// ============================================================================
// EXPERIMENT 5: Breath-based phrasing (natural breathing arc)
// ============================================================================
(
var root = 62;
var scale = ~hirajoshi;  // Hirajoshi for variety

Routine({
    "Breath-based phrasing (2-4 second phrases):".postln;

    // Phrase 1 - ascending, gaining intensity
    [0, 1, 2, 3].do { |deg, i|
        var dur = [0.5, 0.4, 0.5, 0.9][i];
        var amp = 0.28 + (i * 0.03);  // Crescendo through phrase

        Synth(\shakuhachiV4, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.15,
            \vibRate, if(dur > 0.6, 4.5, 0),
            \amp, amp,
            \breathiness, 0.35
        ]);
        dur.wait;
    };

    // Breath pause (ma)
    rrand(0.6, 1.0).wait;

    // Phrase 2 - descending, releasing
    [3, 2, 1, 0].do { |deg, i|
        var dur = [0.6, 0.5, 0.6, 1.2][i];
        var amp = 0.38 - (i * 0.025);  // Decrescendo

        if(i == 3) {
            // Final note with meri-kari cadence
            Synth(\shakuhachiV4MeriKari, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur,
                \amp, amp
            ]);
        } {
            Synth(\shakuhachiV4, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.1,
                \vibRate, if(dur > 0.5, 4, 0),
                \amp, amp
            ]);
        };
        dur.wait;
    };

    // Long rest
    1.5.wait;

    // Phrase 3 - single contemplative note
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 3.0,
        \vibRate, 4.5,
        \vibDepth, 0.012,
        \vibDelay, 0.6,
        \amp, 0.32
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 6: Jo-Ha-Kyu structure (slow-break-rapid)
// ============================================================================
(
var root = 62;
var scale = ~inScale;

Routine({
    "Jo-Ha-Kyu structure demonstration:".postln;

    // JO (序) - slow introduction, establishing mood
    "Jo (slow introduction):".postln;
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 2.5,
        \vibDelay, 0.8,
        \breathiness, 0.35,
        \amp, 0.3
    ]);
    3.2.wait;

    Synth(\shakuhachiV4Meri, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 2.0,
        \meriDepth, 1.0,
        \amp, 0.32
    ]);
    2.8.wait;

    // HA (破) - development, increasing activity
    "Ha (development):".postln;
    [1, 2, 3, 2, 1, 2, 3, 4].do { |deg, i|
        var dur = [0.6, 0.5, 0.7, 0.4, 0.5, 0.4, 0.5, 0.8][i];
        var useMeri = [2, 5].includes(i);

        if(useMeri) {
            Synth(\shakuhachiV4Meri, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.05,
                \meriDepth, 0.6,
                \amp, 0.34
            ]);
        } {
            Synth(\shakuhachiV4, [
                \freq, ~scaleToFreq.(root, scale, deg),
                \dur, dur * 1.05,
                \vibRate, if(dur > 0.5, 4.5, 0),
                \amp, 0.34
            ]);
        };
        dur.wait;
    };

    0.4.wait;

    // KYU (急) - rapid conclusion
    "Kyu (rapid conclusion):".postln;
    [4, 3, 2, 1, 0].do { |deg, i|
        var dur = 0.25 - (i * 0.02);  // Accelerating

        Synth(\shakuhachiV4, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, dur * 1.3,
            \attack, 0.05,
            \vibRate, 0,
            \amp, 0.36
        ]);
        dur.wait;
    };

    // Final muraiki burst
    0.1.wait;
    Synth(\shakuhachiMuraiki, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 0.4,
        \amp, 0.42
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 7: Muraiki (explosive breath) demonstration
// ============================================================================
(
Routine({
    var root = 62;
    var scale = ~inScale;

    "Muraiki (explosive breath attack):".postln;

    // Normal tone for comparison
    "Normal attack:".postln;
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.0,
        \amp, 0.35
    ]);
    1.5.wait;

    // Muraiki - dramatic accent
    "Muraiki:".postln;
    Synth(\shakuhachiMuraiki, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 0.35,
        \amp, 0.45
    ]);
    0.6.wait;

    // Follow with sustained tone
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.5,
        \attack, 0.08,
        \amp, 0.32
    ]);
    2.0.wait;

    // Muraiki sequence
    "Muraiki sequence:".postln;
    [0, 2, 3, 2, 0].do { |deg|
        Synth(\shakuhachiMuraiki, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.25,
            \amp, 0.4
        ]);
        0.35.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 8: Ornamented phrase with all techniques
// ============================================================================
(
var root = 62;
var scale = ~inScale;

Routine({
    "Full ornamented shakuhachi phrase:".postln;

    // Opening - slow, establishing with meri
    Synth(\shakuhachiV4Meri, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 1.8,
        \meriDepth, 1.2,
        \meriTime, 0.35,
        \amp, 0.33
    ]);
    2.3.wait;

    // Step down with vibrato
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \dur, 1.2,
        \vibRate, 4.5,
        \vibDepth, 0.01,
        \vibDelay, 0.3,
        \amp, 0.34
    ]);
    1.5.wait;

    // Kari for brightness contrast
    Synth(\shakuhachiV4Kari, [
        \freq, ~scaleToFreq.(root, scale, 3),
        \dur, 0.9,
        \kariDepth, 0.4,
        \amp, 0.36
    ]);
    1.1.wait;

    // Quick descent
    [2, 1].do { |deg|
        Synth(\shakuhachiV4, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.4,
            \attack, 0.06,
            \vibRate, 0,
            \amp, 0.32
        ]);
        0.35.wait;
    };

    // Meri-kari cadence on tonic
    Synth(\shakuhachiV4MeriKari, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 0.9,
        \amp, 0.35
    ]);
    1.1.wait;

    // Ma
    0.8.wait;

    // Final sustained tonic
    Synth(\shakuhachiV4, [
        \freq, ~scaleToFreq.(root, scale, 0),
        \dur, 3.0,
        \vibRate, 4,
        \vibDepth, 0.012,
        \vibDelay, 0.5,
        \breathiness, 0.3,
        \amp, 0.3
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 9: Comparing breathiness levels
// ============================================================================
(
Routine({
    var root = 62;
    var scale = ~inScale;
    var note = ~scaleToFreq.(root, scale, 2);

    "Breathiness comparison:".postln;

    "Low breathiness (more pure tone):".postln;
    Synth(\shakuhachiV4, [
        \freq, note,
        \dur, 1.5,
        \breathiness, 0.15,
        \brightness, 0.6,
        \amp, 0.35
    ]);
    2.0.wait;

    "Medium breathiness (balanced):".postln;
    Synth(\shakuhachiV4, [
        \freq, note,
        \dur, 1.5,
        \breathiness, 0.4,
        \brightness, 0.5,
        \amp, 0.35
    ]);
    2.0.wait;

    "High breathiness (wind-like):".postln;
    Synth(\shakuhachiV4, [
        \freq, note,
        \dur, 1.5,
        \breathiness, 0.7,
        \brightness, 0.4,
        \amp, 0.35
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 10: Sustained note with gate control
// ============================================================================
(
Routine({
    var root = 62;
    var scale = ~inScale;
    var synth;

    "Sustained shakuhachi (gate-controlled):".postln;

    synth = Synth(\shakuhachiSustain, [
        \freq, ~scaleToFreq.(root, scale, 2),
        \vibRate, 4.5,
        \vibDepth, 0.01,
        \breathiness, 0.4,
        \amp, 0.32
    ]);

    "Holding note...".postln;
    4.0.wait;

    "Releasing...".postln;
    synth.release;
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
