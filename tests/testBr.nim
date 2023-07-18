import std/unittest

import docid/br/[
  cpf,
  cnpj
]

suite "Brazil IDs":
  test "Generate CPF verification digits":
    check [1, 1, 1, 4, 4, 4, 7, 7, 7].genCpfVerificationDigits == [3, 5]
  test "Generate CPF":
    check genCpf(formatted = true).len == 14
    check genCpf(formatted = false).len == 11
  test "Parse CPF":
    let parsed = "111.444.777-35".parseCpf
    check parsed.code == [1, 1, 1, 4, 4, 4, 7, 7, 7]
    check parsed.verification == [3, 5]
  test "Valid CPF":
    check validCpf "111.444.777-35"
    check not validCpf "111.444.777-99"
    
  test "Generate CNPJ verification digits":
    check [1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1].genCnpjVerificationDigits == [8, 1]
  test "Generate CNPJ":
    check genCnpj(formatted = true).len == 18
    check genCnpj(formatted = false).len == 14
  test "Parse CNPJ":
    let parsed = "11.222.333/0001-81".parseCnpj
    check parsed.code == [1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1] 
    check parsed.verification == [8, 1]
  test "Valid CNPJ":
    check validCnpj "11.222.333/0001-81"
    check not validCnpj "11.222.333/0001-99"
