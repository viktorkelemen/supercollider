# Japanese Folk Music Experiment Assessment

Copy this template for each experiment to evaluate style authenticity.

---

## Experiment Info

| Field | Value |
|-------|-------|
| **Name** | |
| **Target Style** | Min'yo / Gagaku / Shomyo / Okinawan / Amami / Shakuhachi / Koto / Biwa / Bon Odori / Taiko / Sankyoku / Noh / Kabuki / Other |
| **Date** | |
| **File** | |

---

## 1. Scale & Pitch (0-10)

### Accuracy
- [ ] Notes consistently stay within the target scale
- [ ] Characteristic intervals are present (semitones for In/Hirajoshi, whole steps for Yo)
- [ ] Tonal center is clear and appropriate
- [ ] Cadences resolve correctly

### Questions
1. When you play only the pitches used, does it sound Japanese?
2. Are there any "wrong notes" that break the style?
3. Is the pitch range appropriate for the style? (folk songs typically span ~1 octave)
4. Does the melody emphasize the characteristic scale degrees?
5. For Okinawan: are the distinctive half-steps (E-F, B-C) present?

### Scale Reference

| Scale | Intervals (semitones) | Example |
|-------|----------------------|---------|
| Yo | 2-3-2-2-3 | D E G A B |
| In | 1-4-2-1-4 | A Bb D E F |
| Hirajoshi | 2-1-4-1-4 | C D Eb G Ab |
| Iwato | 1-4-1-4-2 | C Db F Gb Bb |
| Ryukyu | 4-1-2-4-1 | C E F G B |

### Measurement
```
sc_get_analysis → pitch
- Expected scale: ___
- Actual notes detected: ___
- Out-of-scale occurrences: ___
```

**Score: __ /10**

---

## 2. Rhythm & Timing (0-10)

### Accuracy
- [ ] Appropriate use of ma (silence/space)
- [ ] Breath-based phrasing feels natural
- [ ] Jo-ha-kyu structure present where appropriate
- [ ] Time signature (if any) feels correct

### Questions
1. Does the rhythm "breathe" naturally?
2. Are silences meaningful or just gaps?
3. Does the pacing reflect jo-ha-kyu (slow start → acceleration → rapid conclusion)?
4. For min'yo/Bon Odori: is there a danceable pulse?
5. For shakuhachi/gagaku: is the rhythm properly free?
6. Do phrase lengths feel tied to natural breath?

### Ma Assessment
```
Silence-to-sound ratio: ___
Longest meaningful pause: ___ seconds
Does silence feel intentional? Yes / No
```

### Measurement
```
sc_get_onsets → timing analysis
- Expected rhythm pattern: ___
- Onset intervals detected: ___
- Tempo stability or variation: ___
```

**Score: __ /10**

---

## 3. Melodic Contour (0-10)

### Accuracy
- [ ] Overall contour appropriate for style (often descending)
- [ ] Phrase lengths feel natural (typically 4-8 notes per breath)
- [ ] Melodic motion is mostly stepwise with occasional small leaps
- [ ] Ornamental approach notes present

### Questions
1. If you draw the melody shape, does it match the expected contour?
2. Do phrases feel complete or cut off?
3. Is there a sense of question-and-answer between phrases?
4. Does the melody "breathe" - are there natural pause points?
5. For folk songs: does the range stay within ~1 octave?
6. Are there characteristic descending cadential figures?

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
- [ ] Kobushi (vocal warble) present where appropriate
- [ ] Grace notes/approach notes tasteful
- [ ] Pitch bends (for strings/shakuhachi) authentic
- [ ] Vibrato (yuri) appropriate speed and width

### Questions
1. Is the ornamentation density right for the style?
2. Does kobushi sound like emotional expression or programmatic effect?
3. Are pitch bends the right depth and speed?
4. For koto: are there characteristic aftertouch bends?
5. For shamisen: is there sawari buzz and percussive attack?
6. For shakuhachi: are meri/kari (pitch bends) present?

### Style-Specific Ornamentation

| Style | Expected Ornamentation |
|-------|----------------------|
| Min'yo vocal | Heavy kobushi, emotional vibrato |
| Shakuhachi | Pitch bends (meri/kari), breath accents, muraiki |
| Koto | Aftertouch bends, slides between strings |
| Shamisen | Sawari buzz, percussive attacks, hajiki, bends |
| Biwa | Dramatic sweeps, sawari buzz, pitch bends behind fret |
| Gagaku | Minimal, sustained tones |
| Okinawan | Lighter vibrato than mainland |
| Amami | Intense melisma, high-pitched style |
| Noh/Kabuki | Kakegoe calls, dramatic pauses, ritualistic timing |

### Kobushi Check
```
Pitch fluctuation range: ~___ Hz (authentic: ~70Hz)
Duration of ornament: ~___ ms (authentic: ~100-150ms)
Contour shape: rise-fall-settle? Yes / No
Sounds like crying/emotional? Yes / No
```

### Meri/Kari Check (Shakuhachi)
```
Meri depth: ___ semitones (typical: 0.5-1.5)
Kari range: ___ semitones (typical: 0.2-0.5)
Cadential meri present? Yes / No
Timbral change with pitch bend? Yes / No
```

### Sawari Check (Shamisen)
```
Buzz audible on attack? Yes / No
Buzz frequency appropriate? Yes / No
Rattling sustain present? Yes / No
```

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
2. Does the brightness match? (Shakuhachi: breathy, Koto: bright, Shamisen: buzzy)
3. Is the attack right? (Koto: pluck, Shamisen: percussive, Shakuhachi: soft onset)
4. Does it sound acoustic or obviously synthetic?
5. If multiple voices, are the roles clear?
6. Is there appropriate "space" or ambience?

