import unittest
import std/strutils
import chooselic/licenses

suite "License template replacement":
  test "replace author in MIT license":
    let text = "Copyright (c) [year] [fullname]"
    let result = replaceAuthor("John Doe", "mit", text)
    check result == "Copyright (c) [year] John Doe"

  test "replace year in MIT license":
    let text = "Copyright (c) [year] [fullname]"
    let result = replaceYear("2025", "mit", text)
    check result == "Copyright (c) 2025 [fullname]"

  test "replace author in Apache license":
    let text = "Copyright [yyyy] [name of copyright owner]"
    let result = replaceAuthor("Jane Smith", "apache-2.0", text)
    check result == "Copyright [yyyy] Jane Smith"

  test "replace year in Apache license":
    let text = "Copyright [yyyy] [name of copyright owner]"
    let result = replaceYear("2025", "apache-2.0", text)
    check result == "Copyright 2025 [name of copyright owner]"

  test "replace author in GPL license":
    let text = "Copyright (C) <year> <name of author>"
    let result = replaceAuthor("Bob Wilson", "gpl-3.0", text)
    check result == "Copyright (C) <year> Bob Wilson"

  test "replace year in GPL license":
    let text = "Copyright (C) <year> <name of author>"
    let result = replaceYear("2025", "gpl-3.0", text)
    check result == "Copyright (C) 2025 <name of author>"

  test "replace author in WTFPL license":
    let text = "Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>"
    let result = replaceAuthor("Alice Cooper", "wtfpl", text)
    check result == "Copyright (C) 2004 Alice Cooper"

  test "replace year in WTFPL license":
    let text = "DO WHAT THE F*CK YOU WANT TO PUBLIC LICENSE\nVersion 2, December 2004\n\nCopyright (C) 2004 Sam Hocevar <sam@hocevar.net>"
    let result = replaceYear("2025", "wtfpl", text)
    check result == "DO WHAT THE F*CK YOU WANT TO PUBLIC LICENSE\nVersion 2, December 2004\n\nCopyright (C) 2025 Sam Hocevar <sam@hocevar.net>"

  test "no replacement for unsupported license":
    let text = "This is some license text"
    let authorResult = replaceAuthor("John Doe", "custom-license", text)
    let yearResult = replaceYear("2025", "custom-license", text)
    check authorResult == text
    check yearResult == text

  test "process license with both author and year":
    let license = License(
      key: "mit",
      name: "MIT License",
      body: "Copyright (c) [year] [fullname]\n\nPermission is hereby granted..."
    )
    let result = processLicense(license, "John Doe", "2025")
    check result.contains("Copyright (c) 2025 John Doe")

  test "process license with empty author":
    let license = License(
      key: "mit",
      name: "MIT License",
      body: "Copyright (c) [year] [fullname]"
    )
    let result = processLicense(license, "", "2025")
    check result == "Copyright (c) 2025 [fullname]"

  test "process license with empty year":
    let license = License(
      key: "mit",
      name: "MIT License",
      body: "Copyright (c) [year] [fullname]"
    )
    let result = processLicense(license, "John Doe", "")
    check result == "Copyright (c) [year] John Doe"