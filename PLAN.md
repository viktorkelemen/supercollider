# SC-REPL MCP Server Implementation Plan

## Overview

Build an MCP server that allows Claude Code to evaluate SuperCollider code via sclang and interact with the audio server.

## Architecture

```
Claude Code <--stdio--> sc-repl MCP Server <--supercolliderjs--> sclang/scsynth
```

**Language:** TypeScript (better type safety, official MCP SDK support)
**Communication:** stdio transport (local process)
**SC Interface:** supercolliderjs library (handles sclang spawning and OSC to scsynth)

## Tools to Implement

### 1. `sc_eval` - Evaluate SuperCollider Code
```typescript
{
  name: "sc_eval",
  description: "Evaluate SuperCollider code and return the result",
  inputSchema: {
    code: string,        // SC code to evaluate
    timeout?: number     // Optional timeout in ms (default 5000)
  }
}
```
**Returns:** Post window output, evaluated result, or error message

### 2. `sc_boot` - Boot the Audio Server
```typescript
{
  name: "sc_boot",
  description: "Boot the SuperCollider audio server",
  inputSchema: {
    options?: {
      numOutputBusChannels?: number,
      numInputBusChannels?: number,
      memSize?: number
    }
  }
}
```
**Returns:** Server status, sample rate, available busses

### 3. `sc_status` - Get Server Status
```typescript
{
  name: "sc_status",
  description: "Get current server status (running, CPU, synths, groups)",
  inputSchema: {}
}
```
**Returns:** CPU usage, num synths, num groups, sample rate

### 4. `sc_free_all` - Free All Synths
```typescript
{
  name: "sc_free_all",
  description: "Free all running synths on the server",
  inputSchema: {}
}
```
**Returns:** Confirmation message

### 5. `sc_list_synthdefs` - List Available SynthDefs
```typescript
{
  name: "sc_list_synthdefs",
  description: "List all registered SynthDef names",
  inputSchema: {}
}
```
**Returns:** Array of SynthDef names

### 6. `sc_midi_devices` - List MIDI Devices
```typescript
{
  name: "sc_midi_devices",
  description: "List available MIDI input and output devices",
  inputSchema: {}
}
```
**Returns:** Sources and destinations arrays

## Project Structure

```
sc-repl-mcp/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts          # MCP server entry point
│   ├── sc-client.ts      # SuperCollider connection manager
│   └── tools/
│       ├── eval.ts
│       ├── boot.ts
│       ├── status.ts
│       ├── free-all.ts
│       ├── list-synthdefs.ts
│       └── midi-devices.ts
└── README.md
```

## Dependencies

```json
{
  "dependencies": {
    "@modelcontextprotocol/sdk": "latest",
    "supercolliderjs": "^1.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  }
}
```

## Implementation Steps

### Phase 1: Basic Setup
1. Create project directory `sc-repl-mcp/`
2. Initialize npm project with TypeScript
3. Install dependencies
4. Set up basic MCP server with stdio transport

### Phase 2: SC Connection
1. Implement `sc-client.ts` singleton for managing sclang/scsynth
2. Handle boot, connection, and cleanup
3. Add error handling for server not running

### Phase 3: Core Tools
1. Implement `sc_boot` tool
2. Implement `sc_eval` tool with timeout handling
3. Implement `sc_status` tool
4. Implement `sc_free_all` tool

### Phase 4: Extended Tools
1. Implement `sc_list_synthdefs`
2. Implement `sc_midi_devices`

### Phase 5: Integration
1. Test with Claude Code
2. Register MCP server: `claude mcp add sc-repl -- node /path/to/sc-repl-mcp/dist/index.js`
3. Add to project `.mcp.json` for team sharing

## Usage Example

Once installed, Claude Code can:

```
User: Play a sine wave at 440Hz

Claude: I'll use the sc_eval tool to play a sine wave.
[Calls sc_eval with code: "{ SinOsc.ar(440, 0, 0.2) }.play"]

Result: Synth started, node ID 1000
```

## Error Handling

- **Server not booted:** Prompt user to run `sc_boot` first
- **Syntax errors:** Return sclang error message with line numbers
- **Timeout:** Kill long-running evaluations, return timeout error
- **Connection lost:** Attempt reconnect, report status

## Security Considerations

- MCP runs locally via stdio (no network exposure)
- SuperCollider code executes with user permissions
- No file system access beyond what SC normally has

## Future Enhancements

- `sc_record` - Record output to file
- `sc_load_synthdef` - Load .scsyndef files
- `sc_node_tree` - Visualize synth node tree
- Resources: Expose buffers and samples as MCP resources
