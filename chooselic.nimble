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
task test, "Run tests":
  exec "nim c -r tests/test1.nim"

task clean, "Clean build artifacts":
  rmFile "chooselic"
  rmFile "chooselic.exe"
  rmDir "nimcache"

task demo, "Run a demo showing different license generation":
  echo "Running chooselic demo..."
  exec "nim c -d:release -o:chooselic src/chooselic.nim"
  echo "\n1. MIT License:"
  exec "rm -f LICENSE LICENSE.md"
  exec "./chooselic --license=MIT --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE.md"
  echo "\n2. Apache License:"
  exec "rm -f LICENSE LICENSE.md"
  exec "./chooselic --license=Apache-2.0 --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE.md"
  echo "\n3. GPL License:"
  exec "rm -f LICENSE LICENSE.md"
  exec "./chooselic --license=GPL-3.0 --author=\"Demo User\" --year=2025"
  exec "echo 'Generated:'; head -3 LICENSE.md"
  exec "rm -f LICENSE LICENSE.md"
  echo "\nDemo completed! All licenses generated successfully."

task dev_setup, "Setup development environment and run initial tests":
  echo "Setting up chooselic development environment..."
  exec "nimble install -d"
  exec "nim c -o:chooselic src/chooselic.nim"
  echo "\nRunning tests..."
  exec "nimble test"
  echo "\nTesting basic functionality..."
  exec "rm -f LICENSE && ./chooselic --license=MIT --author=\"Test\" --year=2025"
  echo "✅ Development setup complete!"
  echo "\nAvailable commands:"
  echo "  nimble build          # Build with SSL (config.nims)"
  echo "  nimble -d:release build # Build optimized version"
  echo "  nimble install        # Install to ~/.nimble/bin/"
  echo "  nimble test           # Run tests"
  echo "  nimble demo           # Run demonstration"
  echo "  nimble clean          # Clean build artifacts"
  echo "  nimble quality        # Run all quality checks"

task quality, "Run comprehensive quality checks (build + test + demo)":
  echo "Running comprehensive quality checks..."
  exec "nimble clean"
  exec "nimble -d:release build"
  exec "nimble test"
  exec "nimble demo"
  echo "✅ All quality checks passed!"

