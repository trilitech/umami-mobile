module OffBoard = ReactNavigation.Stack.Make({
  type params = unit
})

module OnboardParams = {
  type params = {
    derivationIndex: option<int>,
    nft: option<Token.tokenNFT>,
    tz1: option<string>,
    assetBalance: option<Asset.t>,
  }
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
