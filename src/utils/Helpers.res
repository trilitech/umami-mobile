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
  | e => e->Js.Exn.asJsExn->Belt.Option.flatMap(Js.Exn.message)
  }
  message->Belt.Option.getWithDefault(
    "Could not parse message from provided error. Exn is probably not of type Js.Exn.t",
  )
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

let rec waitFor = (~predicate: unit => bool, ~onDone) =>
  if predicate() {
    onDone()
  } else {
    Js.Global.setTimeout(() => waitFor(~predicate, ~onDone), 1)->ignore
  }

let resultToOption = r =>
  switch r {
  | Ok(r) => Some(r)
  | Error(_) => None
  }

// Always a pain to find this
let nullToOption = n => Js.Nullable.toOption(n)
let nullToOption2 = n => Js.Null.toOption(n)

let tap = val => {
  Js.Console.log(val)
  val
}

let formatHash = (tz1: string, ~beginLength=5, ~endLength=5, ()) => {
  let length = tz1->Js.String2.length
  tz1->Js.String2.slice(~from=0, ~to_=beginLength) ++
  "..." ++
  tz1->Js.String2.slice(~from=-endLength, ~to_=length)
}
