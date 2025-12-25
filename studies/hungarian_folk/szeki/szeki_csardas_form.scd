// ============================================================================
// SZÉKI CSÁRDÁS - Ritka / Sűrű Variants with Gardon Drive
// ============================================================================
// Focus: Szék (Sic) village dance house style.
// - Ritka csárdás (sparser, heavy bow noise)
// - Sűrű csárdás (denser, more chops)
// - Ütőgardon pulse + rough brácsa + nasal violin
// - Accelerando bridge from ritka → sűrű
// ============================================================================

(
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];
~transylvanianMode = [0, 2, 3, 5, 7, 8, 10];

~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    (root + scale[idx] + (oct * 12)).midicps;
};
)

// ---------------------------------------------------------------------------
// SynthDefs: nasal violin, rough brácsa, ütőgardon, heel-clicks
// ---------------------------------------------------------------------------
(
SynthDef(\szekViolin, {
    |out = 0, freq = 440, amp = 0.35, dur = 0.35, pan = -0.2,
     attack = 0.02, vibRate = 4.5, vibDepth = 0.012, brightness = 0.55|
    var env = EnvGen.kr(Env.perc(attack, dur - attack, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.6).range(-0.4, 0.4)) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    // Nasal body (slightly more 1–2 kHz emphasis)
    sig = BPF.ar(sig, 600, 0.35) * 2 + BPF.ar(sig, 1600, 0.25) * 1.6 + sig * 0.4;
    sig = LPF.ar(sig, freq * (3 + brightness * 6));
    sig = (sig * 1.4).tanh * 0.75;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\szekBracsa, {
    |out = 0, freq = 200, amp = 0.32, pan = 0.2, len = 0.08|
    var env = EnvGen.kr(Env.perc(0.004, len, 1, -8), doneAction: 2);
    var chord = [
        LFSaw.ar(freq * [1, 1.002]),
        LFSaw.ar(freq * 1.49 * [1, 1.001]),
        LFSaw.ar(freq * 2.0)
    ].sum;
    var scratch = HPF.ar(WhiteNoise.ar, 1700) * EnvGen.kr(Env.perc(0.001, 0.02)) * 0.35;
    var sig = chord + scratch;
    sig = BPF.ar(sig, 420, 0.6) * 2 + sig * 0.4;
    sig = LPF.ar(sig, 2200);
    sig = (sig * 1.6).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\szekGardon, {
    |out = 0, freq = 90, amp = 0.45, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, 0.12, 1, -8), doneAction: 2);
    var thump = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.35);
    var slap = HPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.02));
    var sig = LPF.ar(thump + slap * 0.5, 450);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\szekClick, {
    |out = 0, freq = 1100, amp = 0.28|
    var env = EnvGen.kr(Env.perc(0.001, 0.04), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.7 + (SinOsc.ar(freq * 0.3) * EnvGen.kr(Env.perc(0.001, 0.02)));
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ---------------------------------------------------------------------------
// RITKA CSÁRDÁS (sparse, heavy bow, room to breathe)
// ---------------------------------------------------------------------------
(
var tempo = 0.55;  // seconds per beat (slow)
var root = 48;
var scale = ~hungarianMinor;
var melody = [0, 2, 3, 4, 4, 3, 2, 0];
var durs = [1.0, 0.6, 0.8, 0.6, 0.8, 0.6, 0.6, 1.2];

Routine({
    "Széki ritka csárdás:".postln;
    melody.do { |deg, i|
        var dur = durs[i] * tempo;
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(60, scale, deg),
            \dur, dur * 0.95,
            \amp, 0.36,
            \vibDepth, 0.016
        ]);

        // Sparse brácsa on offbeats
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.26]);
        (dur * 0.5).wait;
        Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 4), \amp, 0.22]);

        dur.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// ACCELERANDO TO SŰRŰ
// ---------------------------------------------------------------------------
(
var steps = 18;
var startT = 0.5;
var endT = 0.18;
var pattern = [0, 2, 4, 3, 2, 0];

Routine({
    "Széki accelerando (ritka → sűrű):".postln;
    steps.do { |i|
        var t = startT.blend(endT, i / (steps - 1));
        var deg = pattern.wrapAt(i);
        var amp = i.linlin(0, steps - 1, 0.3, 0.42);

        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(60, ~transylvanianMode, deg),
            \dur, t * 1.2,
            \amp, amp,
            \attack, t.linlin(endT, startT, 0.01, 0.05)
        ]);

        if(i % 2 == 0) {
            Synth(\szekGardon, [\amp, 0.46]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(48 + 12, ~transylvanianMode, 0), \amp, 0.3]);
        };

        t.wait;
    };
}).play;
)

// ---------------------------------------------------------------------------
// SŰRŰ CSÁRDÁS (dense, driving)
// ---------------------------------------------------------------------------
(
var tempo = 0.18;
var root = 48;
var scale = ~transylvanianMode;
var melody = [0, 2, 4, 4, 3, 2, 0, -1, 0, 2, 4, 3, 2, 0];

Routine({
    "Széki sűrű csárdás:".postln;
    melody.do { |deg, i|
        Synth(\szekViolin, [
            \freq, ~scaleToFreq.(60, scale, deg),
            \dur, tempo * 1.4,
            \amp, 0.35,
            \attack, 0.01,
            \vibRate, 0
        ]);

        // Brácsa offbeat chop + gardon downbeat + occasional click
        if(i % 2 == 0) {
            Synth(\szekGardon, [\freq, ~scaleToFreq.(root, scale, 0), \amp, 0.5]);
        } {
            Synth(\szekBracsa, [\freq, ~scaleToFreq.(root + 12, scale, 0), \amp, 0.32]);
        };
        if(i % 4 == 3) { Synth(\szekClick, [\amp, 0.32]); };

        tempo.wait;
    };
}).play;
)
