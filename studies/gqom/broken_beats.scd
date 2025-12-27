// ============================================================================
// GQOM BROKEN BEATS EXPERIMENT
// ============================================================================
// Exploring the syncopated, non-four-on-the-floor rhythm patterns that define
// Gqom. The "broken beat" is the genre's rhythmic signature - deliberately
// avoiding predictable kick placement to create hypnotic, off-kilter grooves.
//
// Key concepts:
// - Two-step and three-step patterns
// - Tresillo (3+3+2) foundation
// - Off-beat emphasis that tricks the ear
// - Tom rolls for tension building
//
// Usage: Load gqom_core.scd first, then evaluate sections below
// ============================================================================

// Load core library first
// Execute this block, then evaluate sections below
(
var libPath = thisProcess.nowExecutingPath.dirname +/+ "lib/gqom_core.scd";
libPath.load;
)

// ============================================================================
// SECTION 1: BASIC TWO-STEP PATTERN
// ============================================================================
// The foundation of gqom rhythm - kicks that deliberately skip beats

(
~clock = TempoClock(120/60);

// Two-step kick pattern
~kickPlayer = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~gqomTwoStep1, inf) * 0.8,
    \freq, 45,
    \decay, 0.35,
    \drive, 2.5
).play(~clock);

// Sparse snare on off-beats
~snarePlayer = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq(~gqomSnare1, inf) * 0.5,
    \freq, 180,
    \decay, 0.15
).play(~clock);
)

// Stop
(~kickPlayer.stop; ~snarePlayer.stop;)

// ============================================================================
// SECTION 2: THREE-STEP PATTERN
// ============================================================================
// Beats grouped in threes - creates a perpetual rolling sensation

(
~clock = TempoClock(115/60);  // 3-step often slightly slower

// Three-step kick (12 steps = 4 groups of 3)
~threeStepKick = Pbind(
    \instrument, \gqomKick,
    \dur, 1/3,  // triplet feel
    \amp, Pseq([0.9, 0, 0, 0.7, 0, 0, 0.8, 0, 0, 0.7, 0, 0], inf),
    \freq, 45
).play(~clock);

// Complementary snare
~threeStepSnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 1/3,
    \amp, Pseq([0, 0, 0.5, 0, 0, 0, 0, 0, 0.6, 0, 0, 0.4], inf),
    \freq, 200
).play(~clock);
)

// Stop
(~threeStepKick.stop; ~threeStepSnare.stop;)

// ============================================================================
// SECTION 3: TRESILLO-BASED PATTERN
// ============================================================================
// The 3+3+2 pattern common in Afro-Latin music, adapted for gqom

(
~clock = TempoClock(124/60);

// Tresillo kick (3+3+2 = 8 sixteenth notes)
~tresilloKick = Pbind(
    \instrument, \gqomKick,
    \dur, Pseq([0.375, 0.375, 0.25], inf),  // 3+3+2 in quarter notes
    \amp, 0.85,
    \freq, 45,
    \drive, 3
).play(~clock);

// Counter-rhythm snare
~tresilloSnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq([0,0,0,0, 0.6,0,0,0], inf),
    \freq, 180
).play(~clock);
)

// Stop
(~tresilloKick.stop; ~tresilloSnare.stop;)

// ============================================================================
// SECTION 4: ALGORITHMIC BROKEN BEAT
// ============================================================================
// Generate random broken patterns using density control

(
~clock = TempoClock(122/60);

// Generate a new broken pattern
~currentPattern = ~generateBrokenBeat.(16, 0.3, true);
("Generated pattern: " ++ ~currentPattern).postln;

~algoKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~currentPattern, inf) * 0.85,
    \freq, Prand([42, 45, 48], inf),  // Slight pitch variation
    \decay, Pwhite(0.3, 0.4)
).play(~clock);

~algoSnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq(~generateBrokenBeat.(16, 0.2, true), inf) * 0.5,
    \freq, 180
).play(~clock);
)

// Regenerate pattern while playing
(
~currentPattern = ~generateBrokenBeat.(16, 0.35, true);
("New pattern: " ++ ~currentPattern).postln;
)

// Stop
(~algoKick.stop; ~algoSnare.stop;)

// ============================================================================
// SECTION 5: TOM ROLL TENSION
// ============================================================================
// Cascading tom patterns that build tension - signature gqom element

(
~clock = TempoClock(120/60);

// Base kick pattern
~rollKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~gqomBroken1, inf) * 0.8,
    \freq, 45
).play(~clock);

