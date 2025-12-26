# Gqom Music Research

A comprehensive guide for creating SuperCollider experiments based on Gqom, the dark electronic dance music from Durban, South Africa.

---

## Table of Contents

1. [Historical Overview](#historical-overview)
2. [Musical Characteristics](#musical-characteristics)
3. [Rhythm Patterns](#rhythm-patterns)
4. [Sound Design Elements](#sound-design-elements)
5. [Song Structure](#song-structure)
6. [Production Techniques](#production-techniques)
7. [Subgenres & Variations](#subgenres--variations)
8. [Key Artists](#key-artists)
9. [Listening References](#listening-references)
10. [Implementation Notes](#implementation-notes)

---

## Historical Overview

### Origins (Early 2010s)

**Gqom** (pronounced with a click: "NQU-om") emerged in the early 2010s from Durban's townships, particularly informal settlements like Umlazi, KwaMashu, and Clermont.

- **Etymology**: Onomatopoeic Zulu word mimicking the sound of a kick drum - "hitting drum," "ricochet," or "bang"
- **First producers**: Naked Boyz, Rudeboyz, Sbucardo, Griffit Vigo, DJ Lag, Citizen Boy
- **Production tools**: Cracked copies of FL Studio on basic home computers
- **Distribution**: Tracks shared via USB drives, taxi speakers, WhatsApp groups, and Facebook communities like "IGqomu"

### The Taxi Connection

Minibus taxis (the primary public transport in South African townships) became crucial to Gqom's spread:

- Drivers loaded tracks from USB drives
- Sound systems in taxis exposed commuters to hypnotic beats
- "Woza Taxi" documentary captures this phenomenon
- Taxi routes became informal radio networks

### Evolution of a Genre

**Pre-Gqom Influences**:
- **Kwaito** (1990s Soweto): Slowed-down house with township attitude
- **Sgxumseni**: Older Durban style meaning "make us jump" - four-step pattern that gqom's broken beat evolved from
- **Durban kwaito**: Faster, more aggressive regional variant

**Timeline**:
- **2010-2012**: Underground emergence in townships
- **2013-2014**: DJ Lag coins "Gqom" for the sound
- **2015-2016**: International attention via Nan Kolé's Gqom Oh! compilation
- **2017**: Distruction Boyz's "Omunye" goes viral (1 billion+ streams)
- **2018-2020**: Beyoncé collaborates with DJ Lag on "My Power" (Black Is King)
- **2020s**: 3-step subgenre emerges; genre influences global electronic music

### Cultural Context

Gqom reflects Durban's specific character:
- Industrial port city atmosphere
- Economic hardship in townships
- Resilience and creativity from limited resources
- Different from Johannesburg's house music scene
- Night culture in the townships (all-night parties)

---

## Musical Characteristics

### Core Aesthetic

Gqom is defined by what it *doesn't* have as much as what it does:

| Element | Gqom Approach |
|---------|---------------|
| Melody | Minimal to none - mood over tune |
| Harmony | Static drones, single-note strings |
| Rhythm | Syncopated, broken, hypnotic |
| Texture | Sparse, raw, industrial |
| Energy | Perpetual tension - build without release |

### The "Never-Drop" Tension

Unlike EDM with its build-up/drop structure, Gqom creates:
- Continuous build-up feeling
- The menace of a drop that never fully comes
- Trance-inducing through sustained tension
- Similar tension to grime and early dubstep

### Tempo Range

| Variant | BPM Range | Character |
|---------|-----------|-----------|
| Traditional Gqom | 110-125 | Heavy, slow stomp |
| Standard | 125-128 | Mid-energy, hypnotic |
| Gqom Tech | 130-140 | Urgent, aggressive |
| 3-Step | 110-120 | Relaxed, spacious |

### Defining Sound Characteristics

1. **Heavy, Dark Bass**
   - Deep, aggressive kick drums
   - Sub-bass presence without overwhelming
   - Noisy, industrial edge

2. **Spooky Atmosphere**
   - Eerie string drones
   - Haunting vocal samples (chopped, repeated)
   - Spacious reverb creating emptiness

3. **Percussive Emphasis**
   - Cascading tom and snare rolls
   - Syncopated rhythms that trick the ear
   - Off-beats that feel like on-beats

4. **Vocal Treatment**
   - Sliced, repeated samples
   - Atmospheric rather than lyrical
   - Zulu chants and whistles
   - Echo and delay processing

---

## Rhythm Patterns

### The Non-Four-On-The-Floor Foundation

Unlike house music, Gqom deliberately **avoids** the predictable kick on every beat:

```
Traditional House:  X . . . | X . . . | X . . . | X . . .
                    1 2 3 4   1 2 3 4   1 2 3 4   1 2 3 4

Gqom (broken):     X . . X | . X . . | X . . X | . . X .
                   1 2 3 4   1 2 3 4   1 2 3 4   1 2 3 4
```

### Step Patterns

**1. Two-Step Pattern**
```
Kick:    X . . . | . . X . | X . . . | . . X .
Snare:   . . X . | . . . X | . . X . | . . . X
         1 2 3 4   1 2 3 4   1 2 3 4   1 2 3 4
```

**2. Three-Step Pattern (3-Step)**
The term coined by Sbucardo and Citizen Boy - beats arranged in groups of three:
```
Kick:    X . . | X . . | X . . | X . .
         1 2 3   1 2 3   1 2 3   1 2 3
```
Creates a perpetual rolling feel, never landing on 4.

**3. Four-Step (Sgubhu variant)**
More aligned with traditional house:
```
Kick:    X . . . | X . . . | X . . . | X . . .
         1 2 3 4   1 2 3 4   1 2 3 4   1 2 3 4
```

### Syncopation Techniques

**Off-Beat Dominance**:
- Off-beats are so emphasized they feel like on-beats
- Listener's perception of "1" becomes confused
- Creates hypnotic, trance-inducing effect

**Tresillo Rhythm** (Core Tribe Gqom):
```
X . . X | . . X . | X . . X | . . X .
3 + 3 + 2 pattern (common in Afro-Latin music)
```

### Percussion Layering

| Element | Role | Pattern Character |
|---------|------|-------------------|
| Kick | Foundation | Broken, unpredictable |
| Snare | Punctuation | Off-beat accents |
| Claps | Energy | Layered with snare |
| Toms | Movement | Cascading rolls |
| Hi-hats | Texture | Sparse or absent |
| Shakers | Flow | When present, subtle |

### The Tom Roll

A signature Gqom element - cascading tom hits that build tension:
```
Tom pattern (16th notes, velocities vary):
. . x . | x . x X | . x X x | X X X X
        (crescendo roll building)
```

---

## Sound Design Elements

### 1. The Kick Drum

**Characteristics**:
- Deep, noisy, industrial
- Aggressive thuds with sub-bass component
- Often distorted or clipped
- Slower attack than typical house kick

**Processing**:
- Heavy compression
- Saturation/distortion
- Low-pass filter to emphasize sub
- Transient shaping for punch

### 2. Dark Strings & Pads

The "dark strings" are essential to Gqom's haunting atmosphere:

**Characteristics**:
- Minor key pads
- Single-note or octave drones
- Long attack, long release (ADSR)
- Creates cinematic, eerie mood

**Processing**:
- Low-pass filtering
- Slow chorus/detune
- Deep reverb
- Subtle automation/movement

**Citizen Boy's Approach**:
> "The first thing I do, I usually start with samples, like vocals and stuff... And then, put my usual dark strings. That's what sets the tone of the song and sets the mood of the song."

### 3. Vocal Samples

**Types**:
- Zulu chants
- Whispered phrases
- Tribal vocalizations
- Pitched-down speech

**Treatment**:
- Heavy chopping/slicing
- Repetition (loop small fragments)
- Echo/delay for space
- Atmospheric placement

### 4. Synth Stabs

**Characteristics**:
- Punchy, rhythmic
- Often in minor key
- Short duration
- Provide movement without melody

### 5. Bass Elements

**Layering Approach**:
- Sub-bass (sine wave, very low)
- Mid-bass (adds character)
- Kick and bass relationship is crucial

---

## Song Structure

### The Extended Build

Gqom tracks are typically **long** (5-8+ minutes) with minimal harmonic movement:

```
Typical Structure:

Intro (8-16 bars)
├── Light percussion
├── Atmospheric pads enter
└── Building anticipation

Build-up (16-32 bars)
├── Drums gradually added
├── Synths layer in
├── Vocal samples appear
└── Energy increases

Drop/Main Section (32+ bars)
├── Full drum patterns
├── Heavy bass engaged
├── Peak energy maintained
└── Variations through subtraction/addition

Breakdown (8-16 bars)
├── Stripped back elements
├── Maintains tension
└── Sets up next drop

[Repeat Drop/Breakdown cycle]

Outro
└── Gradual element removal
```

### Harmonic Stasis

Unlike Western pop/electronic music:
- Single chord or drone throughout entire track
- Movement comes from rhythm, not harmony
- Tension from texture and dynamics, not chord progressions
- Harmonically "flat" but rhythmically rich

### Energy Through Subtraction

Gqom creates dynamics by **removing** elements rather than always adding:
- Drop the kick for tension
- Strip to just vocals
- Leave space (silence is powerful)
- Return elements for impact

---

## Production Techniques

### The FL Studio Approach

Most Gqom is made in FL Studio due to:
- Accessibility (cracked software in townships)
- Intuitive step sequencer for broken beats
- Quick workflow (DJ Lag: "an hour or two to make a track")
- Pattern-based arrangement suits the style

### Production Order (Citizen Boy Method)

1. **Vocals/Samples first** - Set the mood
2. **Dark strings** - Establish atmosphere
3. **Snares/Claps** - Rhythmic skeleton
4. **Kick last** - "I don't focus on the kick, I focus more on the sounds"

### Key Production Principles

| Principle | Implementation |
|-----------|---------------|
| Raw over polished | Don't over-produce; grit is authentic |
| Space over density | Let sounds breathe |
| Mood over melody | Atmosphere is everything |
| Loop-based | Hypnosis through repetition |
| Syncopation | Avoid predictable rhythms |

### Effects & Processing

**Essential Effects**:
- Reverb (large, dark spaces)
- Delay/Echo (especially on vocals)
- Compression (heavy on drums)
- Distortion (on kicks, bass)
- Low-pass filter (dark character)

**Avoid**:
- Excessive high frequencies
- Overly clean production
- Complex automation
- Melodic complexity

---

## Subgenres & Variations

### 1. Sgubhu

**Characteristics**:
- Broken/stuttering kick drums
- ~123-124 BPM typically
- Heavy tribal percussion
- More aggressive than standard gqom

### 2. 3-Step

**Characteristics**:
- Pioneered by Emo Kid, DJ Lag, Ben Myster, Menzi
- ~110-120 BPM (feels slower)
- Jazz-like, freeform feel
- Broken beat with amapiano influences
- More spacious and relaxed
- Emerged late 2010s/early 2020s

### 3. Core Tribe Gqom

**Characteristics**:
- Frequent triplets (tresillo rhythm)
- Blended percussion patterns
- Tribal vocalizations prominent
- Drums over melodies (syncopation focus)

### 4. Gqom Tech

**Characteristics**:
- Faster tempos (130+ BPM)
- Acid-tinged bass elements (303-style)
- More European techno influence
- Darker, more industrial

### 5. Durban Gqom vs. International Gqom

| Aspect | Township Original | International |
|--------|------------------|---------------|
| Production | Raw, minimal | Often more polished |
| Tempo | Variable | Usually 120-128 |
| Purpose | Dance floor | Club/festival |
| Distribution | USB/taxi | Streaming |

---

## Key Artists

### Pioneers

| Artist | Contribution |
|--------|--------------|
| **DJ Lag** | "Gqom King" - coined the genre name, international ambassador, worked with Beyoncé |
| **Citizen Boy** | Started producing at 14, co-coined "three-step" term, emphasizes sounds over kicks |
| **Naked Boyz** | Early pioneers |
| **Rudeboyz** | Founding producers |
| **Sbucardo** | Co-coined "three-step", early innovator |
| **Griffit Vigo** | Dark, minimal pioneer |

### Key Figures

| Artist | Style/Known For |
|--------|-----------------|
| **Distruction Boyz** | Mainstream breakthrough ("Omunye") |
| **Babes Wodumo** | Brought vocal element to gqom |
| **DJ Tira** | Gqom-adjacent, Durban house legend |
| **Menzi** | 3-step development |
| **Emo Kid** | 3-step innovation |
| **Ben Myster** | 3-step pioneer |

### International Platform

| Platform/Label | Role |
|----------------|------|
| **Gqom Oh!** | Nan Kolé's label that brought gqom to international attention |
| **Hyperdub** | DJ Rashad connection, UK platform |
| **Black Major** | Johannesburg label supporting the scene |

---

## Listening References

### Essential Tracks

**DJ Lag**:
- "Ice Drop"
- "Khongela" (with Moonchild Sanelly)
- "My Power" (Beyoncé collab)

**Citizen Boy**:
- Early Gqom Classics (Bandcamp)

**Distruction Boyz**:
- "Omunye" (Phezu Kwamanye)
- "Shut Up & Groove"

**Various**:
- "Gqom Oh! The Sound of Durban" compilation (essential starting point)
- "Sgubhu" DJ mixes for authentic township sound

### YouTube/SoundCloud Searches

- "Gqom mix 2024"
- "Sgubhu mix"
- "3 step gqom"
- "Durban gqom taxi"
- "DJ Lag essential mix"

### Characteristics to Listen For

| Element | What to Notice |
|---------|---------------|
| Kick pattern | When does it hit? Where are the gaps? |
| Tension | How is build-up created without drops? |
| Vocals | How are they chopped and repeated? |
| Strings | What mood do they create? |
| Space | How much silence is there? |
| Loop length | How long before patterns change? |

---

## Implementation Notes

### For SuperCollider Experiments

#### Tempo & Time

```supercollider
// Standard Gqom tempo
~gqomTempo = TempoClock(120/60);  // 120 BPM

// 3-step feels slower
~threeStepTempo = TempoClock(115/60);
```

#### Kick Patterns

```supercollider
// Two-step broken pattern (16 steps)
~twoStep = [1,0,0,0, 0,0,1,0, 1,0,0,0, 0,0,1,0];

// Three-step pattern (12 steps = 3+3+3+3)
~threeStep = [1,0,0, 1,0,0, 1,0,0, 1,0,0];

// Syncopated gqom kick (16 steps)
~gqomKick = [1,0,0,1, 0,1,0,0, 1,0,0,1, 0,0,1,0];

// Tresillo pattern (8 steps)
~tresillo = [1,0,0,1, 0,0,1,0];  // 3+3+2
```

#### Snare/Clap Patterns

```supercollider
// Off-beat snare emphasis
~gqomSnare = [0,0,1,0, 0,0,0,1, 0,0,1,0, 0,0,0,1];

// Sparse claps
~gqomClap = [0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,1];
```

#### Tom Roll Generator

```supercollider
// Cascading tom roll with increasing velocity
~tomRoll = { |steps = 8|
    var vels = Array.series(steps, 0.3, 0.1);
    var pattern = Array.fill(16, 0);
    (16 - steps..15).do { |i, j|
        pattern[i] = vels[j]
    };
    pattern
};
```

#### Dark String Pad

```supercollider
// Gqom dark string synth
SynthDef(\gqomPad, {
    |out = 0, freq = 55, amp = 0.3, attack = 2, release = 4,
     cutoff = 800, res = 0.3, pan = 0|
    var sig, env, filt;

    // Layered oscillators for thickness
    sig = Mix([
        Saw.ar(freq * [1, 1.002]),      // Slight detune
        Saw.ar(freq * 2 * [1, 0.998]),  // Octave up
        Pulse.ar(freq * 0.5, 0.3) * 0.3 // Sub octave
    ]);

    // Dark filtering
    filt = RLPF.ar(sig, cutoff, res);

    // Slow envelope
    env = EnvGen.kr(
        Env.asr(attack, 1, release),
        doneAction: 2
    );

    Out.ar(out, Pan2.ar(filt * env * amp, pan));
}).add;
```

#### Gqom Kick Synth

```supercollider
// Heavy, distorted gqom kick
SynthDef(\gqomKick, {
    |out = 0, amp = 0.8, freq = 50, decay = 0.3,
     drive = 2, click = 0.3|
    var sig, env, clickEnv;

    // Pitch envelope for thump
    var pitchEnv = EnvGen.kr(
        Env.perc(0.001, 0.1),
        levelScale: freq * 2
    );

    // Main body
    sig = SinOsc.ar(freq + pitchEnv);

    // Click transient
    clickEnv = EnvGen.kr(Env.perc(0.001, 0.02));
    sig = sig + (WhiteNoise.ar * clickEnv * click);

    // Distortion for grit
    sig = (sig * drive).tanh;

    // Amplitude envelope
    env = EnvGen.kr(
        Env.perc(0.005, decay),
        doneAction: 2
    );

    Out.ar(out, sig * env * amp ! 2);
}).add;
```

#### Vocal Chop Effect

```supercollider
// Chopped/repeated vocal sample effect
SynthDef(\vocalChop, {
    |out = 0, buf, rate = 1, start = 0, end = 0.1,
     amp = 0.5, delay = 0.3, feedback = 0.4|
    var sig, env, delayed;
    var dur = (end - start) * BufDur.kr(buf);

    sig = PlayBuf.ar(
        1, buf,
        rate * BufRateScale.kr(buf),
        startPos: start * BufFrames.kr(buf),
        loop: 1
    );

    // Gate to create chop effect
    env = EnvGen.kr(
        Env.perc(0.01, dur * 0.8),
        Impulse.kr(dur.reciprocal)
    );

    sig = sig * env;

    // Echo for atmosphere
    delayed = CombL.ar(sig, 0.5, delay, feedback * 4);
    sig = sig + (delayed * 0.5);

    Out.ar(out, sig * amp ! 2);
}).add;
```

#### Gqom Structure Pattern

```supercollider
// Energy envelope over track duration
~gqomEnergyEnv = Env(
    [0.3, 0.5, 0.8, 1.0, 0.6, 1.0, 0.4],  // energy levels
    [16, 32, 32, 16, 32, 16],               // bars
    \sine
);

// Element density control
~gqomDensity = { |section|
    switch(section,
        \intro, { [\pad, \sparse_perc] },
        \build, { [\pad, \perc, \vocal] },
        \drop,  { [\pad, \kick, \snare, \perc, \vocal] },
        \break, { [\pad, \vocal] }
    )
};
```

#### Timbre Targets

| Element | Approx. Centroid | Character |
|---------|-----------------|-----------|
| Sub kick | 40-80 Hz | Deep, felt more than heard |
| Main kick | 80-200 Hz | Punchy, distorted |
| Snare | 200-500 Hz | Thuddy, not crisp |
| Toms | 100-300 Hz | Deep, resonant |
| Dark strings | 200-800 Hz | Muffled, atmospheric |
| Vocals | 300-3000 Hz | Processed, ethereal |

#### Pattern Sequencer Concept

```supercollider
// Basic gqom pattern player
~gqomSequencer = { |patterns, tempo = 120|
    var clock = TempoClock(tempo/60);

    Pbind(
        \instrument, \gqomKick,
        \dur, 0.25,  // 16th notes
        \amp, Pseq(patterns[\kick], inf),
        \freq, 45
    ).play(clock);

    Pbind(
        \instrument, \gqomSnare,
        \dur, 0.25,
        \amp, Pseq(patterns[\snare], inf) * 0.6
    ).play(clock);
};
```

---

## Experiment Ideas

### Beginner

1. **Broken Beat Generator**: Create simple 2-step and 3-step kick patterns
2. **Dark Drone**: Synthesize the characteristic gqom string pad
3. **Kick Synthesis**: Build a heavy, distorted gqom kick from scratch

### Intermediate

4. **Tom Roll System**: Algorithmic cascading tom patterns with velocity curves
5. **Pattern Randomizer**: Generate gqom-style syncopated patterns algorithmically
6. **Vocal Chopper**: Sample manipulation system for atmospheric vocal loops
7. **Build-No-Drop**: Create tension without resolution through layering

### Advanced

8. **Full Gqom Track Generator**: Complete structure with intro, build, drop, breakdown
9. **3-Step Polyrhythm**: Complex triplet-based patterns with multiple percussion voices
10. **Taxi Speaker Simulation**: Lo-fi processing to emulate township sound system
11. **Live Gqom Performance System**: Real-time pattern manipulation tools

---

## Assessment Criteria

When evaluating Gqom experiments, consider:

| Criteria | Weight | What to Check |
|----------|--------|---------------|
| Rhythm authenticity | 1.5x | Broken beats, syncopation, off-beat emphasis |
| Atmosphere | 1.5x | Dark, tense, hypnotic mood |
| Kick character | 1.0x | Heavy, distorted, not clean |
| Space/sparseness | 1.0x | Room to breathe, not overcrowded |
| Tension maintenance | 1.0x | Energy without resolution |
| Tempo accuracy | 0.5x | 110-130 BPM range |
| Harmonic stasis | 0.5x | Minimal chord movement |

---

## Sources

### Articles & Features
- [Wikipedia - Gqom](https://en.wikipedia.org/wiki/Gqom)
- [The FADER - Get To Know Gqom](https://www.thefader.com/2015/10/02/gqom-durban-south-africa)
- [Fact Magazine - Gqom: A Deeper Look](https://www.factmag.com/2016/01/05/gqom-feature/)
- [Mixmag - Gqom Bursting Into Europe](https://mixmag.net/feature/gqom-is-the-south-african-sound-bursting-into-europe)
- [DJ Mag - Exciting Gqom Producers](https://djmag.com/features/these-are-most-exciting-gqom-producers-right-now)
- [Afropop Worldwide - Gqom Generation](https://afropop.org/audio-programs/the-gqom-generation-of-durban-south-africa)

### Production Resources
- [Afroplug - How to Make Gqom Beats](https://afroplug.com/how-to-make-gqom-beats/)
- [Splice - Massive Gqom Sample Pack](https://splice.com/sounds/packs/afroplug/massive-gqom/samples)

### Labels & Compilations
- [Gqom Oh! Label](https://gqomoh.bandcamp.com/)
- [Citizen Boy - Gqom Classics](https://citizenboysa.bandcamp.com/)

### Documentaries
- "Woza Taxi" - Documentary about gqom and taxi culture

---

*Last updated: December 2024*
