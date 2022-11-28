@module("./js/customJestMatchers")
external toHaveTextContent: (~element: RNTestingLibrary.testInstance, ~matcher: string) => 'a =
  "toHaveTextContent"

@module("./js/customJestMatchers")
external toHaveProp: (~element: RNTestingLibrary.testInstance, ~prop: string, ~value: 'a) => 'b =
  "toHaveProp"
