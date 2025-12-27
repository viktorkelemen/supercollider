// ============================================================================
// GQOM CORE LIBRARY
// ============================================================================
// Shared resources for Gqom music experiments - the dark, hypnotic electronic
// dance music from Durban, South Africa.
//
// Usage: "/path/to/gqom_core.scd".load;
//
// Characteristics modeled:
// - Broken beat patterns (non-four-on-the-floor)
// - Heavy, distorted kicks
// - Dark atmospheric pads
// - Syncopated percussion
// - Sparse, tension-building arrangements
// ============================================================================

(
// ============================================================================
// RHYTHM PATTERNS
// ============================================================================
// Gqom uses broken beats - deliberately avoiding predictable kick placement

// Two-step patterns (16 steps at 16th note resolution)
~gqomTwoStep1 = [1,0,0,0, 0,0,1,0, 1,0,0,0, 0,0,1,0];
~gqomTwoStep2 = [1,0,0,1, 0,0,0,0, 1,0,0,1, 0,0,0,0];

// Three-step patterns (groups of 3, creates rolling feel)
~gqomThreeStep = [1,0,0, 1,0,0, 1,0,0, 1,0,0];  // 12 steps

// Syncopated broken patterns
~gqomBroken1 = [1,0,0,1, 0,1,0,0, 1,0,0,1, 0,0,1,0];
~gqomBroken2 = [1,0,0,0, 1,0,0,1, 0,0,1,0, 0,1,0,0];
~gqomBroken3 = [0,0,1,0, 1,0,0,1, 0,1,0,0, 1,0,0,0];

// Tresillo pattern (3+3+2)
~gqomTresillo = [1,0,0,1, 0,0,1,0];  // 8 steps

// Snare/clap patterns (off-beat emphasis)
~gqomSnare1 = [0,0,1,0, 0,0,0,1, 0,0,1,0, 0,0,0,1];
~gqomSnare2 = [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,1];
~gqomClap1 = [0,0,0,0, 0,0,1,0, 0,0,0,0, 0,1,0,0];

// Hi-hat (sparse or absent in traditional gqom)
~gqomHat = [0,0,0,0, 0,0,0,1, 0,0,0,0, 0,0,0,1];

// ============================================================================
// PATTERN UTILITIES
// ============================================================================

// Generate random broken beat pattern with given density
~generateBrokenBeat = { |steps = 16, density = 0.25, avoidDownbeat = true|
    var pattern = Array.fill(steps, { if(density.coin, { 1 }, { 0 }) });
    // Ensure at least one hit
    if(pattern.sum == 0, { pattern[steps.rand] = 1 });
    // Optionally avoid predictable downbeats
    if(avoidDownbeat, {
        if(0.7.coin, { pattern[0] = 0 });
        if(0.7.coin, { pattern[4] = 0 });
        if(0.7.coin, { pattern[8] = 0 });
        if(0.7.coin, { pattern[12] = 0 });
    });
    pattern;
};

// Create tom roll with increasing velocity (tension builder)
~tomRoll = { |steps = 8, startVel = 0.3, endVel = 1.0|
    var vels = Array.interpolation(steps, startVel, endVel);
    var pattern = Array.fill(16, 0);
    (16 - steps..15).do { |i, j|
        pattern[i] = vels[j];
    };
    pattern;
};

// Shift pattern for variation
~shiftPattern = { |pattern, amount = 1|
    pattern.rotate(amount);
};

// Combine two patterns (logical OR)
~combinePatterns = { |p1, p2|
    p1.collect { |v, i| max(v, p2.wrapAt(i)) };
};

// ============================================================================
// TEMPO UTILITIES
// ============================================================================

// Standard tempo ranges
~gqomTempoStandard = 120;
~gqomTempo3Step = 115;
~gqomTempoTech = 135;

// Create tempo clock
~gqomClock = { |bpm = 120|
    TempoClock(bpm / 60);
};

// ============================================================================
// EFFECTS BUS
// ============================================================================
// Bus allocation requires server to be running - call ~gqomInitBusses.() after boot

~gqomInitBusses = {
    if(s.serverRunning, {
        ~gqomReverbBus = Bus.audio(s, 2);
        ~gqomDelayBus = Bus.audio(s, 2);
        "Gqom busses initialized".postln;
    }, {
        "Server not running - call ~gqomInitBusses.() after s.boot".postln;
    });
};

// Try to init now if server is running
~gqomInitBusses.();

// Dark reverb for atmosphere
SynthDef(\gqomReverb, {
    |in, out = 0, mix = 0.35, room = 0.8, damp = 0.7, amp = 1|
    var sig = In.ar(in, 2);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp);
    Out.ar(out, verb * amp);
}).add;

