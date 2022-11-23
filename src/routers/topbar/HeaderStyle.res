open TitleMapping

let useHeaderStyle = (~onBoardingMode=false, ()) => {
  let header = NavStacks.OnBoard.Header.render(p => {
    let navigate = NavUtils.useNavigate()

    let name = NavUtils.getRouteName(p)

    if onBoardingMode == true {
      if name == "Welcome" {
        <TopBarAllScreens.Base hideNetwork=true showLogo=true />
      } else {
        <TopBarAllScreens.Base
          hideNetwork=true
          title=name
          onPressGoBack={_ => {
            navigate("Welcome")
          }}
        />
      }
    } else {
      <TopBarAllScreens title={getPrettyTitle(name)} />
    }
  })

  _ => NavStacks.OnBoard.options(~header, ())
}
