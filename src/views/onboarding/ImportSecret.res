open Paper

let formatForMnemonic = (s: string) => {
  s
  ->Js.String2.trim
  ->Js.String2.replaceByRe(%re("/\\n+/"), "")
  ->Js.String2.replaceByRe(%re("/\s+/g"), " ")
}

let inputIsValid = (s: string) => s->formatForMnemonic->AccountUtils.backupPhraseIsValid

module Display = {
  @react.component
  let make = (~onSubmit, ~dangerousText, ~setDangerousText) => {
    <Container>
      <InstructionsPanel
        title="Enter your recovery phrase"
        instructions="Please fill in the recovery phrase in sequence.
Umami supports 12-, 15-, 18-, 21- and 24-word recovery phrases."
      />
      <TextInput
        value=dangerousText
        style={ReactNative.Style.style(~height=130.->ReactNative.Style.dp, ())}
        multiline=true
        mode=#outlined
        onChangeText={t => setDangerousText(_ => t)}
      />
      <Button
        disabled={!inputIsValid(dangerousText)}
        onPress={_ => {
          onSubmit(dangerousText)
        }}
        style={ReactNative.Style.style(~marginVertical=10.->ReactNative.Style.dp, ())}
        mode=#contained>
        <Paper.Text> {React.string("Continue")} </Paper.Text>
      </Button>
    </Container>
  }
}

open RestoreAndSave
@react.component
let make = (~navigation as _, ~route as _) => {
  let (dangerousText, setDangerousText) = EphemeralState.useEphemeralState("")

  let (loading, setLoading) = React.useState(_ => false)

  let hoc = (~onSubmit) => <Display dangerousText setDangerousText onSubmit />

  let restoreAndSave = useRestoreAndSave()

  // default derivation path when you import via text
  let onConfirm = password => {
    setLoading(_ => true)
    restoreAndSave(
      ~password,
      ~seedPhrase={formatForMnemonic(dangerousText)},
      ~derivationPath=DerivationPath.default,
      (),
    )
    ->Promise.finally(_ => setLoading(_ => false))
    ->ignore
  }

  let element = UsePasswordConfirm.usePasswordConfirm(
    ~hoc,
    ~onConfirm,
    ~creation=true,
    ~loading,
    (),
  )
  <Container> {element} </Container>
}
