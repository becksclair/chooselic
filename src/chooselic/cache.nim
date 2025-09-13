import std/[os, json, times, strformat, httpclient]
import licenses, config, api

proc isCacheExpired*(cacheTime: DateTime): bool =
  let now = now()
  let diff = now - cacheTime
  return diff.inHours >= cacheExpiryHours

proc saveLicenseListCache*(licenses: seq[LicenseItem]) =
  ensureCacheDir()
  let cached = CachedLicenseList(
    licenses: licenses,
    cached_at: now()
  )
  let jsonData = %{
    "licenses": %licenses,
    "cached_at": %($cached.cached_at)
  }
  writeFile(licenseListCacheFile, $jsonData)

proc loadLicenseListCache*(): seq[LicenseItem] =
  if not fileExists(licenseListCacheFile):
    return @[]

  try:
    let content = readFile(licenseListCacheFile)
    let jsonData = parseJson(content)

    let cachedAtStr = jsonData["cached_at"].getStr()
    let cachedAt = parse(cachedAtStr, "yyyy-MM-dd'T'HH:mm:ss'.'fffzzz")

    if isCacheExpired(cachedAt):
      return @[]

    result = newSeq[LicenseItem]()
    for item in jsonData["licenses"]:
      result.add(LicenseItem(
        key: item["key"].getStr(),
        name: item["name"].getStr(),
        spdx_id: item.getOrDefault("spdx_id").getStr(""),
        url: item["url"].getStr(),
        node_id: item["node_id"].getStr(),
        html_url: item.getOrDefault("html_url").getStr("")
      ))
  except:
    return @[]

proc getLicenseCacheFile(key: string): string =
  return cacheDir / fmt"{key}.json"

proc saveLicenseCache*(license: License) =
  ensureCacheDir()
  let cached = CachedLicense(
    license: license,
    cached_at: now()
  )
  let jsonData = %{
    "license": %license,
    "cached_at": %($cached.cached_at)
  }
  let cacheFile = getLicenseCacheFile(license.key)
  writeFile(cacheFile, $jsonData)

proc loadLicenseCache*(key: string): License =
  let cacheFile = getLicenseCacheFile(key)
  if not fileExists(cacheFile):
    raise newException(CatchableError, "License not in cache")

  try:
    let content = readFile(cacheFile)
    let jsonData = parseJson(content)

    let cachedAtStr = jsonData["cached_at"].getStr()
    let cachedAt = parse(cachedAtStr, "yyyy-MM-dd'T'HH:mm:ss'.'fffzzz")

    if isCacheExpired(cachedAt):
      raise newException(CatchableError, "Cache expired")

    let licenseData = jsonData["license"]
    result = License(
      key: licenseData["key"].getStr(),
      name: licenseData["name"].getStr(),
      spdx_id: licenseData.getOrDefault("spdx_id").getStr(""),
      url: licenseData["url"].getStr(),
      html_url: licenseData.getOrDefault("html_url").getStr(""),
      node_id: licenseData["node_id"].getStr(),
      description: licenseData.getOrDefault("description").getStr(""),
      implementation: licenseData.getOrDefault("implementation").getStr(""),
      body: licenseData["body"].getStr()
    )

    # Parse arrays if present
    if licenseData.hasKey("permissions"):
      for perm in licenseData["permissions"]:
        result.permissions.add(perm.getStr())

    if licenseData.hasKey("conditions"):
      for cond in licenseData["conditions"]:
        result.conditions.add(cond.getStr())

    if licenseData.hasKey("limitations"):
      for limit in licenseData["limitations"]:
        result.limitations.add(limit.getStr())

  except:
    raise newException(CatchableError, "Failed to load from cache")

proc getCachedLicenses*(client: HttpClient): seq[LicenseItem] =
  result = loadLicenseListCache()
  if result.len == 0:
    try:
      result = getLicenses(client)
      saveLicenseListCache(result)
    except ApiError as e:
      echo "Error fetching licenses: ", e.msg
      result = @[]

proc getCachedLicense*(client: HttpClient, key: string): License =
  try:
    return loadLicenseCache(key)
  except:
    try:
      result = getLicense(client, key)
      saveLicenseCache(result)
    except ApiError as e:
      raise newException(CatchableError, "Failed to fetch license: " & e.msg)