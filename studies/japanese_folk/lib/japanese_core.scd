// ============================================================================
// JAPANESE FOLK MUSIC - CORE LIBRARY
// ============================================================================
// Shared scales, helper functions, and utilities for Japanese folk experiments.
//
// Load this file first before running other Japanese folk experiments:
// "/path/to/studies/japanese_folk/lib/japanese_core.scd".load;
// ============================================================================

(
// ============================================================================
// SCALES (intervals in semitones from root)
// ============================================================================

// Yo Scale - bright, folk songs (anhemitonic - no semitones)
// Character: Open, cheerful, pastoral
~yoScale = [0, 2, 5, 7, 9];  // D E G A B from D

// In Scale - dark, urban, shamisen music (hemitonic - has semitones)
// Character: Melancholic, mysterious, dramatic
~inScale = [0, 1, 5, 7, 8];  // A Bb D E F from A

// Hirajoshi - koto tuning, contemplative
// Character: Elegant, melancholic, meditative
~hirajoshi = [0, 2, 3, 7, 8];  // C D Eb G Ab from C

// Kumoijoshi - another koto tuning
// Character: Haunting, ethereal
~kumoijoshi = [0, 1, 5, 7, 8];  // D Eb G A Bb from D

// Iwato - darkest scale, named after Amaterasu's cave
// Character: Ancient, mysterious, ominous
~iwato = [0, 1, 5, 6, 10];  // C Db F Gb Bb from C

// Ryukyu - Okinawan scale (distinctly different)
// Character: Bright but exotic, island feeling
~ryukyu = [0, 4, 5, 7, 11];  // C E F G B from C

// ============================================================================
// PITCH HELPERS
// ============================================================================

// Convert scale degree to frequency
// root: MIDI note number of scale root
// scale: array of semitone intervals
// degree: scale degree (can be negative or exceed scale length)
// octave: additional octave offset
~scaleToFreq = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    // Handle negative degrees
    if(degree < 0) {
        idx = scale.size + (degree % scale.size);
        oct = (degree / scale.size).floor;
    };
    (root + scale[idx] + (oct * 12)).midicps;
};

// Get MIDI note from scale degree
~scaleToMidi = { |root, scale, degree, octave = 0|
    var idx = degree % scale.size;
    var oct = (degree / scale.size).floor + octave;
    if(degree < 0) {
        idx = scale.size + (degree % scale.size);
        oct = (degree / scale.size).floor;
    };
    root + scale[idx] + (oct * 12);
};

// Random note from scale within range
~randomScaleNote = { |root, scale, lowDegree = 0, highDegree = 7|
    var degree = rrand(lowDegree, highDegree);
    ~scaleToFreq.(root, scale, degree);
};

// ============================================================================
// KOBUSHI (Vocal Ornament) HELPERS
// ============================================================================

// Kobushi envelope - the rise-fall-settle contour
// Returns an Env suitable for pitch modulation (in ratio, not Hz)
~kobushiEnv = { |depth = 0.03, dur = 0.12|
    Env(
        [0, depth, depth.neg * 0.7, depth * 0.3, 0],
        [0.02, 0.04, 0.03, 0.03].normalizeSum * dur,
        \sine
    );
};

// Kobushi depth in Hz (authentic ~70Hz)
~kobushiHz = 70;

// ============================================================================
// MA (SILENCE) HELPERS
// ============================================================================

// Weighted random rest duration based on ma concept
// Returns rest duration in seconds
~maRest = {
    [0, 0.3, 0.6, 1.0, 1.5, 2.0].wchoose([0.3, 0.25, 0.2, 0.12, 0.08, 0.05]);
};

// Breath-based phrase duration (2-5 seconds typical)
~breathDur = { rrand(2.0, 5.0) };

// ============================================================================
// JO-HA-KYU TEMPO HELPERS
// ============================================================================

// Jo-Ha-Kyu tempo multiplier envelope
// Returns tempo multipliers over time
~joHaKyuEnv = { |joDur = 4, haDur = 4, kyuDur = 2|
    Env(
        [0.6, 0.7, 1.0, 1.6],  // slow -> medium -> fast
        [joDur, haDur, kyuDur],
        [2, 1, 4]  // gradual then sudden
    );
};

// Get tempo at position in jo-ha-kyu structure
~joHaKyuTempo = { |baseTempo, position, totalDur = 10|
    var env = ~joHaKyuEnv.(totalDur * 0.4, totalDur * 0.4, totalDur * 0.2);
    baseTempo * env.at(position);
};

// ============================================================================
// MERI/KARI (Shakuhachi Pitch Bend) HELPERS
// ============================================================================

// Meri envelope - downward bend (in semitones)
~meriEnv = { |depth = 1.0, dur = 0.3|
    Env([0, depth.neg, depth.neg * 0.8], [dur * 0.3, dur * 0.7], \sine);
};

// Kari envelope - upward bend (in semitones)
~kariEnv = { |depth = 0.5, dur = 0.2|
    Env([0, depth, depth * 0.6], [dur * 0.4, dur * 0.6], \sine);
};

// Cadential meri-kari gesture (common phrase ending)
~meriKariCadenceEnv = { |dur = 0.5|
    Env(
        [0, -0.8, 0.2, -0.3, 0],
        [0.3, 0.1, 0.15, 0.1].normalizeSum * dur,
        \sine
    );
};

// ============================================================================
// HETEROPHONY HELPERS
// ============================================================================

// Generate timing offsets for heterophonic voices
~heteroOffsets = { |numVoices = 3, maxDelay = 0.15|
    numVoices.collect { rrand(0, maxDelay) };
};

// Generate pitch variations for heterophonic voices (in cents)
~heteroPitchVar = { |numVoices = 3, maxCents = 10|
    numVoices.collect { rrand(maxCents.neg, maxCents) };
};

// ============================================================================
// SCALE INFORMATION
// ============================================================================

// Print scale intervals
~printScale = { |name, scale|
    var intervals = scale.differentiate.drop(1) ++ [(12 - scale.last)];
    "% scale: % (intervals: %)".format(name, scale, intervals).postln;
};

// Print all scales
~printAllScales = {
    "=== Japanese Scales ===".postln;
    ~printScale.("Yo (bright)", ~yoScale);
    ~printScale.("In (dark)", ~inScale);
    ~printScale.("Hirajoshi", ~hirajoshi);
    ~printScale.("Kumoijoshi", ~kumoijoshi);
    ~printScale.("Iwato", ~iwato);
    ~printScale.("Ryukyu", ~ryukyu);
    "".postln;
};

// ============================================================================
// INITIALIZATION MESSAGE
// ============================================================================

"===========================================".postln;
"Japanese Folk Music Core Library Loaded".postln;
"===========================================".postln;
"".postln;
"Available scales:".postln;
"  ~yoScale      - bright, folk (D E G A B)".postln;
"  ~inScale      - dark, urban (A Bb D E F)".postln;
"  ~hirajoshi    - koto tuning (C D Eb G Ab)".postln;
"  ~kumoijoshi   - ethereal koto (D Eb G A Bb)".postln;
"  ~iwato        - mysterious (C Db F Gb Bb)".postln;
"  ~ryukyu       - Okinawan (C E F G B)".postln;
"".postln;
"Helper functions:".postln;
"  ~scaleToFreq.(root, scale, degree, octave)".postln;
"  ~maRest.value  - random ma rest duration".postln;
"  ~kobushiEnv.(depth, dur) - ornament envelope".postln;
"  ~meriEnv.(depth, dur) - downward bend".postln;
"  ~kariEnv.(depth, dur) - upward bend".postln;
"".postln;
)
