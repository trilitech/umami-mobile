type current<'a> = {current: 'a}
type renderHookResult<'hookReturnType> = {
  result: current<'hookReturnType>,
  waitForNextUpdate: unit => Promise.t<unit>,
}

@module("@testing-library/react-hooks")
external renderHook: 'a => renderHookResult<'b> = "renderHook"

@module("@testing-library/react-hooks")
external act: (unit => 'a) => unit = "act"
