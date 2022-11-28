open Jest

describe("<Profile />", () => {
  test("it displays tez address", () => {
    let account: Account.t = {
      name: "foo",
      tz1: "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6"->Pkh.unsafeBuild,
      derivationPathIndex: 0,
      balance: Some(44),
      tokens: [],
      sk: "bar",
      pk: ""->Pk.unsafeBuild,
      transactions: [],
    }
    let fixture = <Profile.PureProfile account />

    let screen = RNTestingLibrary.render(fixture)
    let res = screen->RNTestingLibrary.getByTestId(~matcher=#Str("tez-display"))
    let expected = "tz1Te...9M7d6"

    CustomJestMatchers.toHaveTextContent(~element=res, ~matcher=expected)
  })
})
