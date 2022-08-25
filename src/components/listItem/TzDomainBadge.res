open Paper
open ReactNative.Style
@react.component
let make = (~domain, ~style as extraStyle=style()) => {
  <CommonComponents.Badge
    style={array([StyleUtils.makeHPadding(), style(~paddingVertical=0.8->dp, ()), extraStyle])}>
    {<Text> {React.string(domain)} </Text>}
  </CommonComponents.Badge>
}
