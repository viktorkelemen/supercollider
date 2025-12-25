// ============================================================================
// VERBUNKOS CORE LIBRARY
// ============================================================================
// Shared scales, helpers, effects, and improved SynthDefs for all verbunkos
// experiments. Load this file before running any verbunkos composition.
//
// Usage: "/path/to/verbunkos_core.scd".load;
// ============================================================================

(
// ============================================================================
// SCALES
// ============================================================================

~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];
~pentatonic = [0, 2, 4, 7, 9];

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

// ============================================================================
// REVERB BUS (shared effect)
// ============================================================================

~reverbBus = Bus.audio(s, 2);

SynthDef(\verbReverb, {
    |in, out = 0, mix = 0.3, room = 0.6, damp = 0.5|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;

// ============================================================================
// IMPROVED MELODY SYNTH
// ============================================================================
// Warmer timbre with formant-like filtering, dynamic control, vibrato option

SynthDef(\verbMelodyPro, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     attack = 0.02, release = 0.3,
     brightness = 0.5, vibRate = 0, vibDepth = 0,
     reverbSend = 0.3|

    var env, vibrato, sig, formant1, formant2;

    // Amplitude envelope with attack/release control
    env = EnvGen.kr(
        Env.perc(attack, dur * release, 1, -4),
        doneAction: 2
    );

    // Optional vibrato
    vibrato = if(vibRate > 0,
        SinOsc.kr(vibRate, 0, freq * vibDepth),
        0
    );

    // Richer source: saw + pulse + triangle blend
    sig = (Saw.ar(freq + vibrato) * 0.4) +
          (Pulse.ar(freq + vibrato, 0.35) * 0.3) +
          (LFTri.ar(freq + vibrato) * 0.3);

    // Two formant-like resonances (violin body simulation)
    formant1 = BPF.ar(sig, 500, 0.8) * 2;
    formant2 = BPF.ar(sig, 1200, 0.6) * 1.5;

    sig = sig + formant1 + formant2;

    // Brightness control via lowpass
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));

    // Subtle saturation for warmth
    sig = (sig * 1.5).tanh * 0.7;

    // Output
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~reverbBus, Pan2.ar(sig * env * amp * reverbSend, pan));
}).add;

// ============================================================================
// MELODY WITH DYNAMICS (phrase shaping)
// ============================================================================

SynthDef(\verbMelodyDyn, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     attack = 0.02, peak = 0.3, sustain = 0.5, release = 0.2,
     dynCurve = 0, // -1 = fade in, 0 = sustain, 1 = fade out
     brightness = 0.5, reverbSend = 0.3|

    var env, dynEnv, sig, formant1, formant2;

    // Main envelope
    env = EnvGen.kr(
        Env([0, 1, sustain, 0], [attack, peak * dur, release * dur], \sin),
        doneAction: 2
    );

    // Dynamic shaping envelope (crescendo/decrescendo)
    dynEnv = EnvGen.kr(
        Env([1 - (dynCurve.clip(-1, 0).abs), 1, 1 - dynCurve.clip(0, 1)],
            [dur * 0.5, dur * 0.5])
    );

    // Rich source
    sig = (Saw.ar(freq) * 0.4) +
          (Pulse.ar(freq * 1.001, 0.35) * 0.3) +
          (LFTri.ar(freq * 0.999) * 0.3);

    // Formants
    formant1 = BPF.ar(sig, 500, 0.8) * 2;
    formant2 = BPF.ar(sig, 1200, 0.6) * 1.5;
    sig = sig + formant1 + formant2;

    // Brightness
    sig = LPF.ar(sig, freq * (2 + (brightness * 6)));
    sig = (sig * 1.5).tanh * 0.7;

    Out.ar(out, Pan2.ar(sig * env * dynEnv * amp, pan));
    Out.ar(~reverbBus, Pan2.ar(sig * env * dynEnv * amp * reverbSend, pan));
}).add;

// ============================================================================
// IMPROVED CIMBALOM (with reverb send)
// ============================================================================

