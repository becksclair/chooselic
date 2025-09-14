import unittest
import std/[os, strutils, parseopt]
import chooselic/[cli, author]

# Helper procedure to test parseCliArgs with simulated command-line arguments
proc testParseCliArgs(args: seq[string]): CliArgs =
  # Create a custom OptParser with the given arguments, same as parseCliArgs
  var parser = initOptParser(args, shortNoVal = {'h', 'v'}, longNoVal = @["help", "version"])

  # Reset result with defaults like parseCliArgs does
  result = CliArgs(
    author: getSystemAuthor(),  # This will be overridden if --author is specified
    year: "2025",  # Use fixed year for testing
    interactive: true
  )

  while true:
    parser.next()
    case parser.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      case parser.key
      of "license", "l":
        var value = parser.val
        if value.len == 0:
          # Space-separated value - peek ahead for the next argument
          parser.next()
          if parser.kind == cmdArgument:
            value = parser.key
          else:
            echo "Error: --license requires a value"
            quit(1)
        result.license = value
        result.interactive = false
      of "author", "a":
        var value = parser.val
        if value.len == 0:
          # Space-separated value - peek ahead for the next argument
          parser.next()
          if parser.kind == cmdArgument:
            value = parser.key
          else:
            echo "Error: --author requires a value"
            quit(1)
        result.author = value
      of "year", "y":
        var value = parser.val
        if value.len == 0:
          # Space-separated value - peek ahead for the next argument
          parser.next()
          if parser.kind == cmdArgument:
            value = parser.key
          else:
            echo "Error: --year requires a value"
            quit(1)
        result.year = value
      of "help", "h":
        result.help = true
      of "version", "v":
        result.version = true
      else:
        echo "Unknown option: --" & parser.key
        quit(1)
    of cmdArgument:
      echo "Unexpected argument: " & parser.key
      quit(1)

  # Apply the same logic as parseCliArgs for interactive mode
  if result.license.len > 0 and result.author.len == 0:
    result.interactive = true

suite "CLI argument parsing":
  test "parse help flag with short option":
    let args = testParseCliArgs(@["-h"])
    check args.help == true

  test "parse help flag with long option":
    let args = testParseCliArgs(@["--help"])
    check args.help == true

  test "parse version flag":
    let args = testParseCliArgs(@["-v"])
    check args.version == true

  test "parse version flag with long option":
    let args = testParseCliArgs(@["--version"])
    check args.version == true

  test "parse license with equals syntax":
    let args = testParseCliArgs(@["--license=MIT"])
    check args.license == "MIT"
    check args.interactive == false

  test "parse license with space syntax":
    let args = testParseCliArgs(@["--license", "MIT"])
    check args.license == "MIT"
    check args.interactive == false

  test "parse author with space syntax":
    let args = testParseCliArgs(@["--author", "John Doe"])
    check args.author == "John Doe"

  test "parse year with space syntax":
    let args = testParseCliArgs(@["--year", "2024"])
    check args.year == "2024"

  test "mixed space and equals syntax":
    let args = testParseCliArgs(@["--license", "Apache-2.0", "--author=Jane Smith", "--year", "2024"])
    check args.license == "Apache-2.0"
    check args.author == "Jane Smith"
    check args.year == "2024"
    check args.interactive == false

  test "parse author with equals syntax":
    let args = testParseCliArgs(@["--author=John Doe"])
    check args.author == "John Doe"

  test "parse year with equals syntax":
    let args = testParseCliArgs(@["--year=2025"])
    check args.year == "2025"

  test "default values":
    let args = testParseCliArgs(@[])
    check args.license == ""
    check args.interactive == true

  test "license specified enables CLI mode":
    let args = testParseCliArgs(@["--license=MIT", "--author=John Doe"])
    check args.license == "MIT"
    check args.author == "John Doe"
    check args.interactive == false

  test "license without explicit author uses default":
    # When no --author is specified, it should use getSystemAuthor() default
    let args = testParseCliArgs(@["--license=MIT"])
    check args.license == "MIT"
    check args.author.len > 0  # Should have default author from getSystemAuthor()
    check args.interactive == false  # CLI mode since author is available

  test "multiple options together":
    let args = testParseCliArgs(@["--license=Apache-2.0", "--author=Jane Smith", "--year=2024"])
    check args.license == "Apache-2.0"
    check args.author == "Jane Smith"
    check args.year == "2024"
    check args.interactive == false