// ============================================================
// PERCEPTUAL FLIP - Extended 3-minute composition
// ============================================================
// Based on Mark Fell's multistability concept
// Structure follows composition.md energy arc principles
//
// Voice Roles:
// - Foundation: 55Hz bass (5-step pattern)
// - Pulse: 900Hz clicks left, 1400Hz clicks right (12-step patterns)
// - Movement: 7-step tonal pattern (440/550/660Hz)
// - Focus: The perceptual ambiguity itself
//
// USAGE: Select everything and evaluate (Cmd+Return), or load the file

(
// --------------------------------------------------
// SYNTHDEFS
// --------------------------------------------------
SynthDef(\fellClick, {
	arg out = 0, amp = 0.2, freq = 1000, decay = 0.015, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, decay, 1, -8), doneAction: 2);
	sig = SinOsc.ar(freq) * 0.7;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 2, decay) * 0.3);
	sig = HPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\fellTone, {
	arg out = 0, amp = 0.15, freq = 440, dur = 0.1, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);
	sig = SinOsc.ar(freq);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\fellBass, {
	arg out = 0, amp = 0.35, freq = 55, dur = 0.2;
	var sig, env, click;
	env = EnvGen.kr(Env.perc(0.005, dur, 1, -4), doneAction: 2);
	sig = SinOsc.ar(freq);
	click = HPF.ar(WhiteNoise.ar, 2000) * EnvGen.kr(Env.perc(0.001, 0.01));
	sig = sig + (click * 0.15);
	sig = LPF.ar(sig, 200);
	sig = sig * env * amp;
	Out.ar(out, [sig, sig]);
}).add;

"SynthDefs loaded".postln;

