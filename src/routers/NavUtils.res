let useNavigateWithParams = () => {
  let nav = ReactNavigation.Native.useNavigation()

  (route, params) => {
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OnBoard.Navigation.navigateWithParams(route, params)
    })
    ->ignore
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
    ->ignore
  }
}

let useRouteName = () => {
  let route = ReactNavigation.Native.useRoute()
  route->Js.Nullable.toOption->Belt.Option.map(r => r.name)
}
let useGoBack = () => {
  let nav = ReactNavigation.Native.useNavigation()

  _ =>
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OnBoard.Navigation.goBack()
    })
    ->ignore
}

let getToken = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.token)
  // ->Belt.Option.flatMap(i => {
  //   accounts->Belt.Array.getBy(a => a.derivationPathIndex == i)
  // })
}

let getTz1FromQr = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.tz1)
}

type route = {name: string}
// Type in binding is broken.
// TODO: PR
external fixType: NavStacks.OnBoard.Header.headerProps<'a> => {"route": route, "back": bool} =
  "%identity"

let getRouteName = headerProps => (headerProps->fixType)["route"].name
