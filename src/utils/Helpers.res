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
