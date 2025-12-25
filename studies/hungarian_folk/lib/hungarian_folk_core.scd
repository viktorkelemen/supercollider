// ============================================================================
// HUNGARIAN FOLK CORE LIBRARY
// ============================================================================
// Comprehensive shared resources for all Hungarian folk music experiments.
// Includes scales, easing functions, vocal formants, and physical models.
//
// Usage: "/path/to/hungarian_folk_core.scd".load;
//
// Resources incorporated from:
// - Vowel quark (formant data from Csound)
// - Ease quark (easing functions)
// - Waveguide synthesis (physical modeling)
// ============================================================================

(
// ============================================================================
// SCALES
// ============================================================================

// Hungarian minor: 1 2 b3 #4 5 b6 7 (characteristic augmented second)
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];

// Phrygian-dominant (gypsy/freygish): 1 b2 3 4 5 b6 b7
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

// Mixolydian b2 (regional variation)
~mixoB2 = [0, 1, 4, 5, 7, 9, 10];

// Anhemitonic pentatonic (archaic "old style")
~pentatonic = [0, 2, 4, 7, 9];

// Minor pentatonic (for laments)
~minorPentatonic = [0, 3, 5, 7, 10];

// Lydian pentatonic (raised 4th for brightness)
~lydianPentatonic = [0, 2, 4, 6, 9];

// Dorian (some regions)
~dorianScale = [0, 2, 3, 5, 7, 9, 10];

// ============================================================================
// SCALE UTILITIES
// ============================================================================

// Convert scale degree to frequency
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};

// Get interval in semitones between two scale degrees
~scaleInterval = { |scale, deg1, deg2|
    var idx1 = deg1 % scale.size;
    var idx2 = deg2 % scale.size;
    scale[idx2] - scale[idx1];
};

// Transpose a melody array by semitones
~transposeMelody = { |melody, semitones|
    melody.collect { |deg| deg + semitones };
};

// ============================================================================
// EASING FUNCTIONS
// ============================================================================
// Adapted from Robert Penner's easing equations (via Ease quark)
// Input t should be 0-1, output is 0-1

~easeLinear = { |t| t };

~easeInQuad = { |t| t * t };
~easeOutQuad = { |t| t * (2 - t) };
~easeInOutQuad = { |t|
    if(t < 0.5, { 2 * t * t }, { -1 + ((4 - (2 * t)) * t) })
};

~easeInCubic = { |t| t * t * t };
~easeOutCubic = { |t| var t1 = t - 1; (t1 * t1 * t1) + 1 };
~easeInOutCubic = { |t|
    if(t < 0.5, { 4 * t * t * t }, { ((t - 1) * ((2 * t) - 2) * ((2 * t) - 2)) + 1 })
};

~easeInSine = { |t| 1 - cos(t * pi / 2) };
~easeOutSine = { |t| sin(t * pi / 2) };
~easeInOutSine = { |t| (1 - cos(pi * t)) / 2 };

// Apply easing to a tempo transition (for accelerando/ritardando)
~easedTempo = { |startTempo, endTempo, position, totalSteps, easeFunc|
    var t = position / (totalSteps - 1);
    var easedT = easeFunc.(t);
    startTempo + ((endTempo - startTempo) * easedT)
};

// ============================================================================
// VOWEL FORMANT DATA
// ============================================================================
// From Csound manual / Vowel quark - frequencies, dB, bandwidths
// Provides realistic vocal formants for synthesis

~vowelFormants = (
    // Tenor (good for male folk singing)
    tenor: (
        a: (freqs: [650, 1080, 2650, 2900, 3250], dBs: [0, -6, -7, -8, -22], bws: [80, 90, 120, 130, 140]),
        e: (freqs: [400, 1700, 2600, 3200, 3580], dBs: [0, -14, -12, -14, -20], bws: [70, 80, 100, 120, 120]),
        i: (freqs: [290, 1870, 2800, 3250, 3540], dBs: [0, -15, -18, -20, -30], bws: [40, 90, 100, 120, 120]),
        o: (freqs: [400, 800, 2600, 2800, 3000], dBs: [0, -10, -12, -12, -26], bws: [40, 80, 100, 120, 120]),
        u: (freqs: [350, 600, 2700, 2900, 3300], dBs: [0, -20, -17, -14, -26], bws: [40, 60, 100, 120, 120])
    ),
    // Alto (female folk singing)
    alto: (
        a: (freqs: [800, 1150, 2800, 3500, 4950], dBs: [0, -4, -20, -36, -60], bws: [80, 90, 120, 130, 140]),
        e: (freqs: [400, 1600, 2700, 3300, 4950], dBs: [0, -24, -30, -35, -60], bws: [60, 80, 120, 150, 200]),
        i: (freqs: [350, 1700, 2700, 3700, 4950], dBs: [0, -20, -30, -36, -60], bws: [50, 100, 120, 150, 200]),
        o: (freqs: [450, 800, 2830, 3500, 4950], dBs: [0, -9, -16, -28, -55], bws: [70, 80, 100, 130, 135]),
        u: (freqs: [325, 700, 2530, 3500, 4950], dBs: [0, -12, -30, -40, -64], bws: [50, 60, 170, 180, 200])
    ),
    // Bass (deep male voice)
    bass: (
        a: (freqs: [600, 1040, 2250, 2450, 2750], dBs: [0, -7, -9, -9, -20], bws: [60, 70, 110, 120, 130]),
        e: (freqs: [400, 1620, 2400, 2800, 3100], dBs: [0, -12, -9, -12, -18], bws: [40, 80, 100, 120, 120]),
        i: (freqs: [250, 1750, 2600, 3050, 3340], dBs: [0, -30, -16, -22, -28], bws: [60, 90, 100, 120, 120]),
        o: (freqs: [400, 750, 2400, 2600, 2900], dBs: [0, -11, -21, -20, -40], bws: [40, 80, 100, 120, 120]),
        u: (freqs: [350, 600, 2400, 2675, 2950], dBs: [0, -20, -32, -28, -36], bws: [40, 80, 100, 120, 120])
    )
);

