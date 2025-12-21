// Extracted melody from mystical_plosives.wav
// 38 notes detected by pitch tracking

(
SynthDef(\melodyNote, {
    arg out = 0, freq = 440, amp = 0.2, dur = 0.3;
    var sig, env;
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3) + (SinOsc.ar(freq * 3) * 0.1);
    env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    sig = sig * env * amp;
    sig = Pan2.ar(sig, LFNoise1.kr(0.5).range(-0.3, 0.3));
    sig = sig + FreeVerb.ar(sig, 0.4, 0.7, 0.3);
    Out.ar(out, sig);
}).add;
)

// Play the melody (evaluate this block)
(
var melody = [
    // [time, midi_note, duration]
    [0.331, 56, 0.3],   // G#3
    [0.437, 61, 0.3],   // C#4
    [0.779, 68, 0.3],   // G#4
    [1.003, 64, 0.5],   // E4
    [1.344, 49, 0.3],   // C#3
    [1.557, 68, 0.3],   // G#4
    [1.781, 61, 0.3],   // C#4
    [2.123, 52, 0.3],   // E3
    [2.240, 49, 0.3],   // C#3
    [2.347, 44, 0.3],   // G#2
    [2.453, 63, 0.3],   // D#4
    [2.571, 64, 0.3],   // E4
    [2.912, 56, 0.3],   // G#3
    [3.019, 76, 0.3],   // E5
    [3.125, 61, 0.3],   // C#4
    [3.253, 52, 0.3],   // E3
    [3.349, 61, 0.3],   // C#4
    [3.680, 68, 0.3],   // G#4
    [4.032, 63, 0.3],   // D#4
    [4.160, 56, 0.3],   // G#3
    [4.480, 61, 0.3],   // C#4
    [4.576, 75, 0.3],   // D#5
    [4.928, 51, 0.3],   // D#3
    [5.355, 63, 0.3],   // D#4
    [5.472, 64, 0.3],   // E4
    [5.611, 49, 0.3],   // C#3
    [5.696, 56, 0.3],   // G#3
    [5.941, 52, 0.3],   // E3
    [6.144, 68, 0.3],   // G#4
    [6.379, 76, 0.3],   // E5
    [6.827, 59, 0.3],   // B3
    [7.403, 54, 0.3],   // F#3
    [7.509, 51, 0.3],   // D#3
    [7.605, 62, 0.3],   // D4
    [7.723, 59, 0.3],   // B3
    [7.829, 56, 0.3],   // G#3
    [8.171, 64, 0.4],   // E4
    [8.512, 49, 0.3],   // C#3
];

melody.do { |note|
    var time = note[0];
    var midi = note[1];
    var dur = note[2];
    s.sendBundle(time, [\s_new, \melodyNote, -1, 0, 0,
        \freq, midi.midicps,
        \dur, dur,
        \amp, 0.25
    ]);
};

"Playing extracted melody - 38 notes over ~9 seconds".postln;
)

// Stop all
// s.freeAll;
