module OffBoard = ReactNavigation.Stack.Make({
  type params = unit
})

module OnboardParams = {
  type params = {
    derivationIndex: option<int>,
    token: option<Token.tokenNFT>,
    tz1: option<string>,
  }
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
