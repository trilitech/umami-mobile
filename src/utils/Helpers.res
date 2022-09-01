open Belt
let update = (arr: array<'a>, i: int, newVal: 'a) => {
  arr->Array.mapWithIndex((j, e) => i != j ? e : newVal)
}

let both = (o1: option<'a>, o2: option<'b>): option<('a, 'b)> =>
  switch (o1, o2) {
  | (Some(o1), Some(o2)) => Some((o1, o2))
  | (_, _) => None
  }

let three = (o1: option<'a>, o2: option<'b>, o3: option<'c>): option<('a, 'b, 'c)> =>
  switch (o1, o2, o3) {
  | (Some(o1), Some(o2), Some(o3)) => Some((o1, o2, o3))
  | (_, _, _) => None
  }

let reactFold = (o, fn) => o->Belt.Option.mapWithDefault(React.null, fn)

let filterNone = (arr: array<option<'a>>) =>
  arr->Array.reduce([], (acc, curr) =>
    switch curr {
    | Some(val) => acc->Belt.Array.concat([val])
    | None => acc
    }
  )

let getMessage = (e: exn) => {
  let message = switch e {
  | Promise.JsError(jsExn) => jsExn->Js.Exn.message
  | _ => None
  }
  message->Belt.Option.getWithDefault("Unknown error")
}

let cancelRef: ref<option<unit => unit>> = ref(None)

exception PromiseCanceled

let withCancel = (fn: 'b => Promise.t<'a>) => {
  let cancelRef: ref<unit => unit> = ref(() => ())

  let fn = () =>
    Promise.make((resolve, reject) => {
      let cancel = () => {
        reject(. PromiseCanceled)
      }
      cancelRef.contents = cancel

      fn()
      ->Promise.thenResolve(res => resolve(. res))
      ->Promise.catch(exn => {
        reject(. exn)->ignore
        Promise.resolve()
      })
      ->ignore
    })

  (fn, cancelRef)
}

let makeQueryAutomator = (
  ~fn,
  ~onResult=_ => (),
  ~onError=_ => (),
  ~refreshRate=Constants.refreshTime,
  (),
) => {
  let (cancelablFn, cancel) = withCancel(fn)
  let timeoutId = ref(None)

  let rec recursive = () => {
    cancelablFn()
    ->Promise.thenResolve(res => onResult(res))
    ->Promise.catch(err => {
      switch err {
      | PromiseCanceled => ()
      | err => onError(err)
      }
      Promise.resolve()
    })
    ->Promise.finally(_ => {
      timeoutId.contents = Js.Global.setTimeout(recursive, refreshRate)->Some
    })
    ->ignore
  }

  let start = recursive

  let stop = () => {
    cancel.contents()
    timeoutId.contents
    ->Option.map(id => {
      Js.Global.clearTimeout(id)
      timeoutId.contents = None
    })
    ->ignore
  }

  let refresh = () => {
    stop()
    start()
  }

  (start, stop, refresh)
}

let rec waitFor = (~predicate: unit => bool, ~onDone) =>
  if predicate() {
    onDone()
  } else {
    Js.Global.setTimeout(() => waitFor(~predicate, ~onDone), 1)->ignore
  }
