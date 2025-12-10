// ============================================================
// SHEPARD WATER - Ambient Shepard tone with water textures
// ============================================================

// --------------------------------------------------
// SYNTH: Continuous Shepard with built-in reverb
// --------------------------------------------------
(
SynthDef(\shepardAmbient, {
    arg out = 0, amp = 0.3, speed = 0.02, baseFreq = 32.7,
        brightness = 5, detune = 0.006, filterHi = 5000,
        reverbMix = 0.6, reverbRoom = 0.85, reverbDamp = 0.3;
    var numOctaves = 10;
    var sig, phase, vibrato, reverb;

    phase = LFSaw.kr(speed, 1).range(0, 1);
    vibrato = SinOsc.kr(0.1).range(0.997, 1.003);

    sig = Mix.fill(numOctaves, { |i|
        var freqRatio, freq, gaussianWeight, voice;

        freqRatio = 2 ** (phase + i).mod(numOctaves);
        freq = baseFreq * freqRatio * vibrato;
        gaussianWeight = exp(-1 * ((phase + i).mod(numOctaves) - brightness).squared / 3.5);

        voice = Mix([
            SinOsc.ar(freq) * 0.5,
            SinOsc.ar(freq * (1 + detune)) * 0.25,
            SinOsc.ar(freq * (1 - detune)) * 0.25,
            SinOsc.ar(freq * (1 + (detune * 1.7))) * 0.12,
            SinOsc.ar(freq * (1 - (detune * 1.7))) * 0.12,
            LFTri.ar(freq) * 0.05
        ]);

        voice * gaussianWeight;
    });

    sig = LPF.ar(sig, LFNoise2.kr(0.06).range(1800, filterHi));
    sig = sig * amp / numOctaves;

    reverb = FreeVerb2.ar(sig, sig, reverbMix, reverbRoom, reverbDamp);
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
// PLAY: Full ambient mix
// --------------------------------------------------
(
~shepard = Synth(\shepardAmbient, [
    \speed, 0.012,       // Very slow rise (~83 sec cycle)
    \amp, 0.35,
    \brightness, 4.2,    // Warmer, less treble
    \detune, 0.009,      // Richer detuning
    \filterHi, 3200,     // Lower filter ceiling
    \reverbMix, 0.65,
    \reverbRoom, 0.88
]);

~stream = Synth(\waterStream, [
    \amp, 0.04,          // Quieter stream
    \reverbMix, 0.6
]);

~drops = Synth(\waterDrops, [
    \amp, 0.1,
    \density, 0.25,      // Very sparse drops (~1 every 4 sec)
    \reverbMix, 0.75
]);
)

// --------------------------------------------------
// VARIATIONS
// --------------------------------------------------

// Darker, slower
(
~shepard.set(\speed, 0.015, \brightness, 4, \filterHi, 3500);
~drops.set(\density, 1.5);
)

// Brighter, more active
(
~shepard.set(\speed, 0.03, \brightness, 5.5, \filterHi, 6000);
~drops.set(\density, 4);
)

// Descending (eerie)
(
~shepard.set(\speed, -0.02);
)

// --------------------------------------------------
// STOP
// --------------------------------------------------
// s.freeAll;