### Measurement
```
sc_get_analysis → timbre
- Spectral centroid: ___ Hz (expected: ___ Hz)
- Spectral flatness: ___ (tonal < 0.1, breathy/noisy > 0.3)
- Inferred waveform: ___

sc_get_spectrum → frequency bands
- Low (60-250 Hz): ___
- Mid (250-2000 Hz): ___
- High (2000-16000 Hz): ___
```

### Instrument Reference Centroids

| Instrument | Approx. Centroid Range | Attack |
|------------|----------------------|--------|
| Taiko | 80-500 Hz | Percussive |
| Biwa | 800-2000 Hz | Percussive/buzzy |
| Shakuhachi | 800-2000 Hz | Soft/breathy |
| Shamisen | 1000-3000 Hz | Percussive/buzzy |
| Sanshin | 1200-2500 Hz | Plucked |
| Koto | 1500-4000 Hz | Plucked/bright |
| Sho | 1000-2500 Hz | Continuous |

### Heterophony Check (Ensemble pieces)
```
Multiple voices playing same melody? Yes / No
Timing variation between voices: ___ ms (typical: 50-150ms)
Individual ornaments per voice? Yes / No
"Blurred unison" effect achieved? Yes / No
Vertical alignment avoided? Yes / No
```

### Kakegoe Check (Taiko/Festival)
```
Vocal calls present? Yes / No
Call types used: Iya / Ha / Sore / Yo / Ho
Rhythmic function of calls: Accent / Fill / Coordination
Energy contribution appropriate? Yes / No
```

**Score: __ /10**

---

## 6. Dynamics & Expression (0-10)

### Accuracy
- [ ] Dynamic range appropriate for style
- [ ] Crescendos/decrescendos feel musical
- [ ] Intensity follows breath phrasing
- [ ] Emotional arc present

### Questions
1. Is there dynamic variety or is it flat?
2. Does intensity build within phrases?
3. For shakuhachi: do dynamics follow breath naturally?
4. For min'yo: is there emotional weight in the delivery?
5. Does the overall energy level match the style?
6. Is there contrast between sections (jo-ha-kyu)?

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
- [ ] Jo-ha-kyu structure present where appropriate
- [ ] Section lengths appropriate
- [ ] Transitions between sections convincing
- [ ] Overall duration suitable

### Questions
1. Can you identify distinct sections?
2. Is there a jo-ha-kyu arc (introduction → development → rapid conclusion)?
3. Are phrase lengths consistent with breath phrasing?
4. Do transitions feel smooth or jarring?
5. Is there a sense of beginning, middle, and end?
6. For min'yo: does it have verse/refrain structure?

### Structure Diagram
```
Draw or describe the structure:

Section:    |_______|_______|_______|_______|
Name:
Duration:
Tempo:
Character:
```

### Jo-Ha-Kyu Check
```
Jo (introduction): ___ seconds, tempo: ___
Ha (development): ___ seconds, tempo: ___
Kyu (conclusion): ___ seconds, tempo: ___

Does tempo naturally accelerate? Yes / No
```

**Score: __ /10**

---

## 8. Authenticity & Feel (0-10)

### Subjective Assessment
- [ ] Would pass the "blind test" as Japanese folk
- [ ] Evokes the right emotional response
- [ ] Has the appropriate "Japanese character"
- [ ] Doesn't sound like a different folk tradition

### Questions
1. If you played this for someone familiar with Japanese music, would they recognize it?
2. Does it evoke the right imagery? (Mountain temple, festival, ocean, rice fields?)
3. Does it have "soul" or does it feel sterile?
4. What's missing that would make it more authentic?
5. What elements feel most successful?
6. Does the use of silence (ma) feel intentional and meaningful?

### The "Ma" Test
Japanese music philosophy emphasizes:
- [ ] Silence is as important as sound
- [ ] Space between notes feels intentional
- [ ] Overall pace reflects natural breathing

### Regional Check
Does it correctly evoke the target region?
- [ ] Mainland general (Yo scale, shamisen)
- [ ] Okinawa (Ryukyu scale, sanshin, sanba)
- [ ] Amami (high-pitched vocals, shima-uta style)
- [ ] Tsugaru (fast futozao shamisen, virtuosic)
- [ ] Tohoku (agricultural themes, Soran Bushi style)
- [ ] Niigata/Echigo (Sado Okesa, graceful)
- [ ] Kansai (festival, Gion Bayashi)

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
| Rhythm/Ma | | | |
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
| 2. Rhythm & Ma | /10 | 1.5x | |
| 3. Melodic Contour | /10 | 1.0x | |
| 4. Ornamentation | /10 | 1.25x | |
| 5. Timbre & Texture | /10 | 1.0x | |
| 6. Dynamics | /10 | 0.75x | |
| 7. Structure | /10 | 1.0x | |
| 8. Authenticity | /10 | 1.5x | |
| 9. Technical | /10 | 0.5x | |
| 10. Reference Match | /10 | 1.5x | |

**Total: ___ / 115** (divide by 1.15 to normalize to 100)

### Weight Rationale
- **Ornamentation 1.25x**: Kobushi is essential for min'yo authenticity
- **Dynamics 0.75x**: Breath dynamics important for wind instruments
- **Timbre includes heterophony** assessment for ensemble pieces

### Rating Scale

| Score | Rating | Interpretation |
|-------|--------|----------------|
| 90-100 | Excellent | Could fool an expert |
| 75-89 | Good | Clearly Japanese, minor issues |
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
