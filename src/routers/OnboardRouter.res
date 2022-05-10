open NavStacks.OnBoard
@react.component
let make = () => {
  let headerStyles = HeaderStyle.useHeaderStyle()
  BalancesSync.useBalancesSync()
  <Navigator>
    <Group>
      <Screen
        name="Home" options={props => options(~headerShown=false, ())} component=HomeScreen.make
      />
      <Screen name="Network" options={headerStyles} component=NetworkScreen.make />
      <Screen name="Accounts" options={headerStyles} component=AccountsScreen.make />
      <Screen name="EditAccount" options={headerStyles} component=EditAccountScreen.make />
      <Screen name="CreateAccount" options={headerStyles} component=CreateAccountScreen.make />
      <Screen name="Settings" options={headerStyles} component=SettingsScreen.make />
      <Screen name="Send" options={headerStyles} component=SendScreen.make />
    </Group>
    // theses views open in modal
    <Group screenOptions={_optionsProps => options(~presentation=#modal, ())}>
      <ScreenWithCallback name="Notifications">
        {({navigation, route}) => <ModalScreen navigation route />}
      </ScreenWithCallback>
    </Group>
  </Navigator>
}
