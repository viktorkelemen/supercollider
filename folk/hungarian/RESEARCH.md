# Hungarian Folk Music Research

A comprehensive guide for creating SuperCollider experiments based on Hungarian folk music traditions.

---

## Table of Contents

1. [Historical Overview](#historical-overview)
2. [Musical Styles](#musical-styles)
3. [Regional Dialects](#regional-dialects)
4. [Scales and Modes](#scales-and-modes)
5. [Rhythmic Patterns](#rhythmic-patterns)
6. [Song Structure](#song-structure)
7. [Traditional Instruments](#traditional-instruments)
8. [Key Figures and Artists](#key-figures-and-artists)
9. [Listening References](#listening-references)
10. [Implementation Notes](#implementation-notes)

---

## Historical Overview

### The Bartók-Kodály Revolution

In the early 20th century, composers **Béla Bartók** and **Zoltán Kodály** systematically collected and documented Hungarian peasant music, distinguishing it from the popular "Gypsy music" that had been mistakenly considered authentic Hungarian music.

- **1904**: Bartók overhears a Transylvanian nanny singing folk songs, sparking his lifelong dedication
- **1908**: Bartók and Kodály begin field collection trips using Edison wax cylinder phonographs
- **10,000+ songs** collected and transcribed
- Discovered that authentic Magyar folk melodies are based on **pentatonic scales**, similar to Central Asian traditions

### The Táncház Movement

The **táncház** ("dance house") revival began on **May 6, 1972** in Budapest:

- Grassroots movement rejecting state-sanitized folk presentations
- Musicians like **Ferenc Sebő** and **Béla Halmos** followed Bartók's path to Transylvanian villages
- Created spaces for authentic music and dance participation
- Listed on **UNESCO's Intangible Cultural Heritage** list
- Continues today from Toronto to Tokyo

---

## Musical Styles

### 1. Verbunkos (Recruitment Dance)

**Origin**: 18th century Austrian army recruitment dances

**Structure**: Binary form with contrasting sections
- **Lassú** (slow): Melancholic, dotted rhythms, rubato
- **Friss** (fast): Energetic, virtuosic, strict tempo

**Characteristics**:
- Dotted rhythms (long-short patterns)
- **Bokázó** cadence (heel-clicking rhythm pattern)
- Augmented second intervals (Hungarian minor scale)
- Garlands of triplet ornaments
- Wide-arched, free melodies
- Typically for solo male dancer

**Classical Influence**: Mozart, Haydn, Schubert, and especially Liszt's Hungarian Rhapsodies drew heavily from verbunkos.

**Time Signature**: 2/4 or 4/4

---

### 2. Csárdás

**Origin**: 1830s, evolved from verbunkos as the national couple dance

**Name**: From "csárda" (roadside tavern)

**Structure**: Tempo variation is the defining feature
- **Lassú** (slow opening)
- **Friss** (fast finale, literally "fresh")

**Variants**:
- **Ritka csárdás** (sparse)
- **Sűrű csárdás** (dense)
- **Szökős csárdás** (leaping)
- **Széki csárdás** (from Szék/Sic village)

**Time Signature**: 2/4 or 4/4

**Notable Classical Works**:
- Brahms, Liszt, Tchaikovsky, Vittorio Monti's "Csárdás"

---

### 3. Magyar Nóta (Hungarian Popular Song)

**Origin**: 19th century, created by middle-class amateur composers

**Characteristics**:
- Combines verbunkos with Italian-Viennese influences
- Performed by Roma (Gypsy) musicians
- Lyrical songs accessible to all social classes
- Often sentimental or dramatic

**Tempi Range**:
- Uptempo friss csárdás
- Medium "Palotás" (palace dance)
- Slow dramatic **tempo rubato** ballads

**Performance Context**: Restaurants, taverns, noble mansions, theaters

**Notable Composers**: Lóránd Fráter, Árpád Balázs, Pista Dankó, Béni Egressy

---

### 4. Hallgató (Listening Song)

**Meaning**: "A song for listening to, not for dancing"

**Style**: **Parlando rubato** - rhythmically free, speech-like delivery

**Characteristics**:
- Heavily ornamented melodies
- Emotional, often melancholic
- Tempo follows the natural rhythm of words
- Connected to ancient lament traditions

**Performance**: Solo vocal, intimate settings

---

### 5. Legényes (Lad's Dance)

**Origin**: Transylvanian men's solo dance

**Regions**: Kalotaszeg, Mezőség, Central Maros River area

**Characteristics**:
- The most virtuosic Eastern European dance
- Freestyle improvisation in front of the band
- Women stand aside singing verses
- Athletic movements: jumping, spinning, intricate footwork

---

## Regional Dialects

### Great Hungarian Plain (Alföld)

- Heartland of Hungarian folk music
- Fast-paced, rhythmic tunes
- Strong violin presence
- Birthplace of csárdás

### Transylvania (Erdély)

The most important region for authentic Hungarian folk traditions.

**Kalotaszeg** (Western Transylvania):
- ~40 Hungarian-speaking villages
- Documented extensively by Bartók
- Distinctive embroidery and painted furniture traditions
- Home of the **legényes** dance

**Szék (Sic)**:
- Origin of the term "táncház"
- Monthly dance houses continue today
- Famous for **Széki csárdás**

**Characteristics of Transylvanian Music**:
- Blends Hungarian, Romanian, and Roma influences
- Highly improvisational
- Uses **brácsa** (3-stringed viola) for rhythm
- **Gardon** (struck cello) for percussive drive

### Székely Region

- Vibrant, intricate melodies
- Strong improvisational tradition

### Northern Hungary / Matyó Region

- Heavy use of bagpipes (duda) and flutes
- Distinctively rhythmic wind-based music

### Csángó Region

- Minimal instrumentation: violin + **ütőgardon** only
- Ancient, archaic style

---

## Scales and Modes

### 1. Pentatonic Scale (Archaic Style)

The foundation of old-style Hungarian folk music.

**Structure**: 5 notes with no half-steps

**Common Form**: Anhemitonic pentatonic
```
Degrees: 1 - 2 - 3 - 5 - 6
Example in C: C - D - E - G - A
```

**Characteristics**:
- Soft, harmonious sound
- Found in archaic peasant songs
- Shared with Central Asian, Chinese, Celtic, and Japanese traditions
- Often modified with European chromatic influence

**Bartók's Observation**: The equal value of 3rd, 5th, and 7th scale degrees and prominence of the perfect 4th influenced his use of quartal harmonies.

---

### 2. Hungarian Minor Scale

Also called: **Double Harmonic Minor** or **Gypsy Minor**

**Structure**: Harmonic minor with raised 4th degree
```
Intervals: W - H - + - H - H - + - H
(W=whole, H=half, +=augmented 2nd)

Degrees: 1 - 2 - b3 - #4 - 5 - b6 - 7
Example in A: A - B - C - D# - E - F - G#
```

**Characteristics**:
- Two augmented seconds (exotic sound)
- Augmented 4th between 1st and 4th degrees
- Dramatic, passionate quality
- Characteristic of verbunkos and csárdás

---

### 3. Gypsy Scale (Hungarian Major)

Used extensively by Liszt in his Hungarian works.

**Characteristics**:
- Arabic origin, brought by Roma travelers
- Creates the distinctive "Hungarian" sound in classical music
- Various forms exist

---

### 4. Modal Variations

Old-style songs may use:
- **Dorian mode** (natural 6th, flat 7th)
- **Mixolydian mode** (flat 7th)
- Chromatic alterations within pentatonic framework

---

## Rhythmic Patterns

### The Verbunkos Rhythm

**Primary Pattern**: Dotted eighth + sixteenth note
```
♩. ♪  or  ♪. ♬
Long-short, creating propulsive march quality
```

### Bokázó (Heel-Click) Cadence

Characteristic cadential figure from verbunkos.
```
Often: ♩ ♩ | ♩ ♩ ♩ ||
Ending with rhythmic "clicks"
```

### Syncopation

- Off-beat accents create tension
- More intense in friss (fast) sections
- Dactylic patterns from Hungarian language stress (first-syllable emphasis)

### Rubato

- **Tempo rubato**: Free rhythmic interpretation
- **Parlando rubato**: Speech-like, following word rhythms
- Essential for hallgató and slow verbunkos sections

### Time Signatures

| Style | Time Signature |
|-------|---------------|
| Verbunkos | 2/4, 4/4 |
| Csárdás | 2/4, 4/4 |
| Legényes | Varies |
| Nóta | Varies by tempo |

---

## Song Structure

### Bartók's Classification System

**Class A (Old Style)**:
- Descending melodic line
- Pentatonic scale
- Fifth construction: A⁵A⁵AA or A⁵B⁵AB
- (Melody repeats a 5th lower)

**Class B (New Style)**:
- Reprise/returning structures
- AABA, ABBA, AA⁵A⁵A, AA⁵BA forms
- Two types of melody lines
- Wider range, more syllables per line
- Arched melodic contour

**Class C (Mixed)**:
- Everything else

### The Fifth Construction

A signature feature: first half of tune repeats a **perfect 5th lower**.
```
A⁵ = A transposed down a 5th
Example: A⁵A⁵AA or A⁵B⁵AB
```

### ABBA and Related Forms

Characteristic of Hungarian and Finno-Ugric traditions:
- **ABBA**: Opening line returns as conclusion
- **AA'A'A**: A' is A transposed by a 5th
- **AABA**: Common song form

### Melodic Contour

| Style | Contour |
|-------|---------|
| Old style | Always descending |
| New style | Arched (rise then fall) |
| Verbunkos | Wide-arched, ornamental |

---

## Traditional Instruments

### String Instruments

**Violin (Hegedű)**
- Most popular Hungarian instrument
- Tradition from medieval minstrels
- **Prímás** (first violin) plays melody in folk bands

**Brácsa (Viola)**
- 3-stringed in Transylvania
- Provides rhythmic accompaniment
- Characteristic of Transylvanian sound

**Double Bass (Nagybőgő)**
- Bass foundation in string bands

**Gardon / Ütőgardon**
- Cello-like instrument that is **struck, not bowed**
- Produces drum-like percussive rhythm
- Essential in Csángó music

**Cimbalom**
- Hammered dulcimer, ~125 strings
- National instrument of Hungary (proclaimed 1897)
- Created by V. József Schunda in 1874
- Damping pedal, 4-octave chromatic range
- Played with spoon-shaped wooden mallets

**Citera (Zither)**
- Most widely used folk instrument
- Various regional types

**Tambura**
- Long-necked plucked lute
- Fizzing, rhythmic sound

**Cobza**
- Short-necked lute

**Tekerő (Hurdy-Gurdy)**
- Solo instrument
- Produces drone, rhythm, and melody simultaneously

### Wind Instruments

**Tárogató**
- Single-reed woodwind (modern version by Schunda, 1890s)
- Sounds like mellow tenor saxophone
- Looks like primitive clarinet
- Historical symbol of Rákóczi's independence war
- Suppressed by Habsburgs in 18th century

**Duda (Bagpipe)**
- Prominent in Northern Hungary
- Ancient pastoral instrument

**Kanászkürt**
- Swineherd's horn

**Flutes**
- Various pastoral flutes

### Percussion

**Doromb (Jew's Harp)**
- Ancient, widespread

**Tambourine**
- Rhythmic accompaniment

### Typical Ensemble Configurations

**Standard Folk Band (String Trio)**:
- Violin (prímás) - melody
- Viola - rhythm/harmony
- Double bass - bass

**With Cimbalom**:
- String trio + cimbalom

**Csángó Duo**:
- Violin + ütőgardon only

---

## Key Figures and Artists

### Ethnomusicologists

| Name | Contribution |
|------|--------------|
| **Béla Bartók** (1881-1945) | Father of ethnomusicology, collected 10,000+ songs |
| **Zoltán Kodály** (1882-1967) | Historical research, Kodály Method pedagogy |
| **Béla Vikár** | Pioneer collector |
| **László Lajtha** | Continued documentation |

### Táncház Pioneers

| Name | Role |
|------|------|
| **Ferenc Sebő** | Founded first táncház (1972) |
| **Béla Halmos** | Co-founder, field collector |

### Contemporary Performers

**Muzsikás**
- Hungary's foremost folk ensemble
- WOMEX Lifetime Achievement Award (2008)
- Balance professional polish with raw village sound
- Long collaboration with Márta Sebestyén

**Márta Sebestyén**
- Icon of world music, best-known Hungarian ethno artist
- Mother was Kodály's pupil
- Sang with Muzsikás for many years

**Csík Zenekar**
- Kossuth Prize winners
- Founded 1988 in Kecskemét
- Traditional peasant folk music

**Fonó Folk Band**
- Based in Budapest since 1997
- Rich sound from instrument variety
- Also perform other regional ethnic music
- Members conduct ethnomusicological fieldwork

**Ghymes**
- Slovak-Hungarian band
- Táncház tradition with modern instrumentation
- World music category

**Parno Graszt**
- Rural Roma band from Pázság
- Fizzing tambura with guitars
- Soulful vocals

**Cimbaliband**
- Led by cimbalom virtuoso Balázs Unger
- Great party ensemble

**Kerekes Band**
- Founded 1995
- Mix authentic acoustic with electronics

**Bohemian Betyars**
- "Speed-folk freak-punk"
- Founded 2009

### Classical Composers Using Hungarian Elements

| Composer | Works |
|----------|-------|
| Franz Liszt | Hungarian Rhapsodies |
| Johannes Brahms | Hungarian Dances |
| Béla Bartók | Romanian Folk Dances, Hungarian Peasant Songs |
| Zoltán Kodály | Háry János, Dances of Galánta |
| György Ligeti | Hungarian Rock, Musica Ricercata |
| György Kurtág | Parlando rubato works |

---

## Listening References

### Essential Albums

Based on [Songlines Magazine's Essential 10](https://www.songlines.co.uk/features/essential-10/hungarian-folk-albums-the-essential-10):

1. **Muzsikás** - Various albums (start with any)
2. **Márta Sebestyén** - Solo and Muzsikás collaborations
3. **Csík Zenekar** - Traditional peasant music
4. **Parno Graszt** - Authentic Roma village music

### Historical Recordings

- Bartók's and Kodály's wax cylinder field recordings (digitized)
- "Living Hungarian Folk Music" series (1970s táncház recordings)

### Classical Interpretations

- Liszt: Hungarian Rhapsodies (especially No. 2, 6, 12)
- Brahms: Hungarian Dances
- Bartók: 15 Hungarian Peasant Songs, Romanian Folk Dances
- Kodály: Dances of Galánta

### Specific Styles to Study

| Style | What to Listen For |
|-------|-------------------|
| Verbunkos | Slow-fast contrast, dotted rhythms, ornamentation |
| Csárdás | Accelerating tempo, 2/4 drive |
| Hallgató | Rubato, ornamentation, emotional weight |
| Legényes | Rhythmic complexity, improvisation |
| Transylvanian | Brácsa and gardon rhythm, raw energy |

---

## Implementation Notes

### For SuperCollider Experiments

#### Scales

```supercollider
// Pentatonic (anhemitonic)
~pentatonic = [0, 2, 4, 7, 9];  // C D E G A

// Hungarian Minor
~hungarianMinor = [0, 2, 3, 6, 7, 8, 11];  // A B C D# E F G#

// With augmented seconds highlighted
~gypsy = [0, 1, 4, 5, 7, 8, 11];  // Variant
```

#### Rhythmic Patterns

```supercollider
// Verbunkos dotted rhythm
~verbunkosRhythm = [0.75, 0.25];  // dotted-eighth + sixteenth

// Bokázó cadence
~bokazo = [0.5, 0.5, 0.25, 0.25, 0.5];

// Csárdás acceleration
~csardasDurs = Array.interpolation(16, 0.5, 0.15);
```

#### Melodic Contours

```supercollider
// Descending old-style
~oldStyleContour = {|steps=8| Array.series(steps, 12, -1.5) };

// Arched new-style
~archedContour = {|steps=8|
    Array.fill(steps, {|i|
        sin(i / steps * pi) * 7
    })
};

// Fifth construction (A5A5AA)
~fifthConstruction = {|phrase|
    phrase ++ (phrase - 7) ++ (phrase - 7) ++ phrase
};
```

#### Ornamentation

- **Appoggiaturas**: Short grace notes before main notes
- **Trills**: On sustained notes, especially in slow sections
- **Slides**: Portamento between notes
- **Vibrato**: Wide, expressive vibrato on held notes

#### Tempo Rubato

```supercollider
// Simulate rubato with tempo variation
~rubatoEnv = Env([1, 0.8, 1.2, 0.9, 1], [1, 1, 1, 1]);
```

#### Ensemble Textures

| Role | Frequency Range | Character |
|------|----------------|-----------|
| Prímás (lead violin) | 200-2000 Hz | Melodic, ornamented |
| Brácsa (rhythm) | 150-800 Hz | Chordal, rhythmic chops |
| Bass | 40-200 Hz | Root notes, simple |
| Cimbalom | 100-4000 Hz | Arpeggiated, shimmering |
| Gardon | 80-300 Hz | Percussive strikes |

---

## Sources

### Wikipedia
- [Hungarian Folk Music](https://en.wikipedia.org/wiki/Hungarian_folk_music)
- [Music of Hungary](https://en.wikipedia.org/wiki/Music_of_Hungary)
- [Csárdás](https://en.wikipedia.org/wiki/Csárdás)
- [Béla Bartók](https://en.wikipedia.org/wiki/Béla_Bartók)
- [Hungarian Minor Scale](https://en.wikipedia.org/wiki/Hungarian_minor_scale)
- [Cimbalom](https://en.wikipedia.org/wiki/Cimbalom)
- [Tárogató](https://en.wikipedia.org/wiki/Tárogató)
- [Nóta](https://en.wikipedia.org/wiki/Nóta)

### Specialized Resources
- [Hungarian Folk Music Research](https://www.feheraniko.hu/en/ethnomusycology/hungarian-folk-music-research)
- [Bartók's Collection Database](https://bartok-gyujtesek.zti.hu/en)
- [Smithsonian Folklife - Kalotaszeg Region](https://festival.si.edu/2013/hungarian-heritage/the-kalaszotszeq-region/smithsonian)
- [World Music Network - Hungary Guide](https://worldmusic.net/blogs/guide-to-world-music/the-music-of-hungary)
- [Songlines - Hungarian Folk Essential 10](https://www.songlines.co.uk/features/essential-10/hungarian-folk-albums-the-essential-10)
- [Daily News Hungary - Contemporary Folk Bands](https://dailynewshungary.com/5-beloved-contemporary-hungarian-folk-bands/)

### Academic
- [Pentatonicism in Hungarian Folk Music - JSTOR](https://www.jstor.org/stable/849798) (Stephen Erdely, 1970)
- [Parlando Rubato - Britannica](https://www.britannica.com/art/parlando-rubato)
- [Folk Music in Bartók's Compositions](http://bartok-nepzene.zti.hu/en/introduction/)

---

## Experiment Ideas

### Beginner
1. **Pentatonic Melody Generator**: Random walks on pentatonic scale with descending tendency
2. **Csárdás Tempo Curve**: Simple melody that accelerates from lassú to friss
3. **Cimbalom Texture**: Tremolo synthesis with shimmering harmonics

### Intermediate
4. **Verbunkos SynthDef**: Dotted rhythms with bokázó cadences
5. **Fifth Construction**: Automatic transposition of melodic phrases
6. **Rubato Engine**: Tempo fluctuation for parlando style
7. **Brácsa Rhythm Section**: Rhythmic chordal accompaniment

### Advanced
8. **Full Csárdás Structure**: Complete slow-to-fast form with transitions
9. **Transylvanian Ensemble**: Multiple voices with proper role distribution
10. **Ornament Generator**: Context-aware grace notes and trills
11. **Gardon Simulation**: Struck string with percussive attack
12. **Hallgató Expression**: Deep rubato with emotional envelope shaping
