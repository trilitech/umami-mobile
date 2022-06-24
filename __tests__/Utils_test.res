open Jest
open Helpers

describe("Expect", () => {
  open Expect
  test("toBe", () => expect(1 + 2)->toBe(3))
  testAsync("test async", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = MockJs.fn(mockFn)
    fn("foo")

    let calls = mockFn->MockJs.calls

    calls == ["foo"] ? finish(pass) : fail("bar")->finish
    ()
  })
})

describe("Query automator", () => {
  testAsync("start and stop", finish => {
    let mockFn = JestJs.fn(_ => ())
    let fn = MockJs.fn(mockFn)

    let cb = () => {
      Promise.make((resolve, _reject) => {
        fn("bar")
        resolve(. true)
      })
    }

    let (start, stop, _refresh) = makeQueryAutomator(~fn=cb, ~refreshRate=1, ())

    waitFor(
      ~predicate=() => {
        let calls = mockFn->MockJs.calls
        calls == ["bar", "bar", "bar"]
      },
      ~onDone=() => {
        stop()
        finish(pass)
      },
    )
    start()
  })
})
