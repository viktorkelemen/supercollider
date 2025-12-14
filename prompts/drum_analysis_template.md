# SuperCollider Drum Sound Recreation Prompt

Use this template to recreate analyzed drum sounds in SuperCollider.

---

## Sound Profile

### Spectral Characteristics
- **Sub-bass (20-60Hz)**: [minimal/moderate/heavy] - [dB level]
- **Bass (60-150Hz)**: [minimal/moderate/heavy] - [dB level]
- **Low-mids (150-500Hz)**: [minimal/moderate/heavy] - [dB level]
- **Mids (500-2kHz)**: [minimal/moderate/heavy] - [dB level]
- **High-mids (2-5kHz)**: [minimal/moderate/heavy] - [dB level]
- **Highs (5kHz+)**: [minimal/moderate/heavy] - [dB level]
- **Overall character**: [dark/neutral/bright]

### Dynamics
- **Peak level**: [dBFS]
- **Integrated loudness**: [LUFS]
- **Dynamic range (LRA)**: [LU]
- **Transient sharpness**: [soft/medium/punchy/hard]

### Envelope
- **Attack**: [ms]
- **Decay**: [ms]
- **Sustain**: [none/short/medium/long]
- **Release**: [ms]

---

## Rhythm Profile

### Tempo & Grid
- **BPM**: [value]
- **Grid resolution**: [8th/16th/32nd notes]
- **Swing/shuffle**: [none/light/heavy] - [%]

### Note Values Used
| Value | Duration at BPM | Frequency of use |
|-------|-----------------|------------------|
| 16th note | [ms] | [rare/common/frequent] |
| 8th note | [ms] | [rare/common/frequent] |
| Dotted 8th | [ms] | [rare/common/frequent] |
| Quarter | [ms] | [rare/common/frequent] |
| Dotted quarter | [ms] | [rare/common/frequent] |

### Pattern Style
- **Feel**: [straight/swung/broken/syncopated]
- **Genre reference**: [4-on-floor/breakbeat/2-step/etc]
- **Hit density**: [sparse/moderate/dense]
- **Clustering**: [isolated hits/pairs/clusters of N]

### Pattern Structure (per bar)
```
Beat:  1 . . . 2 . . . 3 . . . 4 . . .
       |       |       |       |
Hit:   [mark hit positions with X]
```

---

## SuperCollider Synthesis Parameters

### Kick/Low Element
```supercollider
// Suggested SynthDef parameters:
freq: [Hz]           // Fundamental frequency
clickFreq: [Hz]      // Initial transient pitch
clickDecay: [s]      // Transient decay time
bodyDecay: [s]       // Main body decay
filterCutoff: [Hz]   // LPF cutoff
amp: [0-1]           // Amplitude
```

### Snare/Mid Element
```supercollider
freq: [Hz]           // Body frequency
noiseAmt: [0-1]      // Noise mix ratio
noiseHPF: [Hz]       // Noise high-pass filter
decay: [s]           // Overall decay
amp: [0-1]
```

### Hi-hat/High Element
```supercollider
hpf: [Hz]            // High-pass filter cutoff
decay: [s]           // Decay time (closed vs open)
metallic: [0-1]      // Pulse vs noise ratio
amp: [0-1]
```

---

## Example Analysis

**Source**: test.m4a (14.5s, mono, 48kHz)

### Sound Profile
- **Sub-bass (20-60Hz)**: minimal - only -50dB peaks
- **Bass (60-150Hz)**: moderate - main kick energy
- **Low-mids (150-500Hz)**: moderate - body
- **Mids (500-2kHz)**: present - transient click
- **High-mids (2-5kHz)**: sparse bursts
- **Highs (5kHz+)**: minimal
- **Overall character**: dark, punchy, short decay

### Dynamics
- **Peak level**: -20.8 dBFS
- **Integrated loudness**: -39 LUFS
- **Dynamic range (LRA)**: 7.5 LU (very dynamic)
- **Transient sharpness**: punchy

### Envelope
- **Attack**: <5ms (fast)
- **Decay**: 20-60ms (very short)
- **Sustain**: none
- **Release**: immediate

