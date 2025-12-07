# SuperCollider Project

SuperCollider live coding environment with SuperDirt integration.

## File Structure

- `superdirt_startup.scd` - Server boot configuration and SuperDirt initialization
- `test.scd` - SynthDef library with custom synthesizers

## Dependencies

- **SuperCollider 3.x** - Audio synthesis platform
- **SuperDirt** - Sample playback and synthesis framework (Quark)

## Running the Project

1. Open SuperCollider IDE
2. Load startup file: `"path/to/superdirt_startup.scd".load`
3. Wait for server boot and "loaded successfully" message
4. Load synth definitions: `"path/to/test.scd".load`

The startup configures 12 orbits (`~d1` through `~d12`) for multichannel output.

## Coding Conventions

### Naming
- Environment variables use tilde prefix: `~dirt`, `~d1`, `~startupMessage`
- SynthDef names use backslash symbols: `\pitch`, `\gate`, `\saw`
- Local variables use camelCase: `portamento`, `stepsPerOctave`
- Classes use PascalCase: `SynthDef`, `EnvGen`, `OffsetOut`

### Code Blocks
- Wrap independent blocks in parentheses `( ... )` for selective evaluation
- Use `.add` to register SynthDefs globally
- Use `.load` to execute external files

---

## Server

### Booting
```supercollider
s.boot;                  // Boot default server
s.quit;                  // Stop server
s.reboot { };            // Reboot with callback for options
Server.default.boot;     // Explicit reference
```

Keyboard shortcut: **Cmd-B** (macOS) / **Ctrl-B** (Windows/Linux)

The status bar turns green when the server is running.

### Server Options
Configure before booting in a `s.reboot { }` block:
```supercollider
s.options.numBuffers = 1024 * 256;      // Sample buffer count
s.options.memSize = 8192 * 32;          // Memory allocation
s.options.numWireBufs = 2048;           // Interconnect buffers
s.options.maxNodes = 1024 * 32;         // Maximum nodes
s.options.numOutputBusChannels = 8;     // Hardware outputs
s.options.numInputBusChannels = 2;      // Hardware inputs
s.latency = 0.2;                        // Scheduling latency
```

---

## Functions

Functions are reusable code blocks enclosed in curly brackets.

### Basic Syntax
```supercollider
// Define a function
f = { "Hello".postln };
f.value;  // Execute it

// With arguments
f = { arg a, b; a + b };
f.value(2, 3);  // Returns 5

// Pipe syntax (preferred in this project)
f = { |a, b| a * b };
f.value(4, 5);  // Returns 20

// Keyword arguments
f = { |a, b| a / b };
f.value(b: 2, a: 10);  // Returns 5

// Default values
f = { |a, b = 2| a + b };
f.value(3);  // Returns 5
```

### Local Variables
```supercollider
f = { |a, b|
  var sum, result;
  sum = a + b;
  result = sum * 2;
  result  // Last expression is returned
};
```

### Audio Functions
```supercollider
// Quick audio test (auto-creates SynthDef)
{ SinOsc.ar(440, 0, 0.2) }.play;

// Stereo
{ SinOsc.ar([440, 442], 0, 0.2) }.play;
```

---

## SynthDefs & Synths

SynthDefs are compiled templates; Synths are running instances.

### Structure (This Project's Convention)
```supercollider
SynthDef(\name, {
  |
  out,
  channel,
  amp = 1,
  param = default_value |
  var localVar;
  // signal processing
  OffsetOut.ar(channel, signal * amp);
}).add;
```

### Common Parameters
- `out` - Standard output bus (often unused with OffsetOut)
- `channel` - Target output channel
- `amp` - Amplitude control (0-1)
- `delta` - Duration in seconds
- `rate` - Speed/frequency multiplier
- `begin`, `end` - Envelope phase endpoints

### Creating and Playing
```supercollider
// Define and register
SynthDef(\mySynth, { |out = 0, freq = 440, amp = 0.2|
  Out.ar(out, SinOsc.ar(freq, 0, amp))
}).add;

// Instantiate
x = Synth(\mySynth);
y = Synth(\mySynth, [\freq, 660]);
z = Synth(\mySynth, [\freq, 880, \amp, 0.1]);

// Modify running synth
x.set(\freq, 550);
x.set(\freq, 330, \amp, 0.3);

// Stop
x.free;
s.freeAll;  // Free all synths
```

### Output UGens
```supercollider
Out.ar(bus, signal)        // Standard output
OffsetOut.ar(bus, signal)  // Sample-accurate timing (used in this project)
```

