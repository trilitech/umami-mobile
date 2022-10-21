open ReactNative
open ReactNative.Style

open StyleUtils
@react.component
let make = (~children, ~noVPadding=false, ~style as extraStyle=style()) => {
  // flex=1 for full height
  <View
    style={array([style(~flex=1., ()), noVPadding ? makeHPadding() : makePadding(), extraStyle])}>
    {children}
  </View>
}
