# SuperCollider Pads & Textures Recreation Prompt

Use this template to recreate analyzed pads, drones, ambient textures, and atmospheric sounds in SuperCollider.
Best for: synth pads, ambient drones, noise textures, soundscapes, evolving atmospheres.

---

## Sound Profile

### Spectral Characteristics
- **Frequency range**: [Hz] to [Hz]
- **Spectral density**: [sparse/moderate/dense/full]
- **Brightness**: [dark/neutral/bright]
- **Spectral balance**: [sub-heavy/balanced/top-heavy]
- **Harmonic vs noise content**: [tonal/mostly tonal/mixed/mostly noise/noise]

### Tonal Content (if present)
- **Root/fundamental**: [Hz/note] or [none/ambiguous]
- **Chord/harmony**: [type - maj/min/sus/cluster/atonal]
- **Interval content**: [unison/5ths/octaves/complex]
- **Detuning amount**: [cents]
- **Voice count**: [number of distinct layers]

### Noise/Texture Content
- **Noise type**: [white/pink/brown/digital/granular]
- **Noise filtering**: [bandpass center, bandwidth]
- **Grain size** (if granular): [ms]
- **Density**: [sparse/medium/dense]

---

## Temporal Evolution

### Overall Shape
- **Duration**: [seconds/continuous]
- **Amplitude contour**: [static/swelling/fading/breathing]
- **Fade in**: [seconds]
- **Fade out**: [seconds]
- **Dynamic range**: [static/subtle movement/dramatic swells]

### Spectral Movement
- **Filter movement**: [static/slow sweep/rhythmic/random]
- **Sweep rate**: [Hz or seconds per cycle]
- **Sweep range**: [octaves]
- **Direction**: [opening/closing/bidirectional]

### Timbral Evolution
- **Harmonic shifting**: [none/slow drift/morphing]
- **Brightness evolution**: [static/darkening/brightening/cycling]
- **Evolution rate**: [seconds per cycle]

---

## Modulation

### Amplitude Modulation
- **Tremolo rate**: [Hz] or [none]
- **Tremolo depth**: [0-1]
- **Amplitude LFO shape**: [sine/triangle/random]

### Spectral Modulation
- **Filter LFO rate**: [Hz]
- **Filter LFO depth**: [octaves]
- **Resonance modulation**: [none/subtle/pronounced]

### Pitch Modulation
- **Chorus/detune movement**: [static/slow/medium]
- **Vibrato**: [rate, depth] or [none]
- **Pitch drift**: [stable/slight drift/significant]

### Rhythmic Elements (if any)
- **Pulse rate**: [Hz/BPM] or [none]
- **Rhythmic character**: [regular/irregular/polyrhythmic]
- **Gating**: [none/subtle/hard]

---

## Stereo Field

### Width
- **Stereo spread**: [mono/narrow/moderate/wide/extreme]
- **Method**: [hard pan/stereo chorus/mid-side/decorrelation]

### Movement
- **Panning motion**: [static/slow drift/fast motion/random]
- **Pan rate**: [Hz or seconds]
- **Pan depth**: [subtle/moderate/full L-R]

### Depth
- **Reverb amount**: [dry/subtle/moderate/drenched]
- **Reverb character**: [tight/room/hall/infinite]
- **Pre-delay**: [ms]

---

## Processing

### Effects Chain
- **Reverb**: [type, size, decay]
- **Delay**: [time, feedback, filtering]
- **Chorus/ensemble**: [rate, depth, voices]
- **Distortion/saturation**: [none/subtle/heavy]
- **Compression**: [none/gentle/squashed]

### Frequency Processing
- **EQ character**: [scooped/boosted mids/presence peak/etc]
- **Notable cuts**: [Hz]
- **Notable boosts**: [Hz]

---

## SuperCollider Synthesis Approach

### Recommended Techniques
- [ ] Multiple detuned oscillators
- [ ] Noise + filtering
- [ ] Granular synthesis
- [ ] Additive (many sines)
- [ ] FM with slow modulators
- [ ] Wavetable scanning
- [ ] Feedback networks
- [ ] Spectral processing (FFT)

### Suggested UGens
```supercollider
// Oscillators for pads:
Saw, SinOsc, LFTri, Pulse, VarSaw
Klang, DynKlang (additive)
Formant, Blip

// Noise sources:
WhiteNoise, PinkNoise, BrownNoise
Dust, Crackle, GrayNoise
LFNoise0, LFNoise1, LFNoise2

// Filters:
LPF, RLPF, BPF, MoogFF
Resonz, Ringz, Formlet

// Modulation:
SinOsc.kr, LFTri.kr, LFNoise1.kr, LFNoise2.kr

// Effects:
FreeVerb, GVerb, JPverb
CombL, AllpassL
DelayL, DelayC

// Stereo:
Pan2, Splay, SplayAz
PanAz, Rotate2
```

---

## Analysis Commands

