let mockAccount: Account.t = {
  name: "foo",
  tz1: "cool",
  balance: Some(3),
  tokens: [],
  sk: "",
  derivationPathIndex: 9,
  transactions: [],
}

@react.component
let make = (~navigation as _, ~route as _) => {
  <Profile.PureProfile account=mockAccount />
}
