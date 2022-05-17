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

let useGoBack = () => {
  let nav = ReactNavigation.Native.useNavigation()

  _ => {
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OnBoard.Navigation.goBack()
    })
  }
}

let getToken = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.token)
  // ->Belt.Option.flatMap(i => {
  //   accounts->Belt.Array.getBy(a => a.derivationPathIndex == i)
  // })
}

let getTz1FromQr = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.tz1FromQr)
}
