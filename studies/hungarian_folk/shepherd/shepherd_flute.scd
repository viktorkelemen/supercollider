// ============================================================================
// SHEPHERD FLUTE (FURULYA / TILINKÓ) - OVERTONE GLISS & WIND BED
// ============================================================================
// Focus: overtone melodies, pentatonic, airy noise, natural-space reverb
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
// SynthDefs: airy flute with gliss, wind bed, soft drum pulse
// ---------------------------------------------------------------------------
(
SynthDef(\shepFlute, {
    |out = 0, startFreq = 440, endFreq = 440, amp = 0.28, dur = 1.2, pan = 0,
     breath = 0.45, formant = 1500, gliss = 0.15|
    var freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.02, gliss], \exp));
    var env = EnvGen.kr(Env.perc(0.05, dur * 0.95, 1, -4), doneAction: 2);
    var breathNoise = LPF.ar(WhiteNoise.ar * breath, 9000);
    var tone = SinOsc.ar(freqEnv * [1, 2, 3], 0, [0.9, 0.2, 0.1]).sum;
    tone = BPF.ar(tone, formant, 0.25) * 2 + tone * 0.4;
    var sig = tone + breathNoise * 0.5;
    sig = LPF.ar(sig, freqEnv * 5);
    sig = (sig * 1.3).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

SynthDef(\shepWind, {
    |out = 0, amp = 0.08, pan = 0|
    var sig = HPF.ar(WhiteNoise.ar, 200) * 0.4 + LPF.ar(ClipNoise.ar, 800) * 0.2;
    sig = BPF.ar(sig, 600, 0.6) * 0.4 + sig * 0.3;
    sig = LPF.ar(sig, 4000);
    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

SynthDef(\shepDrum, {
    |out = 0, freq = 70, amp = 0.2|
    var env = EnvGen.kr(Env.perc(0.005, 0.18, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.2;
    sig = LPF.ar(sig, 280);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;
)

// ---------------------------------------------------------------------------
// MELODY WITH GLISS AND WIND BED
// ---------------------------------------------------------------------------
(
var root = 55;
var scale = ~pentatonic;
var melody = [0, 2, 4, 7, 9, 7, 4, 2, 0, -1, 0];
var durs = [1.0, 0.7, 0.6, 0.8, 1.2, 0.7, 0.6, 0.9, 1.0, 0.6, 1.4];

Routine({
    var wind;
    "Shepherd flute overtone song:".postln;

    wind = Synth(\shepWind, [\amp, 0.08]);

    0.5.wait;
    melody.do { |deg, i|
        Synth(\shepFlute, [
            \startFreq, ~scaleToFreq.(root + 12, scale, deg + 1),
            \endFreq, ~scaleToFreq.(root + 12, scale, deg),
            \dur, durs[i] * 1.05,
            \amp, 0.3,
            \gliss, 0.12,
            \formant, 1400 + (deg * 30)
        ]);

        if(i % 3 == 0) { Synth(\shepDrum, [\freq, 70, \amp, 0.18]); };
        (durs[i] * rrand(0.9, 1.1)).wait;
    };

    1.0.wait;
    wind.free;
}).play;
)
