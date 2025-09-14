import std/[strformat, strutils, times]
import illwill
import licenses, fuzzy

type
  InputField* = enum
    searchField
    authorField
    yearField

  AppData* = object
    licenses*: seq[LicenseItem]
    selectedLicense*: LicenseItem
    author*: string
    year*: string
    searchQuery*: string
    activeField*: InputField
    exitApp*: bool
    licenseSelected*: bool

proc initAppData*(licenses: seq[LicenseItem], author: string = "", year: string = ""): AppData =
  AppData(
    licenses: licenses,
    author: author,
    year: if year.len > 0: year else: $now().year,
    searchQuery: "",
    activeField: searchField,
    exitApp: false,
    licenseSelected: false
  )

proc runInteractiveTUI*(app: var AppData): bool =
  # Check if terminal dimensions are valid before initializing
  let width = terminalWidth()
  let height = terminalHeight()

  # In non-interactive environments, height can be 0 or invalid
  # Fall back gracefully if we can't get proper terminal dimensions
  if width <= 0 or height <= 0:
    echo "Error: Unable to determine terminal dimensions."
    echo "This usually happens in non-interactive environments (piped input/output)."
    echo "Please run the command in an interactive terminal or use CLI mode with specific license selection."
    return false

  illwillInit(fullscreen=true)
  defer: illwillDeinit()

  var tb = newTerminalBuffer(width, height)

  while not app.exitApp:
    tb.clear()

    # Title
    tb.write(2, 1, "Choose a License", fgYellow, styleBright)
    tb.write(2, 2, "─".repeat(60), fgBlue)

    # Instructions
    tb.write(2, 3, "[Tab] to switch fields | [Enter] to confirm | [Esc] to quit")
    tb.write(2, 4, "Type to search licenses, then fill author and year fields")

    # Input fields with active field indicators
    let searchActive = app.activeField == searchField
    let authorActive = app.activeField == authorField
    let yearActive = app.activeField == yearField

    # License Search field
    let searchIndicator = if searchActive: "▶" else: " "
    let searchColor = if searchActive: fgCyan else: fgWhite
    if searchActive:
      tb.write(2, 6, fmt"{searchIndicator} License Search: ", searchColor, styleBright)
      tb.write(20, 6, app.searchQuery, searchColor, styleBright)
      tb.write(20 + app.searchQuery.len, 6, "_", fgCyan, styleBright)
    else:
      tb.write(2, 6, fmt"{searchIndicator} License Search: ", searchColor)
      tb.write(20, 6, app.searchQuery, searchColor)

    # Author field
    let authorIndicator = if authorActive: "▶" else: " "
    let authorColor = if authorActive: fgGreen else: fgWhite
    if authorActive:
      tb.write(2, 7, fmt"{authorIndicator} Author: ", authorColor, styleBright)
      tb.write(12, 7, app.author, authorColor, styleBright)
      tb.write(12 + app.author.len, 7, "_", fgGreen, styleBright)
    else:
      tb.write(2, 7, fmt"{authorIndicator} Author: ", authorColor)
      tb.write(12, 7, app.author, authorColor)

    # Year field
    let yearIndicator = if yearActive: "▶" else: " "
    let yearColor = if yearActive: fgMagenta else: fgWhite
    if yearActive:
      tb.write(2, 8, fmt"{yearIndicator} Year: ", yearColor, styleBright)
      tb.write(10, 8, app.year, yearColor, styleBright)
      tb.write(10 + app.year.len, 8, "_", fgMagenta, styleBright)
    else:
      tb.write(2, 8, fmt"{yearIndicator} Year: ", yearColor)
      tb.write(10, 8, app.year, yearColor)

    # License list (only show when search field is active and we have a query or no license selected)
    if app.activeField == searchField and (app.searchQuery.len > 0 or not app.licenseSelected):
      let matches = fuzzyMatch(app.searchQuery, app.licenses)
      tb.write(2, 10, fmt"Found {matches.len} licenses:", fgYellow)

      let maxLicenses = min(12, matches.len)  # Limit to fit screen
      for i in 0..<maxLicenses:
        let match = matches[i]
        let prefix = if i < 9: fmt"[{i+1}] " else: "    "
        let line = fmt"{prefix}{match.item.spdx_id}: {match.item.name}"
        let y = 12 + i
        if i == 0 and not app.licenseSelected:
          tb.write(2, y, line, fgWhite, styleBright)
        else:
          tb.write(2, y, line, fgWhite)

    # Show selected license if one is chosen
    if app.licenseSelected:
      tb.write(2, 10, fmt"Selected: {app.selectedLicense.spdx_id} - {app.selectedLicense.name}", fgGreen, styleBright)

      # Show status for required fields
      let authorStatus = if app.author.len > 0: "✓" else: "✗"
      let yearStatus = if app.year.len > 0: "✓" else: "✗"
      tb.write(2, 11, fmt"Author: {authorStatus} | Year: {yearStatus}", fgCyan)

      if app.author.len > 0 and app.year.len > 0:
        tb.write(2, 13, "Ready to generate! Press [Enter] to confirm.", fgGreen, styleBright)

    tb.display()

    let key = illwill.getKey()
    case key
    of Key.Escape:
      return false
    of Key.Tab:
      # Cycle through fields
      case app.activeField
      of searchField: app.activeField = authorField
      of authorField: app.activeField = yearField
      of yearField: app.activeField = searchField
    of Key.Enter:
      case app.activeField
      of searchField:
        # Select first license match if available
        let matches = fuzzyMatch(app.searchQuery, app.licenses)
        if matches.len > 0:
          app.selectedLicense = matches[0].item
          app.licenseSelected = true
          app.activeField = authorField  # Move to author field
      of authorField:
        app.activeField = yearField  # Move to year field
      of yearField:
        # Try to complete if everything is filled
        if app.licenseSelected and app.author.len > 0 and app.year.len > 0:
          return true
        else:
          app.activeField = searchField  # Go back to search
    of Key.One..Key.Nine:
      if app.activeField == searchField:
        let index = ord(key) - ord(Key.One)
        let matches = fuzzyMatch(app.searchQuery, app.licenses)
        if index < matches.len:
          app.selectedLicense = matches[index].item
          app.licenseSelected = true
          app.activeField = authorField  # Move to author field
    of Key.Backspace:
      case app.activeField
      of searchField:
        if app.searchQuery.len > 0:
          app.searchQuery.setLen(app.searchQuery.len - 1)
          app.licenseSelected = false  # Reset selection if modifying search
      of authorField:
        if app.author.len > 0:
          app.author.setLen(app.author.len - 1)
      of yearField:
        if app.year.len > 0:
          app.year.setLen(app.year.len - 1)
    else:
      if key >= Key.Space and key <= Key.Tilde:
        case app.activeField
        of searchField:
          app.searchQuery.add(key.char)
          app.licenseSelected = false  # Reset selection if modifying search
        of authorField:
          app.author.add(key.char)
        of yearField:
          app.year.add(key.char)

  return false

# Legacy function - kept for backward compatibility but should not be used
# The new runInteractiveTUI handles all input in one session
proc getTextInput*(prompt: string, defaultValue: string = ""): string =
  echo prompt
  if defaultValue.len > 0:
    echo fmt"(default: {defaultValue})"
  stdout.write("> ")
  result = readLine(stdin).strip()
  if result.len == 0:
    result = defaultValue

proc clearScreen*() =
  ## Clear the terminal screen and move cursor to home position
  ## Used after exiting TUI mode for clean output
  stdout.write("\x1b[2J\x1b[H")

