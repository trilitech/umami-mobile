open Jest
open Helpers

describe("Cancel promise", () => {
  testAsync("case with cancelation", finish => {
    let mock = () => Promise.resolve(#done)

    let (cancelablePromise, cancelRef) = withCancel(mock)

    cancelablePromise()
    ->Promise.thenResolve(_ => {
      finish(fail("did not reject"))
    })
    ->Promise.catch(err => {
      switch err {
      | PromiseCanceled => finish(pass)
      | _ => fail("wrong rejection")->ignore
      }
      Promise.resolve()
    })
    ->ignore

    cancelRef.contents()
  })

  testAsync("case with no cancelation", finish => {
    let mock = () => Promise.resolve(#done)

    let (cancelablePromise, _cancel) = withCancel(mock)

    cancelablePromise()
    ->Promise.thenResolve(res => {
      finish(res == #done ? pass : fail("wrong rejection"))
    })
    ->ignore
  })
})
