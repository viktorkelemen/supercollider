// ============================================================
// MIDORI TAKADA - RITUAL EXTENDED (3 minutes)
// Following COMPOSITION.md energy arc principles
// ============================================================
// Voice Roles:
//   Foundation: Gong (low, slow)
//   Pulse: Marimba pattern (repetitive, steady)
//   Movement: High marimba fills (1 octave up, syncopation)
//   Sparkle: Very high fills (2 octaves up, peak only)
//   Color: Wood blocks (texture)
//
// Energy Arc:
//   0:00-0:20  Intro - sparse marimba, dark timbre
//   0:20-0:50  Development - add layers, timbre rising
//   0:50-2:00  Peak - maximum density, brightest (extended)
//   2:00-2:30  Breakdown - strip back, timbre falling
//   2:30-3:00  Resolution - sparse, dark, resolve

(
// ---- SynthDefs ----

SynthDef(\marimbaVar, {
	arg out = 0, amp = 0.2, freq = 440, decay = 1.5, pan = 0, timbre = 0.5;
	var sig, env, click, brightness;
	env = EnvGen.kr(Env.perc(0.005, decay, 1, -5), doneAction: 2);
	brightness = timbre.linexp(0, 1, 2, 12);
	sig = SinOsc.ar(freq) * 0.5;
	sig = sig + (SinOsc.ar(freq * 4) * timbre * 0.3 * EnvGen.kr(Env.perc(0.001, 0.05)));
	sig = sig + (SinOsc.ar(freq * 10) * timbre * 0.1 * EnvGen.kr(Env.perc(0.001, 0.02)));
	sig = sig + (SinOsc.ar(freq * 2) * (1 - timbre) * 0.2);
	click = BPF.ar(PinkNoise.ar, freq * brightness, 0.2) * EnvGen.kr(Env.perc(0.001, 0.02));
	sig = sig + (click * 0.15 * timbre);
	sig = LPF.ar(sig, freq * brightness);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

SynthDef(\gong, {
	arg out = 0, amp = 0.25, freq = 80, decay = 8;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.1, decay, 1, -3), doneAction: 2);
	sig = Mix([
		SinOsc.ar(freq) * 0.4,
		SinOsc.ar(freq * 1.47) * 0.25,
		SinOsc.ar(freq * 2.09) * 0.18,
		SinOsc.ar(freq * 2.56) * 0.12,
		SinOsc.ar(freq * 3.24) * 0.08
	]);
	sig = sig * (1 + (SinOsc.kr(0.5) * 0.05));
	sig = LPF.ar(sig, 2000);
	sig = sig * env * amp;
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\woodBlock, {
	arg out = 0, amp = 0.15, freq = 800, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, 0.03) * 0.5;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 1.6, 0.02) * 0.3);
	sig = HPF.ar(sig, 300);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;

// ---- Composition Parameters ----

~totalDuration = 180;  // 3 minutes
~phraseLen = 1.2;
~stepDur = 0.15;
~pattern = [220, 220, 262, 220, 294, 262, 330, 294];
~accents = [1, 0, 0, 1, 0, 0, 1, 0];

// Energy arc timings (in seconds)
~introEnd = 20;
~developEnd = 50;
~peakEnd = 120;  // Extended peak: 50-120 (70 seconds!)
~breakdownEnd = 150;
// Resolution: 150-180

// Continuous timbre function following energy arc
// Returns 0.0-1.0 based on position in arc
~getTimbre = { |time|
	var progress;
	case
		{ time < ~introEnd } {
			// Intro: dark, slowly warming (0.1 -> 0.2)
			0.1 + ((time / ~introEnd) * 0.1)
		}
		{ time < ~developEnd } {
			// Development: rising quickly (0.2 -> 0.85)
			progress = (time - ~introEnd) / (~developEnd - ~introEnd);
			0.2 + (progress * 0.65)
		}
		{ time < ~peakEnd } {
			// Peak: very bright with waves (0.85 -> 1.0), sustained high
			progress = (time - ~developEnd) / (~peakEnd - ~developEnd);
			0.85 + ((progress * 2 * pi).sin * 0.15)
		}
		{ time < ~breakdownEnd } {
			// Breakdown: falling (1.0 -> 0.3)
			progress = (time - ~peakEnd) / (~breakdownEnd - ~peakEnd);
			0.9 - (progress * 0.6)
		}
		{
			// Resolution: dark, fading (0.3 -> 0.1)
			progress = (time - ~breakdownEnd) / (~totalDuration - ~breakdownEnd);
			0.3 - (progress * 0.2)
		}
};

// Density function - controls how many notes play
// Returns probability 0.0-1.0
~getDensity = { |time|
	var progress;
	case
		{ time < ~introEnd } { 0.4 }           // Sparse intro
		{ time < ~developEnd } {               // Building quickly
			progress = (time - ~introEnd) / (~developEnd - ~introEnd);
			0.4 + (progress * 0.55)
		}
		{ time < ~peakEnd } { 1.0 }            // Maximum density at peak
		{ time < ~breakdownEnd } {             // Stripping back
			progress = (time - ~peakEnd) / (~breakdownEnd - ~peakEnd);
			0.95 - (progress * 0.55)
		}
		{ 0.35 }                               // Sparse resolution
};

// ---- Schedule the piece ----

// Opening gong (Foundation enters first)
s.sendBundle(0, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.2, \decay, 10]);

