from std/strformat import fmt
from std/strutils import multiReplace, Digits, parseInt

from pkg/util/forRand import randSeq

# CNPJ

func genCnpjVerificationDigits*(digits: openArray[int]): array[2, int] =
  ## Generates the CNPJ verification  code
  runnableExamples:
    from std/random import randomize
    randomize()
    doAssert [2, 4, 3, 8, 2, 7, 5, 3, 0, 0, 0, 1].genCnpjVerificationDigits == [7, 7]
  func sumMultiplied(arr: openArray[int]; firstDigit = -1): int =
    result = 0
    var i = 5
    if firstDigit >= 0:
      result = firstDigit * 2
      inc i
    for o, x in arr:
      if i < 2:
        i = 9
      result.inc x * i
      dec i
    result = 11 - (result mod 11)
    if result >= 10: result = 0
  if digits.len == 12:
    result[0] = digits.sumMultiplied
    result[1] = digits.sumMultiplied result[0]

type
  ParsedCnpj* = tuple
    valid: bool
    code: array[12, int]
    verification: array[2, int]

const newParsedCnpj = (false, [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], [-1, -1])

func parseCnpj*(cpf: string): ParsedCnpj =
  ## Strip and parses the CNPJ
  runnableExamples:
    let parsed = "11.222.333/0001-81".parseCnpj
    doAssert parsed.code == [1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1]
    doAssert parsed.verification == [8, 1]
  result = newParsedCnpj
  template add(res: var ParsedCnpj; ch: char) =
    let x = parseInt $ch
    var i = 0
    while (i < 12 and res.code[i] != -1): inc i
    if i < 12:
      res.code[i] = x
    else:
      i = 0
      while (i < 2 and res.verification[i] != -1): inc i
      if i < 2:
        result.verification[i] = x
        if i == 1:
          result.valid = true
      else:
        result.valid = false
  for x in cpf:
    if x in Digits:
      result.add x

proc genCnpj*(formatted = true; valid = true): string =
  ## Brazil CNPJ generator
  ## Based in https://www.macoratti.net/alg_cnpj.htm
  runnableExamples:
    from std/random import randomize
    randomize()
    doAssert genCnpj(formatted = true).len == 18
    doAssert genCnpj(formatted = false).len == 14
  var n = randSeq(8, 9)
  n.add 0
  n.add 0
  n.add 0
  n.add 1
  let randomDigit = randSeq(2, 9)
  var d = [randomDigit[0], randomDigit[1]]
  if valid:
    d = n.genCnpjVerificationDigits
  result = fmt"{n[0]}{n[1]}.{n[2]}{n[3]}{n[4]}.{n[5]}{n[6]}{n[7]}/{n[8]}{n[9]}{n[10]}{n[11]}-{d[0]}{d[1]}"
  if not formatted:
    result = result.multiReplace {".": "", "-": "", "/": ""}

proc validCnpj*(cpf: string): bool =
  ## Checks if the given CNPJ is valid
  runnableExamples:
    from std/random import randomize
    randomize()
    doAssert validCnpj "11.222.333/0001-81"
    doAssert not validCnpj "11.222.333/0001-99"
  result = false
  let (valid, code, verification) = parseCnpj cpf
  if not valid:
    return false
  let d = code.genCnpjVerificationDigits
  result = verification == d
