let instructions = "Please record the following 24 words in sequence in order to restore it in the future. Ensure to back it up, keeping it securely offline."

let generateMnemonic = cb =>
  RandomBytes.randomBytes(32, (_, bytes) => {
    bytes->Bip39.entropyToMnemonic->cb
  })->ignore

open CommonComponents
module Word = {
  open ReactNative
  open Style
  @react.component
  let make = (~text, ~label) => {
    open Paper.ThemeProvider
    let theme = useTheme()
    let borderColor = theme->Theme.colors->Theme.Colors.disabled
    <Wrapper
      style={array([
        unsafeStyle({"width": "48%"}),
        style(
          ~padding=6.->dp,
          ~marginTop=6.->dp,
          ~textAlign=#center,
          ~borderRadius=4.,
          ~borderWidth=2.,
          ~borderColor,
          ~borderStyle=#dashed, //not working
          (),
        ),
      ])}>
      <Paper.Text style={style(~textAlign=#right, ~width=20.->dp, ~marginRight=10.->dp, ())}>
        {React.string(label)}
      </Paper.Text>
      <Paper.Text> {React.string(text)} </Paper.Text>
    </Wrapper>
  }
}

module Mnemonic = {
  open ReactNative
  @react.component
  let make = (~mnemonic) => {
    <View
      style={ReactNative.Style.style(
        ~display=#flex,
        ~flexWrap=#wrap,
        ~flexDirection=#row,
        ~justifyContent=#spaceBetween,
        (),
      )}>
      {mnemonic
      ->Belt.Array.mapWithIndex((i, word) => {
        let labledWord = Belt.Int.toString(i + 1) ++ " " ++ word
        <Word key={labledWord} label={Belt.Int.toString(i + 1)} text={word} />
      })
      ->React.array}
    </View>
  }
}

@react.component
let make = (~navigation, ~route as _) => {
  let (mnemonic, setMnemonic) = DangerousMnemonicHooks.useSuperDangerousMnemonic()
  React.useEffect1(() => {
    generateMnemonic(m => setMnemonic(_ => m->Js.String2.split(" ")))
    None
  }, [])

  <>
    <OnboardingIntructions step="Step 1 of 4" title="Record your recovery phrase" instructions />
    <Container>
      <Mnemonic mnemonic />
      <ContinueBtn
        onPress={_ => navigation->NavStacks.OffBoard.Navigation.navigate("RecordRecoveryPhrase")}
        text="Ok, I've recorded it"
      />
    </Container>
  </>
}
