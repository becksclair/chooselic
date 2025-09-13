# Changelog

All notable changes to chooselic will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-15

### Added
- Initial release of chooselic terminal license generator
- SSL-enabled GitHub API client for secure license fetching
- Interactive terminal UI with fuzzy search for license selection
- Command-line interface for direct license generation
- Smart caching system in `~/.cache/chooselic/` for improved performance
- Support for all GitHub API licenses plus uncommon licenses
- Automatic author and year template replacement for all license types
- `--no-ssl` flag for HTTP connections (testing/debugging)
- Comprehensive test suite with >80% coverage
- Cross-platform support (Linux, macOS, Windows)

### Features
- **CLI Mode**: Direct license generation with `--license`, `--author`, `--year` options
- **Interactive Mode**: Fuzzy-searchable license selection with terminal UI
- **Smart Caching**: Reduces API calls and improves response times
- **Template Processing**: Proper author/year replacement for different license formats
- **Error Handling**: Graceful handling of network errors and invalid inputs
- **Help System**: Comprehensive help text and usage examples

### Supported Licenses
- MIT License
- Apache License 2.0
- GNU General Public License v3.0
- BSD 2-Clause "Simplified" License
- BSD 3-Clause "New" or "Revised" License
- GNU Lesser General Public License v2.1
- BSD 4-Clause "Original" License
- Creative Commons Attribution 4.0 International
- ISC License
- GNU Lesser General Public License v3.0
- Do What The F*ck You Want To Public License
- And all other licenses available via GitHub API

### Development Tools
- `nimble build` - Development build with SSL
- `nimble build_release` - Optimized production build
- `nimble test` - Unit test execution
- `nimble demo` - Multi-license demonstration
- `nimble quality` - Comprehensive quality checks
- `nimble dev_setup` - Complete development environment setup

### Architecture
- Modular design with separate concerns for API, caching, UI, and CLI
- SSL-by-default for secure GitHub API communication
- Local caching with expiration for optimal performance
- Fuzzy search algorithm for intuitive license discovery
- Terminal UI built with illwill library

### Dependencies
- Nim >= 2.2.4
- illwill >= 0.4.1

---

## [Unreleased]

### Changed
- Nothing yet

### Added
- Nothing yet

### Fixed
- Nothing yet

### Removed
- Nothing yet