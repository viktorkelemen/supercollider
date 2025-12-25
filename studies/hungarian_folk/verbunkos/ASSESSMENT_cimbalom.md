# Hungarian Folk Music Experiment Assessment

## Experiment Info

| Field | Value |
|-------|-------|
| **Name** | Verbunkos Cimbalom |
| **Target Style** | Verbunkos (instrument focus: Cimbalom) |
| **Date** | 2025-12-25 |
| **File** | verbunkos_cimbalom.scd |

---

## 1. Scale & Pitch (0-10)

### Accuracy
- [x] Notes consistently stay within the target scale
- [x] Characteristic intervals are present
- [x] Tonal center is clear
- [x] Cadences resolve correctly

### Analysis
- Uses Hungarian minor throughout
- Arpeggios use scale degrees [0, 2, 4] (root, third, fifth)
- Melodic runs stay in scale
- Final chords resolve to tonic

**Score: 8/10**

---

## 2. Rhythm & Timing (0-10)

### Accuracy
- [ ] Time signature feels correct
- [ ] Dotted rhythms present
- [ ] Syncopation used appropriately
- [ ] Rubato feels natural

### Analysis
- Focus is on cimbalom technique, not verbunkos rhythm
- Experiment 5 (accompaniment) has basic beat structure
- Rolled chords have fast arpeggiation (0.02-0.04s between notes)
- Tremolo rates (10-16 Hz) are appropriate for cimbalom

### Gaps
- No dotted rhythms demonstrated
- Missing verbunkos rhythmic patterns

**Score: 5/10** (rhythm is secondary focus)

---

## 3. Melodic Contour (0-10)

### Accuracy
- [x] Arpeggiated figures appropriate
- [x] Scalar runs present
- [ ] Not assessing melodic structure

### Analysis
- Experiment 2: arpeggio pattern [0,2,4,6,7,6,4,2] - arch shape
- Experiment 6: ascending and descending scalar runs
- Experiment 8: full phrase with run and tremolo

**Score: 6/10**

---

## 4. Ornamentation (0-10)

