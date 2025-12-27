// ============================================================================
// GQOM DARK ATMOSPHERE EXPERIMENT
// ============================================================================
// Exploring the haunting, tension-filled atmosphere that defines Gqom.
// The genre's power comes not from melody but from mood - dark string pads,
// eerie drones, and spacious reverb creating perpetual tension.
//
// Key concepts:
// - Dark minor-key pads with minimal harmonic movement
// - Drone-based composition (single note/octave sustained)
// - Spacious reverb creating emptiness
// - The "never-drop" tension aesthetic
// - Vocal textures for atmosphere
//
// Usage: Load gqom_core.scd first, then evaluate sections below
// ============================================================================

// Load core library first
// Execute this block, then evaluate sections below
(
var libPath = thisProcess.nowExecutingPath.dirname +/+ "lib/gqom_core.scd";
libPath.load;
)

// ============================================================================
// SECTION 1: BASIC DARK PAD
// ============================================================================
// The foundational atmospheric element - dark filtered strings

(
// Single sustained pad on low A
~pad1 = Synth(\gqomPad, [
    \freq, 55,        // A1
    \amp, 0.35,
    \cutoff, 500,     // Dark filtering
    \attack, 3,
    \detune, 0.01
]);
)

// Release
~pad1.set(\gate, 0);

// ============================================================================
// SECTION 2: OCTAVE DRONE
// ============================================================================
// Classic gqom technique - single note with octave doubling

(
// Root note
~droneRoot = Synth(\gqomDrone, [
    \freq, 55,       // A1
    \amp, 0.3,
    \cutoff, 350
]);

// Octave above
~droneOctave = Synth(\gqomDrone, [
    \freq, 110,      // A2
    \amp, 0.2,
    \cutoff, 600
]);
)

// Release
(~droneRoot.set(\gate, 0); ~droneOctave.set(\gate, 0);)

// ============================================================================
// SECTION 3: EVOLVING PAD WITH FILTER MOVEMENT
// ============================================================================
// Subtle filter automation creates interest without harmonic change

(
~evolvePad = Synth(\gqomPad, [
    \freq, 55,
    \amp, 0.35,
    \cutoff, 400,
    \res, 0.35,
    \attack, 4
]);

// Filter modulation routine
~filterMod = Routine({
    var baseFreq = 400;
    var modDepth = 300;
    inf.do {
        var newCutoff = baseFreq + (sin(thisThread.seconds * 0.1) * modDepth);
        ~evolvePad.set(\cutoff, newCutoff.clip(200, 800));
        0.1.wait;
    }
}).play;
)

// Stop
(~evolvePad.set(\gate, 0); ~filterMod.stop;)

// ============================================================================
// SECTION 4: LAYERED ATMOSPHERE
// ============================================================================
// Multiple pad layers at different octaves and timbres

(
// Deep sub drone
~layerSub = Synth(\gqomDrone, [
    \freq, 27.5,     // A0 - very low
    \amp, 0.25,
    \cutoff, 200
]);

// Main pad layer
~layerMain = Synth(\gqomPad, [
    \freq, 55,
    \amp, 0.3,
    \cutoff, 450,
    \detune, 0.012
]);

// Higher harmonic layer
~layerHigh = Synth(\gqomPad, [
    \freq, 110,
    \amp, 0.15,
    \cutoff, 800,
    \detune, 0.008,
    \pan, 0.3
]);

// Fifth for slight color (common in gqom)
~layerFifth = Synth(\gqomPad, [
    \freq, 82.5,     // E2 (fifth above A1)
    \amp, 0.12,
    \cutoff, 500,
    \pan, -0.3
]);
)

// Release all
(
~layerSub.set(\gate, 0);
~layerMain.set(\gate, 0);
~layerHigh.set(\gate, 0);
~layerFifth.set(\gate, 0);
)

// ============================================================================
// SECTION 5: STAB TEXTURES
// ============================================================================
// Rhythmic stabs add movement to the atmosphere

