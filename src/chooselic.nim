import std/[os, strformat, strutils, times, httpclient]
import chooselic/[cli, api, cache, licenses, ui]

const OUTPUT_FILENAME = "LICENSE.md"

proc saveLicenseFile(license: License, author: string, year: string): bool =
  let content = processLicense(license, author, year)

  if fileExists(OUTPUT_FILENAME):
    echo fmt"File '{OUTPUT_FILENAME}' already exists. Overwrite? (y/N): "
    let answer = readLine(stdin).strip().toLowerAscii()
    if answer != "y" and answer != "yes":
      echo "License file not created."
      return false

  try:
    writeFile(OUTPUT_FILENAME, content)
    echo fmt"License file '{OUTPUT_FILENAME}' created successfully!"
    return true
  except IOError as e:
    echo fmt"Error creating license file: {e.msg}"
    return false

proc runInteractiveMode(args: CliArgs, client: HttpClient, licenses: seq[LicenseItem]): bool =
  # If specific license is provided via CLI, use direct mode
  if args.license.len > 0:
    var selectedLicense: LicenseItem
    for license in licenses:
      if license.key == args.license.toLowerAscii() or
         license.spdx_id.toLowerAscii() == args.license.toLowerAscii():
        selectedLicense = license
        break

    if selectedLicense.key.len == 0:
      echo fmt"License '{args.license}' not found."
      return false

    # Get author and year via simple input if not provided
    var author = args.author
    if author.len == 0:
      author = getTextInput("Enter author name:")
      if author.len == 0:
        echo "Author name is required for this license."
        return false

    var year = args.year
    if year.len == 0:
      year = getTextInput("Enter copyright year:", $now().year)

    # Process the license
    try:
      let fullLicense = getCachedLicense(client, selectedLicense.key)
      return saveLicenseFile(fullLicense, author, year)
    except CatchableError as e:
      echo fmt"Error: {e.msg}"
      return false
  else:
    # Use the new unified TUI for full interactive mode
    echo "Loading licenses..."
    var appData = initAppData(licenses, args.author, args.year)

    if not runInteractiveTUI(appData):
      echo "License selection cancelled."
      return false

    # Fetch and process the selected license
    echo fmt"Fetching license '{appData.selectedLicense.key}'..."
    try:
      let fullLicense = getCachedLicense(client, appData.selectedLicense.key)
      return saveLicenseFile(fullLicense, appData.author, appData.year)

    except CatchableError as e:
      echo fmt"Error: {e.msg}"
      return false

proc runCliMode(args: CliArgs, client: HttpClient): bool =
  try:
    let licenses = getCachedLicenses(client)
    if licenses.len == 0:
      echo "No licenses available. Check your network connection."
      return false

    var selectedLicense: LicenseItem
    for license in licenses:
      if license.key == args.license.toLowerAscii() or
         license.spdx_id.toLowerAscii() == args.license.toLowerAscii():
        selectedLicense = license
        break

    if selectedLicense.key.len == 0:
      echo fmt"License '{args.license}' not found."
      echo "\nAvailable licenses:"
      for license in licenses[0..min(9, licenses.len-1)]:
        echo fmt"  {license.spdx_id}: {license.name}"
      if licenses.len > 10:
        echo fmt"  ... and {licenses.len - 10} more"
      return false

    echo fmt"Fetching license '{selectedLicense.key}'..."
    let fullLicense = getCachedLicense(client, selectedLicense.key)

    return saveLicenseFile(fullLicense, args.author, args.year)

  except CatchableError as e:
    echo fmt"Error: {e.msg}"
    return false

when isMainModule:
  let args = parseCliArgs()

  if args.help:
    showHelp()
    quit(0)

  if args.version:
    showVersion()
    quit(0)

  let client = newApiClient()

  try:
    if args.interactive:
      let licenses = getCachedLicenses(client)
      if licenses.len == 0:
        echo "No licenses available. Check your network connection."
        quit(1)

      if not runInteractiveMode(args, client, licenses):
        quit(1)
    else:
      if not runCliMode(args, client):
        quit(1)

  except CatchableError as e:
    echo fmt"Fatal error: {e.msg}"
    quit(1)
  finally:
    client.close()

