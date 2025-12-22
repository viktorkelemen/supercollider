// =====================================================
// COMPOSITION TEMPLATE
// 5-minute structure with voice roles and energy arc
// =====================================================
// See COMPOSITION.md for principles
//
// Voice Roles:
//   Foundation - harmonic anchor (drone, bass)
//   Pulse      - time feel (kick, steady rhythm)
//   Movement   - rhythmic interest (hats, perc, fills)
//   Color      - texture/atmosphere (pads, noise)
//   Focus      - melody/hook (lead, arp)
//
// Structure:
//   Intro      0:00-1:00  - establish mood
//   Develop    1:00-2:30  - add pulse, movement
//   Peak       2:30-3:30  - maximum density
//   Breakdown  3:30-4:15  - strip back
//   Resolve    4:15-5:00  - fade out
// =====================================================

(
// === CONFIGURATION ===
~bpm = 110;
~beatsPerBar = 4;

// === CLOCK ===
~t = TempoClock.new(~bpm/60);

// Helper: convert bars to beats
~bars = { |n| n * ~beatsPerBar };

// === VOICE HOLDERS ===
~voices = IdentityDictionary[
    \foundation -> nil,
    \pulse -> nil,
    \movement -> nil,
    \color -> nil,
    \focus -> nil
];

// === DEFINE YOUR VOICES HERE ===

// FOUNDATION: slow, low, constant
~startFoundation = {
    ">>> Foundation enters".postln;
    ~voices[\foundation] = Pbind(
        \instrument, \default,
        \midinote, Pseq([36, 36, 38, 36], inf),
        \dur, 4,
        \amp, 0.4,
        \legato, 1.2
    ).play(~t);
};

// PULSE: steady, hypnotic
~startPulse = {
    ">>> Pulse enters".postln;
    ~voices[\pulse] = Pbind(
        \instrument, \default,
        \midinote, 36,
        \dur, 1,
        \amp, 0.5,
        \sustain, 0.1
    ).play(~t);
};

// MOVEMENT: syncopation, fills
~startMovement = {
    ">>> Movement enters".postln;
    ~voices[\movement] = Pbind(
        \instrument, \default,
        \midinote, Pseq([Rest(), 60, Rest(), 60, Rest(), 60, 62, Rest()], inf),
        \dur, 0.5,
        \amp, 0.25
    ).play(~t);
};

// COLOR: texture, atmosphere
~startColor = {
    ">>> Color enters".postln;
    ~voices[\color] = Pbind(
        \instrument, \default,
        \midinote, [60, 67, 72],  // chord
        \dur, 8,
        \amp, 0.15,
        \legato, 1.5
    ).play(~t);
};

// FOCUS: melody, hook
~startFocus = {
    ">>> Focus enters".postln;
    ~voices[\focus] = Pbind(
        \instrument, \default,
        \midinote, Pseq([72, 74, 76, 79, 77, 76, 74, 72], inf),
        \dur, 0.5,
        \amp, 0.3
    ).play(~t);
};

// === CONTROL FUNCTIONS ===

~stopVoice = { |name|
    if(~voices[name].notNil) {
        (">>> " ++ name ++ " exits").postln;
        ~voices[name].stop;
        ~voices[name] = nil;
    };
};

~stopAll = {
    ">>> All voices stop".postln;
    ~voices.keysValuesDo { |key, val|
        if(val.notNil) { val.stop };
    };
    ~voices = IdentityDictionary[
        \foundation -> nil,
        \pulse -> nil,
        \movement -> nil,
        \color -> nil,
        \focus -> nil
    ];
};

// === ARRANGEMENT ===
// Schedule the structure

// INTRO (0:00 - 1:00) - bars 0-16
~t.sched(~bars.(0), {
    "========== INTRO ==========".postln;
    ~startFoundation.();
    nil
});

~t.sched(~bars.(8), {
    ~startColor.();
    nil
});

// DEVELOP (1:00 - 2:30) - bars 16-40
~t.sched(~bars.(16), {
    "========== DEVELOP ==========".postln;
    ~startPulse.();
    nil
});

~t.sched(~bars.(24), {
    ~startMovement.();
    nil
});

// PEAK (2:30 - 3:30) - bars 40-56
~t.sched(~bars.(40), {
    "========== PEAK ==========".postln;
    ~startFocus.();
    nil
});

// BREAKDOWN (3:30 - 4:15) - bars 56-68
~t.sched(~bars.(56), {
    "========== BREAKDOWN ==========".postln;
    ~stopVoice.(\pulse);
    ~stopVoice.(\movement);
    ~stopVoice.(\focus);
    nil
});

// RESOLVE (4:15 - 5:00) - bars 68-80
~t.sched(~bars.(68), {
    "========== RESOLVE ==========".postln;
    ~stopVoice.(\color);
    nil
});

~t.sched(~bars.(76), {
    ~stopVoice.(\foundation);
    nil
});

~t.sched(~bars.(80), {
    "========== END ==========".postln;
    nil
});

// === STATUS ===
"".postln;
"COMPOSITION TEMPLATE LOADED".postln;
("Tempo: " ++ ~bpm ++ " BPM").postln;
("Duration: ~" ++ (~bars.(80) / (~bpm/60) / 60).round(0.1) ++ " minutes").postln;
"".postln;
"Controls:".postln;
"  ~stopVoice.(\\name)  - stop one voice".postln;
"  ~stopAll.()          - stop everything".postln;
"  ~t.stop              - stop clock".postln;
"".postln;
)

// === EMERGENCY STOP ===
// s.freeAll; ~t.stop;
