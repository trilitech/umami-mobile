@react.component
let make = (~balance, ~tokens) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  <Container>
    <CurrentyBalanceDisplay
      tokens
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
            browserUrl: None,
          },
        )}
      balance
    />
  </Container>
}
