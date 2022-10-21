open Jest
open Expect

describe("getMessage", () => {
  test("works sync", () => {
    let message = ref(None)

    try {
      Js.Exn.raiseError("Some error")
    } catch {
    | e => message.contents = e->Helpers.getMessage->Some
    }
    expect(message.contents)->toBe(Some("Some error"))
  })

  testAsync("works async", finish => {
    Promise.resolve()
    ->Promise.then(() => {
      Js.Exn.raiseError("Some error")
    })
    ->Promise.catch(exn => {
      if exn->Helpers.getMessage === "Some error" {
        finish(pass)
      }
      Promise.resolve()
    })
    ->ignore
  })
})
