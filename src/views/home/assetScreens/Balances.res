@react.component
let make = (~account: Account.t) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  <Container>
    <CurrentyBalanceDisplay
      tokens=account.tokens
      onPress={asset =>
        navigateWithParams(
          "Operations",
          {
            tz1: None,
            derivationIndex: None,
            nft: None,
            assetBalance: asset->Some,
          },
        )}
      balance=account.balance
    />
  </Container>
}
