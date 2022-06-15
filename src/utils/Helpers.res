let update = (arr: array<'a>, i: int, newVal: 'a) => {
  arr->Belt.Array.mapWithIndex((j, e) => i != j ? e : newVal)
}

let both = (o1: option<'a>, o2: option<'b>): option<('a, 'b)> =>
  switch (o1, o2) {
  | (Some(o1), Some(o2)) => Some((o1, o2))
  | (None, _)
  | (_, None) =>
    None
  }

let reactFold = (o, fn) => o->Belt.Option.mapWithDefault(React.null, fn)

let filterNone = (arr: array<option<'a>>) =>
  arr->Belt.Array.reduce([], (acc, curr) =>
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