### Rhythm Profile
- **BPM**: 125
- **Grid resolution**: 16th notes (0.12s)
- **Swing/shuffle**: none detected

### Note Values Used
| Value | Duration | Frequency |
|-------|----------|-----------|
| 16th note | 120ms | frequent |
| 8th note | 240ms | common |
| Dotted 8th | 360ms | frequent |
| Quarter | 480ms | rare |
| Dotted quarter | 720ms | occasional |

### Pattern Style
- **Feel**: broken/syncopated
- **Genre reference**: UK garage / 2-step influenced
- **Hit density**: moderate
- **Clustering**: pairs and triplets with space between

### Suggested SuperCollider Parameters
```supercollider
// Dark punchy kick
SynthDef(\analyzedKick, {
    arg out = 0, amp = 0.4, freq = 55, clickFreq = 200;
    var sig, env, click;
    env = EnvGen.kr(Env.perc(0.005, 0.08, 1, -6), doneAction: 2);
    click = EnvGen.kr(Env.perc(0.001, 0.02)) * clickFreq;
    sig = SinOsc.ar(freq + click);
    sig = LPF.ar(sig, 150);  // Dark - cut highs
    Out.ar(out, sig ! 2 * env * amp);
}).add;

// Short percussive hit
SynthDef(\analyzedPerc, {
    arg out = 0, amp = 0.25, freq = 200, decay = 0.04;
    var sig, env;
    env = EnvGen.kr(Env.perc(0.002, decay, 1, -8), doneAction: 2);
    sig = LPF.ar(Pulse.ar(freq, 0.3), 800);
    sig = sig + (BPF.ar(PinkNoise.ar, 400, 0.5) * 0.3);
    Out.ar(out, sig ! 2 * env * amp);
}).add;
```

---

## Analysis Commands (ffmpeg)

```bash
# Basic file info
ffprobe -v quiet -print_format json -show_format -show_streams "file.m4a"

# Volume/loudness
ffmpeg -i "file.m4a" -af "volumedetect" -f null /dev/null 2>&1

# Loudness (EBU R128)
ffmpeg -i "file.m4a" -af "ebur128=peak=true" -f null - 2>&1

# Spectrogram image
ffmpeg -i "file.m4a" -lavfi "showspectrumpic=s=1024x512:scale=log" -y /tmp/spectrum.png

# Onset detection (silence gaps)
ffmpeg -i "file.m4a" -af "silencedetect=noise=-45dB:d=0.05" -f null - 2>&1

# Band-specific analysis
ffmpeg -i "file.m4a" -af "bandpass=f=100:w=80,ebur128" -f null - 2>&1  # Sub/bass
ffmpeg -i "file.m4a" -af "bandpass=f=400:w=200,ebur128" -f null - 2>&1 # Low-mids
ffmpeg -i "file.m4a" -af "bandpass=f=2000:w=1000,ebur128" -f null - 2>&1 # Mids

# RMS over time
ffmpeg -i "file.m4a" -af "astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level:file=-" -f null - 2>/dev/null

# Calculate intervals between hits
ffmpeg -i "file.m4a" -af "silencedetect=noise=-45dB:d=0.05" -f null - 2>&1 | \
  grep "silence_end" | awk '{print $5}' | \
  awk 'NR>1 {print $1 - prev} {prev = $1}'
```

---

## LLM Prompt Template

```
Recreate this drum sound in SuperCollider:

SPECTRAL:
- Character: [dark/neutral/bright]
- Sub-bass: [level]
- Main frequency range: [Hz-Hz]
- High frequency content: [description]

DYNAMICS:
- Transient: [soft/punchy/hard]
- Decay: [ms]
- Dynamic range: [compressed/dynamic]

RHYTHM:
- BPM: [value]
- Grid: [resolution]
- Feel: [straight/swung/broken]
- Pattern style: [description]
- Common intervals: [list]

Create SynthDefs for each element and a pattern that matches this analysis.
Use short variable names. Include amplitude and timing variations for human feel.
```
