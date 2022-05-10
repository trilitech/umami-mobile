@react.component
let make = (~account: Store.account) => {
  <Container> <CurrentyBalanceDisplay balance=account.balance /> </Container>
}
