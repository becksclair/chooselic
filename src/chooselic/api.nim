import std/[httpclient, json, strformat]
import licenses, config

type
  ApiError* = object of CatchableError
    statusCode*: HttpCode

proc newApiClient*(): HttpClient =
  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Accept": "application/vnd.github+json",
    "User-Agent": userAgent
  })
  return client

proc getLicenses*(client: HttpClient): seq[LicenseItem] =
  try:
    let response = client.get(getLicensesEndpoint())
    if response.code != Http200:
      raise newException(ApiError, fmt"HTTP {response.code}: {response.status}")

    let jsonData = parseJson(response.body)
    result = newSeq[LicenseItem]()

    for item in jsonData:
      result.add(LicenseItem(
        key: item["key"].getStr(),
        name: item["name"].getStr(),
        spdx_id: item.getOrDefault("spdx_id").getStr(""),
        url: item["url"].getStr(),
        node_id: item["node_id"].getStr(),
        html_url: item.getOrDefault("html_url").getStr("")
      ))

    # Add uncommon licenses
    result.add(uncommonLicenses)

  except HttpRequestError as e:
    raise newException(ApiError, "Network error: " & e.msg)
  except JsonParsingError as e:
    raise newException(ApiError, "JSON parsing error: " & e.msg)

proc getLicense*(client: HttpClient, key: string): License =
  try:
    let url = getLicenseEndpoint() & "/" & key
    let response = client.get(url)
    if response.code != Http200:
      raise newException(ApiError, fmt"HTTP {response.code}: {response.status}")

    let jsonData = parseJson(response.body)
    result = License(
      key: jsonData["key"].getStr(),
      name: jsonData["name"].getStr(),
      spdx_id: jsonData.getOrDefault("spdx_id").getStr(""),
      url: jsonData["url"].getStr(),
      html_url: jsonData.getOrDefault("html_url").getStr(""),
      node_id: jsonData["node_id"].getStr(),
      description: jsonData.getOrDefault("description").getStr(""),
      implementation: jsonData.getOrDefault("implementation").getStr(""),
      body: jsonData["body"].getStr()
    )

    # Parse arrays if present
    if jsonData.hasKey("permissions"):
      for perm in jsonData["permissions"]:
        result.permissions.add(perm.getStr())

    if jsonData.hasKey("conditions"):
      for cond in jsonData["conditions"]:
        result.conditions.add(cond.getStr())

    if jsonData.hasKey("limitations"):
      for limit in jsonData["limitations"]:
        result.limitations.add(limit.getStr())

  except HttpRequestError as e:
    raise newException(ApiError, "Network error: " & e.msg)
  except JsonParsingError as e:
    raise newException(ApiError, "JSON parsing error: " & e.msg)