### Randomness in SynthDefs
```supercollider
// Rand is evaluated once per synth instance
SynthDef(\randomFreq, { |out = 0|
  Out.ar(out, SinOsc.ar(Rand(400, 800), 0, 0.2))
}).add;
```

---

## Busses

Busses route signals between synths and hardware.

### Bus Layout (Stereo Example)
- Bus 0-1: Hardware outputs
- Bus 2-3: Hardware inputs
- Bus 4+: Private busses for inter-synth routing

### Creating Busses
```supercollider
// Allocate (auto-assigns index)
b = Bus.audio(s);           // 1 audio channel
b = Bus.audio(s, 2);        // 2 audio channels
c = Bus.control(s, 1);      // 1 control channel

b.index;   // Get assigned bus number
b.free;    // Release when done
```

### Reading and Writing
```supercollider
// Write to bus
Out.ar(busIndex, signal);
Out.kr(busIndex, controlSignal);

// Read from bus
In.ar(busIndex, numChannels);
In.kr(busIndex, numChannels);
```

### Synth Ordering
Synths reading from a bus must execute AFTER the source synth:
```supercollider
// Source synth
x = Synth(\source);

// Effect synth - must come after source
y = Synth.after(x, \effect);
// or
y = Synth(\effect, [\in, b.index], x, \addAfter);
```

### Control Bus Mapping
```supercollider
b = Bus.control(s, 1);
b.set(440);                    // Set constant value

x = Synth(\mySynth);
x.map(\freq, b);               // Connect synth arg to bus

// Now modulate via another synth
{ Out.kr(b, SinOsc.kr(1, 0, 100, 440)) }.play;
```

---

## Buffers

Server-side arrays for audio data and samples.

### Allocation
```supercollider
// By frames
b = Buffer.alloc(s, 44100, 2);           // 1 second stereo at 44.1kHz

// By duration
b = Buffer.alloc(s, s.sampleRate * 5, 1); // 5 seconds mono

b.free;  // Release memory
```

### Loading Sound Files
```supercollider
b = Buffer.read(s, "/path/to/file.wav");

// With action callback (operations are async!)
b = Buffer.read(s, "/path/to/file.wav", action: { |buf|
  "Loaded % frames".format(buf.numFrames).postln;
});
```

### Buffer Info
```supercollider
b.bufnum;       // Buffer number
b.numFrames;    // Length in samples
b.numChannels;  // Channel count
b.sampleRate;   // Sample rate
b.duration;     // Length in seconds
```

### Playback with PlayBuf
```supercollider
SynthDef(\player, { |out = 0, bufnum, rate = 1, amp = 1|
  var sig;
  sig = PlayBuf.ar(
    1,                           // numChannels (fixed at compile time)
    bufnum,
    BufRateScale.kr(bufnum) * rate,  // Correct pitch for sample rate
    doneAction: 2                // Free synth when done
  );
  Out.ar(out, sig * amp);
}).add;

Synth(\player, [\bufnum, b.bufnum]);
```

### Streaming Large Files
```supercollider
// Cue for disk streaming (low memory)
b = Buffer.cueSoundFile(s, "/path/to/large.wav", 0, 1);

SynthDef(\diskPlayer, { |out = 0, bufnum|
  Out.ar(out, DiskIn.ar(1, bufnum))
}).add;
```

### Recording to Buffer
```supercollider
b = Buffer.alloc(s, s.sampleRate * 10, 1);  // 10 seconds

SynthDef(\recorder, { |bufnum, in = 0|
  RecordBuf.ar(SoundIn.ar(in), bufnum);
}).add;

x = Synth(\recorder, [\bufnum, b.bufnum]);
```

### Quick Buffer Methods
```supercollider
b.plot;           // Visualize waveform
b.play;           // Quick playback
b.play(true);     // Looped playback
```

---

## Patterns

Patterns generate streams of values for sequencing.

### Pbind (Event Patterns)
```supercollider
(
p = Pbind(
  \instrument, \default,
  \midinote, Pseq([60, 62, 64, 65, 67], inf),
  \dur, 0.25,
  \amp, 0.3
).play;
)

p.stop;
```

