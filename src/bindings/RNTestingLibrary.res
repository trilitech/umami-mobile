type renderResult

@module("@testing-library/react-native") external render: React.element => renderResult = "render"

@send
external getByText: (
  renderResult,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => Dom.element = "getByText"

@send
external getByTestId: (
  renderResult,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => Dom.element = "getByTestId"

@send
external toHaveTextContent: (
  'a,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => unit = "toHaveTextContent"
