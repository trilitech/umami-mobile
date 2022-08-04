open ReactNative
open Style

open CommonComponents
module Word = {
  @react.component
  let make = (~text, ~label) => {
    open Paper.ThemeProvider
    let theme = useTheme()
    let borderColor = theme->Theme.colors->Theme.Colors.disabled
    <Wrapper
      style={array([
        unsafeStyle({"width": "48%"}),
        style(
          ~padding=4.->dp,
          ~marginTop=4.->dp,
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
