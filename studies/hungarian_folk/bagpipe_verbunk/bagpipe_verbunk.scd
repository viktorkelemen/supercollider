// ============================================================================
// BAGPIPE VERBUNK / BALLAD CROSSOVER
// ============================================================================
// Lament-to-dance arc with bagpipe chanter + drone, Phrygian-dominant color,
// cut ornaments instead of trills, and heel-click accents.
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~gypsyScale = [0, 1, 4, 5, 7, 8, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SynthDefs: drone, chanter, cut, heel-click
// ---------------------------------------------------------------------------
(
SynthDef(\bpDrone, {
    |out = 0, freq = 110, amp = 0.3|
    var env = EnvGen.kr(Env.asr(0.2, 1, 0.8), gate: 1);
    var sig = Saw.ar(freq) * 0.7 + Pulse.ar(freq * 0.5, 0.45) * 0.2;
    sig = LPF.ar(sig, 700);
    sig = (sig * 1.8).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, -0.1));
}).add;

SynthDef(\bpChanter, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.6, pan = 0.1,
     nasal = 0.6, buzz = 0.6|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    var sig = Saw.ar(freq) * (0.8 + buzz) + Pulse.ar(freq * 2, 0.4) * 0.3;
    sig = BPF.ar(sig, 650, 0.35) * 2 + BPF.ar(sig, 1800, 0.2) * nasal + sig * 0.3;
    sig = (sig * 1.7).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\bpCut, {
    |out = 0, freq = 440, amp = 0.18, dur = 0.06|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    var sig = Pulse.ar(freq * 1.01, 0.5) + HPF.ar(WhiteNoise.ar, 2200) * 0.3;
    sig = LPF.ar(sig, 3200);
    Out.ar(out, Pan2.ar(sig * env * amp, 0.1));
}).add;

SynthDef(\bpHeel, {
    |out = 0, freq = 1000, amp = 0.28|
    var env = EnvGen.kr(Env.perc(0.001, 0.05), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.7 + (SinOsc.ar(freq * 0.35) * EnvGen.kr(Env.perc(0.001, 0.02)));
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ---------------------------------------------------------------------------
// LAMENT (slow, rubato-ish)
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~gypsyScale;
var melody = [0, 1, 4, 5, 4, 3, 2, 1, 0];
var durs = [1.0, 0.8, 1.1, 0.9, 0.7, 0.7, 0.8, 0.9, 1.3];

Routine({
    var drone;
    "Bagpipe lament → dance:".postln;

    drone = Synth(\bpDrone, [\freq, root.midicps, \amp, 0.32]);

    "Lament:".postln;
    melody.do { |deg, i|
        if([2, 5].includes(i)) { Synth(\bpCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.17]); };
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, durs[i] * 1.1,
            \amp, 0.32
        ]);
        (durs[i] * rrand(0.9, 1.1)).wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// DANCE (friss-like, 2/4, heel clicks)
// ---------------------------------------------------------------------------
(
var tempo = 0.22;
var root = 55;
var scale = ~gypsyScale;
var melody = [0, 1, 4, 4, 3, 2, 0, -1, 0, 1, 4, 5, 4, 3, 2, 1];

Routine({
    "Dance:".postln;
    melody.do { |deg, i|
        Synth(\bpChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.1,
            \amp, 0.3,
            \buzz, 0.65,
            \nasal, 0.7
        ]);

        // Heel clicks on backbeats, drone already running
        if(i % 2 == 1) { Synth(\bpHeel, [\amp, 0.3]); };
        tempo.wait;
    };
}).play;
)
