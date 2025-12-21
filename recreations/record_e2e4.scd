// E2-E4 Recording Script
// Run this in SuperCollider IDE (Cmd-Enter on each block)

// STEP 1: Load the SynthDefs (run this block first)
(
SynthDef(\e2e4Pad, {
    arg out = 0, freq = 138.59, amp = 0.15, gate = 1,
        cutoff = 1200, filterLFO = 0.03, filterDepth = 600;
    var sig, env, filt, voices;
    voices = [
        Saw.ar(freq * [1, 1.002, 0.998]),
        Saw.ar(freq * 1.498 * [1, 1.003]),
        Saw.ar(freq * 1.189 * [1, 0.999]),
        Saw.ar(freq * 1.782 * [1, 1.001]) * 0.5
    ];
    sig = Mix(voices.flatten) * 0.1;
    filt = SinOsc.kr(filterLFO, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, filt.clip(100, 8000), 0.4);
    sig = Splay.ar(sig, spread: 0.6);
    env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);
    sig = sig + FreeVerb2.ar(sig[0], sig[1], mix: 0.35, room: 0.7, damp: 0.5);
    Out.ar(out, sig * env * amp);
}).add;

SynthDef(\e2e4Loop, {
    arg out = 0, amp = 0.25, tempo = 110, cutoffBase = 1500, cutoffMod = 1000, gate = 1;
    var trig, seq, freq, sig, env, cutoffLFO;
    trig = Impulse.kr(tempo / 60 * 4);
    seq = Dseq([49, 52, 56, 52, 49, 52, 56, 59], inf);
    freq = Demand.kr(trig, 0, seq).midicps;
    freq = Lag.kr(freq, 0.005);
    sig = Saw.ar(freq * [1, 1.005]) + Pulse.ar(freq * 0.5, 0.3, 0.3);
    sig = Mix(sig) * 0.5;
    cutoffLFO = SinOsc.kr(0.02, 0, cutoffMod, cutoffBase);
    sig = RLPF.ar(sig, cutoffLFO.clip(200, 10000), 0.3);
    env = EnvGen.kr(Env.perc(0.005, 0.12), trig);
    sig = sig * env;
    sig = sig * EnvGen.kr(Env.asr(0.5, 1, 2), gate, doneAction: 2);
    Out.ar(out, Pan2.ar(sig * amp, 0));
}).add;

"SynthDefs loaded!".postln;
)

// STEP 2: Start recording and play for 5 minutes (run this block)
(
var duration = 300;  // 5 minutes
var path = thisProcess.nowExecutingPath.dirname +/+ "e2e4_5min.wav";

// Setup recording
s.recHeaderFormat = "wav";
s.recSampleFormat = "int24";
s.prepareForRecord(path);

// Start recording
s.record;
("Recording to: " ++ path).postln;

// Start synths
~pad = Synth(\e2e4Pad, [\freq, 138.59, \cutoff, 700, \filterLFO, 0.02, \amp, 0.12]);
~loop = Synth(\e2e4Loop, [\tempo, 110, \amp, 0.22, \cutoffBase, 1500, \cutoffMod, 1200]);

// Schedule stop after duration
SystemClock.sched(duration - 3, {
    "Releasing synths...".postln;
    ~loop.set(\gate, 0);
    nil
});

SystemClock.sched(duration - 1, {
    ~pad.set(\gate, 0);
    nil
});

SystemClock.sched(duration + 2, {
    s.stopRecording;
    "Recording complete!".postln;
    nil
});

("Recording for " ++ (duration/60) ++ " minutes. Will auto-stop.").postln;
)

// MANUAL STOP (if needed - run this to stop early)
(
~loop.set(\gate, 0);
~pad.set(\gate, 0);
SystemClock.sched(2, { s.stopRecording; "Stopped".postln; nil });
)
