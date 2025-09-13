# chooselic API Reference

This document describes the internal API structure of chooselic for developers who want to understand or extend the codebase.

## Module Overview

### `chooselic/api.nim`
Handles GitHub API communication.

```nim
# Create API client
proc newApiClient*(): HttpClient

# Fetch available licenses
proc getLicenses*(client: HttpClient): seq[LicenseItem]

# Fetch specific license content
proc getLicense*(client: HttpClient, key: string): License
```

**Types:**
- `ApiError`: Exception type for API-related errors

### `chooselic/cache.nim`
Local caching system for licenses.

```nim
# Check if cache entry is expired
proc isCacheExpired*(cacheTime: DateTime): bool

# Get licenses with caching
proc getCachedLicenses*(client: HttpClient): seq[LicenseItem]

# Get specific license with caching
proc getCachedLicense*(client: HttpClient, key: string): License

# Cache management
proc saveLicenseListCache*(licenses: seq[LicenseItem])
proc loadLicenseListCache*(): seq[LicenseItem]
proc saveLicenseCache*(license: License)
proc loadLicenseCache*(key: string): License
```

### `chooselic/cli.nim`
Command-line argument parsing.

```nim
# CLI arguments structure
type CliArgs* = object
  license*: string
  author*: string
  year*: string
  help*: bool
  version*: bool
  interactive*: bool
  noSsl*: bool

# Parse command-line arguments
proc parseCliArgs*(): CliArgs

# Display help and version
proc showHelp*()
proc showVersion*()
```

### `chooselic/config.nim`
Configuration constants and helper functions.

```nim
# Constants
const version* = "0.1.0"
const cacheDir* = getHomeDir() / ".cache" / "chooselic"
const cacheExpiryHours* = 24

# Dynamic endpoint generation
proc getGithubApiBase*(useSsl: bool = true): string
proc getLicensesEndpoint*(useSsl: bool = true): string
proc getLicenseEndpoint*(useSsl: bool = true): string

# Utility
proc ensureCacheDir*()
```

### `chooselic/fuzzy.nim`
Fuzzy search implementation for license filtering.

```nim
# Fuzzy match result
type FuzzyMatch* = object
  item*: LicenseItem
  score*: int
  matched*: bool

# Perform fuzzy matching
proc fuzzyMatch*(pattern: string, licenses: seq[LicenseItem]): seq[FuzzyMatch]
```

### `chooselic/licenses.nim`
License data types and template processing.

```nim
# Core data types
type
  LicenseItem* = object
    key*, name*, spdx_id*, url*, node_id*, html_url*: string

  License* = object
    key*, name*, spdx_id*, url*, html_url*, node_id*: string
    description*, implementation*, body*: string
    permissions*, conditions*, limitations*: seq[string]

# Template processing
proc replaceAuthor*(author: string, key: string, text: string): string
proc replaceYear*(year: string, key: string, text: string): string
proc processLicense*(license: License, author: string, year: string): string

# Constants
const uncommonLicenses*: array[5, LicenseItem]
```

### `chooselic/ui.nim`
Terminal user interface for interactive mode.

```nim
# UI state management
type UiState* = enum
  licenseSelection, authorInput, yearInput, finished

type AppData* = object
  licenses*: seq[LicenseItem]
  selectedLicense*: LicenseItem
  author*, year*, searchQuery*: string
  state*: UiState
  exitApp*: bool

# UI functions
proc initAppData*(licenses: seq[LicenseItem], author: string = "", year: string = ""): AppData
proc showLicenseSelection*(app: var AppData): LicenseItem
proc getTextInput*(prompt: string, defaultValue: string = ""): string
proc showLicensePreview*(license: License, author: string, year: string)
```

## Error Handling

### Exception Types
- `ApiError`: Network or API-related errors
- `CatchableError`: General application errors
- `IOError`: File system errors

### Error Patterns
```nim
try:
  # API operation
  let result = getLicense(client, "mit")
except ApiError as e:
  echo "API Error: ", e.msg
except CatchableError as e:
  echo "Error: ", e.msg
```

## Configuration

### Cache Location
- Linux/macOS: `~/.cache/chooselic/`
- Windows: `%LOCALAPPDATA%\chooselic\`

### Files
- `licenses.json`: Cached license list
- `{license-key}.json`: Individual license cache files

### Expiration
- Cache expires after 24 hours
- Automatic refresh on next request

## Extension Points

### Adding New License Types
1. Add template replacement logic in `licenses.nim`
2. Update `replaceAuthor()` and `replaceYear()` procedures
3. Add test cases in `tests/test_licenses.nim`

### Custom API Endpoints
1. Modify `config.nim` endpoint functions
2. Update API client in `api.nim`
3. Ensure SSL/HTTP toggle support

### UI Enhancements
1. Extend `UiState` enum for new screens
2. Add corresponding UI functions in `ui.nim`
3. Update state machine in main application

## Testing

### Test Structure
- `test_licenses.nim`: License processing tests
- `test_fuzzy.nim`: Fuzzy search tests
- `test_cli.nim`: CLI parsing tests
- `test_cache.nim`: Caching system tests

### Running Tests
```bash
nimble test      # Unit tests
nimble quality   # Full quality suite
```

## Performance Considerations

### Caching Strategy
- License list cached for 24 hours
- Individual licenses cached indefinitely
- Cache validation on each request

### Network Optimization
- Single request for license list
- Individual license requests only when needed
- Graceful handling of network failures

### Memory Usage
- Streaming JSON parsing
- Minimal data structures
- Efficient string operations