open Paper
open NavStacks.OffBoard

let intructions =
  "1. Open the Umami desktop app\n" ++
  "2. In the Accounts tab, click \"Management View\"\n" ++
  "3. Choose a secret and click \"Export\"\n" ++ "4. Scan the QR code with Umami mobile"

@react.component
let make = (~navigation, ~route as _) => {
  <InstructionsContainer title="Steps to sync with Umami Desktop" instructions=intructions>
    <Button
      mode={#contained}
      style={StyleUtils.makeVMargin()}
      onPress={_ => navigation->Navigation.navigate("ScanDesktopSeedPhrase")}>
      {"Scan QR"->React.string}
    </Button>
  </InstructionsContainer>
}
