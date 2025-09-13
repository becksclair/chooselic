import std/[os]

const
  version* = "0.1.0"
  cacheDir* = getHomeDir() / ".cache" / "chooselic"
  licenseListCacheFile* = cacheDir / "licenses.json"
  githubApiBase* = "https://api.github.com"
  userAgent* = "chooselic/" & version
  cacheExpiryHours* = 24

proc getGithubApiBase*(): string =
  githubApiBase

proc getLicensesEndpoint*(): string =
  githubApiBase & "/licenses"

proc getLicenseEndpoint*(): string =
  githubApiBase & "/licenses"

proc ensureCacheDir*() =
  createDir(cacheDir)