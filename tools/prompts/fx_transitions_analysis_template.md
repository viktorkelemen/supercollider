# SuperCollider FX & Transitions Recreation Prompt

Use this template to recreate analyzed sound effects, transitions, risers, impacts, and one-shot FX in SuperCollider.
Best for: risers, drops, impacts, sweeps, whooshes, glitches, transitions, stingers.

---

## Sound Type Classification

### Primary Category
- [ ] **Riser/Build** - Increasing energy/pitch leading to climax
- [ ] **Drop/Fall** - Decreasing pitch/energy after climax
- [ ] **Impact/Hit** - Single transient moment (boom, slam, thud)
- [ ] **Sweep** - Filtered movement through frequency spectrum
- [ ] **Whoosh** - Movement through space (fast transient)
- [ ] **Glitch** - Digital artifacts, stutters, malfunctions
- [ ] **Stinger/Sting** - Short attention-grabbing accent
- [ ] **Ambient FX** - Environmental, atmospheric one-shot

### Function
- **Musical context**: [intro/buildup/drop/breakdown/transition/ending]
- **Energy direction**: [building/releasing/static/chaotic]
- **Tension level**: [subtle/moderate/intense/extreme]

---

## Temporal Profile

### Duration & Shape
- **Total duration**: [seconds]
- **Shape**: [linear/exponential/logarithmic/S-curve/custom]
- **Phases**: [single arc/multiple stages - describe each]

### Amplitude Envelope
- **Attack**: [ms/instant]
- **Peak position**: [% through duration]
- **Decay/release shape**: [description]
- **Tail**: [none/short/long reverb tail]

### Timing Markers
- **Key moments**: [list timestamps of significant changes]
- **Climax point**: [seconds from start]

---

## Pitch Content

### Pitch Movement
- **Start pitch**: [Hz/note]
- **End pitch**: [Hz/note]
- **Direction**: [rising/falling/static/bidirectional/chaotic]
- **Range**: [octaves]
- **Curve**: [linear/exponential/logarithmic]

### Pitch Character
- **Tonal/noise ratio**: [tonal/mostly tonal/mixed/mostly noise/noise]
- **Harmonic content**: [sine/complex/inharmonic/noise-based]
- **Pitch stability**: [stable/wobbling/vibrato/random]

### Additional Pitch Elements
- **Sub layer**: [present/absent] - [Hz if present]
- **High layer**: [present/absent] - [Hz range if present]
- **Pitch LFO**: [rate, depth] or [none]

---

## Spectral Movement

### Filter Sweep
- **Start frequency**: [Hz]
- **End frequency**: [Hz]
- **Filter type**: [lowpass/highpass/bandpass]
- **Resonance**: [none/subtle/pronounced/screaming]
- **Sweep curve**: [linear/exponential/stepped]

### Spectral Density
- **Start density**: [thin/moderate/thick]
- **End density**: [thin/moderate/thick]
- **Bandwidth evolution**: [narrowing/widening/static]

### Noise Content
- **Noise amount**: [none/subtle/moderate/dominant]
- **Noise type**: [white/pink/digital/custom]
- **Noise movement**: [static/filtered sweep/burst]

---

## Modulation & Movement

### Rate Changes
- **LFO start rate**: [Hz]
- **LFO end rate**: [Hz]
- **Rate curve**: [accelerating/decelerating/static]

### Intensity Changes
- **Modulation depth start**: [amount]
- **Modulation depth end**: [amount]
- **Destinations**: [pitch/filter/amplitude/other]

### Rhythmic Elements
- **Pulsing**: [none/subtle/prominent]
- **Pulse rate**: [Hz or BPM]
- **Pulse acceleration**: [none/speeding up/slowing down]
- **Stutter/glitch**: [none/occasional/intense]

---

## Stereo & Space

### Width
- **Start width**: [mono/narrow/wide]
- **End width**: [mono/narrow/wide]
- **Width movement**: [expanding/contracting/static]

### Spatial Movement
- **Panning**: [static/sweeping/random]
- **Rotation**: [none/slow/fast]

### Reverb/Space
- **Reverb amount**: [dry/subtle/moderate/washed]
- **Reverb evolution**: [static/increasing/decreasing]
- **Pre-delay**: [ms]
- **Decay time**: [seconds]

---

## Processing & Character

### Distortion
- **Type**: [none/soft saturation/hard clip/bitcrush/foldback]
- **Amount**: [subtle/moderate/heavy]
- **Evolution**: [static/increasing/decreasing]

### Special Processing
- **Granular**: [none/subtle/heavy]
- **Spectral**: [freeze/smear/blur]
- **Glitch**: [stutter rate, probability]
- **Ring mod**: [frequency if present]

---

## SuperCollider Synthesis Approach

### Recommended Techniques
- [ ] Oscillator + filter sweep
- [ ] Noise + resonant filter
- [ ] FM with changing ratios
- [ ] Granular with changing rate
- [ ] Layered sines with beating
- [ ] Feedback network
- [ ] Buffer scratching/manipulation

### Suggested UGens
```supercollider
// Oscillators:
SinOsc, Saw, Pulse, LFSaw, SyncSaw
VarSaw, LFPulse, Blip

// Noise:
WhiteNoise, PinkNoise, ClipNoise
Dust, Crackle, LFNoise0/1/2

// Filters (for sweeps):
RLPF, RHPF, BPF, Resonz
MoogFF, BLowPass4, BMoog

// Envelopes (crucial for FX):
EnvGen, Env.new, Line, XLine
Env.perc, Env.linen

// Modulation:
SinOsc.kr, LFSaw.kr, LFTri.kr
Line.kr, XLine.kr (for sweeps)
Sweep (for linear ramps)

// Special:
PitchShift, FreqShift
Ringz, Formlet, Klank
CombL, AllpassL (for metallic)
```

