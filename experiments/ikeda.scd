// Ryoji Ikeda style - datamatics aesthetic
// Ultra-minimal, precise digital sounds with micro-tones, glitchy rhythms, and stark contrasts
// Uses sendBundle for sample-accurate timing

// =====================================================
// SYNTHDEFS - Evaluate this block first (Cmd+Enter)
// =====================================================
(
SynthDef(\ikedaPulse, {
    arg freq = 1000, amp = 0.3, dur = 0.01, pan = 0;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
    sig = Pan2.ar(sig, pan);
    Out.ar(0, sig);
}).add;

SynthDef(\ikedaClick, {
    arg amp = 0.2, dur = 0.002, pan = 0;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.0001, dur, 1, -8), doneAction: 2);
    sig = WhiteNoise.ar * env * amp;
    sig = HPF.ar(sig, 8000);
    sig = Pan2.ar(sig, pan);
    Out.ar(0, sig);
}).add;

SynthDef(\ikedaSub, {
    arg freq = 40, amp = 0.4, dur = 0.1;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);
    sig = SinOsc.ar(freq) * env * amp;
    sig = sig ! 2;
    Out.ar(0, sig);
}).add;

"SynthDefs loaded.".postln;
)

// =====================================================
// SINGLE SEQUENCE - plays once (~4 seconds)
// =====================================================
(
// High freq data stream
s.sendBundle(0.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 12000, \amp, 0.15, \dur, 0.005, \pan, -0.8]);
s.sendBundle(0.15, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 14000, \amp, 0.12, \dur, 0.003, \pan, 0.8]);
s.sendBundle(0.2, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 11000, \amp, 0.15, \dur, 0.008, \pan, -0.5]);
s.sendBundle(0.22, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.15, \dur, 0.001, \pan, 0.9]);
s.sendBundle(0.25, [\s_new, \ikedaSub, -1, 0, 0, \freq, 35, \amp, 0.5, \dur, 0.15]);
s.sendBundle(0.3, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 15000, \amp, 0.1, \dur, 0.002, \pan, 0.3]);
s.sendBundle(0.35, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 8000, \amp, 0.18, \dur, 0.01, \pan, -0.7]);
s.sendBundle(0.4, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.9]);

// Rhythmic clicks
s.sendBundle(0.5, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
s.sendBundle(0.55, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
s.sendBundle(0.6, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
s.sendBundle(0.6, [\s_new, \ikedaSub, -1, 0, 0, \freq, 40, \amp, 0.6, \dur, 0.1]);
s.sendBundle(0.65, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.15, \dur, 0.001, \pan, 0]);
s.sendBundle(0.7, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
s.sendBundle(0.75, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
s.sendBundle(0.8, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
s.sendBundle(0.8, [\s_new, \ikedaSub, -1, 0, 0, \freq, 45, \amp, 0.55, \dur, 0.08]);

// Scattered tones
s.sendBundle(1.0, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 4000, \amp, 0.2, \dur, 0.02, \pan, 0]);
s.sendBundle(1.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 6000, \amp, 0.15, \dur, 0.015, \pan, -0.6]);
s.sendBundle(1.2, [\s_new, \ikedaSub, -1, 0, 0, \freq, 30, \amp, 0.65, \dur, 0.2]);
s.sendBundle(1.3, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 5000, \amp, 0.18, \dur, 0.018, \pan, 0.6]);
s.sendBundle(1.5, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 3500, \amp, 0.22, \dur, 0.025, \pan, 0]);

// Burst
s.sendBundle(2.0, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.3, \dur, 0.002, \pan, 0]);
s.sendBundle(2.02, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, -0.5]);
s.sendBundle(2.04, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0.5]);
s.sendBundle(2.06, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.8]);
s.sendBundle(2.08, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0.8]);
s.sendBundle(2.1, [\s_new, \ikedaSub, -1, 0, 0, \freq, 25, \amp, 0.7, \dur, 0.3]);
s.sendBundle(2.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 10000, \amp, 0.15, \dur, 0.05, \pan, 0]);

// Descending data
s.sendBundle(2.5, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 18000, \amp, 0.08, \dur, 0.002, \pan, -0.9]);
s.sendBundle(2.55, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 16000, \amp, 0.1, \dur, 0.003, \pan, 0.9]);
s.sendBundle(2.6, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 14000, \amp, 0.12, \dur, 0.004, \pan, -0.7]);
s.sendBundle(2.65, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 12000, \amp, 0.14, \dur, 0.005, \pan, 0.7]);
s.sendBundle(2.7, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 10000, \amp, 0.16, \dur, 0.006, \pan, 0]);
s.sendBundle(2.8, [\s_new, \ikedaSub, -1, 0, 0, \freq, 50, \amp, 0.5, \dur, 0.15]);

