# STJSON Examples

These examples are small, copyable entry points for common STJSON tasks.

- `QuickStart.swift`: basic `JSON` access and Codable round trip
- `AnyCodableExample.swift`: heterogeneous JSON payloads
- `JSONLinesExample.swift`: NDJSON / JSON Lines processing
- `JSONRPCExample.swift`: JSON-RPC 2.0 protocol-layer decoding and response encoding

Each file is written as plain Swift functions so you can paste the parts you need into an app target, test target, or playground.

## Run

From the repository root:

```sh
swift run --package-path Examples
```

The nested package depends on the parent STJSON package through a local path dependency, so it exercises the same public package surface external users import.
