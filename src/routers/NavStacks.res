module OffBoard = ReactNavigation.Stack.Make({
  type params = unit
})

module OnboardParams = {
  type params = {
    derivationIndex: option<int>,
    nft: option<Token.tokenNFT>,
    tz1ForContact: option<string>,
    tz1ForSendRecipient: option<string>,
    injectedAdress: option<AddressImporterTypes.payload>,
    assetBalance: option<Asset.t>,
  }
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
