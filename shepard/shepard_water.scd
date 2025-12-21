// ============================================================
// SHEPARD WATER - Ambient Shepard tone with water textures
// ============================================================

// --------------------------------------------------
// SYNTH: Rich Shepard chord with shimmer and stereo spread
// --------------------------------------------------
(
SynthDef(\shepardChordRich, {
    arg out = 0, amp = 0.3, speed = 0.012, baseFreq = 32.7,
        brightness = 4.5, detune = 0.008, filterHi = 4000,
        reverbMix = 0.6, reverbRoom = 0.85,
        note1 = 0, note2 = 3, note3 = 7;
    var numOctaves = 10;
    var sigL, sigR, phase, reverb;

    phase = LFSaw.kr(speed, 1).range(0, 1);

    // Left channel - slightly different detuning/drift
    sigL = Mix([note1, note2, note3].collect { |note|
        var pitchClass = note.mod(12);
        Mix.fill(numOctaves, { |i|
            var freqRatio, freq, gw, voice, shimmer;
            freqRatio = 2 ** (phase + i + (pitchClass / 12)).mod(numOctaves);
            freq = baseFreq * freqRatio * LFNoise2.kr(0.05).range(0.997, 1.003);
            gw = exp(-1 * ((phase + i + (pitchClass / 12)).mod(numOctaves) - brightness).squared / 3.5);
            shimmer = LFNoise2.kr(0.12).range(0.7, 1.0);
            voice = SinOsc.ar(freq) + (SinOsc.ar(freq * (1 + detune)) * 0.4) + (LFTri.ar(freq) * 0.15);
            voice * gw * shimmer * (1 - (i * 0.03));
        }) * 0.33;
    });

    // Right channel - different drift rates and waveforms
    sigR = Mix([note1, note2, note3].collect { |note|
        var pitchClass = note.mod(12);
        Mix.fill(numOctaves, { |i|
            var freqRatio, freq, gw, voice, shimmer;
            freqRatio = 2 ** (phase + i + (pitchClass / 12)).mod(numOctaves);
            freq = baseFreq * freqRatio * LFNoise2.kr(0.06).range(0.996, 1.004);
            gw = exp(-1 * ((phase + i + (pitchClass / 12)).mod(numOctaves) - brightness).squared / 3.5);
            shimmer = LFNoise2.kr(0.14).range(0.7, 1.0);
            voice = SinOsc.ar(freq * 1.002) + (SinOsc.ar(freq * (1 - detune)) * 0.4) + (LFPar.ar(freq) * 0.15);
            voice * gw * shimmer * (1 - (i * 0.03));
        }) * 0.33;
    });

    sigL = LPF.ar(sigL, LFNoise2.kr(0.04).range(1200, filterHi));
    sigR = LPF.ar(sigR, LFNoise2.kr(0.05).range(1200, filterHi));

    // Gentle saturation for warmth
    sigL = (sigL * 1.2).tanh * amp / numOctaves;
    sigR = (sigR * 1.2).tanh * amp / numOctaves;

    reverb = FreeVerb2.ar(sigL, sigR, reverbMix, reverbRoom, 0.25);
    Out.ar(out, reverb);
}).add;
)

// --------------------------------------------------
// SYNTH: Water drops (random resonant pings)
// --------------------------------------------------
(
SynthDef(\waterDrops, {
    arg out = 0, amp = 0.15, density = 3, reverbMix = 0.7;
    var trig, freq, sig, reverb;

    trig = Dust.kr(density);
    freq = TRand.kr(2000, 5000, trig);

    sig = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.001, TRand.kr(0.08, 0.25, trig)), trig);
    sig = sig + (SinOsc.ar(freq * 0.5) * EnvGen.ar(Env.perc(0.001, 0.15), trig) * 0.3);
    sig = RLPF.ar(sig, freq * 0.8, 0.1);

    sig = sig * amp;
    reverb = FreeVerb2.ar(sig, sig, reverbMix, 0.9, 0.2);
    Out.ar(out, reverb);
}).add;
)

