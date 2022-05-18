@react.component
let make = (~account: Account.t) => {
  <Container> <CurrentyBalanceDisplay balance=account.balance /> </Container>
}
