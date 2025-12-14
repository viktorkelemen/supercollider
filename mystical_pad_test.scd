// Mystical Plosives Recreation
// Based on analysis of mystical_plosives.wav
// Key: C# minor, dense layered pad

(
SynthDef(\mysticalPad, {
    arg out = 0, amp = 0.3, gate = 1,
        root = 138.59, // C#3
        cutoff = 3500, filterLFO = 0.08, filterDepth = 800;
    var sig, env, filt, voices;

    // Multiple voices in C#m voicing with detuning
    voices = [
        // Root layer (C#)
        Saw.ar(root * [1, 1.002, 0.998]),
        // Fifth (G#)
        Saw.ar(root * 1.498 * [1, 1.003, 0.997]),
        // Octave + third (E)
        Saw.ar(root * 2.378 * [1, 1.001, 0.999]) * 0.7,
        // High fifth (G#)
        Saw.ar(root * 2.996 * [1, 1.002]) * 0.5,
    ];

    sig = Mix(voices.flatten) * 0.08;

    // Slow filter movement
    filt = SinOsc.kr(filterLFO, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, filt, 0.4);

    // Stereo spread
    sig = Splay.ar(sig, spread: 0.7);

    // Envelope
    env = EnvGen.kr(Env.asr(2, 1, 3), gate, doneAction: 2);

    // Reverb
    sig = sig + FreeVerb2.ar(sig[0], sig[1], mix: 0.5, room: 0.85, damp: 0.4);

    Out.ar(out, sig * env * amp);
}).add;
)

// Play it (evaluate this line)
x = Synth(\mysticalPad);

// Stop it
// x.set(\gate, 0);

// Or try different roots:
// x = Synth(\mysticalPad, [\root, 103.83]); // G#2 - lower
// x = Synth(\mysticalPad, [\root, 164.81]); // E3
// x = Synth(\mysticalPad, [\root, 207.65]); // G#3
