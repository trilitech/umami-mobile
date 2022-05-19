type renderResult
type testInstance
type eventFirer

@module("@testing-library/react-native") external render: React.element => renderResult = "render"
@module("@testing-library/react-native") external fireEvent: eventFirer = "fireEvent"

@send
external getByText: (
  renderResult,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => testInstance = "getByText"

@send
external getByTestId: (
  renderResult,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => testInstance = "getByTestId"

@send
external getAllByTestId: (
  renderResult,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => array<testInstance> = "getAllByTestId"

@send
external toHaveTextContent: (
  'a,
  ~matcher: @unwrap [#Str(string) | #RegExp(Js.Re.t) | #Func((string, Dom.element) => bool)],
) => unit = "toHaveTextContent"

@send
external debug: (renderResult, unit) => unit = "debug"

@send
external press: (eventFirer, testInstance) => unit = "press"
