open ReactNative.Style
@react.component
let make = (~onPress) => {
  <Paper.FAB
    style={style(~alignSelf=#center, ~marginVertical=20.->dp, ())}
    icon={Paper.Icon.name("plus")}
    onPress={_ => {
      onPress()
    }}
  />
}