SynthDef(\cimbalomPro, {
    |out = 0, freq = 440, amp = 0.3, dur = 1, pan = 0,
     brightness = 0.7, reverbSend = 0.4|

    var env, partials, pAmps, sig, attack, resonance;

    env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

    // Inharmonic partials (stretched like real strings)
    partials = [1, 2.001, 3.002, 4.005, 5.01, 6.02, 7.03];
    pAmps = [1, 0.7, 0.4, 0.25, 0.15, 0.1, 0.05];

    sig = Mix(
        partials.collect { |p, i|
            var detune = LFNoise1.kr(0.5).range(-1, 1);
            SinOsc.ar(freq * p + detune, 0, pAmps[i]);
        }
    );

    // Metallic attack
    attack = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.kr(Env.perc(0.0001, 0.01));

    // Sympathetic resonance
    resonance = DelayC.ar(sig, 0.05, LFNoise1.kr(0.3).range(0.001, 0.003)) * 0.1;

    sig = sig + (attack * 0.15) + resonance;

    // Brightness control
    sig = LPF.ar(sig, (freq * (4 + (brightness * 8))).min(16000));

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~reverbBus, Pan2.ar(sig * env * amp * reverbSend, pan));
}).add;

// ============================================================================
// BOKÁZÓ (heel click) - improved with variations
// ============================================================================

SynthDef(\verbClickPro, {
    |out = 0, freq = 1000, amp = 0.4, brightness = 0.5, reverbSend = 0.2|

    var env, sig, body, click;

    env = EnvGen.kr(Env.perc(0.001, 0.08), doneAction: 2);

    // High frequency click
    click = HPF.ar(WhiteNoise.ar, freq * (0.8 + (brightness * 0.4)));

    // Body thump
    body = SinOsc.ar(freq * 0.4) * EnvGen.kr(Env.perc(0.001, 0.04));

    sig = (click * 0.7) + (body * 0.3);
    sig = sig * env;

    Out.ar(out, Pan2.ar(sig * amp, 0));
    Out.ar(~reverbBus, Pan2.ar(sig * amp * reverbSend, 0));
}).add;

// ============================================================================
// BASS (improved with reverb)
// ============================================================================

SynthDef(\verbBassPro, {
    |out = 0, freq = 60, amp = 0.5, dur = 0.5, reverbSend = 0.15|

    var env, pitch, sig;

    env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);

    // Pitch drop for weight
    pitch = EnvGen.kr(Env([freq * 1.5, freq, freq * 0.95], [0.02, 0.1]));

    sig = SinOsc.ar(pitch) + (SinOsc.ar(pitch * 2) * 0.3);
    sig = LPF.ar(sig, 400);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
    Out.ar(~reverbBus, Pan2.ar(sig * env * amp * reverbSend, 0));
}).add;

// ============================================================================
// DRONE (for slow sections)
// ============================================================================

SynthDef(\verbDronePro, {
    |out = 0, freq = 110, amp = 0.15, gate = 1, reverbSend = 0.5|

    var env, sig;

    env = EnvGen.kr(Env.asr(0.5, 1, 1), gate, doneAction: 2);

    sig = Saw.ar([freq, freq * 1.5, freq * 2], [0.5, 0.3, 0.2]).sum;
    sig = LPF.ar(sig, 800);

    // Subtle movement
    sig = sig * (1 + (SinOsc.kr(0.1) * 0.05));

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
    Out.ar(~reverbBus, Pan2.ar(sig * env * amp * reverbSend, 0));
}).add;

// ============================================================================
// PHRASE DYNAMICS HELPER
// ============================================================================

// Calculate dynamic curve for note position in phrase
// Returns value between -1 (crescendo) and 1 (decrescendo)
~phraseDynamic = { |position, length, shape = \arch|
    var norm = position / (length - 1);
    switch(shape,
        \arch, { sin(norm * pi) * 2 - 1 },      // peak in middle
        \cresc, { norm * 2 - 1 },                // crescendo
        \decresc, { 1 - (norm * 2) },            // decrescendo
        \flat, { 0 }                              // no change
    );
};

// ============================================================================
// INITIALIZATION
// ============================================================================

s.sync;

"Verbunkos Core Library loaded.".postln;
"  Scales: ~hungarianMinor, ~gypsyScale, ~pentatonic".postln;
"  Helpers: ~scaleToFreq, ~scaleInterval, ~phraseDynamic".postln;
"  Effects: ~reverbBus, \\verbReverb".postln;
"  Synths: \\verbMelodyPro, \\verbMelodyDyn, \\cimbalomPro".postln;
"         \\verbClickPro, \\verbBassPro, \\verbDronePro".postln;
)
