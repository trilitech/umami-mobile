module OffboardParams = {
  type params = {desktopSeedPhrase: option<SecretQRPayload.t>}
}
module OffBoard = ReactNavigation.Stack.Make(OffboardParams)

module OnboardParams = {
  type params = {
    derivationIndex: option<int>,
    nft: option<Token.tokenNFT>,
    tz1ForContact: option<Pkh.t>,
    tz1ForSendRecipient: option<Pkh.t>,
    injectedAdress: option<AddressImporterTypes.payload>,
    assetBalance: option<Asset.t>,
    signedContent: option<SignedData.t>,
    beaconRequest: option<ReBeacon.Message.Request.t>,
    browserUrl: option<string>,
  }
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
