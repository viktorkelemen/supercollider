# Hungarian Folk Music Experiment Assessment

Copy this template for each experiment to evaluate style authenticity.

---

## Experiment Info

| Field | Value |
|-------|-------|
| **Name** | |
| **Target Style** | Verbunkos / Csárdás / Hallgató / Nóta / Legényes / Other |
| **Date** | |
| **File** | |

---

## 1. Scale & Pitch (0-10)

### Accuracy
- [ ] Notes consistently stay within the target scale
- [ ] Characteristic intervals are present (augmented 2nds for Hungarian minor)
- [ ] Tonal center is clear and appropriate
- [ ] Cadences resolve correctly

### Questions
1. When you play only the pitches used, does it sound Hungarian?
2. Are there any "wrong notes" that break the style?
3. Is the pitch range appropriate for the style? (folk songs typically span 1-1.5 octaves)
4. Does the melody emphasize the characteristic scale degrees?

### Measurement
```
sc_get_analysis → pitch
- Expected scale degrees: ___
- Actual notes detected: ___
- Out-of-scale occurrences: ___
```

**Score: __ /10**

---

## 2. Rhythm & Timing (0-10)

### Accuracy
- [ ] Time signature feels correct (2/4 or 4/4)
- [ ] Dotted rhythms present where expected
- [ ] Syncopation used appropriately
- [ ] Rubato feels natural (for slow styles)

### Questions
1. Can you tap your foot to it? (Should be yes for csárdás, maybe not for hallgató)
2. Does the rhythm have the characteristic "Hungarian accent" (first beat emphasis)?
3. Are the long-short ratios correct? (3:1 for dotted eighth-sixteenth)
4. For verbunkos/csárdás: is the slow-to-fast transition convincing?
5. For hallgató: does the rubato feel speech-like or mechanical?
6. Is the bokázó (heel-click) cadence recognizable at phrase endings?

### Measurement
```
sc_get_onsets → timing analysis
- Expected rhythm pattern: ___
- Onset intervals detected: ___
- Tempo stability (giusto) or variation (rubato): ___
```

**Score: __ /10**

---

## 3. Melodic Contour (0-10)

### Accuracy
- [ ] Overall contour matches style (descending for old-style, arched for new-style)
- [ ] Phrase lengths feel appropriate (typically 4 or 8 bars)
- [ ] Melodic motion is mostly stepwise with occasional leaps
- [ ] Fifth construction present if targeting old-style

### Questions
1. If you draw the melody shape, does it match the expected contour?
2. Do phrases feel complete or cut off?
3. Is there a sense of question-and-answer between phrases?
4. For old-style: does the melody repeat a 5th lower (A⁵A⁵AA structure)?
5. For new-style: is there an AABA or ABBA return structure?
6. Does the melody "breathe" - are there natural pause points?

### Visual Check
```
Sketch the melodic contour here:

High  |
      |
Mid   |
      |
Low   |______________________________
      Start                      End

Expected: ____________
Actual:   ____________
```

**Score: __ /10**

---

## 4. Ornamentation (0-10)

### Accuracy
- [ ] Grace notes present and tasteful
- [ ] Trills on appropriate sustained notes
- [ ] Slides/portamento between notes
- [ ] Vibrato width and speed appropriate

### Questions
1. Is the ornamentation density right for the style? (Heavy for verbunkos/hallgató, lighter for csárdás friss)
2. Do ornaments feel organic or programmatic?
3. Are grace notes the right duration? (Very short, almost crushed)
4. Is vibrato present on held notes?
5. Do ornaments occur at phrase peaks and cadences?
6. Would a folk musician recognize these as authentic decorations?

### Style-Specific Ornamentation

| Style | Expected Ornamentation |
|-------|----------------------|
| Verbunkos | Heavy: triplet runs, wide trills, dramatic slides |
| Csárdás (lassú) | Moderate: grace notes, gentle vibrato |
| Csárdás (friss) | Light: minimal, rhythm takes priority |
| Hallgató | Very heavy: melismatic, free, emotional |
| Legényes | Rhythmic accents over melodic ornaments |

**Score: __ /10**

---

## 5. Timbre & Instrumentation (0-10)

### Accuracy
- [ ] Sound evokes the target instrument(s)
- [ ] Brightness/darkness appropriate
- [ ] Attack characteristics correct
- [ ] Harmonic content suitable

### Questions
1. Close your eyes - what instrument do you imagine?
2. Does the brightness match? (Violin: mid-bright, Cimbalom: shimmery, Tárogató: mellow-dark)
3. Is the attack right? (Bowed: soft attack, Cimbalom: percussive, Gardon: very percussive)
4. Does it sound acoustic or obviously synthetic?
5. If multiple voices, are the roles clear? (Melody vs rhythm vs bass)
6. Is there appropriate "room" or ambience?

### Measurement
```
sc_get_analysis → timbre
- Spectral centroid: ___ Hz (expected: ___ Hz)
- Spectral flatness: ___ (tonal < 0.1, noisy > 0.3)
- Inferred waveform: ___

sc_get_spectrum → frequency bands
- Low (60-250 Hz): ___
- Mid (250-2000 Hz): ___
- High (2000-16000 Hz): ___
```

### Instrument Reference Centroids