// Interpolate between two vowels (for morphing)
~blendVowels = { |vowel1, vowel2, blend|
    (
        freqs: vowel1.freqs.blend(vowel2.freqs, blend),
        dBs: vowel1.dBs.blend(vowel2.dBs, blend),
        bws: vowel1.bws.blend(vowel2.bws, blend)
    )
};

// ============================================================================
// SHARED EFFECTS BUS
// ============================================================================

~folkReverbBus = Bus.audio(s, 2);

SynthDef(\folkReverb, {
    |in, out = 0, mix = 0.25, room = 0.7, damp = 0.4|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;

// ============================================================================
// VOCAL SYNTHESIS WITH FORMANTS
// ============================================================================

// 5-formant vocal synth using vowel data
SynthDef(\folkVoice, {
    |out = 0, freq = 220, amp = 0.35, dur = 1.0, pan = 0,
     vibRate = 5, vibDepth = 0.015, attack = 0.08,
     // Formant parameters (can be modulated for vowel morphing)
     f1 = 650, f2 = 1080, f3 = 2650, f4 = 2900, f5 = 3250,
     a1 = 0, a2 = -6, a3 = -7, a4 = -8, a5 = -22,
     bw1 = 80, bw2 = 90, bw3 = 120, bw4 = 130, bw5 = 140,
     nasality = 0.3, roughness = 0.2|

    var env, vibrato, source, formants, sig;

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0.7, 0], [attack, dur * 0.3, dur * 0.4, dur * 0.22], [3, -1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.4, 0.4)) * freq * vibDepth;

    // Glottal source with roughness control
    source = (LFSaw.ar(freq + vibrato) * (1 - roughness)) +
             (Pulse.ar(freq + vibrato, 0.4 + LFNoise1.kr(2).range(-0.05, 0.05)) * roughness);

    // 5 parallel formant filters
    formants = [
        BPF.ar(source, f1, bw1.reciprocal) * a1.dbamp,
        BPF.ar(source, f2, bw2.reciprocal) * a2.dbamp,
        BPF.ar(source, f3, bw3.reciprocal) * a3.dbamp * nasality,
        BPF.ar(source, f4, bw4.reciprocal) * a4.dbamp * nasality * 0.7,
        BPF.ar(source, f5, bw5.reciprocal) * a5.dbamp * nasality * 0.5
    ].sum * 3;

    sig = formants;
    sig = LPF.ar(sig, 5000);
    sig = (sig * 1.3).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Simplified vocal for quick use (vowel selected by symbol)
SynthDef(\folkVoiceSimple, {
    |out = 0, freq = 220, amp = 0.35, dur = 1.0, pan = 0,
     vibRate = 5, vibDepth = 0.015, attack = 0.08,
     vowel = 0, register = 0, nasality = 0.4|
    // vowel: 0=a, 1=e, 2=i, 3=o, 4=u
    // register: 0=tenor, 1=alto, 2=bass

    var env, vibrato, source, sig;
    var formantFreqs, formantAmps, formantBWs;

    // Tenor 'a' as default, will be set via args
    formantFreqs = [650, 1080, 2650, 2900, 3250];
    formantAmps = [0, -6, -7, -8, -22].dbamp;
    formantBWs = [80, 90, 120, 130, 140];

    env = EnvGen.kr(
        Env([0, 1, 0.85, 0.7, 0], [attack, dur * 0.3, dur * 0.4, dur * 0.22], [3, -1, -2, -4]),
        doneAction: 2
    );

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.4, 0.4)) * freq * vibDepth;

    source = LFSaw.ar(freq + vibrato) * 0.7 + Pulse.ar(freq + vibrato, 0.4) * 0.3;

    sig = [
        BPF.ar(source, formantFreqs[0], formantBWs[0].reciprocal) * formantAmps[0],
        BPF.ar(source, formantFreqs[1], formantBWs[1].reciprocal) * formantAmps[1],
        BPF.ar(source, formantFreqs[2], formantBWs[2].reciprocal) * formantAmps[2] * nasality,
        BPF.ar(source, formantFreqs[3], formantBWs[3].reciprocal) * formantAmps[3] * nasality * 0.7,
        BPF.ar(source, formantFreqs[4], formantBWs[4].reciprocal) * formantAmps[4] * nasality * 0.5
    ].sum * 3;

    sig = LPF.ar(sig, 5000);
    sig = (sig * 1.3).tanh * 0.75;

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// ============================================================================
// WAVEGUIDE FLUTE (Physical Modeling)
// ============================================================================
// Adapted from ixi SC tutorial - realistic flute through waveguide synthesis

SynthDef(\folkWaveguideFlute, {
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

    // Vibrato envelope
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

// ============================================================================
// BOWED STRING (Physical Modeling)
// ============================================================================
// Physical model for folk violin (hegedu) and similar bowed instruments

SynthDef(\folkBowed, {
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
        Env.adsr(0.05, 0.01, 0.9, 0.15),
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

    // Body resonance for folk violin character
    sig = Resonz.ar(bridge, 500, 0.85) * 0.5;
    sig = sig + Resonz.ar(bridge, 1200, 0.7) * 0.3;
    sig = sig + Resonz.ar(bridge, 3000, 0.5) * 0.15;

    Out.ar(out, Pan2.ar(sig, pan));
}).add;

// Simplified sustained bowed string
SynthDef(\folkBowedSustain, {
    |out = 0, freq = 420, amp = 0.3, pan = 0, gate = 1,
     bowPressure = 0.5, vibRate = 5, vibDepth = 0.01|

    var env, vibrato, sig, body1, body2;

    env = EnvGen.kr(Env.asr(0.1, 1, 0.2), gate, doneAction: 2);

    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3)) * freq * vibDepth;

    // Bowed string approximation using filtered saw
    sig = LFSaw.ar(freq + vibrato);
    sig = sig + (LFSaw.ar(freq + vibrato + 0.3) * 0.15); // Slight detuning

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

// ============================================================================
// PHRASE DYNAMICS HELPER
// ============================================================================

~phraseDynamic = { |position, length, shape = \arch|
    var norm = position / (length - 1).max(1);
    switch(shape,
        \arch, { sin(norm * pi) },           // peak in middle
        \cresc, { norm },                     // crescendo
        \decresc, { 1 - norm },               // decrescendo
        \flat, { 0.7 },                       // no change
        \swell, { sin(norm * pi * 2) * 0.3 + 0.7 }  // two peaks
    );
};

// ============================================================================
// RUBATO HELPER
// ============================================================================

~rubato = { |baseDur, amount = 0.1|
    baseDur * rrand(1 - amount, 1 + amount)
};

// ============================================================================
// INITIALIZATION
// ============================================================================

s.sync;

"".postln;
"============================================".postln;
"  Hungarian Folk Core Library Loaded".postln;
"============================================".postln;
"".postln;
"SCALES:".postln;
"  ~hungarianMinor, ~gypsyScale, ~pentatonic".postln;
"  ~minorPentatonic, ~lydianPentatonic, ~dorianScale".postln;
"".postln;
"UTILITIES:".postln;
"  ~scaleToFreq.(root, scale, degree, octave)".postln;
"  ~easedTempo.(start, end, pos, total, easeFunc)".postln;
"  ~blendVowels.(vowel1, vowel2, blend)".postln;
"  ~phraseDynamic.(position, length, shape)".postln;
"  ~rubato.(baseDur, amount)".postln;
"".postln;
"EASING FUNCTIONS:".postln;
"  ~easeInQuad, ~easeOutQuad, ~easeInOutQuad".postln;
"  ~easeInCubic, ~easeOutCubic, ~easeInOutCubic".postln;
"  ~easeInSine, ~easeOutSine, ~easeInOutSine".postln;
"".postln;
"VOWEL DATA:".postln;
"  ~vowelFormants.tenor.a, .e, .i, .o, .u".postln;
"  ~vowelFormants.alto.a, .e, .i, .o, .u".postln;
"  ~vowelFormants.bass.a, .e, .i, .o, .u".postln;
"".postln;
"SYNTHDEFS:".postln;
"  \\folkVoice - 5-formant vocal synthesis".postln;
"  \\folkWaveguideFlute - physical model flute".postln;
"  \\folkBowed - physical model bowed string".postln;
"  \\folkBowedSustain - sustained bowed string".postln;
"".postln;
"EFFECTS:".postln;
"  ~folkReverbBus, \\folkReverb".postln;
"============================================".postln;
)
