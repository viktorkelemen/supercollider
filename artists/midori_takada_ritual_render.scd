// ============================================================
// MIDORI TAKADA - RITUAL EXTENDED - NRT RENDER VERSION
// Renders to WAV file (faster than realtime)
// ============================================================

(
var score, synthDefs, pattern, accents, phraseLen, stepDur;
var totalDuration, introEnd, developEnd, peakEnd, breakdownEnd;
var numPhrases, getTimbre, getDensity;

// Output file path - change this to your desired location
~outputPath = "~/Music/midori_takada_ritual.wav".standardizePath;

// ---- Parameters ----
totalDuration = 180;
phraseLen = 1.2;
stepDur = 0.15;
pattern = [220, 220, 262, 220, 294, 262, 330, 294];
accents = [1, 0, 0, 1, 0, 0, 1, 0];

introEnd = 20;
developEnd = 50;
peakEnd = 120;
breakdownEnd = 150;

// ---- Timbre/Density functions ----
getTimbre = { |time|
	var progress;
	case
		{ time < introEnd } { 0.1 + ((time / introEnd) * 0.1) }
		{ time < developEnd } {
			progress = (time - introEnd) / (developEnd - introEnd);
			0.2 + (progress * 0.65)
		}
		{ time < peakEnd } {
			progress = (time - developEnd) / (peakEnd - developEnd);
			0.85 + ((progress * 2 * pi).sin * 0.15)
		}
		{ time < breakdownEnd } {
			progress = (time - peakEnd) / (breakdownEnd - peakEnd);
			0.9 - (progress * 0.6)
		}
		{
			progress = (time - breakdownEnd) / (totalDuration - breakdownEnd);
			0.3 - (progress * 0.2)
		}
};

getDensity = { |time|
	var progress;
	case
		{ time < introEnd } { 0.4 }
		{ time < developEnd } {
			progress = (time - introEnd) / (developEnd - introEnd);
			0.4 + (progress * 0.55)
		}
		{ time < peakEnd } { 1.0 }
		{ time < breakdownEnd } {
			progress = (time - peakEnd) / (breakdownEnd - peakEnd);
			0.95 - (progress * 0.55)
		}
		{ 0.35 }
};

// ---- Build Score ----
score = List[];

// SynthDef loading at time 0
score.add([0, [\d_recv, SynthDef(\marimbaVar, {
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
}).asBytes]]);

score.add([0, [\d_recv, SynthDef(\gong, {
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
}).asBytes]]);

score.add([0, [\d_recv, SynthDef(\woodBlock, {
	arg out = 0, amp = 0.15, freq = 800, pan = 0;
	var sig, env;
	env = EnvGen.kr(Env.perc(0.001, 0.08, 1, -8), doneAction: 2);
	sig = Ringz.ar(Impulse.ar(0), freq, 0.03) * 0.5;
	sig = sig + (Ringz.ar(Impulse.ar(0), freq * 1.6, 0.02) * 0.3);
	sig = HPF.ar(sig, 300);
	sig = sig * env * amp;
	Out.ar(out, Pan2.ar(sig, pan));
}).asBytes]]);

// Opening gong
score.add([0.1, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.2, \decay, 10]]);

// Calculate phrases
numPhrases = (totalDuration / phraseLen).floor.asInteger;

