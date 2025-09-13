import unittest
import chooselic/[licenses, fuzzy]

suite "Fuzzy search":
  let testLicenses = @[
    LicenseItem(
      key: "mit",
      name: "MIT License",
      spdx_id: "MIT",
      url: "https://api.github.com/licenses/mit",
      node_id: "MDc6TGljZW5zZTE1",
      html_url: "http://choosealicense.com/licenses/mit/"
    ),
    LicenseItem(
      key: "apache-2.0",
      name: "Apache License 2.0",
      spdx_id: "Apache-2.0",
      url: "https://api.github.com/licenses/apache-2.0",
      node_id: "MDc6TGljZW5zZTI=",
      html_url: "http://choosealicense.com/licenses/apache-2.0/"
    ),
    LicenseItem(
      key: "gpl-3.0",
      name: "GNU General Public License v3.0",
      spdx_id: "GPL-3.0",
      url: "https://api.github.com/licenses/gpl-3.0",
      node_id: "MDc6TGljZW5zZTk=",
      html_url: "http://choosealicense.com/licenses/gpl-3.0/"
    )
  ]

  test "exact match by name":
    let matches = fuzzyMatch("MIT License", testLicenses)
    check matches.len > 0
    check matches[0].item.key == "mit"
    check matches[0].matched == true

  test "exact match by key":
    let matches = fuzzyMatch("mit", testLicenses)
    check matches.len > 0
    check matches[0].item.key == "mit"
    check matches[0].matched == true

  test "exact match by SPDX ID":
    let matches = fuzzyMatch("Apache-2.0", testLicenses)
    check matches.len > 0
    check matches[0].item.key == "apache-2.0"
    check matches[0].matched == true

  test "partial match":
    let matches = fuzzyMatch("GPL", testLicenses)
    check matches.len > 0
    var found = false
    for match in matches:
      if match.item.key == "gpl-3.0" and match.matched:
        found = true
        break
    check found

  test "case insensitive match":
    let matches = fuzzyMatch("apache", testLicenses)
    check matches.len > 0
    var found = false
    for match in matches:
      if match.item.key == "apache-2.0" and match.matched:
        found = true
        break
    check found

  test "empty pattern matches all":
    let matches = fuzzyMatch("", testLicenses)
    check matches.len == testLicenses.len
    for match in matches:
      check match.matched == true

  test "no matches for random string":
    let matches = fuzzyMatch("xyz123randomstring", testLicenses)
    check matches.len == 0

  test "fuzzy matching priority":
    let matches = fuzzyMatch("MIT", testLicenses)
    check matches.len > 0
    # MIT should be the first match due to exact SPDX ID match
    check matches[0].item.key == "mit"
    check matches[0].score > 0

  test "partial word matching":
    let matches = fuzzyMatch("Apache", testLicenses)
    check matches.len > 0
    var found = false
    for match in matches:
      if match.item.key == "apache-2.0" and match.matched:
        found = true
        break
    check found