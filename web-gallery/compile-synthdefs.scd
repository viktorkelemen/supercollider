// ============================================================================
// SYNTHDEF COMPILER FOR WEB GALLERY - ALL HUNGARIAN FOLK EXPERIMENTS
// ============================================================================
// Run this in SuperCollider to export .scsyndef files for SuperSonic.
//
// Usage:
// 1. Boot the server: s.boot
// 2. Run this file: "/path/to/compile-synthdefs.scd".load
// 3. Check the output directory for .scsyndef files
// ============================================================================

(
var outputDir = PathName(thisProcess.nowExecutingPath).pathOnly ++ "supersonic/synthdefs/";
outputDir.mkdir;
"Compiling SynthDefs to: %".format(outputDir).postln;
"".postln;

// ============================================================================
// VERBUNKOS CIMBALOM
// ============================================================================
"[Verbunkos] Compiling cimbalom...".postln;

SynthDef(\cimbalom, {
    |out = 0, freq = 440, amp = 0.3, dur = 1, pan = 0|
    var env = EnvGen.kr(Env.perc(0.001, dur, 1, -6), doneAction: 2);
    var partials = [1, 2.001, 3.002, 4.005, 5.01, 6.02, 7.03];
    var amps = [1, 0.7, 0.4, 0.25, 0.15, 0.1, 0.05];
    var sig = Mix(
        partials.collect { |p, i|
            var detune = LFNoise1.kr(0.5).range(-1, 1);
            SinOsc.ar(freq * p + detune, 0, amps[i]);
        }
    );
    var attack = HPF.ar(WhiteNoise.ar, 4000) * EnvGen.kr(Env.perc(0.0001, 0.01));
    var resonance = DelayC.ar(sig, 0.05, LFNoise1.kr(0.3).range(0.001, 0.003)) * 0.1;
    sig = sig + (attack * 0.15) + resonance;
    sig = LPF.ar(sig, (freq * 8).min(16000));
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\cimbalomTremolo, {
    |out = 0, freq = 440, amp = 0.25, dur = 1, pan = 0, tremoloRate = 12|
    var tremolo = LFPulse.kr(tremoloRate, 0, 0.5).range(0.3, 1);
    var env = EnvGen.kr(Env.linen(0.01, dur - 0.1, 0.08), doneAction: 2);
    var partials = [1, 2.001, 3.002, 4.005];
    var amps = [1, 0.6, 0.3, 0.15];
    var sig = Mix(partials.collect { |p, i| SinOsc.ar(freq * p, 0, amps[i]); });
    var attack = HPF.ar(WhiteNoise.ar, 4000) * tremolo * 0.1;
    sig = sig + attack;
    sig = LPF.ar(sig, freq * 6);
    Out.ar(out, Pan2.ar(sig * env * amp * tremolo, pan));
}).writeDefFile(outputDir);

// ============================================================================
// VERBUNKOS VIOLIN
// ============================================================================
"[Verbunkos] Compiling violin...".postln;

SynthDef(\verbViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.5, pan = 0,
     attack = 0.08, release = 0.15,
     vibRate = 5, vibDepth = 0.015, vibDelay = 0.1,
     bowPressure = 0.5, brightness = 0.6|
    var env, vibEnv, vibrato, exciter, string, sig;
    var bowNoise, formant1, formant2, formant3;
    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, dur - attack - release, release], [2, -2, -4]),
        doneAction: 2
    );
    vibEnv = EnvGen.kr(Env([0, 0, 1], [vibDelay, 0.1]));
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.5).range(-0.3, 0.3)) * freq * vibDepth * vibEnv;
    exciter = LFSaw.ar(freq + vibrato);
    bowNoise = HPF.ar(PinkNoise.ar * EnvGen.kr(Env([1, 0.3, 0.2], [0.05, 0.1])), 2000) * bowPressure * 0.15;
    string = exciter + bowNoise;
    string = CombL.ar(string, 0.05, 1/freq * 0.12, 0.1) * 0.3 + (string * 0.7);
    formant1 = BPF.ar(string, 280, 0.3) * 3;
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;
    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.3).tanh * 0.8;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\verbViolinSlide, {
    |out = 0, startFreq = 440, endFreq = 440, amp = 0.3, dur = 0.5,
     slideTime = 0.1, pan = 0, vibRate = 5, vibDepth = 0.015, brightness = 0.6|
    var env, freqEnv, vibrato, exciter, string, sig;
    var formant1, formant2, formant3, freq;
    freqEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0.01, slideTime], \exp));
    freq = freqEnv;
    env = EnvGen.kr(Env([0, 1, 0.7, 0], [0.05, dur - 0.2, 0.15], [2, -2, -4]), doneAction: 2);
    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    exciter = LFSaw.ar(freq + vibrato);
    string = CombL.ar(exciter, 0.05, 1/freq * 0.12, 0.08) * 0.25 + (exciter * 0.75);
    formant1 = BPF.ar(string, 280, 0.3) * 3;
    formant2 = BPF.ar(string, 460, 0.25) * 2.5;
    formant3 = BPF.ar(string, 2500, 0.2) * 1.5;
    sig = string + formant1 + formant2 + formant3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.3).tanh * 0.8;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

