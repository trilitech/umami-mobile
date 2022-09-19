open Paper

let trimSpacesAndLineBreaks = (s: string) => {
  s
  ->Js.String2.trim
  ->Js.String2.replaceByRe(%re("/\\n+/"), "")
  ->Js.String2.replaceByRe(%re("/\s+/g"), " ")
}

let correctAmountOfWords = s => {
  let length = s->Js.String2.splitByRe(%re("/\s+/"))->Array.length

  length === 24 || length === 21 || length === 18 || length === 15 || length === 12
}
let inputIsValid = (s: string) => s->trimSpacesAndLineBreaks->correctAmountOfWords

module Display = {
  @react.component
  let make = (~onSubmit, ~dangerousText, ~setDangerousText) => {
    <>
      <InstructionsPanel
        title="Enter your recovery phrase"
        instructions="Please fill in the recovery phrase in sequence.
Umami supports 12-, 15-, 18-, 21- and 24-word recovery phrases."
      />
      <Container>
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
    </>
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
      ~seedPhrase={trimSpacesAndLineBreaks(dangerousText)},
      ~derivationPath=DerivationPath.default,
      (),
    )
    ->Promise.catch(_ => {
      setLoading(_ => false)
      Promise.resolve()
    })
    ->ignore
  }

  let element = UsePasswordConfirm.usePasswordConfirm(
    ~hoc,
    ~onConfirm,
    ~creation=true,
    ~loading,
    (),
  )
  {element}
}
