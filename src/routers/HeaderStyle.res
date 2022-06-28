type route = {name: string}
external fixType: NavStacks.OnBoard.Header.headerProps<'a> => {"route": route, "back": bool} =
  "%identity"

let dangerColor = Colors.Light.error

let useHeaderStyle = (~onBoardingMode=false, ()) => {
  let header = NavStacks.OnBoard.Header.render(p => {
    let goBack = NavUtils.useGoBack()
    let navigate = NavUtils.useNavigate()

    let name = (p->fixType)["route"].name

    if onBoardingMode == true {
      if name == "Welcome" {
        <TopBarAllScreens />
      } else {
        <TopBarAllScreens onPressGoBack={_ => navigate("Welcome")} />
      }
    } else {
      <TopBarAllScreens title=name onPressGoBack={goBack} />
    }
  })

  _ => NavStacks.OnBoard.options(~header, ())
}
