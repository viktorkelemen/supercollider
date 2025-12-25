# SuperCollider Melodic Sound Recreation Prompt

Use this template to recreate analyzed melodic/tonal sounds in SuperCollider.
Best for: synth leads, basses, plucks, keys, monophonic/polyphonic instruments.

---

## Sound Profile

### Pitch & Harmonics
- **Fundamental frequency**: [Hz] / [note name]
- **Pitch stability**: [stable/vibrato/drift]
- **Vibrato rate**: [Hz] (if present)
- **Vibrato depth**: [cents/semitones]
- **Harmonic content**: [sine-like/few harmonics/rich/buzzy]
- **Dominant harmonics**: [list ratios: 1, 2, 3, 4...]
- **Odd/even balance**: [odd-heavy/even-heavy/balanced]
- **Inharmonicity**: [none/slight/detuned/bell-like]

### Spectral Character
- **Brightness**: [dark/neutral/bright]
- **Spectral centroid**: [Hz] (center of mass)
- **Filter type implied**: [lowpass/bandpass/highpass/none]
- **Estimated cutoff**: [Hz]
- **Resonance**: [none/subtle/pronounced/self-oscillating]

### Waveform Character
- **Closest basic waveform**: [sine/triangle/saw/square/pulse/noise]
- **Pulse width** (if pulse): [%]
- **Waveshaping/distortion**: [none/soft/hard/bitcrushed]

---

## Envelope Profile

### Amplitude Envelope (ADSR)
- **Attack**: [ms]
- **Decay**: [ms]
- **Sustain level**: [0-1]
- **Release**: [ms]
- **Curve**: [linear/exponential/logarithmic]

### Filter Envelope (if present)
- **Attack**: [ms]
- **Decay**: [ms]
- **Sustain**: [0-1]
- **Envelope depth**: [octaves/Hz]
- **Direction**: [opening/closing]

### Pitch Envelope (if present)
- **Initial pitch offset**: [semitones]
- **Glide time**: [ms]
- **Direction**: [up/down/bend]

---

## Modulation

### LFO (if present)
- **Rate**: [Hz]
- **Destination**: [pitch/filter/amplitude/PWM]
- **Depth**: [amount]
- **Waveform**: [sine/triangle/square/random]

### Other Movement
- **Detuning**: [cents between oscillators]
- **Unison voices**: [count]
- **Stereo spread**: [mono/subtle/wide]

---

## Musical Context

### Note Information
- **Pitch range**: [lowest] to [highest]
- **Note sequence**: [list of notes/intervals]
- **Note durations**: [ms or beat values]
- **Articulation**: [legato/staccato/portamento]
- **Velocity variation**: [static/subtle/dynamic]

### Timing
- **BPM** (if rhythmic): [value]
- **Quantization**: [straight/swung]
- **Swing amount**: [%]

---

## SuperCollider Synthesis Approach

### Recommended Technique
- [ ] Subtractive (oscillator + filter)
- [ ] FM synthesis
- [ ] Additive (multiple sines)
- [ ] Wavetable
- [ ] Physical modeling
- [ ] Sample-based

### Suggested UGens
```supercollider
// Oscillators:
SinOsc, Saw, Pulse, LFTri, VarSaw, SyncSaw, Blip

// Filters:
LPF, RLPF, MoogFF, BLowPass4, BMoog

// Envelopes:
EnvGen, Env.adsr, Env.perc, Env.linen

// Modulation:
SinOsc.kr, LFTri.kr, LFNoise1.kr
```

---

## Analysis Commands (ffmpeg + other)

