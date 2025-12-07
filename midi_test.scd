s.options.device = "Studio Display Speakers 1";  // or "Studio Display Speakers"
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;          // or 0 if you don’t care about input
s.options.sampleRate = 48000;

s.reboot

// ─────────────────────────────────────────────────
// MIDI Init
// ─────────────────────────────────────────────────
(
~voices = ();
~bend = 0;
MIDIClient.init;
MIDIIn.connectAll;
)

// ─────────────────────────────────────────────────
// SynthDef
// ─────────────────────────────────────────────────
(
SynthDef(\midiSynth, { |out = 0, freq = 440, amp = 0.3, gate = 1, bend = 0, pan = 0|
    var env = Env.adsr(0.01, 0.1, 0.7, 0.3).kr(doneAction: 2, gate: gate);
    var finalFreq = freq * (2 ** (bend / 12));
    // Detuned stereo: two saws slightly apart for width
    var sig = Saw.ar([finalFreq * 0.998, finalFreq * 1.002]).sum * 0.5;
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// ─────────────────────────────────────────────────
// MIDI Handlers
// ─────────────────────────────────────────────────
(
// Helper: release a voice by key
~releaseVoice = { |key|
    ~voices[key] !? { |synth|
        synth.set(\gate, 0);
        ~voices[key] = nil;
    };
};

MIDIdef.noteOn(\on, { |vel, num, chan|
    var key = (chan << 8) | num;  // Bitwise key: fast unique integer

    // Handle velocity 0 as noteOff (some controllers do this)
    if (vel == 0) {
        ~releaseVoice.(key);
    } {
        // Release if retriggered (prevents stuck notes)
        ~voices[key] !? { |synth| synth.set(\gate, 0) };

        ~voices[key] = Synth(\midiSynth, [
            \freq, num.midicps,
            \amp, (vel / 127).pow(0.5),  // Velocity curve for natural feel
            \bend, ~bend,
            \gate, 1
        ]);
    };
});

MIDIdef.noteOff(\off, { |vel, num, chan|
    var key = (chan << 8) | num;
    ~releaseVoice.(key);
});

MIDIdef.bend(\bend, { |val, chan|
    // val: 0-16383, center=8192, ±2 semitones
    ~bend = (val - 8192) / 8192 * 2;
    ~voices.do { |synth| synth.set(\bend, ~bend) };
});
)

// ─────────────────────────────────────────────────
// Utilities (evaluate as needed)
// ─────────────────────────────────────────────────
// s.freeAll;           // stop all synths
// MIDIdef.freeAll;     // remove all MIDI handlers
// MIDIdef.all;         // inspect registered handlers
// MIDIFunc.trace(true);  // debug: show all MIDI input
// ~voices.size;        // count active voices