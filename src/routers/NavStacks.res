module OffBoard = ReactNavigation.Stack.Make({
  type params = unit
})

module OnboardParams = {
  type params = {derivationIndex: int}
}

module OnBoard = ReactNavigation.Stack.Make(OnboardParams)
