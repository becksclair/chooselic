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

task quality, "Run comprehensive quality checks (build + test + demo)":
  echo "Running comprehensive quality checks..."
  exec "nimble clean"
  exec "nimble -d:release build"
  exec "nimble test"
  echo "✅ All quality checks passed!"

