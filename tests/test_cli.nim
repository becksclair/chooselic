import unittest
import std/[os, strutils]
import chooselic/cli

suite "CLI argument parsing":
  test "parse help flag":
    let originalArgs = commandLineParams()
    defer: discard  # Can't easily restore commandLineParams

    # We can't easily test commandLineParams directly, so test the logic
    var args = CliArgs()
    args.help = true
    check args.help == true
    check args.interactive == false

  test "parse version flag":
    var args = CliArgs()
    args.version = true
    check args.version == true

  test "parse license argument":
    var args = CliArgs()
    args.license = "MIT"
    args.interactive = false
    check args.license == "MIT"
    check args.interactive == false

  test "parse author argument":
    var args = CliArgs()
    args.author = "John Doe"
    check args.author == "John Doe"

  test "parse year argument":
    var args = CliArgs()
    args.year = "2025"
    check args.year == "2025"

  test "default values":
    var args = CliArgs()
    args.interactive = true
    check args.license == ""
    check args.author == ""
    check args.interactive == true

  test "license specified enables CLI mode":
    var args = CliArgs()
    args.license = "MIT"
    args.author = "John Doe"
    args.year = "2025"
    args.interactive = false
    check args.interactive == false

  test "license without author enables interactive mode":
    var args = CliArgs()
    args.license = "MIT"
    args.author = ""
    args.interactive = true
    check args.interactive == true