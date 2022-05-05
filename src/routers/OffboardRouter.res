open NavStacks.OffBoard
@react.component
let make = () => {
  <Navigator>
    <Group>
      <Screen name="Welcome" component=Welcome.make />
      <Screen name="ImportSecret" component=ImportSecret.make />
      <Screen name="NewSecret" component=NewSecret.make />
      <Screen name="RecordRecoveryPhrase" component=RecordSecret.make />
      <Screen name="NewPassword" component=NewPassword.make />
    </Group>
  </Navigator>
}
