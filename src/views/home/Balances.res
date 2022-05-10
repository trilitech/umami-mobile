@react.component
let make = (~account: Store.account) => {
  <Background> <CurrentyBalanceDisplay balance=account.balance /> </Background>
}
