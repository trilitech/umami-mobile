open Paper
open ReactNative.Style
@react.component
let make = (~onPress, ~text) => {
  <Button style={style(~marginTop=10.->dp, ())} onPress mode=#contained>
    {React.string(text)}
  </Button>
}