| Instrument | Approx. Centroid Range |
|------------|----------------------|
| Double bass | 200-600 Hz |
| Gardon | 300-800 Hz |
| Viola/Brácsa | 500-1500 Hz |
| Violin | 1000-3000 Hz |
| Cimbalom | 1500-4000 Hz |
| Tárogató | 800-2000 Hz |

**Score: __ /10**

---

## 6. Dynamics & Expression (0-10)

### Accuracy
- [ ] Dynamic range appropriate for style
- [ ] Crescendos/decrescendos feel musical
- [ ] Accents on correct beats
- [ ] Emotional arc present

### Questions
1. Is there dynamic variety or is it flat?
2. Do accents fall on beat 1 (Hungarian language stress)?
3. For verbunkos: is there dramatic contrast between sections?
4. For hallgató: does it feel emotionally expressive?
5. Does intensity build toward phrase climaxes?
6. Is the overall energy level right? (Csárdás friss = high, Hallgató = low-medium)

### Measurement
```
sc_get_analysis → amplitude
- Peak amplitude range: ___
- RMS variation: ___
- Dynamic range (dB): ___
```

**Score: __ /10**

---

## 7. Structure & Form (0-10)

### Accuracy
- [ ] Correct number of sections present
- [ ] Section lengths appropriate
- [ ] Transitions between sections convincing
- [ ] Overall duration suitable

### Questions
1. Can you identify distinct sections?
2. For verbunkos/csárdás: is the lassú → friss structure clear?
3. Are sections the right length? (Typically 8, 16, or 32 bars)
4. Do transitions feel smooth or jarring?
5. Is there a sense of beginning, middle, and end?
6. Would this work for actual dancing?

### Structure Diagram
```
Draw or describe the structure:

Section:    |_______|_______|_______|_______|
Name:
Duration:
Tempo:
Character:
```

### Expected Structures

| Style | Typical Structure |
|-------|------------------|
| Verbunkos | Lassú (slow, rubato) → Friss (fast, strict) |
| Csárdás | Lassú → Friss (accelerating) |
| Hallgató | Single slow section, through-composed |
| Nóta | Verse-based, may have tempo changes |
| Legényes | Repeated dance sections with variation |

**Score: __ /10**

---

## 8. Authenticity & Feel (0-10)

### Subjective Assessment
- [ ] Would pass the "blind test" as Hungarian folk
- [ ] Evokes the right emotional response
- [ ] Has the "Hungarian character"
- [ ] Doesn't sound like a different folk tradition

### Questions
1. If you played this for someone familiar with Hungarian music, would they recognize it?
2. Does it evoke the right imagery? (Village dance, tavern, pastoral scene?)
3. Does it have "soul" or does it feel sterile?
4. What's missing that would make it more authentic?
5. What elements feel most successful?
6. Could this accompany actual folk dancing?

### The "Two Character" Test (for verbunkos/csárdás)
Hungarian music is said to express "two contrasting aspects of Hungarian character":
- [ ] Melancholic, introspective slow section
- [ ] Fiery, exuberant fast section

**Score: __ /10**

---

## 9. Technical Quality (0-10)

### Implementation
- [ ] No audio glitches, clicks, or pops
- [ ] Clean transitions
- [ ] Appropriate use of envelopes
- [ ] CPU-efficient

### Questions
1. Are there any unwanted artifacts?
2. Do notes start and end cleanly?
3. Is the stereo field appropriate?
4. Does it sound good at different volumes?
5. Is the code maintainable and well-organized?

**Score: __ /10**

---

## 10. Reference Comparison (0-10)

### A/B Testing
Compare directly against authentic recordings.

**Reference Recording Used**: _______________

### Comparison Notes
| Aspect | Reference | Your Experiment | Match? |
|--------|-----------|-----------------|--------|
| Scale | | | |
| Rhythm | | | |
| Tempo | | | |
| Timbre | | | |
| Dynamics | | | |
| Ornamentation | | | |
| Structure | | | |
| Feel | | | |

### Measurement (if reference played through SC)
```
1. Play reference → sc_capture_reference("ref")
2. Play experiment → sc_compare_to_reference("ref")

Similarity score: ___%
Pitch difference: ___ semitones
Brightness ratio: ___
Loudness difference: ___ sones
```

**Score: __ /10**

---

## Summary

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| 1. Scale & Pitch | /10 | 1.5x | |
| 2. Rhythm & Timing | /10 | 1.5x | |
| 3. Melodic Contour | /10 | 1.0x | |
| 4. Ornamentation | /10 | 1.0x | |
| 5. Timbre | /10 | 1.0x | |
| 6. Dynamics | /10 | 0.5x | |
| 7. Structure | /10 | 1.0x | |
| 8. Authenticity | /10 | 1.5x | |
| 9. Technical | /10 | 0.5x | |
| 10. Reference Match | /10 | 1.5x | |

**Total: ___ / 100**

### Rating Scale

| Score | Rating | Interpretation |
|-------|--------|----------------|
| 90-100 | Excellent | Could fool an expert |
| 75-89 | Good | Clearly Hungarian, minor issues |
| 60-74 | Fair | Recognizable but needs work |
| 40-59 | Developing | Some elements present |
| 0-39 | Early stage | Fundamental elements missing |

---

## Action Items

### What worked well:
1.
2.
3.

### What needs improvement:
1.
2.
3.

### Next iteration focus:
-

---

## Notes

Additional observations, ideas, or references for future experiments:

```




```