// Final section
s.sendBundle(3.2, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 8000, \amp, 0.2, \dur, 0.03, \pan, 0]);
s.sendBundle(3.5, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.3]);
s.sendBundle(3.55, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0.3]);
s.sendBundle(3.6, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
s.sendBundle(3.6, [\s_new, \ikedaSub, -1, 0, 0, \freq, 20, \amp, 0.6, \dur, 0.4]);
s.sendBundle(4.0, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 1000, \amp, 0.25, \dur, 0.1, \pan, 0]);

"datamatics // single sequence".postln;
)

// =====================================================
// LOOPING SEQUENCE - 8 cycles (~36 seconds)
// =====================================================
(
8.do { |cycle|
    var offset = cycle * 4.5;

    // High freq data stream
    s.sendBundle(offset + 0.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 12000, \amp, 0.15, \dur, 0.005, \pan, -0.8]);
    s.sendBundle(offset + 0.15, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 14000, \amp, 0.12, \dur, 0.003, \pan, 0.8]);
    s.sendBundle(offset + 0.2, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 11000, \amp, 0.15, \dur, 0.008, \pan, -0.5]);
    s.sendBundle(offset + 0.22, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.15, \dur, 0.001, \pan, 0.9]);
    s.sendBundle(offset + 0.25, [\s_new, \ikedaSub, -1, 0, 0, \freq, 35, \amp, 0.5, \dur, 0.15]);
    s.sendBundle(offset + 0.3, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 15000, \amp, 0.1, \dur, 0.002, \pan, 0.3]);
    s.sendBundle(offset + 0.35, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 8000, \amp, 0.18, \dur, 0.01, \pan, -0.7]);
    s.sendBundle(offset + 0.4, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.9]);

    // Rhythmic clicks
    s.sendBundle(offset + 0.5, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.55, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.6, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.6, [\s_new, \ikedaSub, -1, 0, 0, \freq, 40, \amp, 0.6, \dur, 0.1]);
    s.sendBundle(offset + 0.65, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.15, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.7, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.75, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.8, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 0.8, [\s_new, \ikedaSub, -1, 0, 0, \freq, 45, \amp, 0.55, \dur, 0.08]);

    // Scattered tones
    s.sendBundle(offset + 1.0, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 4000, \amp, 0.2, \dur, 0.02, \pan, 0]);
    s.sendBundle(offset + 1.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 6000, \amp, 0.15, \dur, 0.015, \pan, -0.6]);
    s.sendBundle(offset + 1.2, [\s_new, \ikedaSub, -1, 0, 0, \freq, 30, \amp, 0.65, \dur, 0.2]);
    s.sendBundle(offset + 1.3, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 5000, \amp, 0.18, \dur, 0.018, \pan, 0.6]);
    s.sendBundle(offset + 1.5, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 3500, \amp, 0.22, \dur, 0.025, \pan, 0]);

    // Burst
    s.sendBundle(offset + 2.0, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.3, \dur, 0.002, \pan, 0]);
    s.sendBundle(offset + 2.02, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, -0.5]);
    s.sendBundle(offset + 2.04, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0.5]);
    s.sendBundle(offset + 2.06, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.8]);
    s.sendBundle(offset + 2.08, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0.8]);
    s.sendBundle(offset + 2.1, [\s_new, \ikedaSub, -1, 0, 0, \freq, 25, \amp, 0.7, \dur, 0.3]);
    s.sendBundle(offset + 2.1, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 10000, \amp, 0.15, \dur, 0.05, \pan, 0]);

    // Descending data
    s.sendBundle(offset + 2.5, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 18000, \amp, 0.08, \dur, 0.002, \pan, -0.9]);
    s.sendBundle(offset + 2.55, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 16000, \amp, 0.1, \dur, 0.003, \pan, 0.9]);
    s.sendBundle(offset + 2.6, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 14000, \amp, 0.12, \dur, 0.004, \pan, -0.7]);
    s.sendBundle(offset + 2.65, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 12000, \amp, 0.14, \dur, 0.005, \pan, 0.7]);
    s.sendBundle(offset + 2.7, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 10000, \amp, 0.16, \dur, 0.006, \pan, 0]);
    s.sendBundle(offset + 2.8, [\s_new, \ikedaSub, -1, 0, 0, \freq, 50, \amp, 0.5, \dur, 0.15]);

    // Final section
    s.sendBundle(offset + 3.2, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 8000, \amp, 0.2, \dur, 0.03, \pan, 0]);
    s.sendBundle(offset + 3.5, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, -0.3]);
    s.sendBundle(offset + 3.55, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.2, \dur, 0.001, \pan, 0.3]);
    s.sendBundle(offset + 3.6, [\s_new, \ikedaClick, -1, 0, 0, \amp, 0.25, \dur, 0.001, \pan, 0]);
    s.sendBundle(offset + 3.6, [\s_new, \ikedaSub, -1, 0, 0, \freq, 20, \amp, 0.6, \dur, 0.4]);
    s.sendBundle(offset + 4.0, [\s_new, \ikedaPulse, -1, 0, 0, \freq, 1000, \amp, 0.25, \dur, 0.1, \pan, 0]);
};

"datamatics // 8 cycles (~36 sec)".postln;
)
