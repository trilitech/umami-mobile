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
            tz1ForContact: None,
            derivationIndex: None,
            nft: None,
            assetBalance: asset->Some,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: None,
            beaconRequest: None,
          },
        )}
      balance=account.balance
    />
  </Container>
}