// --------------------------------------------------
// COMPOSITION - Schedule after short delay for SynthDefs
// --------------------------------------------------
{
	var tempo = 0.12;
	var totalDur = 180; // 3 minutes

	// Section timings (in seconds)
	// Shorter intro (16s), longer peak, much shorter outro (12s)
	var introEnd = 16;
	var build1End = 40;
	var build2End = 75;
	var peakEnd = 148;
	var breakdownEnd = 168;
	var resolutionEnd = 180;

	// Patterns
	var pattern12a = [1, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1]; // 900Hz left
	var pattern12b = [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0]; // 1400Hz right
	var pattern7 = [1, 0, 1, 0, 1, 0, 1]; // tones
	var pattern5 = [1, 0, 0, 1, 0]; // bass

	// Tone frequencies cycle
	var toneFreqs = [440, 550, 660, 440, 550, 660, 440];

	// Pre-calculate peak envelope values
	var peakCenter = (build2End + peakEnd) / 2;
	var peakWidth = (peakEnd - build2End) / 2;

	// Helper: get section for a given time
	var getSection = { |t|
		var result;
		if (t < introEnd) {
			result = \intro;
		} {
			if (t < build1End) {
				result = \build1;
			} {
				if (t < build2End) {
					result = \build2;
				} {
					if (t < peakEnd) {
						result = \peak;
					} {
						if (t < breakdownEnd) {
							result = \breakdown;
						} {
							result = \resolution;
						};
					};
				};
			};
		};
		result
	};

	// Helper: amplitude envelope for fades
	var sectionAmp = { |t, baseAmp, voice|
		var section = getSection.value(t);
		var amp = baseAmp;
		var progress;

		// Intro: only bass
		if (section == \intro) {
			if (voice != \bass) { amp = 0 };
		};

		// Build1: bass + pattern A (900Hz)
		if (section == \build1) {
			if (voice == \patternB) { amp = 0 };
			if (voice == \tone) { amp = 0 };
			// Fade in pattern A
			if (voice == \patternA) {
				amp = amp * ((t - introEnd) / (build1End - introEnd)).clip(0, 1);
			};
		};

		// Build2: bass + pattern A + tones
		if (section == \build2) {
			if (voice == \patternB) { amp = 0 };
			// Fade in tones
			if (voice == \tone) {
				amp = amp * ((t - build1End) / 15).clip(0, 1); // 15 sec fade
			};
		};

		// Peak: all voices, slight swell
		if (section == \peak) {
			// Fade in pattern B
			if (voice == \patternB) {
				amp = amp * ((t - build2End) / 10).clip(0, 1);
			};
			// Slight overall swell at peak center
			amp = amp * (1 + (0.15 * (1 - (((t - peakCenter).abs / peakWidth).clip(0, 1)))));
		};

		// Breakdown: bass + sparse tones only
		if (section == \breakdown) {
			if (voice == \patternA) { amp = 0 };
			if (voice == \patternB) { amp = 0 };
			// Sparse tones (reduce density)
			if (voice == \tone) { amp = amp * 0.5 };
		};

		// Resolution: gradual return
		if (section == \resolution) {
			progress = (t - breakdownEnd) / (resolutionEnd - breakdownEnd);
			// Bring back pattern A
			if (voice == \patternA) {
				amp = amp * (progress * 0.7); // Don't go full
			};
			if (voice == \patternB) { amp = 0 }; // Keep out
			// Fade everything out at the end
			if (progress > 0.7) {
				amp = amp * ((1 - progress) / 0.3);
			};
		};

		amp
	};

	// Schedule all events
	var stepCount = (totalDur / tempo).asInteger;
	var t, step12, step7, ampA, ampB, ampTone, ampBass;
	var section, skip, freq, bassStep, bassFreqs;

	bassFreqs = [55, 55, 55, 73.4, 55];

	0.5.wait; // Wait for SynthDefs to compile

	"PERCEPTUAL FLIP - 3 minute composition".postln;
	"Scheduling % steps...".format(stepCount).postln;

	stepCount.do { |step|
		t = step * tempo;
		step12 = step % 12;
		step7 = step % 7;

		// Pattern A - 900Hz left (12-step)
		if (pattern12a[step12] == 1) {
			ampA = sectionAmp.value(t, 0.16, \patternA);
			if (ampA > 0.01) {
				s.sendBundle(t, [\s_new, \fellClick, -1, 0, 0,
					\freq, 900, \amp, ampA, \decay, 0.02, \pan, -0.3
				]);
			};
		};

		// Pattern B - 1400Hz right (12-step)
		if (pattern12b[step12] == 1) {
			ampB = sectionAmp.value(t, 0.12, \patternB);
			if (ampB > 0.01) {
				s.sendBundle(t, [\s_new, \fellClick, -1, 0, 0,
					\freq, 1400, \amp, ampB, \decay, 0.015, \pan, 0.3
				]);
			};
		};

		// 7-step tones (skip some in breakdown for sparseness)
		if (pattern7[step7] == 1) {
			section = getSection.value(t);
			skip = false;

			// In breakdown, only play every 3rd tone
			if (section == \breakdown) {
				skip = ((step / 7).asInteger % 3) != 0;
			};

			if (skip.not) {
				ampTone = sectionAmp.value(t, 0.1, \tone);
				freq = toneFreqs[step7];
				if (ampTone > 0.01) {
					s.sendBundle(t, [\s_new, \fellTone, -1, 0, 0,
						\freq, freq, \amp, ampTone, \dur, 0.06, \pan, 0
					]);
				};
			};
		};

		// 5-step bass (at half speed, so check every 2 steps)
		if ((step % 2) == 0) {
			bassStep = (step / 2).asInteger % 5;
			if (pattern5[bassStep] == 1) {
				ampBass = sectionAmp.value(t, 0.3, \bass);
				freq = bassFreqs[bassStep];
				if (ampBass > 0.01) {
					s.sendBundle(t, [\s_new, \fellBass, -1, 0, 0,
						\freq, freq, \amp, ampBass, \dur, 0.12
					]);
				};
			};
		};
	};

	"Scheduled! Playing for 3 minutes...".postln;
	"Sections: intro(0-16s) build1(16-40s) build2(40-75s) peak(75-148s) breakdown(148-168s) resolution(168-180s)".postln;
}.fork;
)

// --------------------------------------------------
// STOP
// --------------------------------------------------
// s.freeAll;
