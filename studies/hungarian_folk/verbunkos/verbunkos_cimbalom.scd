// ============================================================================
// VERBUNKOS CIMBALOM - Hammered Dulcimer Synthesis
// ============================================================================
// The cimbalom (Hungarian hammered dulcimer) is central to Verbunkos ensemble.
// Characteristics:
// - Metallic, shimmering timbre from struck strings
// - Rich harmonics with inharmonicity (like piano)
// - Fast decay with sustain pedal capability
// - Tremolo technique (rapid repeated notes)
// - Wide range and chordal capabilities
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
// CIMBALOM SYNTHDEFS
// ============================================================================
(
// Basic cimbalom - struck string with metallic shimmer
SynthDef(\cimbalom, {
    |out = 0, freq = 440, amp = 0.3, dur = 1, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);

    // Inharmonic partials (slightly stretched like real strings)
    var partials = [1, 2.001, 3.002, 4.005, 5.01, 6.02, 7.03];
    var amps = [1, 0.7, 0.4, 0.25, 0.15, 0.1, 0.05];

    // Main tone - additive synthesis with slight detuning
    var sig = Mix(
        partials.collect { |p, i|
            var detune = LFNoise1.kr(0.5).range(-1, 1);
            SinOsc.ar(freq * p + detune, 0, amps[i]);
        }
    );

    // Add metallic attack transient
    var attack = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.kr(Env.perc(0.0001, 0.01));

    // Sympathetic resonance simulation (subtle chorus)
    var resonance = DelayC.ar(sig, 0.05, LFNoise1.kr(0.3).range(0.001, 0.003)) * 0.1;

    sig = sig + (attack * 0.15) + resonance;
    sig = LPF.ar(sig, (freq * 8).min(16000));

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Cimbalom with sustain (pedal down)
SynthDef(\cimbalomSustain, {
    |out = 0, freq = 440, amp = 0.3, gate = 1, pan = 0|
    var env = EnvGen.kr(Env.asr(0.001, 1, 0.5), gate, doneAction: 2);
    var decay = EnvGen.kr(Env.perc(0.001, 4, 1, -4));

    var partials = [1, 2.001, 3.002, 4.005, 5.01];
    var amps = [1, 0.6, 0.35, 0.2, 0.1];

    var sig = Mix(
        partials.collect { |p, i|
            SinOsc.ar(freq * p + LFNoise1.kr(0.3).range(-0.5, 0.5), 0, amps[i]);
        }
    );

    var attack = HPF.ar(WhiteNoise.ar, 3000) * EnvGen.kr(Env.perc(0.0001, 0.015));
    sig = sig + (attack * 0.1);

    Out.ar(out, Pan2.ar(sig * env * decay * amp, pan));
}).add;

// Cimbalom tremolo (rapid repeated strikes)
SynthDef(\cimbalomTremolo, {
    |out = 0, freq = 440, amp = 0.3, dur = 1, rate = 12, pan = 0|
    var trem = LFPulse.kr(rate, 0, 0.3);
    var tremEnv = EnvGen.kr(Env.perc(0.001, 1/rate * 0.8));
    var mainEnv = EnvGen.kr(Env.linen(0.01, dur * 0.8, dur * 0.19), doneAction: 2);

    var partials = [1, 2.001, 3.002, 4.005];
    var pAmps = [1, 0.5, 0.25, 0.12];

    var sig = Mix(
        partials.collect { |p, i|
            SinOsc.ar(freq * p, 0, pAmps[i]);
        }
    );

    var attack = HPF.ar(WhiteNoise.ar, 4000) * trem * tremEnv * 0.2;
    sig = (sig * (trem * tremEnv * 0.7 + 0.3)) + attack;

    Out.ar(out, Pan2.ar(sig * mainEnv * amp, pan));
}).add;

// Low register cimbalom (bass strings)
SynthDef(\cimbalomBass, {
    |out = 0, freq = 110, amp = 0.4, dur = 2|
    var env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);

    // More fundamental, less high partials
    var sig = SinOsc.ar(freq, 0, 0.6) +
              SinOsc.ar(freq * 2.002, 0, 0.3) +
              SinOsc.ar(freq * 3.005, 0, 0.15);

    // Warm attack
    var attack = LPF.ar(WhiteNoise.ar, 800) * EnvGen.kr(Env.perc(0.0001, 0.03));

    sig = sig + (attack * 0.2);
    sig = LPF.ar(sig, 2000);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ============================================================================
// EXPERIMENT 1: Basic cimbalom tones across register
// ============================================================================
(
Routine({
    var root = 48;
    var scale = ~hungarianMinor;

    "Cimbalom across registers:".postln;

    // Low register
    Synth(\cimbalomBass, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 1.5]);
    0.8.wait;

    // Middle register
    Synth(\cimbalom, [\freq, ~scaleToFreq.(root + 12, scale, 0), \dur, 1.2]);
    0.8.wait;

    // High register
    Synth(\cimbalom, [\freq, ~scaleToFreq.(root + 24, scale, 0), \dur, 1.0]);
}).play;
)

// ============================================================================
// EXPERIMENT 2: Cimbalom arpeggio
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;
var arpeggio = [0, 2, 4, 6, 7, 6, 4, 2];

Routine({
    "Cimbalom arpeggio:".postln;

    arpeggio.do { |deg, i|
        var octave = if(deg > 4, 1, 0);
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 0.8,
            \amp, 0.25,
            \pan, i.linlin(0, 7, -0.4, 0.4)
        ]);
        0.12.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 3: Cimbalom tremolo technique
// ============================================================================
(
var root = 60;
var scale = ~hungarianMinor;

Routine({
    "Tremolo on single note:".postln;
    Synth(\cimbalomTremolo, [
        \freq, ~scaleToFreq.(root, scale, 4),
        \dur, 1.5,
        \rate, 10,
        \amp, 0.35
    ]);

    2.0.wait;

    "Tremolo melody:".postln;
    [4, 3, 2, 0].do { |deg|
        Synth(\cimbalomTremolo, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, 0.6,
            \rate, 12,
            \amp, 0.3
        ]);
        0.5.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 4: Rolled chords (arpeggiated)
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;

// C minor chord in Hungarian minor context
var chord = [0, 2, 4]; // Root, third, fifth

Routine({
    "Rolled chord (upward):".postln;
    chord.do { |deg, i|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 1.5 - (i * 0.1),
            \amp, 0.28,
            \pan, -0.2 + (i * 0.2)
        ]);
        0.04.wait;
    };

    1.5.wait;

    "Full spread chord:".postln;
    // Bass
    Synth(\cimbalomBass, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 2]);
    0.03.wait;
    // Middle voices
    chord.do { |deg, i|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 1.8,
            \amp, 0.22
        ]);
        0.025.wait;
    };
    // High octave doubling
    0.02.wait;
    Synth(\cimbalom, [
        \freq, ~scaleToFreq.(root + 24, scale, 0),
        \dur, 1.5,
        \amp, 0.2
    ]);
}).play;
)

