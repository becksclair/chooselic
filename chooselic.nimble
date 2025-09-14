# Package

version       = "0.1.0"
author        = "Rebecca Clair"
description   = "Choose a license for your project in the terminal via GitHub Licenses API"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["chooselic"]


# Dependencies

requires "nim >= 2.2.4"
requires "illwill >= 0.4.1"

# Helper tasks
task build, "Build with SSL support (default)":
  exec "nim c -d:ssl -o:chooselic src/chooselic.nim"

task build_release, "Build optimized release version":
  exec "nim c -d:ssl -d:release -o:chooselic src/chooselic.nim"

task build_debug, "Build debug version":
  exec "nim c -d:ssl -d:debug -o:chooselic src/chooselic.nim"

task test, "Run tests":
  exec "nim c -d:ssl -r tests/test1.nim"

task clean, "Clean build artifacts":
  rmFile "chooselic"
  rmFile "chooselic.exe"
  rmDir "nimcache"

task install_local, "Install to local bin directory":
  exec "nim c -d:ssl -d:release -o:chooselic src/chooselic.nim"
  exec "cp chooselic ~/.local/bin/"
  echo "Installed chooselic to ~/.local/bin/"

task uninstall_local, "Uninstall from local bin directory":
  rmFile "~/.local/bin/chooselic"
  echo "Removed chooselic from ~/.local/bin/"

task demo, "Run a demo showing different license generation":
  echo "Running chooselic demo..."
  exec "nim c -d:ssl -d:release -o:chooselic src/chooselic.nim"
  echo "\n1. MIT License:"
  exec "rm -f LICENSE"
  exec "./chooselic --license=MIT --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE"
  echo "\n2. Apache License:"
  exec "rm -f LICENSE"
  exec "./chooselic --license=Apache-2.0 --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE"
  echo "\n3. GPL License:"
  exec "rm -f LICENSE"
  exec "./chooselic --license=GPL-3.0 --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE"
  exec "rm -f LICENSE"
  echo "\nDemo completed! All licenses generated successfully."

task dev_setup, "Setup development environment and run initial tests":
  echo "Setting up chooselic development environment..."
  exec "nimble install -d"
  exec "nim c -d:ssl -o:chooselic src/chooselic.nim"
  echo "\nRunning tests..."
  exec "nimble test"
  echo "\nTesting basic functionality..."
  exec "rm -f LICENSE && ./chooselic --license=MIT --author=\"Test\" --year=2025"
  echo "✅ Development setup complete!"
  echo "\nAvailable commands:"
  echo "  nimble build          # Build with SSL (default)"
  echo "  nimble build_release  # Build optimized version"
  echo "  nimble test           # Run tests"
  echo "  nimble demo           # Run demonstration"
  echo "  nimble install_local  # Install to ~/.local/bin"
  echo "  nimble clean          # Clean build artifacts"
  echo "  nimble quality        # Run all quality checks"

task quality, "Run comprehensive quality checks (build + test + demo)":
  echo "Running comprehensive quality checks..."
  exec "nimble clean"
  exec "nimble build_release"
  exec "nimble test"
  exec "nimble demo"
  echo "✅ All quality checks passed!"