// Tom roll that builds every 2 bars
~tomRollPlayer = Pbind(
    \instrument, \gqomTom,
    \dur, 0.25,
    // Roll builds in last 8 steps of every 32
    \amp, Pseq(
        Array.fill(24, 0) ++ Array.interpolation(8, 0.2, 0.9),
        inf
    ),
    \freq, Pseq(
        Array.fill(24, { \rest }) ++ Array.fill(8, { rrand(80, 150) }),
        inf
    ),
    \decay, 0.15
).play(~clock);
)

// Stop
(~rollKick.stop; ~tomRollPlayer.stop;)

// ============================================================================
// SECTION 6: LAYERED POLYRHYTHM
// ============================================================================
// Multiple interlocking broken patterns creating complex texture

(
~clock = TempoClock(118/60);

// Primary kick - broken pattern
~polyKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~gqomBroken2, inf) * 0.85,
    \freq, 45
).play(~clock);

// Secondary kick - shifted pattern (creates polyrhythm)
~polyKick2 = Pbind(
    \instrument, \gqomKickLight,
    \dur, 0.25,
    \amp, Pseq(~shiftPattern.(~gqomBroken2, 3), inf) * 0.5,
    \freq, 55
).play(~clock);

// Snare layer
~polySnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq(~gqomSnare2, inf) * 0.45,
    \freq, 180
).play(~clock);

// Sparse clap accent
~polyClap = Pbind(
    \instrument, \gqomClap,
    \dur, 0.25,
    \amp, Pseq(~gqomClap1, inf) * 0.35,
    \decay, 0.1
).play(~clock);
)

// Stop all
(~polyKick.stop; ~polyKick2.stop; ~polySnare.stop; ~polyClap.stop;)

// ============================================================================
// SECTION 7: PATTERN MORPHING
// ============================================================================
// Gradually shift between patterns over time

(
~clock = TempoClock(120/60);

// Patterns to morph between
~patternA = ~gqomTwoStep1;
~patternB = ~gqomBroken1;
~morphPos = 0;

~morphKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pfunc({
        var idx = (~clock.beats * 4).asInteger % 16;
        var valA = ~patternA[idx];
        var valB = ~patternB[idx];
        // Blend based on morph position
        ((valA * (1 - ~morphPos)) + (valB * ~morphPos)) * 0.85
    }),
    \freq, 45
).play(~clock);

// Morph control routine
~morphRoutine = Routine({
    inf.do {
        ~morphPos = (~morphPos + 0.05).wrap(0, 1);
        ("Morph position: " ++ ~morphPos.round(0.01)).postln;
        4.wait;  // Change every 4 beats
    }
}).play(~clock);
)

// Stop
(~morphKick.stop; ~morphRoutine.stop;)

// ============================================================================
// SECTION 8: FULL BROKEN BEAT GROOVE
// ============================================================================
// Complete rhythm section demonstrating gqom broken beat aesthetic

(
~clock = TempoClock(122/60);

// Main kick - broken pattern
~fullKick = Pbind(
    \instrument, \gqomKick,
    \dur, 0.25,
    \amp, Pseq(~gqomBroken1, inf) * 0.85,
    \freq, 45,
    \decay, 0.35,
    \drive, 2.8
).play(~clock);

// Sub layer (follows kick but quieter)
~fullSub = Pbind(
    \instrument, \gqomSub,
    \dur, 0.25,
    \amp, Pseq(~gqomBroken1, inf) * 0.4,
    \freq, 35,
    \decay, 0.4
).play(~clock);

// Snare on off-beats
~fullSnare = Pbind(
    \instrument, \gqomSnare,
    \dur, 0.25,
    \amp, Pseq(~gqomSnare1, inf) * 0.5,
    \freq, 180,
    \decay, 0.15
).play(~clock);

// Clap accents
~fullClap = Pbind(
    \instrument, \gqomClap,
    \dur, 0.25,
    \amp, Pseq([0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0.4,0,0], inf),
    \decay, 0.12
).play(~clock);

// Tom roll every 4 bars
~fullTom = Pbind(
    \instrument, \gqomTom,
    \dur, 0.25,
    \amp, Pseq(
        (Array.fill(56, 0) ++ ~tomRoll.(8, 0.25, 0.85)),
        inf
    ),
    \freq, Pwhite(90, 140),
    \decay, 0.18
).play(~clock);

// Very sparse hi-hat
~fullHat = Pbind(
    \instrument, \gqomHat,
    \dur, 0.25,
    \amp, Pseq(~gqomHat, inf) * 0.2,
    \decay, 0.04
).play(~clock);
)

// Stop all
(
~fullKick.stop; ~fullSub.stop; ~fullSnare.stop;
~fullClap.stop; ~fullTom.stop; ~fullHat.stop;
)

// ============================================================================
// CLEANUP
// ============================================================================

// s.freeAll;