---

## Analysis Commands

```bash
# Pitch contour visualization
ffmpeg -i "file.wav" -lavfi "showspectrumpic=s=1920x256:scale=log" -y /tmp/pitch_contour.png

# Amplitude envelope
ffmpeg -i "file.wav" -af "astats=metadata=1:reset=50,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" -f null - 2>/dev/null

# Peak detection (for impacts)
ffmpeg -i "file.wav" -af "astats=metadata=1:reset=10,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=-" -f null - 2>/dev/null | head -100

# Spectral centroid (brightness over time)
ffmpeg -i "file.wav" -af "aspectralstats=measure=centroid,ametadata=print:file=-" -f null - 2>/dev/null

# Duration
ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "file.wav"
```

### SuperCollider Analysis
```supercollider
// Track pitch over time (for risers/falls)
(
SynthDef(\trackPitch, {
    var sig, freq, hasFreq;
    sig = PlayBuf.ar(1, b, doneAction: 2);
    # freq, hasFreq = Pitch.kr(sig);
    freq.poll(20, "Pitch");
}).play;
)

// Track amplitude envelope
(
SynthDef(\trackAmp, {
    var sig, amp;
    sig = PlayBuf.ar(1, b, doneAction: 2);
    amp = Amplitude.kr(sig, 0.01, 0.1);
    amp.poll(20, "Amp");
}).play;
)
```

---

## Example Analyses

### Example 1: Riser
**Source**: riser_8bar.wav (4 seconds)

**Temporal Profile:**
- Duration: 4 seconds
- Shape: Exponential rise
- Climax: Final 200ms

**Pitch Content:**
- Start: 80 Hz
- End: 2500 Hz
- Curve: Exponential
- Additional: White noise layer increasing

**Filter:**
- Start cutoff: 200 Hz
- End cutoff: 8000 Hz
- Resonance: Increasing from 0.2 to 0.8

**Modulation:**
- LFO rate: 2 Hz → 20 Hz (accelerating)
- Depth: Increasing

```supercollider
SynthDef(\riser, {
    arg out = 0, dur = 4, startFreq = 80, endFreq = 2500, amp = 0.4;
    var sig, env, pitch, filt, lfoRate, lfo, noise;

    env = EnvGen.kr(Env([0, 1, 0], [dur * 0.95, dur * 0.05], [4, -4]), doneAction: 2);

    // Exponential pitch rise
    pitch = XLine.kr(startFreq, endFreq, dur);

    // Accelerating LFO
    lfoRate = XLine.kr(2, 20, dur);
    lfo = SinOsc.kr(lfoRate, 0, 0.5, 1);

    // Main oscillator
    sig = Saw.ar(pitch * lfo) * 0.3;

    // Rising noise layer
    noise = WhiteNoise.ar * Line.kr(0, 0.3, dur);

    sig = sig + noise;

    // Opening filter with rising resonance
    filt = XLine.kr(200, 8000, dur);
    sig = RLPF.ar(sig, filt, Line.kr(0.5, 0.1, dur));

    Out.ar(out, sig ! 2 * env * amp);
}).add;
```

### Example 2: Impact
**Source**: impact_hit.wav (1.5 seconds)

**Temporal Profile:**
- Duration: 1.5 seconds (mostly tail)
- Attack: Instant (<5ms)
- Peak: At start
- Tail: Reverb decay

**Pitch Content:**
- Initial: Pitched thump at 50 Hz
- Decay: Pitch drops to 30 Hz over 100ms
- Layers: Sub hit + mid crack + high transient

**Processing:**
- Heavy compression on transient
- Large reverb on tail

```supercollider
SynthDef(\impact, {
    arg out = 0, amp = 0.5;
    var sub, mid, high, sig, env;

    // Sub layer - pitched drop
    sub = SinOsc.ar(XLine.kr(50, 30, 0.1)) * EnvGen.kr(Env.perc(0.001, 0.4, 1, -8));

    // Mid crack
    mid = BPF.ar(WhiteNoise.ar, 400, 0.3) * EnvGen.kr(Env.perc(0.001, 0.08, 1, -6));

    // High transient
    high = HPF.ar(WhiteNoise.ar, 3000) * EnvGen.kr(Env.perc(0.001, 0.02, 0.5, -8));

    sig = (sub * 0.6) + (mid * 0.3) + (high * 0.2);

    // Add reverb tail
    sig = sig + FreeVerb.ar(sig, 0.8, 0.9, 0.3);

    env = EnvGen.kr(Env.perc(0.001, 1.5), doneAction: 2);

    Out.ar(out, sig ! 2 * env * amp);
}).add;
```

---

## LLM Prompt Template

```
Recreate this sound effect in SuperCollider:

TYPE: [riser/drop/impact/sweep/whoosh/glitch/stinger]
DURATION: [seconds]
FUNCTION: [buildup/release/accent/transition]

PITCH:
- Start: [Hz]
- End: [Hz]
- Curve: [linear/exponential/logarithmic]
- Character: [tonal/noisy/mixed]

FILTER:
- Movement: [opening/closing/sweep direction]
- Range: [Hz] to [Hz]
- Resonance: [amount and evolution]

MODULATION:
- LFO rate: [start Hz] to [end Hz]
- Rate change: [accelerating/decelerating/static]
- Depth: [evolution description]

LAYERS:
- Sub: [description or none]
- Mid: [description or none]
- High: [description or none]

PROCESSING:
- Distortion: [type and amount]
- Reverb: [amount and character]
- Special: [any unique processing]

Create a self-terminating SynthDef (doneAction: 2) that plays the complete effect.
Use Line.kr or XLine.kr for parameter sweeps. Layer multiple elements for complexity.
```