// ============================================================================
// EXPERIMENT 5: Cimbalom accompaniment pattern
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;
var tempo = 0.25;

Routine({
    "Typical cimbalom accompaniment:".postln;

    4.do { |bar|
        // Beat 1: Bass + chord
        Synth(\cimbalomBass, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 0.8, \amp, 0.4]);
        [0, 2, 4].do { |deg, i|
            Synth(\cimbalom, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, 0.5,
                \amp, 0.2
            ]);
            0.015.wait;
        };
        (tempo * 2).wait;

        // Beat 2: Just chord (lighter)
        [0, 2, 4].do { |deg|
            Synth(\cimbalom, [
                \freq, ~scaleToFreq.(root + 12, scale, deg),
                \dur, 0.3,
                \amp, 0.15
            ]);
            0.01.wait;
        };
        (tempo * 2).wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 6: Fast scalar runs
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Fast ascending run:".postln;

    (0..14).do { |deg|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 0.4,
            \amp, 0.2 + (deg * 0.01),
            \pan, deg.linlin(0, 14, -0.5, 0.5)
        ]);
        0.06.wait;
    };

    0.5.wait;

    "Fast descending run:".postln;
    (14..0).do { |deg|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 0.4,
            \amp, 0.25 - (deg * 0.008),
            \pan, deg.linlin(0, 14, -0.5, 0.5)
        ]);
        0.05.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 7: Tremolo with bass
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Tremolo melody over bass:".postln;

    var melody = [4, 4, 3, 2, 4, 3, 2, 0];
    var bassDegrees = [0, 0, 4, 4, 0, 0, 4, 0];

    melody.do { |deg, i|
        // Bass note
        if(i % 2 == 0) {
            Synth(\cimbalomBass, [
                \freq, ~scaleToFreq.(root, scale, bassDegrees[i]),
                \dur, 0.8,
                \amp, 0.35
            ]);
        };

        // Tremolo melody
        Synth(\cimbalomTremolo, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 0.45,
            \rate, 14,
            \amp, 0.28
        ]);

        0.4.wait;
    };
}).play;
)

// ============================================================================
// EXPERIMENT 8: Full cimbalom texture
// ============================================================================
(
var root = 48;
var scale = ~hungarianMinor;

Routine({
    "Full cimbalom phrase:".postln;

    // Opening rolled chord
    Synth(\cimbalomBass, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 2, \amp, 0.4]);
    0.02.wait;
    [0, 2, 4, 7].do { |deg, i|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 1.8 - (i * 0.1),
            \amp, 0.22
        ]);
        0.02.wait;
    };

    0.8.wait;

    // Melodic run
    [4, 5, 6, 7, 6, 5, 4, 3].do { |deg, i|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 0.35,
            \amp, 0.25
        ]);
        0.1.wait;
    };

    // Tremolo climax
    Synth(\cimbalomTremolo, [
        \freq, ~scaleToFreq.(root + 12, scale, 4),
        \dur, 0.8,
        \rate, 16,
        \amp, 0.3
    ]);

    0.7.wait;

    // Final chord
    Synth(\cimbalomBass, [\freq, ~scaleToFreq.(root, scale, 0), \dur, 2, \amp, 0.45]);
    0.02.wait;
    [0, 4, 7].do { |deg|
        Synth(\cimbalom, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, 1.8,
            \amp, 0.25
        ]);
        0.015.wait;
    };
}).play;
)

// ============================================================================
// CLEANUP
// ============================================================================
s.freeAll;
