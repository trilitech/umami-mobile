open NavStacks.OffBoard
@react.component
let make = () => {
  DangerousMnemonicHooks.useWipeOutOnUnmount()
  let headerStyles = HeaderStyle.useHeaderStyle(~onBoardingMode=true, ())
  <Navigator>
    <Group>
      <Screen name="Welcome" options=headerStyles component=Welcome.make />
      <Screen name="ImportSecret" options=headerStyles component=ImportSecret.make />
      <Screen name="NewSecret" options=headerStyles component=NewSecret.make />
      <Screen name="RecordRecoveryPhrase" options=headerStyles component=RecordSecret.make />
      <Screen name="NewPassword" options=headerStyles component=NewPassword.make />
    </Group>
  </Navigator>
}
