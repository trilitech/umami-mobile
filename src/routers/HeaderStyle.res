type route = {name: string}
external fixType: NavStacks.OnBoard.Header.headerProps<'a> => {"route": route, "back": bool} =
  "%identity"

let dangerColor = Colors.Light.error
let useHeaderStyle = () => {
  let header = NavStacks.OnBoard.Header.render(p => {
    let goBack = NavUtils.useGoBack()

    let name = (p->fixType)["route"].name
    <TopBarAllScreens title=name onPressGoBack={goBack} />
  })

  let options = NavStacks.OnBoard.options(~header, ())
  _ => options
}
