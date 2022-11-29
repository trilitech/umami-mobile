module Result = {
  @deriving({abstract: light})
  type rec current<'value> = {current: 'value}
  and result<'value> = {result: current<'value>}
}

module Options = {
  @deriving({abstract: light})
  type t<'props> = {
    @optional
    initialProps: 'props,
    @optional
    wrapper: React.component<{
      "children": React.element,
    }>,
  }
}

@module("@testing-library/react-hooks")
external renderHook: (
  'props => 'hook,
  ~options: Options.t<'props>=?,
  unit,
) => Result.result<'hook> = "renderHook"

@module("@testing-library/react-hooks")
external jsAct: (unit => Js.undefined<'a>) => unit = "act"

let act = callback =>
  jsAct(() => {
    callback()
    Js.undefined
  })
