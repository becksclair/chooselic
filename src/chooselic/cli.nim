import std/[parseopt, strformat, times, os]
import config, author

type
  CliArgs* = object
    license*: string
    author*: string
    year*: string
    help*: bool
    version*: bool
    interactive*: bool

proc showHelp*() =
  echo fmt"""chooselic v{version}

Usage: chooselic [options]

Choose a license for your project via GitHub Licenses API.

Options:
  --license <name>    Specify license directly (e.g., MIT, Apache-2.0)
  --author <name>     Set author name for license
  --year <year>       Set copyright year (default: current year)
  -h, --help          Show this help message
  -v, --version       Show version information

Examples:
  chooselic --license MIT --author "John Doe" --year 2025
  chooselic --license Apache-2.0 --author "Jane Smith"
  chooselic                  # Interactive mode

If no license is specified, an interactive mode will launch where you can
search and select from available licenses."""

proc showVersion*() =
  echo fmt"chooselic v{version}"

proc parseCliArgs*(): CliArgs =
  result = CliArgs(
    author: getSystemAuthor(),  # Auto-detect author from system
    year: $now().year,
    interactive: true
  )

  var parser = initOptParser(commandLineParams(), shortNoVal = {'h', 'v'}, longNoVal = @["help", "version"])

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
            echo "Error: --license requires a value (e.g., --license MIT or --license=MIT)"
            echo "Use --help for usage information."
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
            echo "Error: --author requires a value (e.g., --author \"John Doe\" or --author=\"John Doe\")"
            echo "Use --help for usage information."
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
            echo "Error: --year requires a value (e.g., --year 2025 or --year=2025)"
            echo "Use --help for usage information."
            quit(1)
        result.year = value
      of "help", "h":
        result.help = true
      of "version", "v":
        result.version = true
      else:
        echo fmt"Unknown option: --{parser.key}"
        echo "Use --help for usage information."
        quit(1)
    of cmdArgument:
      echo fmt"Unexpected argument: {parser.key}"
      echo "Use --help for usage information."
      quit(1)

  # If license is specified but no author, prompt for it in interactive mode
  if result.license.len > 0 and result.author.len == 0:
    result.interactive = true