# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### Building
```bash
nimble build          # Development build with SSL (default)
nimble build_release  # Optimized production build
nimble build_debug    # Debug build with symbols
```

### Testing
```bash
nimble test           # Run complete test suite (all modules)
nimble quality        # Full quality checks: clean + build_release + test + demo
```

### Development Workflow
```bash
nimble dev_setup      # Complete setup: install deps + build + test + demo
nimble demo           # Multi-license demonstration with SSL and --no-ssl modes
nimble clean          # Remove build artifacts
```

### Individual Test Modules
```bash
nim c -d:ssl -r tests/test_licenses.nim  # Test license template processing
nim c -d:ssl -r tests/test_fuzzy.nim     # Test fuzzy search algorithm
nim c -d:ssl -r tests/test_cli.nim       # Test CLI argument parsing
nim c -d:ssl -r tests/test_cache.nim     # Test caching system
```

## Architecture Overview

chooselic is a terminal license generator with dual interfaces (CLI + TUI) that fetches licenses from GitHub's API with smart caching and template processing.

### Core Design Patterns

**SSL-by-Default Architecture**: All builds include SSL support. The application uses HTTPS by default but accepts `--no-ssl` runtime flag for HTTP testing. This design ensures secure API communication while allowing development flexibility.

**Dual Interface Pattern**: The application automatically switches between:
- **CLI Mode**: Direct license generation when `--license` is provided
- **Interactive Mode**: TUI with fuzzy search when no license specified

**Layered Caching Strategy**:
- License lists cached for 24 hours in `~/.cache/chooselic/licenses.json`
- Individual licenses cached indefinitely in `~/.cache/chooselic/{key}.json`
- Cache validation on each request with automatic refresh

### Module Responsibilities

**chooselic.nim** (Main Orchestrator)
- Determines CLI vs Interactive mode based on arguments
- Coordinates between all modules
- Handles main application flow and error propagation

**cli.nim** (Argument Processing)
- Defines `CliArgs` type with `noSsl` flag for SSL control
- Parses command-line arguments using parseopt
- Provides help/version display functions

**api.nim + cache.nim** (Data Layer)
- `api.nim`: Raw GitHub API client with SSL/HTTP endpoint selection
- `cache.nim`: Caching wrapper that tries cache first, falls back to API
- Both accept `useSsl` parameter passed through from CLI args

**licenses.nim** (Template Processing)
- Defines core data types: `LicenseItem`, `License`, `CachedLicense`
- License-specific template replacement in `replaceAuthor()` and `replaceYear()`
- Hardcoded uncommon licenses not available via GitHub API

**ui.nim** (Terminal Interface)
- Interactive license selection using illwill library
- Fuzzy search integration for license filtering
- Preview functionality before license generation

**fuzzy.nim** (Search Algorithm)
- Implements fuzzy matching for intuitive license discovery
- Returns scored matches for UI ranking

### Template Processing Logic

License template replacement follows specific patterns per license type:
- **MIT/BSD licenses**: Replace `[fullname]` and `[year]` placeholders
- **GPL licenses**: Replace `<name of author>` and `<year>` placeholders
- **Apache**: Replace `[name of copyright owner]` and `[yyyy]` placeholders
- **WTFPL**: Special handling for author replacement and second occurrence of year

### Error Handling Patterns

- `ApiError`: Network/GitHub API failures
- `CatchableError`: General application errors with user-friendly messages
- Cache failures gracefully fall back to API requests
- Network failures provide helpful guidance about connectivity

### Testing Strategy

The test suite is organized by module with `test1.nim` as the main runner:
- **test_licenses.nim**: Template processing and license data validation
- **test_fuzzy.nim**: Search algorithm accuracy and performance
- **test_cli.nim**: Argument parsing edge cases
- **test_cache.nim**: Cache expiration and JSON serialization (note: some DateTime tests skipped due to serialization complexity)

Quality gate process: `nimble quality` runs clean build + tests + live demo to ensure SSL and --no-ssl modes work correctly with actual GitHub API.

## Development Notes

### Cache Management
Cache files are stored in `~/.cache/chooselic/` and can be manually cleared for testing. The cache system handles both HTTP and HTTPS endpoints separately.

### SSL/HTTP Testing
Use `--no-ssl` flag for testing HTTP connections. This is particularly useful for development environments or when debugging network issues.

### Adding New License Types
1. Update template replacement logic in `licenses.nim` `replaceAuthor()` and `replaceYear()` functions
2. Add test cases in `tests/test_licenses.nim`
3. Consider adding to `uncommonLicenses` array if not available via GitHub API