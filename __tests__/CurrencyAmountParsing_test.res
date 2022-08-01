open Jest
open SendInputs

describe("parsePrettyAmountStr", () => {
  open Expect
  test("parses strings with , as comma", () => {
    expect("30,123"->parsePrettyAmountStr)->toEqual(30.123->Some)
  })

  test("nominal cases", () => {
    expect(("1"->parsePrettyAmountStr, "1.23"->parsePrettyAmountStr))->toEqual((
      1.->Some,
      1.23->Some,
    ))
  })

  test("edge cases", () => {
    expect((
      "1.0"->parsePrettyAmountStr,
      "01.230"->parsePrettyAmountStr,
      "01,230"->parsePrettyAmountStr,
      "01,230,"->parsePrettyAmountStr,
      "01.230,"->parsePrettyAmountStr,
      "01,230."->parsePrettyAmountStr,
      ".01,230."->parsePrettyAmountStr,
    ))->toEqual((1.->Some, 1.23->Some, 1.23->Some, None, None, None, None))
  })
})
