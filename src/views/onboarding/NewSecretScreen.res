let instructions = "Please record the following 24 words in sequence in order to restore it in the future. Ensure to back it up, keeping it securely offline."

let generateMnemonic = cb =>
  RandomBytes.randomBytes(32, (_, bytes) => {
    bytes->Bip39.entropyToMnemonic->cb
  })->ignore

@react.component
let make = (~navigation, ~route as _) => {
  let (mnemonic, setMnemonic) = DangerousMnemonicHooks.useMnemonic()
  React.useEffect1(() => {
    generateMnemonic(m => setMnemonic(_ => m->Js.String2.split(" ")))
    None
  }, [])

  <InstructionsContainer step="Step 1 of 4" title="Record your recovery phrase" instructions>
    <Mnemonic mnemonic />
    <ContinueBtn
      onPress={_ => navigation->NavStacks.OffBoard.Navigation.navigate("RecordRecoveryPhrase")}
      text="Ok, I've recorded it"
    />
  </InstructionsContainer>
}
