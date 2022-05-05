open NavStacks.OnBoard
@react.component
let make = () => {
  BalancesSync.useBalancesSync()
  <Navigator>
    <Group>
      <Screen
        name="Home" options={props => options(~headerShown=false, ())} component=HomeScreen.make
      />
      <Screen name="Network" component=NetworkScreen.make />
      <Screen name="Accounts" component=AccountsScreen.make />
      <Screen name="EditAccount" component=EditAccountScreen.make />
      <Screen name="CreateAccount" component=CreateAccountScreen.make />
      <Screen name="Settings" component=SettingsScreen.make />
      <Screen name="Send" component=SendScreen.make />
    </Group>
    // theses views open in modal
    <Group screenOptions={_optionsProps => options(~presentation=#modal, ())}>
      <ScreenWithCallback name="Notifications">
        {({navigation, route}) => <ModalScreen navigation route />}
      </ScreenWithCallback>
    </Group>
  </Navigator>
}
