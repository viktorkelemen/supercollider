// =====================================================
// DUB AMBIENT COMPOSITION TEMPLATE
// Uses existing SynthDefs from dub/ and ambient/ folders
// =====================================================
// Load SynthDefs first:
//   "dub/dub_techno.scd".load;
//   "ambient/loscil_drone.scd".load;
//
// Voice Roles:
//   Foundation - \submergedDrone (continuous texture bed)
//   Pulse      - \dubKick (4-on-floor or sparse)
//   Movement   - \dubHat (rhythmic interest)
//   Color      - \dubStabDelayVerb (chord stabs w/ delay)
//   Focus      - \hydrophone, \tapeLoop (melodic moments)
// =====================================================

(
// === CONFIGURATION ===
~bpm = 100;
~beatsPerBar = 4;
~root = 55;  // A1 - change for different keys

// === CLOCK ===
~t = TempoClock.new(~bpm/60);
~bars = { |n| n * ~beatsPerBar };

// === VOICE HOLDERS ===
~synths = IdentityDictionary.new;
~routines = IdentityDictionary.new;

// =====================================================
// VOICE DEFINITIONS
// =====================================================

// FOUNDATION: Submerged drone - continuous texture
~startFoundation = { |root = 55, depth = 0.6|
	">>> Foundation: submergedDrone".postln;
	~synths[\foundation] = Synth(\submergedDrone, [
		\root, root,
		\amp, 0.25,
		\depth, depth,
		\warmth, 0.6,
		\hissAmp, 0.02
	]);
};

// PULSE: Dub kick - steady or sparse
~startPulse = { |pattern = \fourOnFloor|
	">>> Pulse: dubKick".postln;
	~routines[\pulse] = switch(pattern,
		\fourOnFloor, {
			Pbind(
				\instrument, \dubKick,
				\freq, 42,
				\dur, 1,
				\amp, 0.4
			).play(~t);
		},
		\sparse, {
			Pbind(
				\instrument, \dubKick,
				\freq, 42,
				\dur, Pseq([2, 1, 1, 2, 2], inf),
				\amp, 0.35
			).play(~t);
		},
		\halftime, {
			Pbind(
				\instrument, \dubKick,
				\freq, 42,
				\dur, 2,
				\amp, 0.4
			).play(~t);
		}
	);
};

// MOVEMENT: Dub hats - offbeat groove
~startMovement = { |pattern = \offbeat|
	">>> Movement: dubHat".postln;
	~routines[\movement] = switch(pattern,
		\offbeat, {
			Pbind(
				\instrument, \dubHat,
				\dur, 1,
				\amp, Pseq([0.05, 0.08], inf),
				\decay, 0.08
			).play(~t, quant: 0.5);  // offset by half beat
		},
		\sixteenths, {
			Pbind(
				\instrument, \dubHat,
				\dur, 0.25,
				\amp, Pseq([0.06, 0.03, 0.04, 0.03], inf),
				\decay, Pwhite(0.04, 0.08, inf)
			).play(~t);
		},
		\sparse, {
			Pbind(
				\instrument, \dubHat,
				\dur, Pwrand([0.5, 1, 1.5], [0.5, 0.3, 0.2], inf),
				\amp, Pwhite(0.04, 0.08, inf),
				\decay, 0.06
			).play(~t);
		}
	);
};

// COLOR: Chord stabs with delay/reverb
~startColor = { |root = 55|
	">>> Color: dubStabDelayVerb".postln;
	~routines[\color] = Pbind(
		\instrument, \dubStabDelayVerb,
		\freq, Pseq([root, root, root * 1.5, root], inf),  // root, root, fifth, root
		\dur, Pseq([4, 3, 4, 5], inf),  // irregular spacing
		\amp, 0.28,
		\delayTime, 60 / ~bpm * 0.75,  // dotted eighth
		\feedback, 0.7,
		\verbAmp, 0.8,
		\decay, 6
	).play(~t);
};

// FOCUS: Melodic moments - hydrophone pings
~startFocus = { |root = 55|
	">>> Focus: hydrophone melody".postln;
	~routines[\focus] = Routine({
		var scale = [0, 3, 5, 7, 10, 12];  // minor pentatonic intervals
		var notes = scale.collect({ |i| root * 2 * (2 ** (i/12)) });  // one octave up
		inf.do {
			if (0.4.coin) {  // sparse, intentional
				var note = notes.choose;
				Synth(\hydrophone, [
					\freq, note,
					\amp, rrand(0.06, 0.12),
					\dur, rrand(2, 4),
					\depth, 0.5
				]);
			};
			rrand(3, 8).wait;
		};
	}).play(~t);
};

// TEXTURE: Tape loops - background movement
~startTexture = { |root = 55|
	">>> Texture: tapeLoop".postln;
	~routines[\texture] = Routine({
		var notes = [root, root * 1.5, root * 2];  // root, fifth, octave
		inf.do {
			if (0.25.coin) {
				Synth(\tapeLoop, [
					\freq, notes.choose,
					\amp, rrand(0.06, 0.1),
					\loopTime, rrand(3, 6),
					\decay, rrand(5, 10)
				]);
			};
			rrand(15, 30).wait;
		};
	}).play(~t);
};

// =====================================================
// CONTROL FUNCTIONS
// =====================================================

~stopVoice = { |name|
	if(~synths[name].notNil) {
		(">>> " ++ name ++ " synth exits").postln;
		~synths[name].free;
		~synths[name] = nil;
	};
	if(~routines[name].notNil) {
		(">>> " ++ name ++ " routine exits").postln;
		~routines[name].stop;
		~routines[name] = nil;
	};
};

~stopAll = {
	">>> All voices stop".postln;
	~synths.do(_.free);
	~routines.do(_.stop);
	~synths = IdentityDictionary.new;
	~routines = IdentityDictionary.new;
};

~fadeFoundation = { |time = 8|
	">>> Foundation fading...".postln;
	if(~synths[\foundation].notNil) {
		~synths[\foundation].set(\amp, 0, \time, time);
		SystemClock.sched(time, {
			~synths[\foundation].free;
			~synths[\foundation] = nil;
			nil
		});
	};
};

// =====================================================
// ARRANGEMENT - 5 MINUTES (~80 bars at 100bpm)
// =====================================================

// INTRO (0:00 - 1:00) - bars 0-16
// Establish atmosphere, no rhythm
~t.sched(~bars.(0), {
	"".postln;
	"========== INTRO (0:00) ==========".postln;
	~startFoundation.(~root, 0.7);  // deeper at start
	nil
});

~t.sched(~bars.(8), {
	~startTexture.(~root);
	nil
});

// DEVELOP (1:00 - 2:30) - bars 16-40
// Add pulse, movement
~t.sched(~bars.(16), {
	"".postln;
	"========== DEVELOP (1:00) ==========".postln;
	~startPulse.(\halftime);  // start sparse
	nil
});

~t.sched(~bars.(24), {
	~startPulse.(\fourOnFloor);  // switch to 4otf
	~startMovement.(\sparse);
	nil
});

~t.sched(~bars.(32), {
	~startColor.(~root);
	nil
});

// PEAK (2:30 - 3:30) - bars 40-56
// Full density
~t.sched(~bars.(40), {
	"".postln;
	"========== PEAK (2:30) ==========".postln;
	~stopVoice.(\movement);
	~startMovement.(\offbeat);  // more driving
	~startFocus.(~root);
	nil
});

~t.sched(~bars.(48), {
	// Modulate drone - shallower, brighter
	~synths[\foundation].set(\depth, 0.4);
	nil
});

// BREAKDOWN (3:30 - 4:15) - bars 56-68
// Strip back
~t.sched(~bars.(56), {
	"".postln;
	"========== BREAKDOWN (3:30) ==========".postln;
	~stopVoice.(\pulse);
	~stopVoice.(\movement);
	~stopVoice.(\focus);
	// Keep foundation + color (echoes)
	nil
});

~t.sched(~bars.(62), {
	~stopVoice.(\color);
	// Just drone and texture
	nil
});

// RESOLVE (4:15 - 5:00) - bars 68-80
~t.sched(~bars.(68), {
	"".postln;
	"========== RESOLVE (4:15) ==========".postln;
	// Brief pulse return
	~startPulse.(\sparse);
	nil
});

~t.sched(~bars.(74), {
	~stopVoice.(\pulse);
	~stopVoice.(\texture);
	// Drone fading deeper
	~synths[\foundation].set(\depth, 0.85);
	nil
});

~t.sched(~bars.(78), {
	~fadeFoundation.(10);  // 10 second fade
	nil
});

~t.sched(~bars.(82), {
	"".postln;
	"========== END ==========".postln;
	~stopAll.();
	nil
});

// === STATUS ===
"".postln;
"DUB AMBIENT COMPOSITION LOADED".postln;
("Tempo: " ++ ~bpm ++ " BPM").postln;
("Root: " ++ ~root ++ " Hz").postln;
("Duration: ~" ++ (~bars.(82) / (~bpm/60) / 60).round(0.1) ++ " minutes").postln;
"".postln;
"Make sure SynthDefs are loaded:".postln;
"  \"dub/dub_techno.scd\".load;".postln;
"  \"ambient/loscil_drone.scd\".load;".postln;
"".postln;
"Controls:".postln;
"  ~stopVoice.(\\name)  - stop one voice".postln;
"  ~stopAll.()          - emergency stop".postln;
"  ~t.stop              - stop clock".postln;
"".postln;
)

// =====================================================
// MANUAL CONTROL - for live performance
// =====================================================

// Start individual voices
// ~startFoundation.(55, 0.6);
// ~startPulse.(\fourOnFloor);
// ~startMovement.(\offbeat);
// ~startColor.(55);
// ~startFocus.(55);
// ~startTexture.(55);

// Stop individual voices
// ~stopVoice.(\pulse);
// ~stopVoice.(\movement);
// ~stopVoice.(\color);
// ~stopVoice.(\focus);
// ~stopVoice.(\texture);
// ~stopVoice.(\foundation);

// Modulate drone depth live
// ~synths[\foundation].set(\depth, 0.3);  // brighter
// ~synths[\foundation].set(\depth, 0.8);  // darker

// Change kick pattern live
// ~stopVoice.(\pulse); ~startPulse.(\sparse);
// ~stopVoice.(\pulse); ~startPulse.(\fourOnFloor);

// Emergency stop
// ~stopAll.();
// s.freeAll;