// ============================================================================
// VERBUNKOS BRACSA (Rhythmic Viola)
// ============================================================================
"[Verbunkos] Compiling bracsa...".postln;

SynthDef(\bracsa, {
    |out = 0, freq = 220, amp = 0.25, dur = 0.08, pan = 0|
    var env = EnvGen.kr(Env.perc(0.003, dur, 1, -8), doneAction: 2);
    var freqs = [freq, freq * 1.5, freq * 2];
    var sig = Mix(freqs.collect { |f| LFSaw.ar(f + LFNoise1.kr(3).range(-2, 2)) * 0.33 });
    sig = HPF.ar(sig, 180);
    sig = LPF.ar(sig, 2500);
    sig = (sig * 2).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\bracsaAccent, {
    |out = 0, freq = 220, amp = 0.3, dur = 0.1, pan = 0|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -6), doneAction: 2);
    var freqs = [freq, freq * 1.5, freq * 2];
    var sig = Mix(freqs.collect { |f| LFSaw.ar(f) * 0.33 });
    var attack = HPF.ar(WhiteNoise.ar, 1500) * EnvGen.kr(Env.perc(0.001, 0.015)) * 0.3;
    sig = sig + attack;
    sig = HPF.ar(sig, 150);
    sig = LPF.ar(sig, 3000);
    sig = (sig * 2.5).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

// ============================================================================
// SHEPHERD FLUTES
// ============================================================================
"[Shepherd] Compiling flutes...".postln;

SynthDef(\shepFurulya, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.8, pan = 0,
     breath = 0.35, vibRate = 4.5, vibDepth = 0.01, attack = 0.04, brightness = 0.6|
    var env, breathNoise, vibrato, sig;
    env = EnvGen.kr(Env([0, 1, 0.85, 0], [attack, dur * 0.7, dur * 0.26], [2, -2, -4]), doneAction: 2);
    vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.4).range(-0.3, 0.3)) * freq * vibDepth;
    sig = SinOsc.ar(freq + vibrato) * 0.65 +
          SinOsc.ar((freq + vibrato) * 2, 0, 0.22) +
          SinOsc.ar((freq + vibrato) * 3, 0, 0.08) +
          SinOsc.ar((freq + vibrato) * 4, 0, 0.03);
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 6000) * 0.4;
    breathNoise = breathNoise + HPF.ar(PinkNoise.ar * breath * 0.2, 3000);
    sig = sig + breathNoise;
    sig = BPF.ar(sig, 900, 0.35) * 1.5 + sig * 0.55;
    sig = LPF.ar(sig, freq * (3 + brightness * 5));
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\shepTilinko, {
    |out = 0, freq = 440, amp = 0.28, dur = 1.0, pan = 0,
     breath = 0.4, overblowMix = 0.35, formant = 1500|
    var env, breathNoise, fundamental, overtones, sig;
    env = EnvGen.kr(Env.perc(0.05, dur * 0.95, 1, -4), doneAction: 2);
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 7000) * 0.45;
    fundamental = SinOsc.ar(freq * (1 + LFNoise1.kr(2.5).range(-0.004, 0.004)));
    overtones = SinOsc.ar(freq * 2, 0, 0.4) + SinOsc.ar(freq * 3, 0, 0.22) + SinOsc.ar(freq * 4, 0, 0.1);
    sig = (fundamental * (1 - overblowMix)) + (overtones * overblowMix);
    sig = BPF.ar(sig, formant, 0.22) * 2 + sig * 0.5;
    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 6);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\shepLongFlute, {
    |out = 0, freq = 220, amp = 0.32, dur = 1.2, pan = 0,
     breath = 0.3, vibRate = 3.5, vibDepth = 0.012|
    var env, breathNoise, vibrato, sig;
    env = EnvGen.kr(Env([0, 1, 0.9, 0.7, 0], [0.06, dur * 0.4, dur * 0.35, dur * 0.19], [2, -1, -2, -4]), doneAction: 2);
    vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    sig = SinOsc.ar(freq + vibrato) * 0.75 + SinOsc.ar((freq + vibrato) * 2, 0, 0.15) + SinOsc.ar((freq + vibrato) * 3, 0, 0.05);
    breathNoise = LPF.ar(WhiteNoise.ar * breath, 4000) * 0.35;
    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 4);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

