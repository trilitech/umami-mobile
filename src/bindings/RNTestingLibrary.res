type renderResult
type testInstance
type eventFirer

@module("@testing-library/react-native") external render: React.element => renderResult = "render"
@module("@testing-library/react-native") external fireEvent: eventFirer = "fireEvent"

@module("@testing-library/react-native")
external within: testInstance => renderResult = "within"

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
external debug: (renderResult, unit) => unit = "debug"

@send
external press: (eventFirer, testInstance) => unit = "press"

@send
external changeText: (eventFirer, testInstance, ~input: string) => unit = "changeText"
