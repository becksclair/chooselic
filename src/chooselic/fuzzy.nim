import std/[strutils, algorithm]
import licenses

type
  FuzzyMatch* = object
    item*: LicenseItem
    score*: int
    matched*: bool

proc fuzzyScore(pattern: string, text: string): int =
  if pattern.len == 0:
    return 100

  let lowerPattern = pattern.toLowerAscii()
  let lowerText = text.toLowerAscii()

  var score = 0
  var patternIndex = 0
  var textIndex = 0

  # Exact substring match bonus
  if lowerText.contains(lowerPattern):
    score += 50

  # Character matching with position bonus
  while patternIndex < lowerPattern.len and textIndex < lowerText.len:
    if lowerPattern[patternIndex] == lowerText[textIndex]:
      score += 10
      # Bonus for consecutive matches
      if patternIndex > 0 and textIndex > 0 and
         lowerPattern[patternIndex - 1] == lowerText[textIndex - 1]:
        score += 5
      patternIndex += 1
    textIndex += 1

  # Penalize if not all pattern characters matched
  if patternIndex < lowerPattern.len:
    score -= (lowerPattern.len - patternIndex) * 5

  # Bonus for start of word matches
  let words = lowerText.split(' ')
  for word in words:
    if word.startsWith(lowerPattern):
      score += 20
      break

  return score

proc fuzzyMatch*(pattern: string, licenses: seq[LicenseItem]): seq[FuzzyMatch] =
  result = newSeq[FuzzyMatch]()

  for license in licenses:
    let nameScore = fuzzyScore(pattern, license.name)
    let keyScore = fuzzyScore(pattern, license.key)
    let spdxScore = fuzzyScore(pattern, license.spdx_id)

    let bestScore = max(nameScore, max(keyScore, spdxScore))
    let matched = bestScore > 0 or pattern.len == 0

    if matched:
      result.add(FuzzyMatch(
        item: license,
        score: bestScore,
        matched: matched
      ))

  # Sort by score descending
  result.sort do (a, b: FuzzyMatch) -> int:
    return b.score - a.score