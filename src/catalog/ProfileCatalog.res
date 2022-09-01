let mockAccount: Account.t = {
  name: "foo",
  tz1: "cool"->Pkh.unsafeBuild,
  balance: Some(3),
  tokens: [],
  sk: "",
  derivationPathIndex: 9,
  transactions: [],
  pk: "",
}

@react.component
let make = (~navigation as _, ~route as _) => {
  <Profile.PureProfile account=mockAccount />
}