// ============================================================================
// DUDA (HUNGARIAN BAGPIPE)
// ============================================================================
"[Duda] Compiling bagpipe...".postln;

SynthDef(\dudaDrone, {
    |out = 0, freq = 110, amp = 0.28, dur = 2, pan = -0.1|
    var env, fundamental, fifth, sig;
    env = EnvGen.kr(Env.linen(0.3, dur - 0.6, 0.3), doneAction: 2);
    fundamental = Saw.ar(freq) * 0.6 + Pulse.ar(freq, 0.45) * 0.25;
    fifth = Saw.ar(freq * 1.5) * 0.35 + Pulse.ar(freq * 1.5, 0.4) * 0.15;
    sig = fundamental + fifth;
    sig = LPF.ar(sig, 800);
    sig = (sig * 2).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\dudaChanter, {
    |out = 0, freq = 440, amp = 0.28, dur = 0.4, pan = 0.1,
     buzz = 0.5, nasal = 0.6, vibAmt = 0.0|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -4), doneAction: 2);
    var vib = SinOsc.kr(6).range(vibAmt.neg, vibAmt) * freq;
    var sig = Saw.ar(freq + vib) * (0.7 + buzz) + Pulse.ar(freq * 2, 0.4) * 0.3;
    sig = BPF.ar(sig, 600, 0.3) * 2 + BPF.ar(sig, 1800, 0.2) * nasal + sig * 0.3;
    sig = (sig * 1.6).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\dudaChanterLong, {
    |out = 0, freq = 440, amp = 0.26, dur = 1.0, pan = 0.1,
     buzz = 0.5, nasal = 0.6, vibAmt = 0.008|
    var env = EnvGen.kr(Env.linen(0.02, dur - 0.15, 0.12, 1, -3), doneAction: 2);
    var vib = SinOsc.kr(5.5).range(vibAmt.neg, vibAmt) * freq;
    var sig = Saw.ar(freq + vib) * (0.7 + buzz) + Pulse.ar(freq * 2, 0.42) * 0.28;
    sig = BPF.ar(sig, 620, 0.32) * 2.2 + BPF.ar(sig, 1750, 0.22) * nasal + sig * 0.28;
    sig = (sig * 1.5).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\dudaStomp, {
    |out = 0, freq = 70, amp = 0.5|
    var env = EnvGen.kr(Env.perc(0.005, 0.18, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) + SinOsc.ar(freq * 2) * 0.25;
    sig = LPF.ar(sig, 300);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

SynthDef(\dudaHeel, {
    |out = 0, freq = 1200, amp = 0.25|
    var env = EnvGen.kr(Env.perc(0.001, 0.04), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar, freq) * 0.6 + BPF.ar(WhiteNoise.ar, freq * 1.5, 0.3) * 0.4;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// CSÁRDÁS
// ============================================================================
"[Csárdás] Compiling dance synths...".postln;

SynthDef(\csardViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.4, pan = 0, vibRate = 5, vibDepth = 0.012|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 280, 0.3) * 2.5 + BPF.ar(sig, 460, 0.25) * 2 + sig * 0.4;
    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.2).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\csardBass, {
    |out = 0, freq = 110, amp = 0.35, dur = 0.3|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -6), doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.7 + SinOsc.ar(freq * 2) * 0.2 + LFTri.ar(freq) * 0.1;
    sig = LPF.ar(sig, 400);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// HALLGATÓ (Slow Lament)
// ============================================================================
"[Hallgató] Compiling expressive synths...".postln;

SynthDef(\hallgatoViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 1.0, pan = 0,
     vibRate = 4, vibDepth = 0.025, brightness = 0.5|
    var env = EnvGen.kr(Env([0, 1, 0.8, 0.6, 0], [0.1, dur * 0.4, dur * 0.3, dur * 0.2], [2, -1, -2, -4]), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate + LFNoise1.kr(0.3).range(-0.3, 0.3)) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    var bowNoise = HPF.ar(PinkNoise.ar, 2000) * 0.08;
    sig = sig + bowNoise;
    sig = BPF.ar(sig, 280, 0.35) * 3 + BPF.ar(sig, 460, 0.3) * 2.5 + BPF.ar(sig, 2500, 0.2) * 1.5 + sig * 0.3;
    sig = LPF.ar(sig, freq * (3 + (brightness * 8)));
    sig = (sig * 1.4).tanh * 0.75;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

// ============================================================================
// LEGÉNYES (Men's Dance)
// ============================================================================
"[Legényes] Compiling dance synths...".postln;

SynthDef(\legenyViolin, {
    |out = 0, freq = 440, amp = 0.32, dur = 0.2, pan = 0|
    var env = EnvGen.kr(Env.perc(0.008, dur, 1, -6), doneAction: 2);
    var sig = LFSaw.ar(freq);
    sig = BPF.ar(sig, 500, 0.4) * 2 + sig * 0.5;
    sig = LPF.ar(sig, freq * 4);
    sig = (sig * 1.5).tanh * 0.6;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\legenyGardon, {
    |out = 0, freq = 80, amp = 0.4, dur = 0.15|
    var env, bodyHit, string, sig;
    env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    bodyHit = LPF.ar(WhiteNoise.ar, 400) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.5;
    string = SinOsc.ar(freq) * 0.6 + Saw.ar(freq) * 0.2;
    string = LPF.ar(string, 300);
    sig = bodyHit + string;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// TÁNCHÁZ (Dance House)
// ============================================================================
"[Táncház] Compiling ensemble synths...".postln;

SynthDef(\tzViolin, {
    |out = 0, freq = 440, amp = 0.28, dur = 0.4, pan = 0, vibRate = 5, vibDepth = 0.01|
    var env = EnvGen.kr(Env.perc(0.015, dur, 1, -4), doneAction: 2);
    var vibrato = SinOsc.kr(vibRate) * freq * vibDepth;
    var sig = LFSaw.ar(freq + vibrato);
    sig = BPF.ar(sig, 280, 0.3) * 2.5 + BPF.ar(sig, 460, 0.25) * 2 + sig * 0.35;
    sig = LPF.ar(sig, freq * 5);
    sig = (sig * 1.3).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\tzBracsa, {
    |out = 0, freq = 220, amp = 0.22, dur = 0.07, pan = 0.2|
    var env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    var freqs = [freq, freq * 1.5, freq * 2];
    var sig = Mix(freqs.collect { |f| LFSaw.ar(f) * 0.33 });
    sig = HPF.ar(sig, 200);
    sig = LPF.ar(sig, 2200);
    sig = (sig * 2).tanh * 0.5;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\tzGardon, {
    |out = 0, freq = 90, amp = 0.35, dur = 0.12|
    var env, bodyHit, string, sig;
    env = EnvGen.kr(Env.perc(0.002, dur, 1, -8), doneAction: 2);
    bodyHit = LPF.ar(WhiteNoise.ar, 350) * EnvGen.kr(Env.perc(0.001, 0.025)) * 0.4;
    string = SinOsc.ar(freq) * 0.5 + Saw.ar(freq) * 0.15;
    string = LPF.ar(string, 280);
    sig = bodyHit + string;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

SynthDef(\tzBass, {
    |out = 0, freq = 55, amp = 0.3, dur = 0.4|
    var env = EnvGen.kr(Env.perc(0.02, dur, 1, -4), doneAction: 2);
    var sig = SinOsc.ar(freq) * 0.6 + LFTri.ar(freq) * 0.3 + SinOsc.ar(freq * 2) * 0.1;
    sig = LPF.ar(sig, 350);
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// SZÉKI (Transylvanian)
// ============================================================================
"[Széki] Compiling Transylvanian synths...".postln;

SynthDef(\szekViolin, {
    |out = 0, freq = 440, amp = 0.3, dur = 0.35, pan = 0|
    var env = EnvGen.kr(Env.perc(0.01, dur, 1, -5), doneAction: 2);
    var sig = LFSaw.ar(freq);
    var bowNoise = HPF.ar(PinkNoise.ar, 1800) * 0.12;
    sig = sig + bowNoise;
    sig = BPF.ar(sig, 350, 0.35) * 2.5 + BPF.ar(sig, 550, 0.3) * 2 + sig * 0.4;
    sig = LPF.ar(sig, freq * 4.5);
    sig = (sig * 1.4).tanh * 0.65;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\szekGardon, {
    |out = 0, freq = 85, amp = 0.38, dur = 0.1|
    var env, stick, body, string, sig;
    env = EnvGen.kr(Env.perc(0.001, dur, 1, -8), doneAction: 2);
    stick = HPF.ar(WhiteNoise.ar, 800) * EnvGen.kr(Env.perc(0.0005, 0.02)) * 0.5;
    body = LPF.ar(WhiteNoise.ar, 300) * EnvGen.kr(Env.perc(0.001, 0.04)) * 0.3;
    string = SinOsc.ar(freq) * 0.4;
    string = LPF.ar(string, 250);
    sig = stick + body + string;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// CSÁNGÓ (Archaic Style)
// ============================================================================
"[Csángó] Compiling archaic synths...".postln;

SynthDef(\csangoTilinko, {
    |out = 0, freq = 440, amp = 0.26, dur = 0.8, pan = 0, breath = 0.45|
    var env = EnvGen.kr(Env.perc(0.04, dur * 0.96, 1, -4), doneAction: 2);
    var breathNoise = LPF.ar(WhiteNoise.ar * breath, 6000) * 0.4;
    var instability = LFNoise1.kr(3).range(-0.006, 0.006);
    var fundamental = SinOsc.ar(freq * (1 + instability));
    var overtones = SinOsc.ar(freq * 2, 0, 0.35) + SinOsc.ar(freq * 3, 0, 0.2);
    var sig = fundamental * 0.6 + overtones * 0.4;
    sig = BPF.ar(sig, 1400, 0.25) * 1.8 + sig * 0.5;
    sig = sig + breathNoise;
    sig = LPF.ar(sig, freq * 5);
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\csangoVoice, {
    |out = 0, freq = 300, amp = 0.25, dur = 0.6, pan = 0, nasality = 0.7|
    var env = EnvGen.kr(Env([0, 1, 0.8, 0], [0.05, dur * 0.7, dur * 0.25], [2, -2, -4]), doneAction: 2);
    var vibrato = SinOsc.kr(5.5) * freq * 0.018;
    var sig = Pulse.ar(freq + vibrato, 0.3) * 0.5 + Saw.ar(freq + vibrato) * 0.3;
    sig = BPF.ar(sig, 800, 0.25) * 2 * nasality + BPF.ar(sig, 2500, 0.2) * 1.5 + sig * 0.3;
    sig = LPF.ar(sig, 4000);
    sig = (sig * 1.3).tanh * 0.7;
    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).writeDefFile(outputDir);

SynthDef(\csangoGardon, {
    |out = 0, freq = 75, amp = 0.35, dur = 0.12|
    var env, hit, drone, sig;
    env = EnvGen.kr(Env.perc(0.002, dur, 1, -7), doneAction: 2);
    hit = LPF.ar(WhiteNoise.ar, 350) * EnvGen.kr(Env.perc(0.001, 0.03)) * 0.45;
    drone = SinOsc.ar(freq) * 0.5 + Saw.ar(freq) * 0.15;
    drone = LPF.ar(drone, 280);
    sig = hit + drone;
    Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).writeDefFile(outputDir);

// ============================================================================
// Done
// ============================================================================
"".postln;
"=== SynthDef compilation complete! ===".postln;
"Output directory: %".format(outputDir).postln;
"".postln;
"Compiled SynthDefs:".postln;
"  [Verbunkos] cimbalom, cimbalomTremolo, verbViolin, verbViolinSlide, bracsa, bracsaAccent".postln;
"  [Shepherd]  shepFurulya, shepTilinko, shepLongFlute".postln;
"  [Duda]      dudaDrone, dudaChanter, dudaChanterLong, dudaStomp, dudaHeel".postln;
"  [Csárdás]   csardViolin, csardBass".postln;
"  [Hallgató]  hallgatoViolin".postln;
"  [Legényes]  legenyViolin, legenyGardon".postln;
"  [Táncház]   tzViolin, tzBracsa, tzGardon, tzBass".postln;
"  [Széki]     szekViolin, szekGardon".postln;
"  [Csángó]    csangoTilinko, csangoVoice, csangoGardon".postln;
"".postln;
"Total: 28 SynthDefs".postln;
)