### Common Patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| `Pseq` | Sequential | `Pseq([1, 2, 3], inf)` |
| `Prand` | Random choice | `Prand([1, 2, 3], inf)` |
| `Pxrand` | Random, no repeats | `Pxrand([1, 2, 3], inf)` |
| `Pshuf` | Shuffle once | `Pshuf([1, 2, 3], 1)` |
| `Pwrand` | Weighted random | `Pwrand([1, 2], [0.8, 0.2], inf)` |
| `Pwhite` | Uniform random | `Pwhite(0, 100, inf)` |
| `Pexprand` | Exponential random | `Pexprand(100, 1000, inf)` |
| `Pseries` | Arithmetic series | `Pseries(0, 1, 10)` |
| `Pgeom` | Geometric series | `Pgeom(1, 2, 8)` |
| `Pn` | Repeat pattern | `Pn(Pseq([1,2]), 4)` |

### Nested Patterns
```supercollider
(
Pbind(
  \instrument, \default,
  \midinote, Pseq([
    Prand([60, 62, 64], 4),
    Pseq([72, 71, 69, 67], 1)
  ], inf),
  \dur, Pwhite(0.1, 0.3, inf)
).play;
)
```

### Pattern Keys
```supercollider
\instrument  // SynthDef name
\midinote    // MIDI note (60 = middle C)
\freq        // Frequency in Hz
\dur         // Duration until next event
\sustain     // Note length
\amp         // Amplitude
\pan         // Stereo position (-1 to 1)
\out         // Output bus
```

---

## MIDI

### Connecting to MIDI Devices
```supercollider
MIDIClient.init;
MIDIIn.connectAll;

MIDIClient.sources;       // List inputs
MIDIClient.destinations;  // List outputs
```

### Sending MIDI
```supercollider
~midiOut = MIDIOut.newByName("Device Name", "Port Name");

~midiOut.noteOn(0, 60, 100);   // channel, note, velocity
~midiOut.noteOff(0, 60, 0);
~midiOut.control(0, 1, 64);    // channel, cc, value
~midiOut.program(0, 5);        // channel, program
~midiOut.bend(0, 8192);        // channel, value (8192 = center)
```

### Receiving MIDI
```supercollider
MIDIdef.noteOn(\myNoteOn, { |vel, note, chan, src|
  ["Note On", note, vel, chan].postln;
});

MIDIdef.noteOff(\myNoteOff, { |vel, note, chan, src|
  ["Note Off", note].postln;
});

MIDIdef.cc(\myCC, { |val, num, chan, src|
  ["CC", num, val].postln;
}, ccNum: 1);  // nil for all CCs

MIDIdef.bend(\myBend, { |val, chan, src|
  ["Bend", val].postln;
});
```

### MIDI Cleanup
```supercollider
MIDIdef(\myNoteOn).free;   // Remove specific
MIDIdef.freeAll;           // Remove all
MIDIClient.disposeClient;  // Disconnect
```

### MIDI to Frequency
```supercollider
60.midicps;  // Returns 261.63 (middle C)
440.cpsmidi; // Returns 69 (A4)
```

---

## Common Workflows

### Adding a New SynthDef
1. Create the definition in `test.scd` wrapped in parentheses
2. Follow the existing parameter conventions (`out`, `channel`, `amp`)
3. Use `OffsetOut.ar()` for sample-accurate output timing
4. End with `.add` to register

### Testing a Synth
```supercollider
Synth(\synthName, [\param1, value1, \param2, value2]);
s.freeAll;
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "alloc failed" | Increase `s.options.memSize` |
| "exceeded interconnect buffers" | Increase `s.options.numWireBufs` |
| "too many nodes" | Increase `s.options.maxNodes` |
| "late" messages | Increase `s.latency` |
| Need more samples | Increase `s.options.numBuffers` |
| MIDI device not found | Check `MIDIClient.sources` for exact name |
| MIDI not responding | Ensure `MIDIIn.connectAll` was called |
| Buffer not playing | Check `numChannels` matches in PlayBuf |
| Synth not receiving bus | Check synth ordering with `.after` |

---

## Resources

- [SuperCollider Documentation](http://doc.sccode.org/)
- [ServerOptions Reference](http://doc.sccode.org/Classes/ServerOptions.html)
- [SynthDef Reference](http://doc.sccode.org/Classes/SynthDef.html)
- [Buffer Reference](http://doc.sccode.org/Classes/Buffer.html)
- [Bus Reference](http://doc.sccode.org/Classes/Bus.html)
- [Pattern Guide](http://doc.sccode.org/Tutorials/A-Practical-Guide/PG_01_Introduction.html)
- [MIDIOut Reference](http://doc.sccode.org/Classes/MIDIOut.html)
- [MIDIdef Reference](http://doc.sccode.org/Classes/MIDIdef.html)
- [SuperDirt GitHub](https://github.com/musikinformatik/SuperDirt)
