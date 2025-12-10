// ============================================================
// SHEPARD AMBIENT - Rich, continuous Shepard tone for ambient music
// ============================================================

// --------------------------------------------------
// PAD SYNTH - Rich, detuned Shepard voice
// --------------------------------------------------
(
SynthDef(\shepardPad, {
    arg out = 0, note = 0, amp = 0.3, sustain = 4, attack = 1.5, release = 2,
        baseFreq = 32.7, brightness = 5, detune = 0.008, vibRate = 0.15, vibDepth = 0.003;
    var numOctaves = 10;
    var sig, pitchClass, env, vibrato;

    pitchClass = note.mod(12);

    // Gentle vibrato with random phase per voice
    vibrato = SinOsc.kr(vibRate, Rand(0, 2pi)).range(1 - vibDepth, 1 + vibDepth);

    // Generate all octave copies with richer sound
    sig = Mix.fill(numOctaves, { |i|
        var octaveFreq, gaussianWeight, voice;

        octaveFreq = baseFreq * (2 ** (pitchClass / 12)) * (2 ** i) * vibrato;
        gaussianWeight = exp(-1 * (i - brightness).squared / 3.5);

        // Rich voice: detuned sine cluster + subtle triangle for warmth
        voice = Mix([
            SinOsc.ar(octaveFreq) * 0.5,
            SinOsc.ar(octaveFreq * (1 + detune)) * 0.25,
            SinOsc.ar(octaveFreq * (1 - detune)) * 0.25,
            SinOsc.ar(octaveFreq * (1 + (detune * 2))) * 0.12,
            SinOsc.ar(octaveFreq * (1 - (detune * 2))) * 0.12,
            LFTri.ar(octaveFreq) * 0.08
        ]);

        voice * gaussianWeight;
    });

    // Soft pad envelope
    env = EnvGen.kr(
        Env([0, 1, 0.7, 0], [attack, sustain, release], [\sin, \lin, \sin]),
        doneAction: 2
    );

    // Gentle low-pass filter movement for subtle animation
    sig = LPF.ar(sig, LFNoise2.kr(0.1).range(2000, 8000));

    sig = sig * env * amp / numOctaves;
    Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// CONTINUOUS DRONE - Infinite rising Shepard pad
// --------------------------------------------------
(
SynthDef(\shepardDrone, {
    arg out = 0, amp = 0.3, speed = 0.03, baseFreq = 32.7,
        brightness = 5, detune = 0.006, filterLo = 1500, filterHi = 6000;
    var numOctaves = 10;
    var sig, phase, vibrato;

    // Shared phase ramp - very slow for ambient
    phase = LFSaw.kr(speed, 1).range(0, 1);

    // Subtle vibrato
    vibrato = SinOsc.kr(0.12).range(0.998, 1.002);

    sig = Mix.fill(numOctaves, { |i|
        var freqRatio, freq, gaussianWeight, voice;

        freqRatio = 2 ** (phase + i).mod(numOctaves);
        freq = baseFreq * freqRatio * vibrato;

        // Gaussian envelope centered at brightness
        gaussianWeight = exp(-1 * ((phase + i).mod(numOctaves) - brightness).squared / 3.5);

        // Rich detuned voice
        voice = Mix([
            SinOsc.ar(freq) * 0.5,
            SinOsc.ar(freq * (1 + detune)) * 0.25,
            SinOsc.ar(freq * (1 - detune)) * 0.25,
            SinOsc.ar(freq * (1 + (detune * 1.7))) * 0.15,
            SinOsc.ar(freq * (1 - (detune * 1.7))) * 0.15,
            LFTri.ar(freq) * 0.06
        ]);

        voice * gaussianWeight;
    });

    // Animated filter
    sig = LPF.ar(sig, LFNoise2.kr(0.08).range(filterLo, filterHi));

    sig = sig * amp / numOctaves;
    Out.ar(out, sig ! 2);
}).add;
)

// --------------------------------------------------
// PLAY: Continuous infinite rise
// --------------------------------------------------
// Very slow - one full cycle takes ~33 seconds
x = Synth(\shepardDrone, [\speed, 0.03, \amp, 0.35]);

// Faster variation
// x = Synth(\shepardDrone, [\speed, 0.06, \amp, 0.35]);

// Descending version
// x = Synth(\shepardDrone, [\speed, -0.03, \amp, 0.35]);

// Darker, slower
// x = Synth(\shepardDrone, [\speed, 0.02, \amp, 0.35, \brightness, 4, \filterHi, 4000]);

// x.free;  // Stop drone

// --------------------------------------------------
// PLAY: Slow melodic sequence (major scale feel)
// --------------------------------------------------
(
Routine({
    var notes = [0, 2, 4, 5, 7, 9, 11];  // Major scale
    var interval = 3;  // Seconds between notes

    inf.do { |i|
        var note = notes[i.mod(notes.size)] + (i.div(notes.size) * 12);
        Synth(\shepardPad, [
            \note, note,
            \amp, 0.22,
            \sustain, interval * 2.5,
            \attack, interval * 0.6,
            \release, interval * 0.8,
            \brightness, 5 + (0.3 * sin(i * 0.3))  // Subtle brightness drift
        ]);
        interval.wait;
    };
}).play;
)

// --------------------------------------------------
// PLAY: Slow chromatic rise (classic Shepard)
// --------------------------------------------------
(
Routine({
    var interval = 2.5;

    inf.do { |i|
        Synth(\shepardPad, [
            \note, i.mod(12),
            \amp, 0.22,
            \sustain, interval * 2.2,
            \attack, interval * 0.5,
            \release, interval * 0.7
        ]);
        interval.wait;
    };
}).play;
)

// --------------------------------------------------
// PLAY: Two-voice canon (haunting)
// --------------------------------------------------
(
Routine({
    var interval = 3.5;

    inf.do { |i|
        var note = i.mod(12);

        // Voice 1 - lower brightness
        Synth(\shepardPad, [
            \note, note,
            \amp, 0.18,
            \sustain, interval * 2,
            \attack, interval * 0.5,
            \release, interval * 0.6,
            \brightness, 4.2
        ]);

        // Voice 2 - perfect fifth above, brighter
        Synth(\shepardPad, [
            \note, note + 7,
            \amp, 0.15,
            \sustain, interval * 2,
            \attack, interval * 0.6,
            \release, interval * 0.7,
            \brightness, 5.8
        ]);

        interval.wait;
    };
}).play;
)

// --------------------------------------------------
// STOP ALL
// --------------------------------------------------
// s.freeAll;