(
~clock = TempoClock(120/60);

// Background pad
~stabPad = Synth(\gqomPad, [
    \freq, 55,
    \amp, 0.25,
    \cutoff, 400
]);

// Rhythmic stabs - sparse and syncopated
~stabs = Pbind(
    \instrument, \gqomStab,
    \dur, 0.5,
    \amp, Pseq([0, 0.35, 0, 0, 0.3, 0, 0, 0.25], inf),
    \freq, 110,
    \decay, Pwhite(0.2, 0.4),
    \cutoff, Pwhite(800, 1400),
    \pan, Pwhite(-0.4, 0.4)
).play(~clock);
)

// Stop
(~stabPad.set(\gate, 0); ~stabs.stop;)

// ============================================================================
// SECTION 6: VOCAL TEXTURE LAYER
// ============================================================================
// Synthetic vocal sounds for eerie atmosphere

(
~clock = TempoClock(120/60);

// Sustained pad
~vocalPad = Synth(\gqomPad, [\freq, 55, \amp, 0.25, \cutoff, 400]);

// Occasional vocal-like textures
~vocalLayer = Pbind(
    \instrument, \gqomVocalSynth,
    \dur, Prand([1, 2, 1.5, 0.5], inf),
    \amp, Pwhite(0.15, 0.3),
    \freq, Prand([110, 165, 220, 82.5], inf),  // A, E, A octave
    \sustain, Pwhite(0.3, 0.8),
    \formant1, Pwhite(400, 800),
    \formant2, Pwhite(1000, 1600),
    \pan, Pwhite(-0.5, 0.5)
).play(~clock);
)

// Stop
(~vocalPad.set(\gate, 0); ~vocalLayer.stop;)

// ============================================================================
// SECTION 7: THE TENSION BUILD
// ============================================================================
// Demonstrating the "perpetual build-up" gqom aesthetic

(
~clock = TempoClock(120/60);

// Start with minimal pad
~tensionPad = Synth(\gqomPad, [
    \freq, 55,
    \amp, 0.2,
    \cutoff, 300,
    \attack, 5
]);

// Routine that gradually increases tension over time
~tensionBuild = Routine({
    var startCutoff = 300;
    var endCutoff = 900;
    var startAmp = 0.2;
    var endAmp = 0.4;
    var duration = 32;  // beats

    duration.do { |i|
        var progress = i / duration;
        var cutoff = startCutoff + ((endCutoff - startCutoff) * progress);
        var amp = startAmp + ((endAmp - startAmp) * progress);

        ~tensionPad.set(\cutoff, cutoff, \amp, amp);

        // Add occasional high harmonics as tension builds
        if((progress > 0.5) && (0.2.coin)) {
            Synth(\gqomStab, [
                \freq, 220,
                \amp, 0.1 * progress,
                \decay, 0.2,
                \cutoff, 1200
            ]);
        };

        1.wait;
    };

    // Hold at peak - the "never drop"
    "Peak tension reached - holding...".postln;
    8.wait;

    // Slight release but maintain tension
    ~tensionPad.set(\cutoff, 600, \amp, 0.3);
    "Tension sustained - no full release".postln;
}).play(~clock);
)

// Stop
(~tensionPad.set(\gate, 0); ~tensionBuild.stop;)

// ============================================================================
// SECTION 8: REVERB SPACE
// ============================================================================
// Using reverb to create the characteristic empty, dark space

(
// Start reverb effect
~reverbSynth = Synth(\gqomReverb, [
    \in, ~gqomReverbBus,
    \mix, 0.5,
    \room, 0.9,
    \damp, 0.6
]);

// Pad sending to reverb
~spacePad = Synth(\gqomPad, [
    \out, ~gqomReverbBus,
    \freq, 55,
    \amp, 0.3,
    \cutoff, 450
]);

// Occasional stabs through reverb
~clock = TempoClock(120/60);

~spaceStabs = Pbind(
    \instrument, \gqomStab,
    \out, ~gqomReverbBus,
    \dur, Prand([0.5, 1, 1.5, 2], inf),
    \amp, Pwhite(0.2, 0.35),
    \freq, Prand([110, 165, 220], inf),
    \decay, 0.3,
    \cutoff, Pwhite(1000, 1800)
).play(~clock);
)

// Stop
(~spacePad.set(\gate, 0); ~spaceStabs.stop; ~reverbSynth.free;)

