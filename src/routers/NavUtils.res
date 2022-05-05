let useNavigateWithParams = () => {
  let nav = ReactNavigation.Native.useNavigation()

  (route, params) => {
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OnBoard.Navigation.navigateWithParams(route, params)
    })
  }
}

let useNavigate = () => {
  let nav = ReactNavigation.Native.useNavigation()

  route => {
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OnBoard.Navigation.navigate(route)
    })
  }
}
