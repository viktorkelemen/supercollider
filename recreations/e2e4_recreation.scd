// E2-E4 Recreation - inspired by Manuel Göttsching's 1984 masterpiece
// Boot the server first with Cmd-B, then evaluate each block with Cmd-Enter

// Analysis of E2-E4:
// - Key: C# minor
// - Tempo: ~110 BPM (16th notes = ~136ms each)
// - Two main chords: C#m7 (C#-E-G#-B) and F#m (F#-A-C#)
// - ARP Odyssey through ARP Sequencer for the iconic sequence
// - Slow filter modulation creates the hypnotic "breathing" effect

s.boot;

(
// ==========================================
// E2-E4 SEQUENCE SYNTHDEF
// ==========================================
// Emulates ARP Odyssey: sawtooth oscillators + resonant filter
SynthDef(\e2e4Seq, {
    arg out = 0, freq = 138.59, amp = 0.3, gate = 1,
        cutoff = 2000, res = 0.3, filterLFO = 0.02, filterDepth = 1500;
    var sig, env, filt;

    // Dual detuned saws (ARP Odyssey character)
    sig = Saw.ar(freq * [1, 1.005]) + Pulse.ar(freq * 0.5, 0.3, 0.3);
    sig = Mix(sig) * 0.5;

    // Slow filter sweep - the signature E2-E4 "breathing"
    filt = SinOsc.kr(filterLFO, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, filt.clip(100, 12000), res);

    // Percussive envelope for each note
    env = EnvGen.kr(Env.perc(0.005, 0.15), gate, doneAction: 2);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// ==========================================
// E2-E4 PAD SYNTHDEF
// ==========================================
// Prophet-10 style pad for the two-chord progression
SynthDef(\e2e4Pad, {
    arg out = 0, freq = 138.59, amp = 0.15, gate = 1,
        cutoff = 1200, filterLFO = 0.03, filterDepth = 600;
    var sig, env, filt, voices;

    // Stacked detuned saws (Prophet-10 style)
    voices = [
        Saw.ar(freq * [1, 1.002, 0.998]),
        Saw.ar(freq * 1.498 * [1, 1.003]),  // ~fifth
        Saw.ar(freq * 1.189 * [1, 0.999]),  // ~minor third
        Saw.ar(freq * 1.782 * [1, 1.001]) * 0.5  // ~minor 7th
    ];

    sig = Mix(voices.flatten) * 0.1;

    // Slow filter modulation
    filt = SinOsc.kr(filterLFO, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, filt.clip(100, 8000), 0.4);
    sig = Splay.ar(sig, spread: 0.6);

    // Slow attack/release for pads
    env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);

    // Subtle reverb
    sig = sig + FreeVerb2.ar(sig[0], sig[1], mix: 0.35, room: 0.7, damp: 0.5);

    Out.ar(out, sig * env * amp);
}).add;

// ==========================================
// METALLIC PERCUSSION (Pearl Syncussion style)
// ==========================================
SynthDef(\e2e4Perc, {
    arg out = 0, freq = 4000, amp = 0.1, decay = 0.1;
    var sig, env;

    // Metallic ring - bandpass filtered noise + sine
    sig = BPF.ar(WhiteNoise.ar, freq, 0.01) * 4;
    sig = sig + SinOsc.ar(freq * 0.5, 0, 0.3);

    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
    sig = HPF.ar(sig, 2000);

    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// ==========================================
// SELF-SEQUENCING LOOP (no Routine needed)
// ==========================================
// Uses Demand UGens to sequence internally - plays continuously
SynthDef(\e2e4Loop, {
    arg out = 0, amp = 0.25, tempo = 110, cutoffBase = 1500, cutoffMod = 1000, gate = 1;
    var trig, seq, freq, sig, env, filt, cutoffLFO;

    // 16th note trigger at tempo
    trig = Impulse.kr(tempo / 60 * 4);

    // C#m7 arpeggio: C#3, E3, G#3, E3, C#3, E3, G#3, B3
    seq = Dseq([49, 52, 56, 52, 49, 52, 56, 59], inf);
    freq = Demand.kr(trig, 0, seq).midicps;
    freq = Lag.kr(freq, 0.005);

    // Dual detuned saws (ARP Odyssey character)
    sig = Saw.ar(freq * [1, 1.005]) + Pulse.ar(freq * 0.5, 0.3, 0.3);
    sig = Mix(sig) * 0.5;

    // Slow filter sweep - the signature E2-E4 "breathing"
    cutoffLFO = SinOsc.kr(0.02, 0, cutoffMod, cutoffBase);
    sig = RLPF.ar(sig, cutoffLFO.clip(200, 10000), 0.3);

    // Percussive envelope per note
    env = EnvGen.kr(Env.perc(0.005, 0.12), trig);
    sig = sig * env;

    // Overall gate envelope
    sig = sig * EnvGen.kr(Env.asr(0.5, 1, 2), gate, doneAction: 2);

    Out.ar(out, Pan2.ar(sig * amp, 0));
}).add;

"E2-E4 SynthDefs loaded!".postln;
)

(
// ==========================================
// THE SEQUENCE
// ==========================================
// E2-E4's iconic 16-step pattern in C# minor
// Notes: C#3, G#3, E3, G#3 repeated with variations

var tempo = 110;  // BPM
var sixteenth = 60 / tempo / 4;  // Duration of 16th note

// C# minor scale notes (MIDI): C#=49, D#=51, E=52, F#=54, G#=56, A=57, B=59

// The classic E2-E4 arpeggio pattern (approximated)
// Alternates C#m and F#m chord tones
~e2e4Pattern = [
    49, 56, 52, 56,   // C#, G#, E, G# (C#m)
    49, 56, 52, 56,   // repeat
    54, 61, 57, 61,   // F#, C#(+oct), A, C# (F#m)
    54, 61, 57, 61    // repeat
];

// Or try this simpler hypnotic pattern (closer to opening):
~simplePattern = [
    49, 52, 56, 52,   // C#, E, G#, E
    49, 52, 56, 59,   // C#, E, G#, B (adding 7th)
    49, 52, 56, 52,   // C#, E, G#, E
    49, 52, 56, 59    // C#, E, G#, B
];

// Start the pad
~pad = Synth(\e2e4Pad, [\freq, 49.midicps, \cutoff, 800, \filterLFO, 0.025]);

// Start the sequence
~seq = Routine({
    var pattern = ~simplePattern;
    var idx = 0;

    inf.do {
        var note = pattern[idx % pattern.size];

        // Play sequence note
        Synth(\e2e4Seq, [
            \freq, note.midicps,
            \amp, 0.25,
            \cutoff, rrand(1500, 3000),  // Slight variation
            \filterLFO, 0.02,
            \filterDepth, 2000
        ]);

        // Occasional metallic hit (every 8th note)
        if(idx % 8 == 0) {
            Synth(\e2e4Perc, [
                \freq, rrand(3000, 6000),
                \amp, 0.05,
                \decay, 0.08
            ]);
        };

        idx = idx + 1;
        sixteenth.wait;
    };
}).play;

"E2-E4 sequence started! Press Cmd-. to stop".postln;
)

// ==========================================
// QUICK PLAY (self-sequencing version)
// ==========================================
// Just evaluate this block - no Routine needed
(
~pad = Synth(\e2e4Pad, [\freq, 49.midicps, \cutoff, 700, \filterLFO, 0.02, \amp, 0.12]);
~loop = Synth(\e2e4Loop, [\tempo, 110, \amp, 0.22, \cutoffBase, 1500, \cutoffMod, 1200]);
"E2-E4 playing! Evaluate the stop block below to stop.".postln;
)

// ==========================================
// STOP EVERYTHING
// ==========================================
(
~seq.stop;
~pad.set(\gate, 0);
s.freeAll;
"Stopped".postln;
)

// ==========================================
// VARIATIONS TO TRY
// ==========================================

// Variation 1: More hypnotic (single chord, slower filter)
(
var tempo = 100;
var sixteenth = 60 / tempo / 4;

~pad = Synth(\e2e4Pad, [\freq, 49.midicps, \cutoff, 600, \filterLFO, 0.015, \filterDepth, 800]);

~seq = Routine({
    var pattern = [49, 56, 52, 56, 49, 56, 52, 59];  // Simple C#m7 arpeggio
    var idx = 0;

    inf.do {
        Synth(\e2e4Seq, [
            \freq, pattern[idx % pattern.size].midicps,
            \amp, 0.2,
            \cutoff, 1000 + (500 * sin(idx * 0.05)),  // Evolving filter
            \filterDepth, 1500
        ]);
        idx = idx + 1;
        sixteenth.wait;
    };
}).play;
)

// Variation 2: With bass pulse (like later in E2-E4)
(
SynthDef(\e2e4Bass, {
    arg out = 0, freq = 69.3, amp = 0.4, gate = 1;
    var sig, env;
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2, 0, 0.3));
    sig = sig + LPF.ar(Saw.ar(freq), 200, 0.5);
    env = EnvGen.kr(Env.perc(0.01, 0.3), gate, doneAction: 2);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

var tempo = 110;
var sixteenth = 60 / tempo / 4;

~pad = Synth(\e2e4Pad, [\freq, 49.midicps, \cutoff, 800]);

~seq = Routine({
    var pattern = [49, 56, 52, 56, 49, 56, 52, 59];
    var idx = 0;

    inf.do {
        Synth(\e2e4Seq, [
            \freq, pattern[idx % pattern.size].midicps,
            \amp, 0.2
        ]);

        // Bass on beats 1 and 9 (every half bar)
        if(idx % 8 == 0) {
            Synth(\e2e4Bass, [\freq, 49.midicps / 2, \amp, 0.35]);
        };

        idx = idx + 1;
        sixteenth.wait;
    };
}).play;
)