```bash
# Spectrogram (shows evolution over time)
ffmpeg -i "file.wav" -lavfi "showspectrumpic=s=1920x512:scale=log:legend=0" -y /tmp/spectrum.png

# Long-term spectral average
ffmpeg -i "file.wav" -af "asplit[a][b],[a]showfreqs=s=640x480:mode=line:fscale=log[v],[b]anullsink" -map "[v]" -frames:v 1 -y /tmp/freq.png

# Spectral flux (amount of change over time)
ffmpeg -i "file.wav" -af "aspectralstats=measure=flux,ametadata=print:file=-" -f null - 2>/dev/null | head -50

# RMS envelope (amplitude shape)
ffmpeg -i "file.wav" -af "astats=metadata=1:reset=100,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" -f null - 2>/dev/null

# Stereo analysis
ffmpeg -i "file.wav" -af "stereotools=smode=ms,astats" -f null - 2>&1 | grep -E "(Bit|RMS)"
```

### SuperCollider Analysis
```supercollider
// Spectral flatness (noise vs tonal)
(
SynthDef(\flatness, {
    var sig, fft, flat;
    sig = PlayBuf.ar(2, b, doneAction: 2);
    fft = FFT(LocalBuf(2048), Mix(sig));
    flat = SpecFlatness.kr(fft);
    flat.poll(5, "Flatness (0=tonal, 1=noise)");
}).play;
)

// Spectral centroid over time
(
SynthDef(\evolution, {
    var sig, fft, centroid;
    sig = PlayBuf.ar(2, b, doneAction: 2);
    fft = FFT(LocalBuf(2048), Mix(sig));
    centroid = SpecCentroid.kr(fft);
    centroid.poll(5, "Centroid");
}).play;
)
```

---

## Example Analysis

**Source**: ambient_pad.wav (30 seconds, stereo)

### Spectral Characteristics
- **Frequency range**: 80Hz - 6kHz
- **Spectral density**: Dense, layered
- **Brightness**: Dark to neutral
- **Harmonic vs noise**: Mostly tonal with noise layer

### Tonal Content
- **Root**: E (82 Hz), ambiguous/suspended
- **Chord**: Esus2 voicing (E-F#-B) spread across octaves
- **Detuning**: ~8 cents between voices
- **Voice count**: 6+ oscillators

### Temporal Evolution
- **Fade in**: 3 seconds
- **Filter movement**: Slow sweep, ~15 second cycle
- **Sweep range**: 800Hz - 3kHz
- **Brightness evolution**: Gradually opens over duration

### Modulation
- **Tremolo**: None
- **Filter LFO**: 0.07 Hz (14 sec cycle), sine
- **Chorus**: Slow, ~0.3 Hz, subtle depth

### Stereo Field
- **Width**: Wide (different voices panned)
- **Movement**: Slow drift
- **Reverb**: Large hall, 4+ second decay

### Suggested SuperCollider
```supercollider
SynthDef(\analyzedPad, {
    arg out = 0, freq = 82.41, amp = 0.3, gate = 1,
        cutoff = 1500, filterLFORate = 0.07, filterDepth = 1200;
    var sig, env, filt, lfo, spread;

    // Multiple detuned saws - root, 2nd, 5th across octaves
    sig = Saw.ar(freq * [1, 1.006, 1.122, 1.126, 1.498, 1.504, 2, 2.008] *
                 [1, 1.002, 0.998, 1.001, 1.003, 0.999, 1.001, 0.997]) * 0.12;

    // Spread across stereo field
    sig = Splay.ar(sig, spread: 0.8);

    // Slow filter movement
    lfo = SinOsc.kr(filterLFORate, 0, filterDepth, cutoff);
    sig = RLPF.ar(sig, lfo, 0.3);

    // Add subtle noise layer
    sig = sig + (BPF.ar(PinkNoise.ar([1,1]) * 0.03, lfo * 0.5, 0.5));

    // Slow amplitude envelope
    env = EnvGen.kr(Env.asr(3, 1, 4), gate, doneAction: 2);

    // Reverb
    sig = sig + (FreeVerb2.ar(sig[0], sig[1], mix: 0.6, room: 0.9, damp: 0.5) * 0.5);

    Out.ar(out, sig * env * amp);
}).add;
```

---

## LLM Prompt Template

```
Recreate this pad/texture sound in SuperCollider:

SPECTRAL CHARACTER:
- Frequency range: [Hz-Hz]
- Tonal vs noise: [ratio/description]
- Brightness: [dark/neutral/bright]
- Density: [sparse/moderate/dense]

TONAL CONTENT (if any):
- Root/chord: [note/chord type]
- Detuning: [cents]
- Voice count: [number]

EVOLUTION:
- Duration: [seconds or continuous]
- Filter movement: [description]
- Amplitude shape: [static/swelling/breathing]
- Modulation rates: [slow/medium - Hz values]

STEREO & SPACE:
- Width: [mono to wide]
- Reverb: [amount, character]
- Movement: [static/drifting]

Create a SynthDef with multiple detuned voices, slow filter modulation,
and appropriate stereo spread. Include reverb in the synth or note to add externally.
Sound should evolve slowly and work as background texture.
```
