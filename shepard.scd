// Shepard Tone - Auditory illusion of endlessly rising pitch
// Uses 10 stacked octaves with Gaussian amplitude envelope

(
SynthDef(\shepard, {
    arg out = 0, baseFreq = 55, speed = 0.1, amp = 0.3;
    var numTones = 10;
    var sig, phase;

    // Shared phase ramp from 0 to 1, cycling continuously
    phase = LFSaw.kr(speed, 1).range(0, 1);

    // Generate 10 overlapping octaves
    sig = Mix.fill(numTones, { |i|
        var freqRatio, freq, envelope;

        // Each tone is offset by 1/numTones in phase space
        freqRatio = 2 ** (phase + i).mod(numTones);
        freq = baseFreq * freqRatio;

        // Gaussian-like amplitude envelope centered around middle octaves
        // Peak at octave 5 (of 0-9), fades at extremes
        envelope = exp(-1 * ((phase + i).mod(numTones) - 5).squared / 4);

        SinOsc.ar(freq) * envelope;
    });

    sig = sig * amp / numTones;
    Out.ar(out, sig ! 2);
}).add;
)

// Play examples:
// Synth(\shepard);                                    // Default: rising tone
// Synth(\shepard, [\speed, -0.1]);                   // Descending
// Synth(\shepard, [\speed, 0.05, \baseFreq, 110]);   // Slower, higher base
// s.freeAll;                                          // Stop all
