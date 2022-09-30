open NavStacks.OffBoard
@react.component
let make = () => {
  let headerStyles = HeaderStyle.useHeaderStyle(~onBoardingMode=true, ())
  DangerousMnemonicHooks.useResetOnUnmount()

  <Navigator>
    <Group>
      <Screen name="Welcome" options=headerStyles component=Welcome.make />
      <Screen name="ImportSecret" options=headerStyles component=ImportSecret.make />
      <Screen
        name="QRImportInstructions" options=headerStyles component=QRImportInstructionsScreen.make
      />
      <Screen name="NewSecret" options=headerStyles component=NewSecret.make />
      <Screen name="RecordRecoveryPhrase" options=headerStyles component=RecordSecret.make />
      <Screen name="NewPassword" options=headerStyles component=NewPasswordScreen.make />
      <Screen
        name="ScanDesktopSeedPhrase"
        options={headerStyles}
        component=ScanQRScreen.ScanDesktopSeedPhrase.make
      />
      <Screen
        name="RestoreDesktopSeedPhrase"
        options={headerStyles}
        component=RestoreDesktopSeedPhraseScreen.make
      />
    </Group>
  </Navigator>
}