### Accuracy
- [ ] Grace notes - N/A for cimbalom study
- [ ] Trills - N/A
- [ ] Slides - N/A (cimbalom doesn't slide)
- [x] Tremolo technique present

### Analysis
- Tremolo is THE key cimbalom ornament - well covered
- `\cimbalomTremolo` uses LFPulse at 10-16 Hz
- Tremolo envelope creates natural attack on each strike

### Gaps
- Could demonstrate tremolo with dynamic swell
- Missing "choked" stopped-string technique

**Score: 7/10** (for cimbalom-specific techniques)

---

## 5. Timbre & Instrumentation (0-10)

### Accuracy
- [x] Sound evokes the target instrument
- [x] Brightness/darkness appropriate
- [x] Attack characteristics correct
- [x] Harmonic content suitable

### Analysis

**`\cimbalom` (main synth)**:
- Inharmonic partials: `[1, 2.001, 3.002, 4.005, 5.01, 6.02, 7.03]` - stretched harmonics like real strings
- Amplitude decay: `[1, 0.7, 0.4, 0.25, 0.15, 0.1, 0.05]` - natural rolloff
- LFNoise1 detuning on each partial - shimmer
- HPF white noise attack transient at 4000 Hz - hammer strike
- DelayC for sympathetic resonance (0.001-0.003s) - subtle chorus
- Perc envelope with -6 curve - realistic decay

**`\cimbalomSustain`**:
- ASR envelope for pedal-down playing
- Separate decay envelope overlaid

**`\cimbalomTremolo`**:
- LFPulse at tremolo rate
- Separate attack envelope per "strike"
- Maintains overall phrase envelope

**`\cimbalomBass`**:
- Fewer partials, more fundamental
- LPF at 2000 Hz - darker bass strings
- Longer decay (2s)

### Strengths
- Inharmonic partial stretching is authentic (real strings are inharmonic)
- Attack transient is crucial - captured well
- Sympathetic resonance adds liveness
- Register-appropriate variations (bass vs treble)

### Gaps
- Could add damper pedal simulation (cutting sustain)
- Missing the "zing" of very high register
- No string-per-note variation

**Score: 8/10** (good instrument modeling)

---

## 6. Dynamics & Expression (0-10)

### Accuracy
- [x] Dynamic range appropriate
- [ ] Crescendos/decrescendos
- [x] Accents on correct beats (in accompaniment)
- [ ] Emotional arc present

### Analysis
- Experiment 5: Beat 1 louder (0.4) than beat 2 (0.15) - correct
- Rolled chords have slight amplitude variation
- Tremolo has natural dynamic fluctuation from technique
- Pan position varies in arpeggios for stereo spread

### Gaps
- No phrase-level dynamics
- Missing dramatic cimbalom crescendo-decrescendo

**Score: 6/10**

---

## 7. Structure & Form (0-10)

### Accuracy
- [ ] Correct sections
- [ ] Section lengths
- [ ] Transitions
- [x] Overall duration suitable

### Analysis
- Educational structure with 8 technique demonstrations
- Experiment 8 "Full cimbalom phrase" shows complete musical idea
- No verbunkos form structure (lassú→friss)

**Score: N/A (technique demonstrations)**

---

## 8. Authenticity & Feel (0-10)

### Subjective Assessment
- [x] Would pass as cimbalom-like sound
- [x] Evokes the shimmer and ring of the instrument
- [x] Has Hungarian character
- [x] Doesn't sound like piano or xylophone

### Analysis
- The inharmonic partials give it the cimbalom "character"
- Tremolo sounds like rapid hammer strikes
- Bass register has appropriate weight
- Rolled chords evoke the cascading cimbalom texture

### Strengths
- Best timbre work of the four experiments
- Tremolo is convincing
- Register variation is effective

### Gaps
- Would benefit from room reverb for authenticity
- Missing the "live" variation of real performance

**Score: 8/10**

---

## 9. Technical Quality (0-10)

### Implementation
- [x] No audio glitches
- [x] Clean transitions
- [x] Appropriate use of envelopes
- [x] CPU-efficient

### Analysis
- Mix() efficiently combines partials
- Proper use of doneAction: 2
- Delay line for resonance is short, efficient
- Well-structured additive synthesis
- `.min(16000)` on LPF prevents Nyquist issues

### Code Quality
- Clear comments explaining the synthesis approach
- Consistent parameter naming
- Good separation of technique-specific SynthDefs

**Score: 9/10**

---

## 10. Reference Comparison (0-10)

### Code-Based Assessment

| Aspect | Real Cimbalom | This Synthesis | Match? |
|--------|--------------|----------------|--------|
| Attack | Hammer strike | HPF noise burst | ✓ |
| Sustain | Ring decay | Perc envelope -6 | ✓ |
| Harmonics | Stretched inharmonic | Stretched partials | ✓ |
| Tremolo | Rapid strikes | LFPulse modulation | ✓ |
| Bass register | Darker, longer | Fewer partials, LPF | ✓ |
| Sympathetic | String resonance | Short delay | ~ |
| Damping | Pedal control | Not implemented | ✗ |
| Room | Natural reverb | Dry | ✗ |

**Score: 7/10**

---

## Summary

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| 1. Scale & Pitch | 8/10 | 1.5x | 12 |
| 2. Rhythm & Timing | 5/10 | 1.5x | 7.5 |
| 3. Melodic Contour | 6/10 | 1.0x | 6 |
| 4. Ornamentation | 7/10 | 1.0x | 7 |
| 5. Timbre | 8/10 | 1.0x | 8 |
| 6. Dynamics | 6/10 | 0.5x | 3 |
| 7. Structure | N/A | - | - |
| 8. Authenticity | 8/10 | 1.5x | 12 |
| 9. Technical | 9/10 | 0.5x | 4.5 |
| 10. Reference Match | 7/10 | 1.5x | 10.5 |

**Adjusted Total: 70.5 / 90 = 78%**

### Rating: Good

**Interpretation**: Strong cimbalom synthesis with convincing timbre. The inharmonic partial approach and attack transient are effective. Main gaps are verbunkos-specific rhythm patterns and room ambience. This is the best instrument modeling of the four experiments.

---

## Action Items

### What worked well:
1. Inharmonic partial stretching creates authentic timbre
2. Attack transient (HPF noise) sounds like hammer strike
3. Register variations (bass vs treble) are appropriate
4. Tremolo technique is well-implemented

### What needs improvement:
1. Add damper pedal functionality (gate-controlled decay)
2. Add room reverb for natural ambience
3. Integrate with verbunkos dotted rhythms
4. Dynamic phrase shaping

### Next iteration focus:
- Combine cimbalom texture with rhythm and ornament experiments for complete verbunkos piece

---

## Notes

The cimbalom SynthDef library is production-ready:
- `\cimbalom` - general purpose struck string
- `\cimbalomSustain` - pedal-down playing
- `\cimbalomTremolo` - rapid strikes with envelope
- `\cimbalomBass` - low register with appropriate timbre

Key insight: The `partials.collect` pattern with stretched ratios and decaying amplitudes is a good template for any struck string instrument (dulcimer, santoor, yangqin, etc.)

Potential enhancement: Add a `brightness` parameter that shifts the partial amplitudes toward/away from fundamental for tonal control.
