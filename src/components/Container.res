open ReactNative
open ReactNative.Style

@react.component
let make = (~children) => {
  // flex=1 for full height
  <View style={style(~flex=1., ~padding=10.->dp, ())}> {children} </View>
}
