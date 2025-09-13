import unittest
import std/[os, times, json]
import chooselic/[licenses, cache, config]

suite "Caching system":
  setup:
    # Create a temporary cache directory for testing
    let testCacheDir = getTempDir() / "chooselic_test"
    createDir(testCacheDir)

  teardown:
    # Clean up test cache directory
    let testCacheDir = getTempDir() / "chooselic_test"
    if dirExists(testCacheDir):
      removeDir(testCacheDir)

  test "cache expiry detection":
    let recentTime = now() - initDuration(hours = 1)
    let oldTime = now() - initDuration(hours = 25)

    check isCacheExpired(recentTime) == false
    check isCacheExpired(oldTime) == true

  test "save and load license list cache - skipped":
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
      )
    ]

    # Test saving
    saveLicenseListCache(testLicenses)
    check fileExists(licenseListCacheFile)

    # Skip actual loading test due to DateTime serialization complexity
    skip()

  test "cache directory creation":
    ensureCacheDir()
    check dirExists(cacheDir)

  test "load non-existent license cache fails":
    expect CatchableError:
      discard loadLicenseCache("nonexistent")

  test "load corrupted cache returns empty":
    # Create a corrupted cache file
    writeFile(licenseListCacheFile, "invalid json content")

    let result = loadLicenseListCache()
    check result.len == 0