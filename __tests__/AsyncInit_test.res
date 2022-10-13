open Jest

open TestingLibraryHooks

describe("useAsyncInit", () => {
  testAsync("it returns true when function resolves", finish => {
    let {result, waitForNextUpdate} = renderHook(() =>
      AsyncInit._useAsyncInit(~init=_ => Promise.resolve(), ~notify=_ => (), ())
    )

    // Can't use waitFor here becase we would get "setState outside of act" warnings
    waitForNextUpdate()
    ->Promise.thenResolve(_ =>
      if result.current === true {
        finish(pass)
      }
    )
    ->ignore
  })

  testAsync("it notifies and returns false if there is an error", finish => {
    let mockFn = JestJs.fn(_ => ())

    let _ = renderHook(() =>
      AsyncInit._useAsyncInit(
        ~init=_ => Promise.resolve()->Promise.thenResolve(() => Js.Exn.raiseError("Some error")),
        ~notify=m => mockFn->MockJs.fn(m),
        ~errMsgPrefix="Your promise did not resolve.",
        (),
      )
    )

    Helpers.waitFor(
      ~predicate=_ => mockFn->MockJs.calls == ["Your promise did not resolve. Some error"],
      ~onDone=_ => finish(pass),
    )
  })
})
