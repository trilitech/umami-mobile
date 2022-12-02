open SecretQRPayload

open Jest
open Expect

describe("SecretQRPayload", () => {
  test("JSON decode malformed payload", () => {
    let data = `{
  "points": [
    { "x": 1, "y": -4 },
    { "x": 5, "y": 8 }
  ]
}`
    let result = JSON.Decode.decode(data)

    let expected = Error("derivationPath required")
    expect(result)->toEqual(expected)
  })

  test("JSON decode valid payload", () => {
    let data = `
{
  "version": "1.0",
  "derivationPath": 
    "m/44'/1729'/?'/0'"
  ,
  "recoveryPhrase": 
    {
      "salt": "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
      "iv": "7b34cdbfa79a753d2ce393caea78c9f8",
      "data": "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff"
    }
  
}

`
    let result = JSON.Decode.decode(data)

    let expected: result<JSON.t, string> = {
      derivationPath: "m/44'/1729'/?'/0'",
      recoveryPhrase: {
        salt: "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
        iv: "7b34cdbfa79a753d2ce393caea78c9f8",
        data: "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff",
      },
    }->Ok

    expect(result)->toEqual(expected)
  })

  test("fromString returns result(valid data)", () => {
    let data = `
{
  "version": "1.0",
  "derivationPath": 
    "m/44'/1729'/?'/0'"
  ,
  "recoveryPhrase": 
    {
      "salt": "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
      "iv": "7b34cdbfa79a753d2ce393caea78c9f8",
      "data": "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff"
    }
  
}

`
    let result = fromString(data)

    let expected = {
      derivationPath: "m/44'/1729'/?'/0'"->DerivationPath.unsafeBuild,
      recoveryPhrase: {
        salt: "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
        iv: "7b34cdbfa79a753d2ce393caea78c9f8",
        data: "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff",
      },
    }->Ok

    expect(result)->toEqual(expected)
  })

  test("fromString handles errors (missing derivation path)", () => {
    let data = `
{
  "version": "1.0",
  "recoveryPhrase": 
    {
      "salt": "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
      "iv": "7b34cdbfa79a753d2ce393caea78c9f8",
      "data": "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff"
    }
  
}

`
    let result = fromString(data)

    let expected = Error("derivationPath required")

    expect(result)->toEqual(expected)
  })

  test("fromString handles errors(invalid JSON)", () => {
    let data = ` bar content `
    let result = fromString(data)

    let expected = Error(
      "Unabled to parse string. Reason: Could not parse message from provided error. Exn is probably not of type Js.Exn.t",
    )

    expect(result)->toEqual(expected)
  })
})
