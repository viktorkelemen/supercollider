// ============================================================================
// SYNTHDEF COMPILER FOR WEB GALLERY
// ============================================================================
// Run this in SuperCollider to export .scsyndef files for SuperSonic.
//
// Usage:
// 1. Boot the server: s.boot
// 2. Run this file: "/path/to/compile-synthdefs.scd".load
// 3. Check the output directory for .scsyndef files
// ============================================================================

(
var outputDir = PathName(thisProcess.nowExecutingPath).pathOnly ++ "synthdefs/";

// Create output directory if it doesn't exist
outputDir.mkdir;

"Compiling SynthDefs to: %".format(outputDir).postln;

// ============================================================================
// CIMBALOM - for the arpeggio experiment
// ============================================================================

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
}).writeDefFile(outputDir);

"  ✓ cimbalom.scsyndef".postln;

// ============================================================================
// Done
// ============================================================================

"".postln;
"SynthDef compilation complete!".postln;
"Output directory: %".format(outputDir).postln;
"".postln;
"Next steps:".postln;
"1. Copy the 'synthdefs' folder to your web project".postln;
"2. Or download SuperSonic and add these to its synthdefs folder".postln;
)
