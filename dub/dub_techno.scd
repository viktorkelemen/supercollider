// Hypnotic Dub Techno - 100 BPM
// Deep, minimal chord stabs with delay and reverb

(
// ====== SynthDefs ======

// Soft pillowy kick - low and deep
SynthDef(\dubKick, {
    arg out = 0, amp = 0.5, freq = 42;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.03, 0.6, 1, -3), doneAction: 2);
    sig = SinOsc.ar(freq + (EnvGen.kr(Env.perc(0.02, 0.1)) * 80));
    sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.kr(Env.perc(0.02, 0.25)) * 0.25);
    sig = LPF.ar(sig, 120);
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Soft metallic hihat with pink noise
SynthDef(\dubHat, {
    arg out = 0, amp = 0.1, decay = 0.1, hpf = 8000;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.01, decay, 1, -6), doneAction: 2);
    sig = Mix(Pulse.ar([4010, 4151, 6023, 8117], 0.5)) * 0.08;
    sig = sig + (PinkNoise.ar * 0.3);
    sig = HPF.ar(sig, hpf);
    sig = LPF.ar(sig, 12000);
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Dub chord stab with ping-pong delay and massive reverb
SynthDef(\dubStabDelayVerb, {
    arg out = 0, freq = 110, amp = 0.4, dur = 1,
        delayTime = 0.375, feedback = 0.7, delayAmp = 0.8,
        verbAmp = 0.8, decay = 6;
    var sig, dry, env, delayed, verb, local;

    // Filtered detuned saws - root, 5th, octave
    sig = LPF.ar(Saw.ar(freq * [1, 1.002, 1.5, 1.501, 2, 2.001]), 1200) * 0.12;
    sig = Mix(sig);
    sig = RLPF.ar(sig, 1000 + (SinOsc.kr(0.1) * 200), 0.5);

    // Soft attack envelope
    env = EnvGen.kr(Env.perc(0.05, dur, 1, -3));
    dry = sig * env;

    // Ping-pong delay with filtered feedback
    local = LocalIn.ar(2);
    delayed = [
        DelayL.ar(dry + (local[1] * feedback), 2, delayTime),
        DelayL.ar(dry + (local[0] * feedback), 2, delayTime * 1.33)
    ];
    delayed = LPF.ar(delayed, 1800);
    delayed = HPF.ar(delayed, 80);
    LocalOut.ar(delayed);

    sig = (dry ! 2 * 0.5) + (delayed * delayAmp);

    // Massive lush reverb
    verb = FreeVerb2.ar(sig[0], sig[1], mix: 1, room: 0.97, damp: 0.5);
    verb = verb + AllpassL.ar(verb, 0.25, [0.13, 0.17], decay * 0.6);
    verb = LPF.ar(verb, 3000);
    verb = HPF.ar(verb, 80);

    sig = (sig * 0.4) + (verb * verbAmp);
    sig = sig * EnvGen.kr(Env([1, 1, 0], [decay * 0.7, decay * 0.5], \sin), doneAction: 2);

    Out.ar(out, sig * amp);
}).add;
)

(
// ====== Pattern - 8 bars at 100 BPM ======
// quarter = 0.6s, eighth = 0.3s

// Kicks - 4 on the floor
s.sendBundle(0.0, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(0.6, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(1.2, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(1.8, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(2.4, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(3.0, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(3.6, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(4.2, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(4.8, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(5.4, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(6.0, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(6.6, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(7.2, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(7.8, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(8.4, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);
s.sendBundle(9.0, [\s_new, \dubKick, -1, 0, 0, \amp, 0.4]);

// Sparse hihats - every other offbeat for hypnotic feel
s.sendBundle(0.3, [\s_new, \dubHat, -1, 0, 0, \amp, 0.06, \decay, 0.08]);
s.sendBundle(1.5, [\s_new, \dubHat, -1, 0, 0, \amp, 0.05, \decay, 0.06]);
s.sendBundle(2.7, [\s_new, \dubHat, -1, 0, 0, \amp, 0.06, \decay, 0.08]);
s.sendBundle(3.9, [\s_new, \dubHat, -1, 0, 0, \amp, 0.04, \decay, 0.06]);
s.sendBundle(5.1, [\s_new, \dubHat, -1, 0, 0, \amp, 0.06, \decay, 0.08]);
s.sendBundle(6.3, [\s_new, \dubHat, -1, 0, 0, \amp, 0.05, \decay, 0.06]);
s.sendBundle(7.5, [\s_new, \dubHat, -1, 0, 0, \amp, 0.06, \decay, 0.08]);
s.sendBundle(8.7, [\s_new, \dubHat, -1, 0, 0, \amp, 0.04, \decay, 0.06]);

// Chord stabs with delay and reverb - sparse, let them breathe
s.sendBundle(0.0, [\s_new, \dubStabDelayVerb, -1, 0, 0,
    \freq, 82.41,  // E2
    \amp, 0.32,
    \dur, 0.7,
    \delayTime, 0.3,
    \feedback, 0.73,
    \delayAmp, 0.75,
    \verbAmp, 0.85,
    \decay, 7]);

s.sendBundle(5.4, [\s_new, \dubStabDelayVerb, -1, 0, 0,
    \freq, 82.41,  // E2
    \amp, 0.28,
    \dur, 0.4,
    \delayTime, 0.3,
    \feedback, 0.7,
    \delayAmp, 0.7,
    \verbAmp, 0.8,
    \decay, 6]);

"Deep hypnotic dub techno - 100 BPM".postln;
)
