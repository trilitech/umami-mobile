open NavStacks.OnBoard
let noHeader = _ => options(~headerShown=false, ())

module Base = {
  // Need to memoize to prevent rerenders in modals
  @react.component
  let make = React.memo(() => {
    let headerStyles = HeaderStyle.useHeaderStyle()

    <Navigator initialRouteName="Home">
      <Group>
        <Screen name="Home" options={noHeader} component=HomeScreen.make />
        <Screen name="NFT" options={headerStyles} component=DisplayNFTScreen.make />
        <Screen name="Network" options={headerStyles} component=NetworkScreen.make />
        <Screen name="Theme" options={headerStyles} component=ThemeScreen.make />
        <Screen name="BackupPhrase" options={headerStyles} component=BackupPhraseScreen.make />
        <Screen name="Accounts" options={noHeader} component=AccountsScreen.make />
        <Screen name="EditAccount" options={noHeader} component=EditAccountScreen.make />
        <Screen name="CreateAccount" options={noHeader} component=CreateAccountScreen.make />
        <Screen name="Contacts" options={noHeader} component=ContactsScreen.make />
        <Screen name="SelectRecipient" options={noHeader} component=SelectRecipientScreen.make />
        <Screen name="EditContact" options={noHeader} component=EditContactScreen.make />
        <Screen name="ShowContact" options={noHeader} component=ShowContactScreen.make />
        <Screen name="Settings" options={headerStyles} component=SettingsScreen.make />
        <Screen name="Send" options={headerStyles} component=SendScreen.make />
        <Screen name="Operations" options={headerStyles} component=OperationsScreen.make />
        <Screen name="OffboardWallet" options={headerStyles} component=OffboardWalletScreen.make />
        <Screen name="ChangePassword" options={headerStyles} component=ChangePasswordScreen.make />
        <Screen name="Logs" options={noHeader} component=LogsScreen.make />
        <Screen name="NewRecipient" options={headerStyles} component=NewRecipientScreen.make />
        <Screen name="SignContent" options={headerStyles} component=SignContentScreen.make />
        // TODO refactor these routes in a route param
        <Screen
          name="ScanSignedContent"
          options={headerStyles}
          component=ScanQRScreen.ScanSignedContent.make
        />
        <Screen
          name="ScanAddressOrDomain"
          options={headerStyles}
          component=ScanQRScreen.ScanTezosDomain.make
        />
        <Screen
          name="ScanNFTSignature" options={headerStyles} component=ScanQRScreen.ScanTezosDomain.make
        />
        <Screen name="ScanBeacon" options={headerStyles} component=ScanQRScreen.ScanBeacon.make />
        <Screen
          name="VerifySignedContent" options={headerStyles} component=VerifyContentScreen.make
        />
        <Screen name="Dapps" options={headerStyles} component=DappsScreen.make />
        <Screen name="Biometrics" options={headerStyles} component=BiometricsScreen.make />
      </Group>
      // theses views open in modal
      <Group screenOptions={_optionsProps => options(~presentation=#modal, ())}>
        <ScreenWithCallback
          name="BeaconRequest"
          options={props =>
            options(
              ~headerShown=false,
              // ~cardStyle=style(~backgroundColor="transparent", ~opacity=1., ()),
              (),
            )}>
          {({navigation, route}) => <BeaconRequestScreen navigation route />}
        </ScreenWithCallback>
        <ScreenWithCallback name="Browser" options={headerStyles}>
          {({navigation, route}) => <BrowserScreen navigation route />}
        </ScreenWithCallback>
      </Group>
    </Navigator>
  })
}

@react.component
let make = () => {
  InitAddressMetadata.useSingleRefresh()
  AccountInfoSync.useBalancesAndOpsSync()
  BeaconHooks.useInit()
  <>
    // Component is needed for BeaconDeepLink because we can't conditionaly call hooks
    <BeaconDeepLink />
    <Base />
  </>
}