// Schedule all phrases
numPhrases.do { |phraseNum|
	var phraseStart, timbre, density, highFreq;
	phraseStart = phraseNum * phraseLen;
	timbre = getTimbre.value(phraseStart);
	density = getDensity.value(phraseStart);

	// Gong scheduling
	if (phraseStart < introEnd) {
		if ((phraseNum % 12 == 0) and: (phraseNum > 0)) {
			score.add([phraseStart, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.12, \decay, 8]]);
		};
	};
	if ((phraseStart >= introEnd) and: (phraseStart < developEnd)) {
		if (phraseNum % 10 == 0) {
			score.add([phraseStart, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.15, \decay, 7]]);
		};
	};
	if ((phraseStart >= developEnd) and: (phraseStart < peakEnd)) {
		if (phraseNum % 7 == 0) {
			score.add([phraseStart, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.18, \decay, 6]]);
		};
	};
	if ((phraseStart >= peakEnd) and: (phraseStart < breakdownEnd)) {
		if (phraseNum % 15 == 0) {
			score.add([phraseStart, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.12, \decay, 8]]);
		};
	};

	// Marimba pattern
	8.do { |step|
		var time, freq, isAccent, stepTimbre, amp, decay, pan;
		time = phraseStart + (step * stepDur);
		freq = pattern[step];
		isAccent = accents[step] == 1;
		stepTimbre = timbre + (step * 0.01);

		if (isAccent or: (density > 0.5.rand)) {
			amp = if(isAccent, 0.18, 0.1) * (0.8 + (density * 0.2));
			decay = if(isAccent, 1.0, 0.5);
			pan = [-0.1, 0.1].wrapAt(step);
			score.add([time, [\s_new, \marimbaVar, -1, 0, 0,
				\freq, freq, \amp, amp, \decay, decay,
				\pan, pan, \timbre, stepTimbre.clip(0.1, 1.0)]]);
		};
	};

	// Wood blocks
	if ((phraseStart >= introEnd) and: (phraseStart < breakdownEnd)) {
		if ((phraseNum % 2 == 0) and: (density > 0.6)) {
			score.add([phraseStart, [\s_new, \woodBlock, -1, 0, 0,
				\freq, 700 + (timbre * 400), \amp, 0.05 * density]]);
		};
		if ((phraseNum % 3 == 0) and: (density > 0.7)) {
			score.add([phraseStart + (3 * stepDur), [\s_new, \woodBlock, -1, 0, 0,
				\freq, 750 + (timbre * 400), \amp, 0.04 * density, \pan, 0.3]]);
		};
	};

	// Movement layer
	if ((phraseStart >= 35) and: (phraseStart < peakEnd)) {
		if (density > 0.7) {
			highFreq = pattern.choose * 2;
			score.add([phraseStart + (5 * stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, highFreq, \amp, 0.08 * density,
				\decay, 0.4, \pan, 0.4, \timbre, timbre * 0.85]]);
		};
		if ((phraseNum % 2 == 0) and: (density > 0.8)) {
			highFreq = pattern.choose * 2;
			score.add([phraseStart + (2 * stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, highFreq, \amp, 0.07 * density,
				\decay, 0.35, \pan, -0.3, \timbre, timbre * 0.9]]);
		};
	};

	// Sparkle layer
	if ((phraseStart >= developEnd) and: (phraseStart < peakEnd)) {
		if (phraseNum % 2 == 1) {
			score.add([phraseStart + (4 * stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, pattern.choose * 4, \amp, 0.04,
				\decay, 0.25, \pan, 0.6, \timbre, 0.95]]);
		};
		if (phraseNum % 3 == 0) {
			score.add([phraseStart + (7 * stepDur), [\s_new, \marimbaVar, -1, 0, 0,
				\freq, pattern.choose * 4, \amp, 0.035,
				\decay, 0.2, \pan, -0.5, \timbre, 1.0]]);
		};
	};
};

// Final gong
score.add([totalDuration - 5, [\s_new, \gong, -1, 0, 0, \freq, 55, \amp, 0.2, \decay, 15]]);

// End marker
score.add([totalDuration + 10, [\c_set, 0, 0]]);

// Sort by time and convert to Score
score = score.sort({ |a, b| a[0] < b[0] });

// Render
Score(score.asArray).recordNRT(
	outputFilePath: ~outputPath,
	headerFormat: "WAV",
	sampleFormat: "int24",
	options: ServerOptions.new.numOutputBusChannels_(2).sampleRate_(48000),
	duration: totalDuration + 12
);

"Rendering to: %".format(~outputPath).postln;
"This may take a minute...".postln;
)
