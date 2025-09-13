# chooselic

Choose a license for your project in the terminal via [GitHub Licenses API](https://docs.github.com/en/free-pro-team@latest/rest/licenses/licenses)

A fast, interactive terminal application for generating license files with proper author and year replacement.

## Features

- 🚀 **Fast & Secure**: Always uses SSL/HTTPS for secure GitHub API access
- 🎯 **Interactive Mode**: Fuzzy-searchable license selection with terminal UI
- ⚡ **CLI Mode**: Direct license generation via command-line arguments
- 💾 **Smart Caching**: Local caching to reduce API calls and improve performance
- 🔧 **Template Processing**: Automatic author and year replacement for all license types
- 📦 **Easy Installation**: Single binary with no external dependencies

## Installation

### From Source
```bash
git clone https://github.com/yourusername/chooselic
cd chooselic
nimble install
```

### Build from Source
```bash
nimble build_release    # Optimized build
# or
nimble build           # Development build
```

## Usage

### Command Line Mode
Generate a license directly with command-line arguments:

```bash
# MIT License
chooselic --license MIT --author "John Doe" --year 2025

# Apache License 2.0
chooselic --license Apache-2.0 --author "Jane Smith"

# Use current year (default)
chooselic --license GPL-3.0 --author "Developer Name"
```

### Interactive Mode
Launch interactive mode when no license is specified:

```bash
chooselic
```

This opens a terminal UI where you can:
- Search licenses with fuzzy matching
- Browse all available licenses
- Enter author and year information
- Preview the license before saving

### Available Options
```
  --license <name>    Specify license directly (e.g., MIT, Apache-2.0)
  --author <name>     Set author name for license
  --year <year>       Set copyright year (default: current year)
  -h, --help          Show help message
  -v, --version       Show version information
```

## Supported Licenses

chooselic supports all licenses available through the GitHub API, including:

**Popular Licenses:**
- MIT License
- Apache License 2.0
- GNU General Public License v3.0
- BSD 2-Clause "Simplified" License
- BSD 3-Clause "New" or "Revised" License
- GNU Lesser General Public License v2.1

**Uncommon Licenses:**
- BSD 4-Clause "Original" License
- Creative Commons Attribution 4.0 International
- ISC License
- GNU Lesser General Public License v3.0
- Do What The F*ck You Want To Public License

## Development

### Quick Start
```bash
git clone https://github.com/yourusername/chooselic
cd chooselic
nimble dev_setup    # Complete setup with tests
```

### Available Tasks
```bash
nimble build          # Build with SSL (default)
nimble build_release  # Build optimized version
nimble build_debug    # Build debug version
nimble test           # Run test suite
nimble demo           # Run demonstration
nimble quality        # Run comprehensive quality checks
nimble install_local  # Install to ~/.local/bin
nimble clean          # Clean build artifacts
```

### Testing
```bash
nimble test      # Run unit tests
nimble quality   # Run all quality checks (build + test + demo)
```

## Architecture

- **CLI Parser**: Handles command-line arguments and options
- **API Client**: Secure GitHub API integration using HTTPS
- **Cache System**: Local caching in `~/.cache/chooselic/`
- **Template Engine**: License text processing with author/year replacement
- **Terminal UI**: Interactive license selection with fuzzy search

## Requirements

- Nim >= 2.2.4
- illwill >= 0.4.1 (for terminal UI)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run quality checks (`nimble quality`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Heavily inspired by [vscode-choosealicense](https://github.com/ultram4rine/vscode-choosealicense)
- Uses [GitHub Licenses API](https://docs.github.com/en/free-pro-team@latest/rest/licenses/licenses)

