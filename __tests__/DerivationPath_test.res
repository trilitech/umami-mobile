open Jest
open Expect
describe("DerivationPath", () => {
  test("build", () => {
    let ok = DerivationPath.build("m/44'/1729'/?'/0'")
    let error = DerivationPath.build("m/4d4'/1729'/?'/0'")
    expect((ok, error))->toEqual((
      Ok(DerivationPath.unsafeBuild("m/44'/1729'/?'/0'")),
      Error("Invalid derivation path! m/4d4'/1729'/?'/0'"),
    ))
  })

  test("getByIndex", () => {
    let d = DerivationPath.unsafeBuild("m/44'/1729'/?'/0'")
    let result = d->DerivationPath.getByIndex(3)
    expect(result)->toEqual("m/44'/1729'/3'/0'")
  })
})
