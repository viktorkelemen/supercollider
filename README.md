# SuperCollider Experiments

A collection of experimental SuperCollider sketches exploring sound synthesis, algorithmic composition, and various musical styles.

## Overview

This repository contains live coding experiments organized into several categories:

### Artists (47 files)
Studies inspired by electronic and experimental musicians:
- **Ambient/Drone**: Tim Hecker, Éliane Radigue, Stars of the Lid, William Basinski, Loscil
- **Electronic/IDM**: Autechre, Aphex Twin, Boards of Canada, µ-Ziq, Squarepusher
- **Dub Techno**: Deepchord, Porter Ricks, Pole, Vladislav Delay
- **Glitch/Noise**: Oval, Alva Noto, Ryoji Ikeda, Fennesz, Pan Sonic
- **Modular/Synth**: Caterina Barbieri, Suzanne Ciani, Kaitlyn Aurelia Smith
- **Minimalist**: Midori Takada, Hiroshi Yoshimura, Beverly Glenn-Copeland

### Techniques
Explorations of specific synthesis and composition approaches:
- **Bouncing Ball** — Physics-based rhythm generation using gravity simulations
- **Shepard Tones** — Auditory illusions and infinite pitch spirals
- **Mark Fell** — Algorithmic rhythm and perceptual pattern studies

### Studies
In-depth research projects:
- **Hungarian Folk** — Verbunkos, csárdás, hallgató, and magyar nóta styles with authentic ornamentation
- **Dub Techno** — Chord progressions, delays, and spatial processing
- **Recreations** — Covers including Steve Reich and Manuel Göttsching's E2-E4

### Experiments
Miscellaneous work-in-progress sketches and sound design explorations.

## Requirements

- [SuperCollider](https://supercollider.github.io/) 3.x
- [SuperDirt](https://github.com/musikinformatik/SuperDirt) (Quark)

## Getting Started

1. Open SuperCollider IDE
2. Boot the server: `s.boot` or press **Cmd-B**
3. Load the startup configuration:
   ```supercollider
   "/path/to/core/superdirt_startup.scd".load;
   ```
4. Load synth definitions:
   ```supercollider
   "/path/to/core/synthdefs.scd".load;
   ```
5. Open any `.scd` file and evaluate code blocks with **Cmd-Enter**

## Project Structure

```
supercollider/
├── core/           # Startup and synth definitions
├── artists/        # Artist-inspired experiments
├── techniques/     # Technique explorations
├── studies/        # Research projects
├── experiments/    # WIP sketches
├── tools/          # Utility scripts
└── output/         # Recorded audio
```

## License

These are personal experiments for learning and exploration.
