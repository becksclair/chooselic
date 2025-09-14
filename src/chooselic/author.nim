import std/[os, osproc, strutils]

proc getSystemAuthor*(): string =
  ## Automatically detect the user's name from system sources
  ## Priority order: git config (name + email) -> passwd database -> environment variables

  # Try git config first (most likely to have proper full name and email)
  try:
    let (gitNameOutput, gitNameExitCode) = execCmdEx("git config --global user.name")
    if gitNameExitCode == 0 and gitNameOutput.strip().len > 0:
      let name = gitNameOutput.strip()

      # Try to get email as well
      try:
        let (gitEmailOutput, gitEmailExitCode) = execCmdEx("git config --global user.email")
        if gitEmailExitCode == 0 and gitEmailOutput.strip().len > 0:
          let email = gitEmailOutput.strip()
          return name & " <" & email & ">"
        else:
          # No email configured, just return the name
          return name
      except:
        # Error getting email, just return the name
        return name
  except:
    discard  # Continue to next method

  # Try passwd database on Unix/Linux systems
  when defined(posix):
    try:
      let user = getEnv("USER")
      if user.len > 0:
        let (passwdOutput, passwdExitCode) = execCmdEx("getent passwd " & user)
        if passwdExitCode == 0:
          # Parse GECOS field (5th field in passwd entry)
          let fields = passwdOutput.split(':')
          if fields.len >= 5 and fields[4].len > 0:
            # GECOS field may contain comma-separated values, take first part
            let fullName = fields[4].split(',')[0].strip()
            if fullName.len > 0:
              return fullName
    except:
      discard  # Continue to next method

  # Windows systems - try getting display name from environment
  when defined(windows):
    # Windows doesn't have a standard way to get full name easily
    # Just use username as fallback
    discard

  # Final fallback to username from environment
  result = getEnv("USER", getEnv("USERNAME", ""))