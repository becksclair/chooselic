# Contributing to chooselic

Thank you for your interest in contributing to chooselic! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites
- Nim >= 2.2.4
- Git

### Quick Setup
```bash
git clone https://github.com/yourusername/chooselic
cd chooselic
nimble dev_setup    # Complete setup with tests
```

This will:
1. Install all dependencies
2. Build the project
3. Run the test suite
4. Test basic functionality
5. Display available commands

## Development Workflow

### 1. Building
```bash
nimble build           # Development build
nimble build_release   # Optimized production build
nimble build_debug     # Debug build with symbols
```

### 2. Testing
```bash
nimble test      # Run unit test suite
nimble demo      # Run demonstration with multiple licenses
nimble quality   # Run comprehensive quality checks (build + test + demo)
```

### 3. Code Quality
Before submitting a PR, ensure all quality checks pass:
```bash
nimble quality
```

This runs:
- Clean build from scratch
- Optimized release build
- Full test suite
- Demo with SSL and --no-ssl modes

## Project Structure

```
chooselic/
├── src/chooselic/
│   ├── api.nim          # GitHub API client
│   ├── cache.nim        # Local caching system
│   ├── cli.nim          # Command-line parsing
│   ├── config.nim       # Configuration constants
│   ├── fuzzy.nim        # Fuzzy search algorithm
│   ├── licenses.nim     # License data types & processing
│   └── ui.nim           # Terminal user interface
├── tests/               # Unit tests
├── chooselic.nimble     # Package configuration & tasks
└── README.md           # Project documentation
```

## Code Style Guidelines

### Nim Style
- Follow standard Nim naming conventions
- Use meaningful variable names
- Add type annotations for public APIs
- Include doc comments for public procedures

### Error Handling
- Use proper exception types (`ApiError`, `CatchableError`)
- Provide meaningful error messages
- Handle network failures gracefully
- Validate user input

### Testing
- Write unit tests for new functionality
- Test both success and error cases
- Maintain >80% test coverage
- Use descriptive test names

## Making Changes

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes
- Keep commits focused and atomic
- Write clear commit messages
- Add tests for new functionality
- Update documentation if needed

### 3. Test Your Changes
```bash
nimble quality  # Run all quality checks
```

### 4. Submit a Pull Request
- Describe your changes clearly
- Reference any related issues
- Ensure all checks pass
- Be responsive to code review feedback

## Areas for Contribution

### High Priority
- Additional license template support
- Performance improvements
- Better error messages
- Documentation improvements

### Medium Priority
- Configuration file support
- Additional output formats
- Enhanced terminal UI features
- Cross-platform testing

### Low Priority
- Plugin system
- Custom license templates
- Batch processing
- API rate limiting improvements

## Reporting Issues

When reporting bugs, please include:
- chooselic version (`chooselic --version`)
- Operating system and version
- Nim version
- Steps to reproduce
- Expected vs actual behavior
- Error messages (if any)

## Questions and Support

- Check existing issues and documentation first
- Create a new issue for bugs or feature requests
- Use clear, descriptive titles
- Provide context and examples

## License

By contributing to chooselic, you agree that your contributions will be licensed under the same MIT License that covers the project.

## Recognition

Contributors will be recognized in the project documentation and release notes. Thank you for helping make chooselic better!