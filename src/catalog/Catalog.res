open NavStacks.OnBoard

module Home = {
  open Paper
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let navigate = NavUtils.useNavigate()
    <>
      <Headline> {React.string("catalog")} </Headline>
      <Button onPress={_ => navigate("ProfileCatalog")->ignore}> {React.string("profile")} </Button>
      <Button onPress={_ => navigate("RecapCatalog")->ignore}> {React.string("recap")} </Button>
    </>
  }
}

module PureCatalog = {
  @react.component
  let make = () => {
    let navTheme = App.useNavTheme()
    <ReactNavigation.Native.NavigationContainer theme={navTheme}>
      <ThemeProvider>
        <Navigator initialRouteName="Home">
          <Screen name="Home" component=Home.make />
          <Screen name="ProfileCatalog" component=ProfileCatalog.make />
          <Screen name="RecapCatalog" component=RecapCatalog.make />
        </Navigator>
      </ThemeProvider>
    </ReactNavigation.Native.NavigationContainer>
  }
}
@react.component
let app = () => {
  <PureCatalog />
}
