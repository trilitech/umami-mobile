open NavStacks.OffBoard
@react.component
let make = () => {
  let headerStyles = HeaderStyle.useHeaderStyle(~onBoardingMode=true, ())
  DangerousMnemonicHooks.useResetOnUnmount()

  <Navigator>
    <Group>
      <Screen name="Welcome" options=headerStyles component=WelcomeScreen.make />
      <Screen name="ImportSecret" options=headerStyles component=ImportSecretScreen.make />
      <Screen
        name="QRImportInstructions" options=headerStyles component=QRImportInstructionsScreen.make
      />
      <Screen name="NewSecret" options=headerStyles component=NewSecretScreen.make />
      <Screen name="RecordRecoveryPhrase" options=headerStyles component=RecordSecretScreen.make />
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
