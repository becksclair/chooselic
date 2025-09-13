import std/[times, strutils]

type
  LicenseItem* = object
    key*: string
    name*: string
    spdx_id*: string
    url*: string
    node_id*: string
    html_url*: string

  License* = object
    key*: string
    name*: string
    spdx_id*: string
    url*: string
    html_url*: string
    node_id*: string
    description*: string
    implementation*: string
    permissions*: seq[string]
    conditions*: seq[string]
    limitations*: seq[string]
    body*: string

  CachedLicense* = object
    license*: License
    cached_at*: DateTime

  CachedLicenseList* = object
    licenses*: seq[LicenseItem]
    cached_at*: DateTime

const uncommonLicenses* = [
  LicenseItem(
    key: "bsd-4-clause",
    name: "BSD 4-Clause \"Original\" or \"Old\" License",
    spdx_id: "BSD-4-Clause",
    url: "https://api.github.com/licenses/bsd-4-clause",
    node_id: "MDc6TGljZW5zZTM5",
    html_url: "http://choosealicense.com/licenses/bsd-4-clause/"
  ),
  LicenseItem(
    key: "cc-by-4.0",
    name: "Creative Commons Attribution 4.0 International",
    spdx_id: "CC-BY-4.0",
    url: "https://api.github.com/licenses/cc-by-4.0",
    node_id: "MDc6TGljZW5zZTI1",
    html_url: "http://choosealicense.com/licenses/cc-by-4.0/"
  ),
  LicenseItem(
    key: "isc",
    name: "ISC License",
    spdx_id: "ISC",
    url: "https://api.github.com/licenses/isc",
    node_id: "MDc6TGljZW5zZTEw",
    html_url: "http://choosealicense.com/licenses/isc/"
  ),
  LicenseItem(
    key: "lgpl-3.0",
    name: "GNU Lesser General Public License v3.0",
    spdx_id: "LGPL-3.0",
    url: "https://api.github.com/licenses/lgpl-3.0",
    node_id: "MDc6TGljZW5zZTEy",
    html_url: "http://choosealicense.com/licenses/lgpl-3.0/"
  ),
  LicenseItem(
    key: "wtfpl",
    name: "Do What The F*ck You Want To Public License",
    spdx_id: "WTFPL",
    url: "https://api.github.com/licenses/wtfpl",
    node_id: "MDc6TGljZW5zZTE4",
    html_url: "http://choosealicense.com/licenses/wtfpl/"
  )
]

proc replaceAuthor*(author: string, key: string, text: string): string =
  result = text
  case key
  of "agpl-3.0", "gpl-2.0", "gpl-3.0", "lgpl-2.1":
    result = result.replace("<name of author>", author)
  of "apache-2.0":
    result = result.replace("[name of copyright owner]", author)
  of "bsd-2-clause", "bsd-3-clause", "mit", "bsd-4-clause", "isc":
    result = result.replace("[fullname]", author)
  of "wtfpl":
    result = result.replace("Sam Hocevar <sam@hocevar.net>", author)
  else:
    discard

proc replaceYear*(year: string, key: string, text: string): string =
  result = text
  case key
  of "agpl-3.0", "gpl-2.0", "gpl-3.0", "lgpl-2.1":
    result = result.replace("<year>", year)
  of "apache-2.0":
    result = result.replace("[yyyy]", year)
  of "bsd-2-clause", "bsd-3-clause", "mit", "bsd-4-clause", "isc":
    result = result.replace("[year]", year)
  of "wtfpl":
    # Replace second occurrence of "2004"
    var count = 0
    var i = 0
    while i < result.len - 3:
      if result[i..i+3] == "2004":
        inc count
        if count == 2:
          result = result[0..<i] & year & result[i+4..^1]
          break
        i += 4
      else:
        i += 1
  else:
    discard

proc processLicense*(license: License, author: string, year: string): string =
  result = license.body
  if author.len > 0:
    result = replaceAuthor(author, license.key, result)
  if year.len > 0:
    result = replaceYear(year, license.key, result)