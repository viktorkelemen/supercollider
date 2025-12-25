(
// ============================================================================
// TRITONE PARADOX
// ============================================================================
// An auditory illusion where two Shepard tones separated by a tritone
// (6 semitones / half octave) are perceived as either ascending or descending
// depending on the listener's internal pitch class reference.
//
// Usage:
//   ~tritone.play(startNote)  - Play tritone pair starting at given pitch class (0-11)
//   ~tritone.sequence(n)      - Play n random tritone pairs
//   ~tritone.demo             - Demonstrate all 12 pitch classes
// ============================================================================

// Shepard tone SynthDef - multiple octaves with Gaussian amplitude envelope
SynthDef(\shepardTone, {
	|out = 0, freq = 440, amp = 0.3, dur = 1, gate = 1|
	var sig, freqs, amps, env, centerFreq, sigma;

	// Center frequency for the Gaussian envelope (around middle of hearing range)
	centerFreq = 500;
	// Sigma controls the width of the bell curve (in octaves)
	sigma = 1.5;

	// Generate 6 octaves of the same pitch class
	freqs = Array.fill(6, { |i| freq * (2 ** (i - 2)) });

	// Gaussian amplitude envelope based on distance from center frequency
	amps = freqs.collect({ |f|
		var octaveDistance = (f.cpsoct - centerFreq.cpsoct);
		exp(octaveDistance.squared.neg / (2 * sigma.squared))
	});

	// Normalize amplitudes
	amps = amps / amps.sum;

	// Generate the tone
	sig = Mix.fill(6, { |i|
		SinOsc.ar(freqs[i]) * amps[i]
	});

	// Amplitude envelope
	env = EnvGen.kr(
		Env.linen(0.05, dur - 0.1, 0.05),
		doneAction: 2
	);

	Out.ar(out, Pan2.ar(sig * env * amp, 0));
}).add;

// Environment setup
~tritone = (
	// Play a single tritone pair
	// startNote: pitch class 0-11 (0=C, 1=C#, etc.)
	play: { |self, startNote = 0|
		var baseFreq, tritoneFreq, dur;
		dur = 2.0;

		// Convert pitch class to frequency (using C4 = 261.63 Hz as reference)
		baseFreq = (60 + startNote).midicps;
		// Tritone is exactly 6 semitones up
		tritoneFreq = (60 + startNote + 6).midicps;

		fork {
			"Playing tritone pair: % -> % (pitch classes % and %)".format(
				baseFreq.round(0.1),
				tritoneFreq.round(0.1),
				startNote,
				(startNote + 6) % 12
			).postln;

			Synth(\shepardTone, [\freq, baseFreq, \dur, dur, \amp, 0.3]);
			(dur + 0.1).wait;
			Synth(\shepardTone, [\freq, tritoneFreq, \dur, dur, \amp, 0.3]);
			(dur + 0.3).wait;

			"Did it sound ascending or descending?".postln;
		};
	},

	// Play a sequence of random tritone pairs
	sequence: { |self, count = 5, interval = 2|
		fork {
			count.do { |i|
				var startNote = 12.rand;
				"--- Pair % of % ---".format(i + 1, count).postln;
				self.play(startNote);
				interval.wait;
			};
			"Sequence complete.".postln;
		};
	},

	// Demonstrate all 12 pitch classes
	demo: { |self|
		var noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
		fork {
			"=== TRITONE PARADOX DEMONSTRATION ===".postln;
			"Playing all 12 pitch classes with their tritone pairs...".postln;
			"".postln;

			12.do { |i|
				var tritoneNote = (i + 6) % 12;
				"--- % -> % ---".format(noteNames[i], noteNames[tritoneNote]).postln;
				self.play(i);
				3.wait;
			};

			"".postln;
			"=== DEMONSTRATION COMPLETE ===".postln;
			"Notice how some pairs consistently sound ascending".postln;
			"while others sound descending to you.".postln;
			"This pattern is unique to each listener!".postln;
		};
	}
);

"Tritone Paradox loaded!".postln;
"".postln;
"Usage:".postln;
"  ~tritone.play(0)     // Play C -> F# tritone pair".postln;
"  ~tritone.play(3)     // Play D# -> A tritone pair".postln;
"  ~tritone.sequence(5) // Play 5 random pairs".postln;
"  ~tritone.demo        // Full 12-note demonstration".postln;
)
