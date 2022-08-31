open Belt
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

let useOffboardNavigateWithParams = () => {
  let nav = ReactNavigation.Native.useNavigation()

  (route, params) => {
    nav
    ->Js.Nullable.toOption
    ->Belt.Option.map(nav => {
      nav->NavStacks.OffBoard.Navigation.navigateWithParams(route, params)
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

let getNft = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.nft)
}

let getTz1FforContact = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.tz1ForContact)
}

let getTz1ForSendRecipient = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.tz1ForSendRecipient)
}

let getInjectedAddress = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.injectedAdress)
}

let getAssetBalance = (route: NavStacks.OnBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.assetBalance)
}

let getDesktopSeedPhrase = (route: NavStacks.OffBoard.route) => {
  route.params->Belt.Option.flatMap(p => p.desktopSeedPhrase)
}

type route = {name: string}
// Type in binding is broken.
// TODO: PR
external fixType: NavStacks.OnBoard.Header.headerProps<'a> => {"route": route, "back": bool} =
  "%identity"

let getRouteName = headerProps => (headerProps->fixType)["route"].name

// let mockReponse: Taquito.Toolkit.operation = Obj.magic({"hash": "mockHash"})

type myRoute = {name: string}
type hackedState = {routes: array<myRoute>}

let useGetLastRouteName = () => {
  let nav = ReactNavigation.Native.useNavigation()

  let state = nav->Js.Nullable.toOption->Option.map(NavStacks.OnBoard.Navigation.getState)

  state->Option.flatMap(state => {
    let state: hackedState = Obj.magic(state)
    state.routes->Array.map(r => r.name)->Array.get(state.routes->Belt.Array.length - 2)
  })
}

let useGoBackWithParams = () => {
  let lastRoute = useGetLastRouteName()
  let navvigateWithParams = useNavigateWithParams()
  params => {
    lastRoute
    ->Option.map(route => {
      navvigateWithParams(route, params)
    })
    ->ignore
  }
}
