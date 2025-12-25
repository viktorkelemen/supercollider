# Verbunkos Sound Gallery - Minimal Prototype

Live synthesis of Hungarian folk music experiments using SuperSonic (SuperCollider in the browser).

## Quick Start

### 1. Compile the SynthDef

Open SuperCollider and run:

```supercollider
s.boot;
"/path/to/web-gallery/compile-synthdefs.scd".load;
```

This creates `synthdefs/cimbalom.scsyndef`.

### 2. Download SuperSonic

```bash
cd web-gallery
npm init -y
npm install supersonic-scsynth-bundle
```

Or download manually from [SuperSonic releases](https://github.com/samaaron/supersonic/releases).

### 3. Set Up the Folder Structure

```
web-gallery/
├── index.html
├── compile-synthdefs.scd
├── supersonic/                  ← Copy from node_modules/supersonic-scsynth-bundle/dist/
│   ├── supersonic.js
│   ├── wasm/
│   ├── workers/
│   └── synthdefs/
│       ├── sonic-pi-*.scsyndef  ← Built-in synths
│       └── cimbalom.scsyndef    ← Your compiled synth (copy from synthdefs/)
└── README.md
```

### 4. Serve with Correct Headers

SuperSonic requires `SharedArrayBuffer`, which needs specific security headers.

**Option A: Python (quick test)**
```bash
# Won't work for SharedArrayBuffer, but useful for debugging HTML/JS
python3 -m http.server 8000
```

**Option B: Node.js with headers**
```bash
npm install -g http-server
npx http-server -p 8000 --cors -c-1 \
  -S -C cert.pem -K key.pem \
  --header "Cross-Origin-Opener-Policy: same-origin" \
  --header "Cross-Origin-Embedder-Policy: require-corp"
```

**Option C: Vite (recommended for development)**
```bash
npm install -D vite
```

Create `vite.config.js`:
```javascript
export default {
  server: {
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp'
    }
  }
}
```

Run:
```bash
npx vite
```

### 5. Open in Browser

Navigate to `http://localhost:8000` (or whatever port you're using).

Click anywhere to initialize audio, then click **Play** to hear the cimbalom arpeggio.

## How It Works

### SynthDef Compilation

SuperCollider compiles SynthDefs to a binary format (`.scsyndef`). This file contains the synthesis graph that scsynth (the synthesis server) executes.

```supercollider
SynthDef(\cimbalom, { ... }).writeDefFile(outputDir);
```

### SuperSonic

SuperSonic runs the actual SuperCollider synthesis engine (scsynth) compiled to WebAssembly. It:
1. Loads `.scsyndef` files
2. Accepts OSC commands (`/s_new`, `/n_set`, `/n_free`)
3. Outputs audio via Web Audio API

### The Experiment

The cimbalom arpeggio plays 8 notes from the Hungarian minor scale:
- Scale degrees: 0, 2, 4, 6, 7, 6, 4, 2
- Note interval: 120ms
- Stereo panning spreads across the sound field

## Troubleshooting

### "SharedArrayBuffer is not defined"
You need to serve with the correct COOP/COEP headers. Use Vite or configure your server.

### "Failed to load SynthDef"
1. Check that `cimbalom.scsyndef` is in `supersonic/synthdefs/`
2. Verify the file was created by running the compile script

### No sound
1. Check browser console for errors
2. Ensure you clicked to initialize audio (browser autoplay policy)
3. Check your system audio output

## Next Steps

To add more experiments:
1. Add more SynthDefs to `compile-synthdefs.scd`
2. Create experiment functions in `index.html` (or separate JS files)
3. Add UI cards for each experiment

The full gallery would include:
- 8 violin experiments
- 8 cimbalom experiments
- 8 brácsa experiments
- 8 ornament experiments
- 6 rhythm experiments
- 5 scale experiments
