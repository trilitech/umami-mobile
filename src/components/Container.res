open ReactNative
open ReactNative.Style

open StyleUtils
@react.component
let make = (~children) => {
  // flex=1 for full height
  <View style={array([style(~flex=1., ()), makePadding()])}> {children} </View>
}
