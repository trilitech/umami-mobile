open Jest
describe("withCache2", () => {
  testAsync("2 calls with same arguments -> Computation done once", finish => {
    let fn1 = (_ => ())->JestJs.fn
    let mockFn = fn1->MockJs.fn

    let fn = arg => {
      mockFn(arg)
      Promise.resolve("result")
    }

    let memoized = Cache.withCache(fn, arg => arg["field1"])

    memoized({"field1": "hello"})
    ->Promise.then(res1 => memoized({"field1": "hello"})->Promise.thenResolve(res2 => (res1, res2)))
    ->Promise.thenResolve(result => {
      let calls = fn1->MockJs.calls
      Js.Console.log(calls)
      let expected = result == ("result", "result") && calls == [{"field1": "hello"}]->Obj.magic
      if expected {
        finish(pass)
      }
    })
    ->ignore
  })

  testAsync("2 calls with different arguments -> Computation done twice", finish => {
    let fn1 = (_ => ())->JestJs.fn
    let mockFn = fn1->MockJs.fn

    let fn = arg => {
      mockFn(arg)
      Promise.resolve(arg["field1"] == "foo" ? "result1" : "result2")
    }

    let memoized = Cache.withCache(fn, arg => arg["field1"])

    memoized({"field1": "foo"})
    ->Promise.then(res1 => memoized({"field1": "bar"})->Promise.thenResolve(res2 => (res1, res2)))
    ->Promise.thenResolve(result => {
      let calls = fn1->MockJs.calls
      let expected =
        result == ("result1", "result2") && calls == [{"field1": "foo"}, {"field1": "bar"}]
      if expected {
        finish(pass)
      }
    })
    ->ignore
  })
})