// ============================================================================
// SECTION 9: COMPLETE DARK ATMOSPHERE
// ============================================================================
// Full atmospheric arrangement demonstrating gqom mood

(
~clock = TempoClock(120/60);

// Start reverb
~atmoReverb = Synth(\gqomReverb, [
    \in, ~gqomReverbBus,
    \mix, 0.45,
    \room, 0.85,
    \damp, 0.5
]);

// Start delay
~atmoDelay = Synth(\gqomDelay, [
    \in, ~gqomDelayBus,
    \delayTime, 0.375,  // Dotted eighth
    \feedback, 0.35,
    \mix, 0.3
]);

// Sub drone
~atmoSub = Synth(\gqomDrone, [
    \out, 0,
    \freq, 27.5,
    \amp, 0.2,
    \cutoff, 150
]);

// Main pad with reverb
~atmoMain = Synth(\gqomPad, [
    \out, ~gqomReverbBus,
    \freq, 55,
    \amp, 0.28,
    \cutoff, 450,
    \detune, 0.01
]);

// Octave layer
~atmoOctave = Synth(\gqomPad, [
    \out, ~gqomReverbBus,
    \freq, 110,
    \amp, 0.15,
    \cutoff, 600,
    \pan, 0.2
]);

// Occasional stabs through delay
~atmoStabs = Pbind(
    \instrument, \gqomStab,
    \out, ~gqomDelayBus,
    \dur, Pwrand([0.5, 1, 1.5, 2, 4], [0.1, 0.2, 0.3, 0.3, 0.1], inf),
    \amp, Pwhite(0.2, 0.35),
    \freq, Prand([110, 165, 220, 82.5], inf),
    \decay, Pwhite(0.25, 0.5),
    \cutoff, Pwhite(900, 1500),
    \pan, Pwhite(-0.4, 0.4)
).play(~clock);

// Sparse vocal textures
~atmoVocal = Pbind(
    \instrument, \gqomVocalSynth,
    \out, ~gqomReverbBus,
    \dur, Prand([2, 3, 4, 6], inf),
    \amp, Pwhite(0.1, 0.2),
    \freq, Prand([110, 220, 165], inf),
    \sustain, Pwhite(0.4, 1.0),
    \formant1, Pwhite(500, 700),
    \formant2, Pwhite(1100, 1400),
    \pan, Pwhite(-0.6, 0.6)
).play(~clock);
)

// Stop all atmosphere
(
~atmoSub.set(\gate, 0);
~atmoMain.set(\gate, 0);
~atmoOctave.set(\gate, 0);
~atmoStabs.stop;
~atmoVocal.stop;
~atmoReverb.free;
~atmoDelay.free;
)

// ============================================================================
// SECTION 10: ATMOSPHERE WITH RHYTHM
// ============================================================================
// Complete gqom texture combining atmosphere and broken beats

(
~clock = TempoClock(120/60);

// Effects
~fullReverb = Synth(\gqomReverb, [
    \in, ~gqomReverbBus, \mix, 0.4, \room, 0.8, \damp, 0.5
]);

// Atmosphere layers
~fullSub = Synth(\gqomDrone, [\freq, 27.5, \amp, 0.2, \cutoff, 150]);
~fullPad = Synth(\gqomPad, [
    \out, ~gqomReverbBus, \freq, 55, \amp, 0.25, \cutoff, 450
]);

// Broken beat drums
~fullKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~gqomBroken1, inf) * 0.8,
    \freq, 45
).play(~clock);

~fullSnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq(~gqomSnare1, inf) * 0.45,
    \freq, 180
).play(~clock);

// Stabs through reverb
~fullStabs = Pbind(
    \instrument, \gqomStab,
    \out, ~gqomReverbBus,
    \dur, Prand([0.5, 1, 2], inf),
    \amp, Pwhite(0.2, 0.3),
    \freq, Prand([110, 165, 220], inf),
    \decay, 0.3,
    \cutoff, Pwhite(1000, 1600)
).play(~clock);
)

// Stop all
(
~fullSub.set(\gate, 0);
~fullPad.set(\gate, 0);
~fullKick.stop;
~fullSnare.stop;
~fullStabs.stop;
~fullReverb.free;
)

// ============================================================================
// CLEANUP
// ============================================================================

// s.freeAll;
