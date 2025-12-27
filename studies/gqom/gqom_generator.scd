// ============================================================================
// GQOM TRACK GENERATOR
// ============================================================================
// A complete generative Gqom track system that creates full arrangements
// following the genre's conventions: long builds, tension without drops,
// broken beats, and dark atmospheric elements.
//
// Structure follows Gqom conventions:
// - Intro: Pads and sparse percussion (16-32 bars)
// - Build: Drums gradually added (16-32 bars)
// - Drop: Full pattern with maximum energy (32+ bars)
// - Breakdown: Stripped back, maintains tension (8-16 bars)
// - [Repeat Drop/Breakdown]
// - Outro: Gradual element removal
//
// Usage: Load gqom_core.scd first, then evaluate the generator
// ============================================================================

// Load core library first
// Execute this block, then evaluate the generator below
(
var libPath = thisProcess.nowExecutingPath.dirname +/+ "lib/gqom_core.scd";
libPath.load;
)

// ============================================================================
// GQOM TRACK GENERATOR CLASS
// ============================================================================

(
~GqomTrack = (

    // Configuration
    tempo: 120,
    rootNote: 55,  // A1
    key: \minor,

    // Pattern storage
    kickPattern: nil,
    snarePattern: nil,

    // Active players
    players: Dictionary.new,
    synths: Dictionary.new,
    clock: nil,
    effects: Dictionary.new,

    // Current state
    currentSection: \stopped,
    sectionBars: 0,

    // Initialize the track
    init: { |self, tempo = 120, root = 55|
        self.tempo = tempo;
        self.rootNote = root;
        self.clock = TempoClock(tempo / 60);

        // Generate patterns
        self.kickPattern = ~generateBrokenBeat.(16, 0.3, true);
        self.snarePattern = ~generateBrokenBeat.(16, 0.2, true);

        // Ensure patterns have some hits
        if(self.kickPattern.sum < 3, {
            self.kickPattern = ~gqomBroken1;
        });

        // Setup effects
        self.effects[\reverb] = Synth(\gqomReverb, [
            \in, ~gqomReverbBus,
            \mix, 0.4,
            \room, 0.85,
            \damp, 0.5
        ]);

        self.effects[\delay] = Synth(\gqomDelay, [
            \in, ~gqomDelayBus,
            \delayTime, self.tempo.reciprocal * 60 * 0.75,  // Dotted eighth
            \feedback, 0.35,
            \mix, 0.3
        ]);

        ("GqomTrack initialized at " ++ tempo ++ " BPM").postln;
        ("Kick pattern: " ++ self.kickPattern).postln;
        self;
    },

    // Start/stop individual elements
    startPad: { |self|
        if(self.synths[\pad].isNil, {
            self.synths[\pad] = Synth(\gqomPad, [
                \out, ~gqomReverbBus,
                \freq, self.rootNote,
                \amp, 0.28,
                \cutoff, 450,
                \attack, 3
            ]);
        });
    },

    stopPad: { |self|
        if(self.synths[\pad].notNil, {
            self.synths[\pad].set(\gate, 0);
            self.synths[\pad] = nil;
        });
    },

    startSub: { |self|
        if(self.synths[\sub].isNil, {
            self.synths[\sub] = Synth(\gqomDrone, [
                \freq, self.rootNote * 0.5,
                \amp, 0.2,
                \cutoff, 150
            ]);
        });
    },

    stopSub: { |self|
        if(self.synths[\sub].notNil, {
            self.synths[\sub].set(\gate, 0);
            self.synths[\sub] = nil;
        });
    },

    startKick: { |self, amp = 0.8|
        if(self.players[\kick].isNil, {
            self.players[\kick] = Pbind(
                \instrument, \gqomKick,
                \dur, 0.25,
                \amp, Pseq(self.kickPattern, inf) * amp,
                \freq, 45,
                \decay, 0.35,
                \drive, 2.8
            ).play(self.clock);
        });
    },

    stopKick: { |self|
        if(self.players[\kick].notNil, {
            self.players[\kick].stop;
            self.players[\kick] = nil;
        });
    },

    startSnare: { |self, amp = 0.5|
        if(self.players[\snare].isNil, {
            self.players[\snare] = Pbind(
                \instrument, \gqomSnare,
                \dur, 0.25,
                \amp, Pseq(self.snarePattern, inf) * amp,
                \freq, 180
            ).play(self.clock);
        });
    },

    stopSnare: { |self|
        if(self.players[\snare].notNil, {
            self.players[\snare].stop;
            self.players[\snare] = nil;
        });
    },

    startClap: { |self, amp = 0.35|
        if(self.players[\clap].isNil, {
            self.players[\clap] = Pbind(
                \instrument, \gqomClap,
                \dur, 0.25,
                \amp, Pseq(~gqomClap1, inf) * amp
            ).play(self.clock);
        });
    },

    stopClap: { |self|
        if(self.players[\clap].notNil, {
            self.players[\clap].stop;
            self.players[\clap] = nil;
        });
    },

    startTomRoll: { |self|
        if(self.players[\tom].isNil, {
            self.players[\tom] = Pbind(
                \instrument, \gqomTom,
                \dur, 0.25,
                \amp, Pseq(
                    Array.fill(56, 0) ++ ~tomRoll.(8, 0.25, 0.8),
                    inf
                ),
                \freq, Pwhite(90, 140),
                \decay, 0.18
            ).play(self.clock);
        });
    },

    stopTomRoll: { |self|
        if(self.players[\tom].notNil, {
            self.players[\tom].stop;
            self.players[\tom] = nil;
        });
    },

    startStabs: { |self|
        if(self.players[\stabs].isNil, {
            self.players[\stabs] = Pbind(
                \instrument, \gqomStab,
                \out, ~gqomDelayBus,
                \dur, Prand([0.5, 1, 1.5, 2, 4], inf),
                \amp, Pwhite(0.2, 0.35),
                \freq, Prand([
                    self.rootNote * 2,
                    self.rootNote * 3,
                    self.rootNote * 4
                ], inf),
                \decay, Pwhite(0.25, 0.5),
                \cutoff, Pwhite(900, 1500),
                \pan, Pwhite(-0.4, 0.4)
            ).play(self.clock);
        });
    },

    stopStabs: { |self|
        if(self.players[\stabs].notNil, {
            self.players[\stabs].stop;
            self.players[\stabs] = nil;
        });
    },

    startHat: { |self, amp = 0.2|
        if(self.players[\hat].isNil, {
            self.players[\hat] = Pbind(
                \instrument, \gqomHat,
                \dur, 0.25,
                \amp, Pseq(~gqomHat, inf) * amp
            ).play(self.clock);
        });
    },

    stopHat: { |self|
        if(self.players[\hat].notNil, {
            self.players[\hat].stop;
            self.players[\hat] = nil;
        });
    },

    // Section transitions
    playIntro: { |self, bars = 16|
        self.currentSection = \intro;
        (">>> INTRO (" ++ bars ++ " bars)").postln;

        self.startPad;
        self.startSub;

        // Add sparse elements after half the intro
        self.clock.sched(bars * 0.5 * 4, {
            if(self.currentSection == \intro, {
                self.startStabs;
            });
        });
    },

    playBuild: { |self, bars = 16|
        self.currentSection = \build;
        (">>> BUILD (" ++ bars ++ " bars)").postln;

        // Ensure atmosphere is running
        self.startPad;
        self.startSub;

        // Add snare first
        self.clock.sched(0, { self.startSnare.(0.4) });

        // Add kick halfway
        self.clock.sched(bars * 0.5 * 4, {
            if(self.currentSection == \build, {
                self.startKick.(0.6);
            });
        });

        // Add hats near end
        self.clock.sched(bars * 0.75 * 4, {
            if(self.currentSection == \build, {
                self.startHat.(0.15);
            });
        });
    },

    playDrop: { |self, bars = 32|
        self.currentSection = \drop;
        (">>> DROP (" ++ bars ++ " bars)").postln;

        // Full elements
        self.startPad;
        self.startSub;
        self.startKick.(0.85);
        self.startSnare.(0.5);
        self.startClap.(0.35);
        self.startTomRoll;
        self.startHat.(0.2);
        self.startStabs;
    },

    playBreakdown: { |self, bars = 8|
        self.currentSection = \breakdown;
        (">>> BREAKDOWN (" ++ bars ++ " bars)").postln;

        // Strip back to atmosphere
        self.stopKick;
        self.stopSnare;
        self.stopClap;
        self.stopTomRoll;
        self.stopHat;

        // Keep pads and sparse stabs
        self.startPad;
        self.startSub;
        self.startStabs;
    },

    playOutro: { |self, bars = 16|
        self.currentSection = \outro;
        (">>> OUTRO (" ++ bars ++ " bars)").postln;

        // Gradual removal
        self.stopKick;
        self.stopClap;
        self.stopTomRoll;

        // Keep minimal elements
        self.startPad;
        self.startSub;

        // Fade out remaining elements
        self.clock.sched(bars * 0.5 * 4, {
            if(self.currentSection == \outro, {
                self.stopSnare;
                self.stopHat;
            });
        });

        self.clock.sched(bars * 0.75 * 4, {
            if(self.currentSection == \outro, {
                self.stopStabs;
            });
        });
    },

    // Full track sequence
    playFullTrack: { |self|
        var schedule = [
            [\playIntro, 16],
            [\playBuild, 16],
            [\playDrop, 32],
            [\playBreakdown, 8],
            [\playDrop, 32],
            [\playBreakdown, 8],
            [\playDrop, 16],
            [\playOutro, 16]
        ];
        var currentBeat = 0;

        "=== STARTING FULL GQOM TRACK ===".postln;
        ("Total duration: " ++ (schedule.collect(_[1]).sum * 4 / self.tempo * 60).round(0.1) ++ " seconds").postln;

        schedule.do { |section|
            var method = section[0];
            var bars = section[1];

            self.clock.sched(currentBeat, {
                self.perform(method, bars);
            });

            currentBeat = currentBeat + (bars * 4);
        };

        // Final cleanup
        self.clock.sched(currentBeat, {
            "=== TRACK COMPLETE ===".postln;
            self.stop;
        });
    },

    // Stop everything
    stop: { |self|
        self.currentSection = \stopped;

        // Stop all players
        self.players.keysValuesDo { |key, player|
            if(player.notNil, { player.stop });
        };
        self.players = Dictionary.new;

        // Release all synths
        self.synths.keysValuesDo { |key, synth|
            if(synth.notNil, { synth.set(\gate, 0) });
        };
        self.synths = Dictionary.new;

        "Track stopped".postln;
    },

    // Cleanup effects
    free: { |self|
        self.stop;
        self.effects.keysValuesDo { |key, synth|
            if(synth.notNil, { synth.free });
        };
        self.effects = Dictionary.new;
        "Track freed".postln;
    }
);
)

