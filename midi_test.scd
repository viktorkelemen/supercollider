s.options.device = "Studio Display Speakers 1";  // or "Studio Display Speakers"
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;          // or 0 if you don’t care about input
s.options.sampleRate = 48000;

s.reboot

(
~voices = ();

MIDIClient.init;
MIDIIn.connectAll;
)

(
MIDIdef.noteOff(\off, { |vel, num, chan|
    [\noteOff, chan, num, vel].postln;

});
)


(
MIDIdef.noteOn(\on, { |vel, num, chan|
	// ~voices[[chan, num]] = Synth(\midiSynth, [
	// 	\freq, num.midicps,
	// 	\amp,  vel / 127,
	// 	\gate, 1
// ]);
});
)

MIDIdef.noteOff(\off, { |vel, num, chan|
	// var key = [chan, num];
	// var synth = ~voices[key];
	// if (synth.notNil) {
	// 	synth.set(\gate, 0);    // envelope release
	// 	~voices.removeAt(key);
	// }
	});
)

(
SynthDef(\midiSynth, { |freq = 440, amp = 0.3, gate = 1|
    var env = Env.asr(0.01, 1, 0.3).kr(gate, doneAction: 2);
    var sig = Saw.ar(freq) * env * amp;
	// Out.ar(0, sig ! 2);
}).add;
)

s.freeAll;