// Calculate number of phrases
~numPhrases = (~totalDuration / ~phraseLen).floor.asInteger;

// Schedule all phrases
~numPhrases.do { |phraseNum|
	var phraseStart, timbre, density, highFreq;
	phraseStart = phraseNum * ~phraseLen;
	timbre = ~getTimbre.value(phraseStart);
	density = ~getDensity.value(phraseStart);

	// Gong scheduling (Foundation)
	// Intro: every 15 sec, Development: every 12 sec, Peak: every 8 sec, then sparse
	if (phraseStart < ~introEnd) {
		if ((phraseNum % 12 == 0) and: (phraseNum > 0)) {
			s.sendBundle(phraseStart, [\s_new, \gong, -1, 0, 0,
				\freq, 55, \amp, 0.12, \decay, 8]);
		};
	};
	if ((phraseStart >= ~introEnd) and: (phraseStart < ~developEnd)) {
		if (phraseNum % 10 == 0) {
			s.sendBundle(phraseStart, [\s_new, \gong, -1, 0, 0,
				\freq, 55, \amp, 0.15, \decay, 7]);
		};
	};
	if ((phraseStart >= ~developEnd) and: (phraseStart < ~peakEnd)) {
		if (phraseNum % 7 == 0) {
			s.sendBundle(phraseStart, [\s_new, \gong, -1, 0, 0,
				\freq, 55, \amp, 0.18, \decay, 6]);
		};
	};
	if ((phraseStart >= ~peakEnd) and: (phraseStart < ~breakdownEnd)) {
		if (phraseNum % 15 == 0) {
			s.sendBundle(phraseStart, [\s_new, \gong, -1, 0, 0,
				\freq, 55, \amp, 0.12, \decay, 8]);
		};
	};

	// Marimba pattern (Pulse) - always present but density varies
	8.do { |step|
		var time = phraseStart + (step * ~stepDur);
		var freq = ~pattern[step];
		var isAccent = ~accents[step] == 1;
		var stepTimbre = timbre + (step * 0.01);  // Micro variation
		var amp, decay, pan;

		// Apply density - skip some notes in sparse sections
		if ((isAccent) or: (density.coin)) {
			amp = if(isAccent, 0.18, 0.1) * (0.8 + (density * 0.2));
			decay = if(isAccent, 1.0, 0.5);
			pan = [-0.1, 0.1].wrapAt(step);

			s.sendBundle(time, [\s_new, \marimbaVar, -1, 0, 0,
				\freq, freq,
				\amp, amp,
				\decay, decay,
				\pan, pan,
				\timbre, stepTimbre.clip(0.1, 1.0)
			]);
		};
	};

	// Wood blocks (Color) - only during development and peak
	if ((phraseStart >= ~introEnd) and: (phraseStart < ~breakdownEnd)) {
		if ((phraseNum % 2 == 0) and: (density > 0.6) and: density.coin) {
			s.sendBundle(phraseStart, [\s_new, \woodBlock, -1, 0, 0,
				\freq, 700 + (timbre * 400),
				\amp, 0.05 * density
			]);
		};
		if ((phraseNum % 3 == 0) and: (density > 0.7) and: density.coin) {
			s.sendBundle(phraseStart + (3 * ~stepDur), [\s_new, \woodBlock, -1, 0, 0,
				\freq, 750 + (timbre * 400),
				\amp, 0.04 * density,
				\pan, 0.3
			]);
		};
	};

	// Movement layer - high marimba fills during development/peak
	if ((phraseStart >= 35) and: (phraseStart < ~peakEnd)) {
		// High fills (1 octave up) - every phrase during peak
		if (density.coin) {
			highFreq = ~pattern.choose * 2;
			s.sendBundle(phraseStart + (5 * ~stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, highFreq, \amp, 0.08 * density,
				\decay, 0.4, \pan, 0.4, \timbre, timbre * 0.85
			]);
		};
		// Additional fill on even phrases
		if ((phraseNum % 2 == 0) and: density.coin) {
			highFreq = ~pattern.choose * 2;
			s.sendBundle(phraseStart + (2 * ~stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, highFreq, \amp, 0.07 * density,
				\decay, 0.35, \pan, -0.3, \timbre, timbre * 0.9
			]);
		};
	};

	// Sparkle layer (2 octaves up) - only during peak
	if ((phraseStart >= ~developEnd) and: (phraseStart < ~peakEnd)) {
		if ((phraseNum % 2 == 1) and: density.coin) {
			s.sendBundle(phraseStart + (4 * ~stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, ~pattern.choose * 4, \amp, 0.04,
				\decay, 0.25, \pan, 0.6, \timbre, 0.95
			]);
		};
		if ((phraseNum % 3 == 0) and: density.coin) {
			s.sendBundle(phraseStart + (7 * ~stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, ~pattern.choose * 4, \amp, 0.035,
				\decay, 0.2, \pan, -0.5, \timbre, 1.0
			]);
		};
	};
};

// Final gong with long decay (Resolution)
s.sendBundle(~totalDuration - 5, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.2, \decay, 15]);

"RITUAL EXTENDED - 3 minute energy arc".postln;
"  0:00-0:20  Intro (dark, sparse)".postln;
"  0:20-0:50  Development (building, brightening)".postln;
"  0:50-2:00  Peak (maximum density, brightest) <<<".postln;
"  2:00-2:30  Breakdown (stripping back)".postln;
"  2:30-3:00  Resolution (sparse, dark)".postln;
)