// ============================================================================
// USAGE EXAMPLES
// ============================================================================
// Evaluate these lines manually - they are not auto-executed

// Initialize the track generator
// ~track = ~GqomTrack.copy.init(120, 55);

// Manual section control
// ~track.playIntro(16);
// ~track.playBuild(16);
// ~track.playDrop(32);
// ~track.playBreakdown(8);
// ~track.playOutro(16);

// Stop
// ~track.stop;

// Play full automated track
// ~track.playFullTrack;

// Stop at any time
// ~track.stop;

// Free all resources
// ~track.free;

// ============================================================================
// QUICK START - EVALUATE THIS BLOCK FOR INSTANT GQOM
// ============================================================================

(
// Initialize and play
~track = ~GqomTrack.copy.init(122, 55);  // 122 BPM, root A1
~track.playFullTrack;
)

// Stop
// ~track.free;

// ============================================================================
// VARIATION: 3-STEP GQOM
// ============================================================================

(
~track3Step = ~GqomTrack.copy.init(115, 55);  // Slower for 3-step
~track3Step.kickPattern = [1,0,0, 1,0,0, 1,0,0, 1,0,0, 0,0,0,0];  // 3-step pattern
~track3Step.playDrop(32);
)

// Stop
// ~track3Step.free;

// ============================================================================
// VARIATION: GQOM TECH (FASTER)
// ============================================================================

(
~trackTech = ~GqomTrack.copy.init(135, 55);  // Faster
~trackTech.playDrop(32);
)

// Stop
// ~trackTech.free;

// ============================================================================
// CLEANUP
// ============================================================================

// s.freeAll;
