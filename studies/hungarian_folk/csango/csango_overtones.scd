// ============================================================================
// CSÁNGÓ OVERTONE SONG - Tilinkó / Simple Flute + Gardon Drone
// ============================================================================
// Focus: archaic Moldavian Csángó style
// - Anhemitonic pentatonic, overtone melodies
// - Breath noise + formant flute
// - Sparse ütőgardon-like drone pulse
// ============================================================================

(
~pentatonic = [0, 2, 4, 7, 9];
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SynthDefs: breathy overtone flute, simple gardon drone
// ---------------------------------------------------------------------------
(
SynthDef(\csangoFlute, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     breath = 0.35, tilt = 0.4, formant = 1800|
    var env = EnvGen.kr(Env.perc(0.05, dur * 0.95, 1, -4), doneAction: 2);
    var breathNoise = LPF.ar(WhiteNoise.ar * breath, 8000) * 0.6;
    var tone = SinOsc.ar(freq * [1, 2, 3], 0, [0.9, 0.25, 0.12]).sum;
    tone = BPF.ar(tone, formant, 0.2) * 1.8 + tone * 0.4;
    tone = tone * (tilt.linlin(0, 1, 0.7, 1.1));
    var sig = (tone + breathNoise);
    sig = LPF.ar(sig, freq * 6);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\csangoGardon, {
    |out = 0, freq = 90, amp = 0.28, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, 0.14, 1, -8), doneAction: 2);
    var body = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.3;
    var slap = HPF.ar(WhiteNoise.ar, 350) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.4;
    var sig = LPF.ar(body + slap, 420);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;
)

// ---------------------------------------------------------------------------
// OVERTONE MELODY (tilinkó-like, no finger holes)
// ---------------------------------------------------------------------------
(
var root = 55; // low A as drone
var scale = ~pentatonic;
var melody = [0, 2, 4, 7, 9, 7, 4, 2, 0];
var durs = [1.0, 0.7, 0.6, 0.8, 1.1, 0.7, 0.6, 0.9, 1.4];

Routine({
    var drone;
    "Csángó overtone melody:".postln;

    // Start drone pulse
    drone = {
        loop {
            Synth(\csangoGardon, [\freq, root.midicps, \amp, 0.3]);
            0.6.wait;
        }
    }.fork;

    0.4.wait;
    melody.do { |deg, i|
        Synth(\csangoFlute, [
            \freq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, durs[i],
            \amp, 0.32,
            \breath, 0.4,
            \formant, 1700 + (deg * 40)
        ]);
        (durs[i] * rrand(0.9, 1.1)).wait;
    };

    1.0.wait;
    drone.stop;
}).play;
)
