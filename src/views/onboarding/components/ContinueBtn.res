open Paper
open ReactNative.Style
@react.component
let make = (~onPress, ~text, ~color=?, ~disabled=?) => {
  <Button ?color ?disabled style={style(~marginTop=10.->dp, ())} onPress mode=#contained>
    {React.string(text)}
  </Button>
}
