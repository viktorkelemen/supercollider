// ============================================================================
// DUDÁS STYLE DANCE - Bagpipe Drone + Chanter Cuts
// ============================================================================
// Focus: Palóc/Matyó dudás aesthetic
// - Phrygian-dominant / Hungarian minor color
// - Fixed drone + buzzing chanter
// - Grace “cuts” instead of bowed ornaments
// - 2/4 stomps with nasal buzz
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~gypsyScale = [0, 1, 4, 5, 7, 8, 10]; // Phrygian-dominant flavor

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SynthDefs: buzzing chanter, drone, cut-grace, stomp
// ---------------------------------------------------------------------------
(
SynthDef(\dudaDrone, {
    |out = 0, freq = 110, amp = 0.28, pan = -0.1|
    var env = EnvGen.kr(Env.asr(0.3, 1, 0.8), gate: 1);
    var buzz = Saw.ar(freq) * 0.6 + Pulse.ar(freq * 0.5, 0.4) * 0.2;
    buzz = LPF.ar(buzz, 800);
    buzz = (buzz * 2).tanh * 0.5;
    Out.ar(out, Pan2.ar(buzz * env * amp, pan));
}).add;

SynthDef(\dudaChanter, {
    |out = 0, freq = 440, amp = 0.28, dur = 0.4, pan = 0.1,
     buzz = 0.5, nasal = 0.6, vibrato = 0.0|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    var vib = SinOsc.kr(6).range(-vibrato, vibrato) * freq;
    var sig = Saw.ar(freq + vib) * (0.7 + buzz) + Pulse.ar(freq * 2, 0.4) * 0.3;
    sig = BPF.ar(sig, 600, 0.3) * 2 + BPF.ar(sig, 1800, 0.2) * nasal + sig * 0.3;
    sig = (sig * 1.6).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\dudaCut, {
    |out = 0, freq = 440, amp = 0.18, dur = 0.05, pan = 0.1|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    var sig = Pulse.ar(freq * 1.01, 0.5) + HPF.ar(WhiteNoise.ar, 2000) * 0.3;
    sig = LPF.ar(sig, 3000);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\dudaStomp, {
    |out = 0, freq = 70, amp = 0.5|
    var env = EnvGen.kr(Env.perc(0.005, 0.18, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.25;
    sig = LPF.ar(sig, 300);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ---------------------------------------------------------------------------
// DUDÁS DANCE PATTERN (2/4 with cuts)
// ---------------------------------------------------------------------------
(
var tempo = 0.28;
var root = 55;
var scale = ~gypsyScale;
var melody = [0, 1, 4, 3, 2, 1, 0, -1, 0, 1, 4, 5, 4, 3, 2, 1];

Routine({
    var drone;
    "Dudás dance (buzzing chanter + drone):".postln;

    drone = Synth(\dudaDrone, [\freq, root.midicps, \amp, 0.32]);

    melody.do { |deg, i|
        // Grace cut on offbeats
        if(i % 2 == 1) {
            Synth(\dudaCut, [\freq, ~scaleToFreq.(root, scale, deg + 1), \amp, 0.16]);
        };

        Synth(\dudaChanter, [
            \freq, ~scaleToFreq.(root, scale, deg),
            \dur, tempo * 1.2,
            \amp, 0.3,
            \buzz, 0.6,
            \nasal, 0.7,
            \vibrato, 0.01
        ]);

        // Stomp on beat 1 each bar
        if(i % 4 == 0) { Synth(\dudaStomp, [\amp, 0.55]); };

        tempo.wait;
    };

    0.5.wait;
    drone.free;
}).play;
)
