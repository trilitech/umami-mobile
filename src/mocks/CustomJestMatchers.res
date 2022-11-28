// Need to do this because we can't access Jest module outside of __tests__ folder
@module("./js/customJestMatchers")
external dummyAssertion: 'a = "dummyAssertion"

@module("./js/customJestMatchers")
external toHaveTextContentRaw: (~element: RNTestingLibrary.testInstance, ~matcher: string) => unit =
  "toHaveTextContent"

let toHaveTextContent = (~element, ~matcher) => {
  toHaveTextContentRaw(~element, ~matcher)
  dummyAssertion
}

@module("./js/customJestMatchers")
external toHavePropRaw: (
  ~element: RNTestingLibrary.testInstance,
  ~prop: string,
  ~value: 'a,
) => unit = "toHaveProp"

let toHaveProp = (~element, ~prop, ~value) => {
  toHavePropRaw(~element, ~prop, ~value)
  dummyAssertion
}
