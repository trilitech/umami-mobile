@react.component
let make = (~account: Account.t) => {
  let navigate = NavUtils.useNavigate()
  <Container>
    <CurrentyBalanceDisplay
      tokens=account.tokens onPress={_ => navigate("Operations")->ignore} balance=account.balance
    />
  </Container>
}