// Echo/delay for vocal treatment
SynthDef(\gqomDelay, {
    |in, out = 0, delayTime = 0.375, feedback = 0.4, mix = 0.3, amp = 1|
    var sig = In.ar(in, 2);
    var delayed = CombL.ar(sig, 1.0, delayTime, feedback * 4);
    Out.ar(out, (sig * (1 - mix)) + (delayed * mix) * amp);
}).add;

// ============================================================================
// KICK DRUM SYNTHS
// ============================================================================

// Heavy gqom kick - distorted, deep, industrial
SynthDef(\gqomKick, {
    |out = 0, amp = 0.8, freq = 45, decay = 0.35,
     drive = 2.5, click = 0.4, punch = 200|
    var sig, env, clickEnv, pitchEnv, sub;

    // Pitch envelope for thump
    pitchEnv = EnvGen.kr(
        Env.perc(0.001, 0.08),
        levelScale: punch
    );

    // Main body - sine with pitch drop
    sig = SinOsc.ar(freq + pitchEnv);

    // Sub layer
    sub = SinOsc.ar(freq * 0.5) * 0.3;

    // Click transient
    clickEnv = EnvGen.kr(Env.perc(0.001, 0.015));
    sig = sig + (WhiteNoise.ar * clickEnv * click);

    // Add sub
    sig = sig + sub;

    // Distortion for grit (essential for gqom)
    sig = (sig * drive).tanh;

    // Amplitude envelope
    env = EnvGen.kr(
        Env.perc(0.005, decay, 1, -6),
        doneAction: 2
    );

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// Lighter kick variant
SynthDef(\gqomKickLight, {
    |out = 0, amp = 0.6, freq = 55, decay = 0.25, drive = 1.5|
    var sig, env, pitchEnv;

    pitchEnv = EnvGen.kr(Env.perc(0.001, 0.06), levelScale: 100);
    sig = SinOsc.ar(freq + pitchEnv);
    sig = (sig * drive).tanh;
    env = EnvGen.kr(Env.perc(0.003, decay), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// 808-style sub kick
SynthDef(\gqomSub, {
    |out = 0, amp = 0.7, freq = 40, decay = 0.5|
    var sig, env, pitchEnv;

    pitchEnv = EnvGen.kr(Env.perc(0.001, 0.1), levelScale: 30);
    sig = SinOsc.ar(freq + pitchEnv);
    sig = sig + (SinOsc.ar(freq * 2) * 0.2);
    env = EnvGen.kr(Env.perc(0.01, decay, 1, -4), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// ============================================================================
// SNARE/CLAP SYNTHS
// ============================================================================

// Gqom snare - thuddy, not crisp
SynthDef(\gqomSnare, {
    |out = 0, amp = 0.5, freq = 180, decay = 0.15, noiseAmt = 0.6|
    var sig, noise, env, toneEnv;

    // Tone component
    toneEnv = EnvGen.kr(Env.perc(0.001, 0.05));
    sig = SinOsc.ar(freq) * toneEnv;

    // Noise component (filtered)
    noise = BPF.ar(WhiteNoise.ar, 1200, 0.8) * noiseAmt;

    sig = sig + noise;
    env = EnvGen.kr(Env.perc(0.005, decay), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// Clap
SynthDef(\gqomClap, {
    |out = 0, amp = 0.4, decay = 0.12|
    var sig, env, delays;

    // Multiple short noise bursts
    sig = WhiteNoise.ar;
    sig = BPF.ar(sig, 1500, 0.5);

    // Characteristic clap "spread"
    delays = [0, 0.008, 0.015, 0.022].collect { |del|
        DelayN.ar(sig, 0.05, del) * EnvGen.kr(Env.perc(0.001, 0.02))
    }.sum;

    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

    Out.ar(out, (delays * env * amp) ! 2);
}).add;

// ============================================================================
// TOM SYNTHS
// ============================================================================

// Deep tom for rolls
SynthDef(\gqomTom, {
    |out = 0, amp = 0.5, freq = 100, decay = 0.2|
    var sig, env, pitchEnv;

    pitchEnv = EnvGen.kr(Env.perc(0.001, 0.04), levelScale: freq * 0.5);
    sig = SinOsc.ar(freq + pitchEnv);
    sig = sig + (SinOsc.ar(freq * 1.5) * 0.3);
    sig = (sig * 1.5).tanh;
    env = EnvGen.kr(Env.perc(0.005, decay), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// High tom
SynthDef(\gqomTomHi, {
    |out = 0, amp = 0.4, freq = 180, decay = 0.12|
    var sig, env, pitchEnv;

    pitchEnv = EnvGen.kr(Env.perc(0.001, 0.03), levelScale: freq * 0.3);
    sig = SinOsc.ar(freq + pitchEnv);
    sig = (sig * 1.3).tanh;
    env = EnvGen.kr(Env.perc(0.003, decay), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// ============================================================================
// HI-HAT SYNTHS
// ============================================================================

// Sparse closed hat
SynthDef(\gqomHat, {
    |out = 0, amp = 0.25, decay = 0.05|
    var sig, env;

    sig = WhiteNoise.ar;
    sig = HPF.ar(sig, 7000);
    sig = BPF.ar(sig, 10000, 0.3);
    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// ============================================================================
// DARK PAD/STRING SYNTHS
// ============================================================================

// The essential gqom dark string pad
SynthDef(\gqomPad, {
    |out = 0, freq = 55, amp = 0.3, attack = 2.5, release = 4,
     cutoff = 600, res = 0.3, detune = 0.008, pan = 0, gate = 1|
    var sig, env, filt;

    // Layered detuned saws for thickness
    sig = Mix([
        Saw.ar(freq * [1, 1 + detune]),
        Saw.ar(freq * 2 * [1, 1 - detune]) * 0.5,
        Pulse.ar(freq * 0.5, 0.3) * 0.4
    ]);

    // Slow subtle movement
    sig = sig + (SinOsc.ar(freq * 0.5) * 0.1);

    // Dark low-pass filtering
    filt = RLPF.ar(sig, cutoff + LFNoise1.kr(0.2).range(-100, 100), res);

    // Slow envelope
    env = EnvGen.kr(
        Env.asr(attack, 1, release, \sine),
        gate,
        doneAction: 2
    );

    Out.ar(out, Pan2.ar(filt * env * amp, pan));
}).add;

// Drone pad (even more minimal)
SynthDef(\gqomDrone, {
    |out = 0, freq = 55, amp = 0.25, cutoff = 400, pan = 0, gate = 1|
    var sig, env;

    sig = Saw.ar(freq * [1, 1.003]) + Pulse.ar(freq * 0.5, 0.4) * 0.5;
    sig = LPF.ar(sig, cutoff);
    sig = sig.sum * 0.5;
    env = EnvGen.kr(Env.asr(3, 1, 5), gate, doneAction: 2);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// Eerie string stab
SynthDef(\gqomStab, {
    |out = 0, freq = 110, amp = 0.4, decay = 0.3, cutoff = 1200, pan = 0|
    var sig, env;

    sig = Saw.ar(freq * [1, 1.01, 2]) + Pulse.ar(freq, 0.5) * 0.5;
    sig = RLPF.ar(sig.sum, cutoff, 0.4);
    env = EnvGen.kr(Env.perc(0.01, decay), doneAction: 2);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// ============================================================================
// VOCAL/SAMPLE TREATMENT
// ============================================================================

// Vocal chop effect (for use with buffers)
SynthDef(\gqomVocalChop, {
    |out = 0, buf, rate = 1, start = 0, dur = 0.2,
     amp = 0.5, pan = 0, delayMix = 0.3, delayTime = 0.25|
    var sig, env, delayed;
    var frames = BufFrames.kr(buf);

    sig = PlayBuf.ar(
        1, buf,
        rate * BufRateScale.kr(buf),
        startPos: start * frames,
        loop: 0
    );

    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = sig * env;

    // Characteristic gqom delay
    delayed = CombL.ar(sig, 0.5, delayTime, 1.5);
    sig = (sig * (1 - delayMix)) + (delayed * delayMix);

    Out.ar(out, Pan2.ar(sig * amp, pan));
}).add;

// Synthetic vocal texture (no sample needed)
SynthDef(\gqomVocalSynth, {
    |out = 0, freq = 200, amp = 0.3, dur = 0.5, pan = 0,
     formant1 = 600, formant2 = 1200|
    var sig, env, form1, form2;

    sig = Pulse.ar(freq, 0.3) + Saw.ar(freq * 1.01) * 0.5;

    form1 = BPF.ar(sig, formant1, 0.1) * 2;
    form2 = BPF.ar(sig, formant2, 0.15) * 1.5;

    sig = form1 + form2;
    sig = LPF.ar(sig, 3000);

    env = EnvGen.kr(Env.perc(0.02, dur), doneAction: 2);

    Out.ar(out, Pan2.ar(sig * env * amp, pan));
}).add;

// ============================================================================
// UTILITY SYNTHS
// ============================================================================

// Simple sine for testing
SynthDef(\gqomSine, {
    |out = 0, freq = 440, amp = 0.3, dur = 1|
    var sig = SinOsc.ar(freq);
    var env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    Out.ar(out, (sig * env * amp) ! 2);
}).add;

// ============================================================================
// PATTERN PLAYERS
// ============================================================================

// Play a pattern array as kicks
~playKickPattern = { |pattern, clock, synthName = \gqomKick, amp = 0.8|
    Pbind(
        \instrument, synthName,
        \dur, 0.25,
        \amp, Pseq(pattern, inf) * amp,
        \freq, 45
    ).play(clock);
};

// Play snare pattern
~playSnarePattern = { |pattern, clock, amp = 0.5|
    Pbind(
        \instrument, \gqomSnare,
        \dur, 0.25,
        \amp, Pseq(pattern, inf) * amp
    ).play(clock);
};

// ============================================================================
// ENERGY/STRUCTURE HELPERS
// ============================================================================

// Energy envelope for track sections
~gqomEnergy = { |section|
    switch(section,
        \intro, { 0.4 },
        \build, { 0.6 },
        \drop, { 1.0 },
        \breakdown, { 0.5 },
        \outro, { 0.3 }
    );
};

// Element sets per section
~gqomElements = { |section|
    switch(section,
        \intro, { [\pad] },
        \build, { [\pad, \hatSparse, \snare] },
        \drop, { [\pad, \kick, \snare, \tom] },
        \breakdown, { [\pad, \vocal] },
        \outro, { [\pad, \kickSparse] }
    );
};

// ============================================================================
// INITIALIZATION
// ============================================================================
// Note: SynthDefs use .add which is asynchronous - they'll be ready shortly after load

"".postln;
"============================================".postln;
"  Gqom Core Library Loaded".postln;
"============================================".postln;
"".postln;
"RHYTHM PATTERNS (16-step):".postln;
"  ~gqomTwoStep1, ~gqomTwoStep2".postln;
"  ~gqomBroken1, ~gqomBroken2, ~gqomBroken3".postln;
"  ~gqomTresillo (8-step), ~gqomThreeStep (12-step)".postln;
"  ~gqomSnare1, ~gqomSnare2, ~gqomClap1".postln;
"".postln;
"PATTERN UTILITIES:".postln;
"  ~generateBrokenBeat.(steps, density, avoidDownbeat)".postln;
"  ~tomRoll.(steps, startVel, endVel)".postln;
"  ~shiftPattern.(pattern, amount)".postln;
"  ~combinePatterns.(p1, p2)".postln;
"".postln;
"SYNTHDEFS - DRUMS:".postln;
"  \\gqomKick - heavy distorted kick".postln;
"  \\gqomKickLight - lighter variant".postln;
"  \\gqomSub - 808-style sub".postln;
"  \\gqomSnare - thuddy snare".postln;
"  \\gqomClap - layered clap".postln;
"  \\gqomTom, \\gqomTomHi - toms for rolls".postln;
"  \\gqomHat - sparse hi-hat".postln;
"".postln;
"SYNTHDEFS - ATMOSPHERE:".postln;
"  \\gqomPad - dark string pad".postln;
"  \\gqomDrone - minimal drone".postln;
"  \\gqomStab - eerie stab".postln;
"  \\gqomVocalSynth - synthetic vocal texture".postln;
"".postln;
"EFFECTS:".postln;
"  ~gqomReverbBus, \\gqomReverb".postln;
"  ~gqomDelayBus, \\gqomDelay".postln;
"".postln;
"TEMPO:".postln;
"  ~gqomTempoStandard (120), ~gqomTempo3Step (115)".postln;
"  ~gqomTempoTech (135)".postln;
"============================================".postln;
)
