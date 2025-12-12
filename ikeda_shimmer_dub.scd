// Ikeda meets Shimmer Dub - 100 BPM
// Negative space arrangement with pulse drops

(
// ====== SynthDefs ======

// Low pulse - replaces kick
SynthDef(\ikedaPulse, {
    arg out = 0, amp = 0.25, freq = 60, dur = 0.015;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, dur, 1, -4), doneAction: 2);
    sig = Pulse.ar(freq, 0.5);
    sig = LPF.ar(sig, 200);
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Deep cut - low frequency burst
SynthDef(\ikedaDeepCut, {
    arg out = 0, amp = 0.25, freq = 80, dur = 0.025;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);
    sig = LPF.ar(Pulse.ar(freq, 0.3), 300);
    sig = sig + (SinOsc.ar(freq * 0.5) * 0.5);
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Sub click - ultra low with impulse
SynthDef(\ikedaSubClick, {
    arg out = 0, amp = 0.3, freq = 40, dur = 0.02;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.0005, dur, 1, -8), doneAction: 2);
    sig = SinOsc.ar(freq);
    sig = sig + (Impulse.ar(0) * 0.3);
    sig = LPF.ar(sig, 150);
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Dub chord with shimmer reverb
SynthDef(\dubStabShimmer, {
    arg out = 0, freq = 110, amp = 0.4, dur = 1,
        delayTime = 0.375, feedback = 0.7, delayAmp = 0.8,
        shimmerAmt = 0.5, decay = 6;
    var sig, dry, env, delayed, verb, shimmer, local, pitched;

    // Filtered detuned saws - root, 5th, octave
    sig = LPF.ar(Saw.ar(freq * [1, 1.002, 1.5, 1.501, 2, 2.001]), 1200) * 0.12;
    sig = Mix(sig);
    sig = RLPF.ar(sig, 1000 + (SinOsc.kr(0.1) * 200), 0.5);

    // Soft attack envelope
    env = EnvGen.kr(Env.perc(0.05, dur, 1, -3));
    dry = sig * env;

    // Ping-pong delay
    local = LocalIn.ar(2);
    delayed = [
        DelayL.ar(dry + (local[1] * feedback), 2, delayTime),
        DelayL.ar(dry + (local[0] * feedback), 2, delayTime * 1.33)
    ];
    delayed = LPF.ar(delayed, 1800);
    delayed = HPF.ar(delayed, 80);
    LocalOut.ar(delayed);

    sig = (dry ! 2 * 0.5) + (delayed * delayAmp);

    // Shimmer reverb - pitch shift up and feed back
    verb = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.95, damp: 0.6);

    // Pitch shift the reverb tail up an octave and a fifth
    pitched = PitchShift.ar(verb, 0.2, 2.0, 0.01, 0.01);
    pitched = pitched + (PitchShift.ar(verb, 0.2, 1.5, 0.01, 0.01) * 0.5);

    // Mix original verb with pitched, then diffuse
    shimmer = verb + (pitched * shimmerAmt);
    shimmer = AllpassL.ar(shimmer, 0.25, [0.13, 0.17], decay * 0.5);
    shimmer = AllpassL.ar(shimmer, 0.25, [0.09, 0.11], decay * 0.4);
    shimmer = LPF.ar(shimmer, 4000);
    shimmer = HPF.ar(shimmer, 80);

    sig = (sig * 0.3) + (shimmer * 0.7);
    sig = sig * EnvGen.kr(Env([1, 1, 0], [decay * 0.6, decay * 0.6], \sin), doneAction: 2);

    Out.ar(out, sig * amp);
}).add;
)

(
// ====== Arrangement - 16 bars at 100 BPM ======
// quarter = 0.6s
// Structure: build (bars 1-4) -> drop (bars 5-8) -> return (bars 9-12+)

// Bar 1-4: Pulse with gaps
s.sendBundle(0.0, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.25, \freq, 55]);
s.sendBundle(0.6, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.23, \freq, 55]);
s.sendBundle(1.2, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.25, \freq, 55]);
// skip 1.8 - first gap
s.sendBundle(2.4, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.25, \freq, 55]);
s.sendBundle(3.0, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.23, \freq, 55]);
s.sendBundle(3.6, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.25, \freq, 55]);
s.sendBundle(4.2, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.23, \freq, 55]);
// skip 4.8 - second gap, leads into drop

// Bar 5-8: DROP - no pulse, shimmer blooms in the void

// Bar 9-12+: Pulse returns stronger
s.sendBundle(9.6, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);
s.sendBundle(10.2, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.26, \freq, 55]);
s.sendBundle(10.8, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);
s.sendBundle(11.4, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.26, \freq, 55]);
s.sendBundle(12.0, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);
s.sendBundle(12.6, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.26, \freq, 55]);
s.sendBundle(13.2, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);
s.sendBundle(13.8, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.26, \freq, 55]);
s.sendBundle(14.4, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);
s.sendBundle(15.0, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.26, \freq, 55]);
s.sendBundle(15.6, [\s_new, \ikedaPulse, -1, 0, 0, \amp, 0.28, \freq, 55]);

// Deep cuts - first section and return only
s.sendBundle(0.45, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.18, \freq, 70]);
s.sendBundle(2.1, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.16, \freq, 80]);
s.sendBundle(4.65, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.15, \freq, 55]);
// gap during drop
s.sendBundle(10.5, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.18, \freq, 70]);
s.sendBundle(12.3, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.16, \freq, 65]);
s.sendBundle(14.1, [\s_new, \ikedaDeepCut, -1, 0, 0, \amp, 0.18, \freq, 80]);

// Sub clicks - sparse, continue through drop
s.sendBundle(0.9, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.25, \freq, 35]);
s.sendBundle(3.3, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.22, \freq, 40]);
// isolated subs in the void
s.sendBundle(6.0, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.2, \freq, 32]);
s.sendBundle(8.4, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.18, \freq, 38]);
// return section
s.sendBundle(11.7, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.25, \freq, 35]);
s.sendBundle(14.7, [\s_new, \ikedaSubClick, -1, 0, 0, \amp, 0.22, \freq, 40]);

// Chord 1 - starts the journey (E2)
s.sendBundle(0.0, [\s_new, \dubStabShimmer, -1, 0, 0,
    \freq, 82.41,
    \amp, 0.34,
    \dur, 0.7,
    \delayTime, 0.3,
    \feedback, 0.72,
    \delayAmp, 0.65,
    \shimmerAmt, 0.6,
    \decay, 9]);

// Chord 2 - during drop, more shimmer, longer tail
s.sendBundle(4.8, [\s_new, \dubStabShimmer, -1, 0, 0,
    \freq, 82.41,
    \amp, 0.3,
    \dur, 0.5,
    \delayTime, 0.3,
    \feedback, 0.75,
    \delayAmp, 0.7,
    \shimmerAmt, 0.75,
    \decay, 10]);

// Chord 3 - return, punchy
s.sendBundle(9.6, [\s_new, \dubStabShimmer, -1, 0, 0,
    \freq, 82.41,
    \amp, 0.36,
    \dur, 0.6,
    \delayTime, 0.3,
    \feedback, 0.68,
    \delayAmp, 0.6,
    \shimmerAmt, 0.55,
    \decay, 8]);

"Ikeda shimmer dub - negative space arrangement".postln;
)