// --------------------------------------------------
// SYNTH: Water stream (continuous filtered noise)
// --------------------------------------------------
(
SynthDef(\waterStream, {
    arg out = 0, amp = 0.08, reverbMix = 0.5;
    var sig, reverb;

    sig = Mix([
        // Babbling brook texture
        BPF.ar(PinkNoise.ar, LFNoise1.kr(0.5).range(400, 1200), 0.3) * 0.4,
        // Higher splashy texture
        BPF.ar(WhiteNoise.ar, LFNoise2.kr(0.8).range(2000, 5000), 0.2) * 0.2,
        // Resonant micro-drops
        Ringz.ar(Dust.ar(8), LFNoise0.kr(2).range(1500, 4000), 0.02) * 0.3
    ]);

    sig = sig * amp;
    reverb = FreeVerb2.ar(sig, sig, reverbMix, 0.8, 0.3);
    Out.ar(out, reverb);
}).add;
)

// --------------------------------------------------
// SYNTH: Ikeda ambient high pulses
// --------------------------------------------------
(
SynthDef(\ikedaAmbientPulse, {
    arg out = 0, amp = 0.1, density = 0.3, reverbMix = 0.7;
    var trig, freq, dur, pan, sig, reverb;

    trig = Dust.kr(density);
    freq = TRand.kr(3000, 12000, trig);
    dur = TRand.kr(0.01, 0.04, trig);
    pan = TRand.kr(-0.9, 0.9, trig);

    sig = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.001, dur, 1, -8), trig);
    sig = Pan2.ar(sig, pan) * amp;

    reverb = FreeVerb2.ar(sig[0], sig[1], reverbMix, 0.85, 0.25);
    Out.ar(out, reverb);
}).add;
)

// --------------------------------------------------
// SYNTH: Ikeda ambient sub pulses
// --------------------------------------------------
(
SynthDef(\ikedaAmbientSub, {
    arg out = 0, amp = 0.25, density = 0.15, reverbMix = 0.5;
    var trig, freq, dur, sig, reverb;

    trig = Dust.kr(density);
    freq = TRand.kr(25, 50, trig);
    dur = TRand.kr(0.15, 0.35, trig);

    sig = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.005, dur, 1, -4), trig);
    sig = sig * amp;

    reverb = FreeVerb2.ar(sig, sig, reverbMix, 0.7, 0.4);
    Out.ar(out, reverb);
}).add;
)

// --------------------------------------------------
// PLAY: Full ambient mix
// --------------------------------------------------
(
~shepard = Synth(\shepardChordRich, [
    \speed, 0.012,
    \amp, 0.4,
    \note1, 0,           // C
    \note2, 3,           // Eb (minor third)
    \note3, 7,           // G (fifth)
    \brightness, 3.8,    // Dark, warm
    \filterHi, 2200,     // Heavy low-pass
    \reverbMix, 0.6,
    \reverbRoom, 0.85
]);

~stream = Synth(\waterStream, [
    \amp, 0.04,
    \reverbMix, 0.6
]);

~drops = Synth(\waterDrops, [
    \amp, 0.1,
    \density, 0.25,      // Very sparse (~1 every 4 sec)
    \reverbMix, 0.75
]);

~ikedaHi = Synth(\ikedaAmbientPulse, [
    \amp, 0.08,
    \density, 0.4,
    \reverbMix, 0.75
]);

~ikedaSub = Synth(\ikedaAmbientSub, [
    \amp, 0.3,
    \density, 0.35,      // ~1 every 3 sec
    \reverbMix, 0.45
]);
)

// --------------------------------------------------
// CHORD VARIATIONS
// --------------------------------------------------

// Minor chord (default)
~shepard.set(\note1, 0, \note2, 3, \note3, 7);

// Major chord
~shepard.set(\note1, 0, \note2, 4, \note3, 7);

// Sus4
~shepard.set(\note1, 0, \note2, 5, \note3, 7);

// Diminished
~shepard.set(\note1, 0, \note2, 3, \note3, 6);

// --------------------------------------------------
// MOOD VARIATIONS
// --------------------------------------------------

// Darker, slower
(
~shepard.set(\speed, 0.008, \brightness, 3.5, \filterHi, 1800);
~drops.set(\density, 0.15);
~ikedaSub.set(\density, 0.2);
)

// Brighter, more active
(
~shepard.set(\speed, 0.02, \brightness, 5, \filterHi, 4000);
~drops.set(\density, 0.5);
~ikedaHi.set(\density, 0.8);
)

// Descending (eerie)
~shepard.set(\speed, -0.012);

// --------------------------------------------------
// STOP
// --------------------------------------------------
// s.freeAll;
