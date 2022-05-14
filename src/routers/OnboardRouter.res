open NavStacks.OnBoard
open ReactNative.Style
@react.component
let make = () => {
  let headerStyles = HeaderStyle.useHeaderStyle()
  BalancesSync.useBalancesSync()
  <Navigator>
    <Group>
      <Screen
        name="Home" options={props => options(~headerShown=false, ())} component=HomeScreen.make
      />
      <Screen name="NFT" options={headerStyles} component=DisplayNFTScreen.make />
      <Screen name="Network" options={headerStyles} component=NetworkScreen.make />
      <Screen name="Accounts" options={headerStyles} component=AccountsScreen.make />
      <Screen name="EditAccount" options={headerStyles} component=EditAccountScreen.make />
      <Screen name="CreateAccount" options={headerStyles} component=CreateAccountScreen.make />
      <Screen name="Settings" options={headerStyles} component=SettingsScreen.make />
      <Screen name="Send" options={headerStyles} component=SendScreen.make />
    </Group>
    // theses views open in modal
    <Group screenOptions={_optionsProps => options(~presentation=#modal, ())}>
      <ScreenWithCallback
        name="Receive"
        options={props =>
          options(
            ~headerShown=false,
            ~cardStyle=style(~backgroundColor="transparent", ~opacity=0.99, ()),
            (),
          )}>
        {({navigation, route}) => <ModalScreen navigation route />}
      </ScreenWithCallback>
    </Group>
  </Navigator>
}
