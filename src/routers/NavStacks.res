module OffBoard = ReactNavigation.Stack.Make({
  type params = unit
})

module OnboardParams = {
  type params = {derivationIndex: int, token: option<Token.t>, tz1FromQr: option<string>}
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
