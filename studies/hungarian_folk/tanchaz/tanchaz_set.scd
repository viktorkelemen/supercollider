// ============================================================================
// TÁNCHÁZ BAND AESTHETIC - MODERN REVIVAL SET
// ============================================================================
// Focus: clean intonation, light room, optional guitar/cajon, brácsa/gardon core.
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// Shared verb bus
// ---------------------------------------------------------------------------
(
~tanchazVerbBus = Bus.audio(s, 2);

SynthDef(\tanchazVerb, {
    |in, out = 0, mix = 0.2, room = 0.7, damp = 0.5|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb);
}).add;
)

// ---------------------------------------------------------------------------
// SynthDefs: polished violin, tight brácsa, gardon, soft guitar, cajon
// ---------------------------------------------------------------------------
(
SynthDef(\tzViolin, {
    |out = 0, freq = 440, amp = 0.32, dur = 0.4, pan = -0.2,
     vibRate = 5, vibDepth = 0.012, attack = 0.02, send = 0.25|
    var env = EnvGen.kr(Env.perc(attack, dur - attack, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 500, 0.35) * 2 + BPF.ar(sig, 2500, 0.2) * 1.4 + sig * 0.4;
    sig = LPF.ar(sig, freq * 6);
    sig = (sig * 1.2).tanh * 0.8;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

SynthDef(\tzBracsa, {
    |out = 0, freq = 200, amp = 0.28, pan = 0.2, send = 0.15|
    var env = EnvGen.kr(Env.perc(0.004, 0.08, 1, -8), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.001]),
        LFSaw.ar(freq * 1.5 * [1, 1.001]),
        LFSaw.ar(freq * 2.0)
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1600) * EnvGen.kr(Env.perc(0.001, 0.015)) * 0.25;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 380, 0.55) * 2 + sig * 0.4;
    sig = LPF.ar(sig, 2300);
    sig = (sig * 1.4).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

SynthDef(\tzGardon, {
    |out = 0, freq = 90, amp = 0.38, pan = 0, send = 0.1|
    var env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);
    var thump = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.3;
    var slap = HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.02));
    var sig = LPF.ar(thump + slap * 0.4, 450);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * env * amp * send, pan));
}).add;

SynthDef(\tzGuitar, {
    |out = 0, freq = 220, amp = 0.22, dur = 0.35, pan = 0.25, send = 0.2|
    var env = EnvGen.kr(Env.perc(0.005, dur, 1, -5), doneAction: 2);
    var body = LPF.ar(Pluck.ar(WhiteNoise.ar(0.4), 1, 1/freq, 1/freq, 4, 0.4), 3500);
    var sig = body * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;

SynthDef(\tzCajon, {
    |out = 0, amp = 0.25, pan = 0, send = 0.1|
    var env = EnvGen.kr(Env.perc(0.003, 0.12, 1, -6), doneAction: 2);
    var low = LPF.ar(WhiteNoise.ar, 200) * 1.2;
    var slap = HPF.ar(WhiteNoise.ar, 1500) * 0.4;
    var sig = (low + slap) * env;
    Out.ar(out, Pan2.ar(sig * amp, pan));
    Out.ar(~tanchazVerbBus, Pan2.ar(sig * amp * send, pan));
}).add;
)

// ---------------------------------------------------------------------------
// VERB FOR ALL
// ---------------------------------------------------------------------------
(
Synth(\tanchazVerb, [\in, ~tanchazVerbBus]);
)

// ---------------------------------------------------------------------------
// TÁNCHÁZ SET: LASSÚ → FRISS WITH OPTIONAL GUITAR/CAJON
// ---------------------------------------------------------------------------
(
var root = 48;
var melodyRoot = 60;
var scale = ~hungarianMinor;

// Lassú (gentle, with guitar pads)
Routine({
    var tempo = 0.5;
    var melody = [0, 2, 3, 4, 4, 3, 2, 0];
    var durs = [1.0, 0.6, 0.7, 1.0, 0.6, 0.6, 0.6, 1.2];

    "Táncház lassú:".postln;
    melody.do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, durs[i] * tempo,
            \amp, 0.34,
            \vibDepth, 0.013
        ]);
        Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.22]);
        if(i % 2 == 0) { Synth(\tzGuitar, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.18]); };
        (durs[i] * tempo).wait;
    };
}).play;

// Friss (tight groove, cajon optional)
Routine({
    var tempo = 0.2;
    var melody = [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 3, 2, 0];

    0.5.wait;
    "Táncház friss:".postln;
    melody.do { |deg, i|
        Synth(\tzViolin, [
            \freq, ~scaleToFreq.(melodyRoot, scale, deg),
            \dur, tempo * 1.2,
            \amp, 0.32,
            \vibRate, 0
        ]);
        // Brácsa offbeats, gardon on beats
        if(i % 2 == 0) {
            Synth(\tzGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.42]);
        } {
            Synth(\tzBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.3]);
        };
        if(i % 4 == 2) { Synth(\tzCajon, [\amp, 0.22]); };
        tempo.wait;
    };
}).play;
)
