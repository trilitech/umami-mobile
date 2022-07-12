open NavStacks.OnBoard
@react.component
let make = () => {
  let headerStyles = HeaderStyle.useHeaderStyle()
  BalancesSync.useBalancesSync()
  <Navigator initialRouteName="Home">
    <Group>
      <Screen
        name="Home" options={props => options(~headerShown=false, ())} component=HomeScreen.make
      />
      <Screen name="NFT" options={headerStyles} component=DisplayNFTScreen.make />
      <Screen name="Network" options={headerStyles} component=NetworkScreen.make />
      <Screen name="Theme" options={headerStyles} component=ThemeScreen.make />
      <Screen name="BackupPhrase" options={headerStyles} component=BackupPhraseScreen.make />
      <Screen name="Accounts" options={headerStyles} component=AccountsScreen.make />
      <Screen name="EditAccount" options={headerStyles} component=EditAccountScreen.make />
      <Screen name="CreateAccount" options={headerStyles} component=CreateAccountScreen.make />
      <Screen name="Contacts" options={headerStyles} component=ContactsScreen.make />
      <Screen name="EditContact" options={headerStyles} component=EditContactScreen.make />
      <Screen name="ShowContact" options={headerStyles} component=ShowContactScreen.make />
      <Screen name="CreateAddress" options={headerStyles} component=CreateContactScreen.make />
      <Screen name="Settings" options={headerStyles} component=SettingsScreen.make />
      <Screen name="Send" options={headerStyles} component=SendScreen.make />
      <Screen name="ScanQR" options={headerStyles} component=ScanQRScreen.make />
      <Screen name="Operations" options={headerStyles} component=OperationsScreen.make />
      <Screen name="OffboardWallet" options={headerStyles} component=OffboardWalletScreen.make />
      <Screen name="Wert" options={headerStyles} component=WertScreen.make />
    </Group>
    // theses views open in modal
    // <Group screenOptions={_optionsProps => options(~presentation=#modal, ())}>
    //   <ScreenWithCallback
    //     name="Receive"
    //     options={props =>
    //       options(
    //         ~headerShown=false,
    //         ~cardStyle=style(~backgroundColor="transparent", ~opacity=0.99, ()),
    //         (),
    //       )}>
    //     {({navigation, route}) => <ReceiveModal navigation route />}
    //   </ScreenWithCallback>
    // </Group>
  </Navigator>
}