```bash
# Basic spectral analysis
ffmpeg -i "file.wav" -lavfi "showspectrumpic=s=1024x512:scale=log" -y /tmp/spectrum.png

# Pitch detection (requires aubio)
aubiopitch -i "file.wav" -p yinfft

# Fundamental frequency over time
aubiopitch -i "file.wav" -p yin -B 512 -H 256

# Note onset detection
aubioonset -i "file.wav" -B 512

# Spectral centroid (brightness) over time
ffmpeg -i "file.wav" -af "aspectralstats=measure=centroid,ametadata=print:file=-" -f null - 2>/dev/null

# Harmonic analysis (requires sonic-annotator or similar)
# Or use SuperCollider's built-in FFT analysis
```

### SuperCollider Analysis
```supercollider
// Load and analyze a buffer
b = Buffer.read(s, "path/to/file.wav");

// Pitch tracking
(
SynthDef(\pitchTrack, {
    var sig, freq, hasFreq;
    sig = PlayBuf.ar(1, b, doneAction: 2);
    # freq, hasFreq = Pitch.kr(sig, ampThreshold: 0.1);
    freq.poll(10, "Freq");
}).play;
)

// Spectral centroid
(
SynthDef(\centroid, {
    var sig, fft, centroid;
    sig = PlayBuf.ar(1, b, doneAction: 2);
    fft = FFT(LocalBuf(2048), sig);
    centroid = SpecCentroid.kr(fft);
    centroid.poll(10, "Centroid");
}).play;
)
```

---

## Example Analysis

**Source**: synth_lead.wav

### Pitch & Harmonics
- **Fundamental**: 220 Hz (A3)
- **Pitch stability**: Subtle vibrato
- **Vibrato rate**: 5 Hz
- **Vibrato depth**: ±15 cents
- **Harmonic content**: Rich, saw-like
- **Dominant harmonics**: 1, 2, 3, 4, 5, 6 (descending amplitude)
- **Odd/even balance**: Balanced (saw character)

### Spectral Character
- **Brightness**: Neutral, filtered
- **Filter type**: Lowpass with resonance
- **Estimated cutoff**: 2.5 kHz
- **Resonance**: Subtle peak

### Envelope
- **Attack**: 15ms
- **Decay**: 200ms
- **Sustain**: 0.7
- **Release**: 300ms
- **Filter envelope**: Opens 1 octave over 100ms, sustains at 0.6

### Suggested SuperCollider
```supercollider
SynthDef(\analyzedLead, {
    arg out = 0, freq = 220, amp = 0.3, gate = 1,
        cutoff = 2500, res = 0.2, vibRate = 5, vibDepth = 0.01;
    var sig, env, fenv, vib;

    // Vibrato
    vib = SinOsc.kr(vibRate, 0, vibDepth, 1);

    // Saw oscillator with slight detune for thickness
    sig = Saw.ar(freq * vib * [1, 1.003]) * 0.5;
    sig = Mix(sig);

    // Filter with envelope
    fenv = EnvGen.kr(Env.adsr(0.1, 0.2, 0.6, 0.3), gate) * cutoff;
    sig = RLPF.ar(sig, cutoff + fenv, res);

    // Amplitude envelope
    env = EnvGen.kr(Env.adsr(0.015, 0.2, 0.7, 0.3), gate, doneAction: 2);

    Out.ar(out, sig ! 2 * env * amp);
}).add;
```

---

## LLM Prompt Template

```
Recreate this melodic sound in SuperCollider:

PITCH & HARMONICS:
- Fundamental: [Hz/note]
- Waveform character: [description]
- Harmonic richness: [sine-like to buzzy scale]
- Vibrato: [rate, depth, or none]

TIMBRE:
- Brightness: [dark/neutral/bright]
- Filter: [type, cutoff, resonance]
- Character: [description - warm, harsh, hollow, etc.]

ENVELOPE:
- Amp ADSR: [A]ms / [D]ms / [S] / [R]ms
- Filter envelope: [description or none]
- Pitch envelope: [description or none]

MODULATION:
- LFO: [destination, rate, depth]
- Detuning: [cents]
- Other movement: [description]

Create a SynthDef that captures this character. Include filter and amplitude
envelopes. Add subtle detuning or modulation for organic feel.
```
