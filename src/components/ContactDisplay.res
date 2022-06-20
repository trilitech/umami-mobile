open CommonComponents
open ReactNative.Style

module Tz1Display = {
  @react.component
  let make = (~tz1) => {
    let color = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.disabled

    let formatted = TezHelpers.formatTz1(tz1)
    let copy = ClipboardCopy.useCopy()

    <Wrapper>
      <Wrapper
        style={style(
          ~backgroundColor=color,
          ~borderRadius=4.,
          ~paddingHorizontal=10.->dp,
          ~marginTop=12.->dp,
          (),
        )}>
        <Paper.TouchableRipple onPress={_ => copy(tz1)}>
          <Paper.Caption testID="tez-display"> {React.string(formatted)} </Paper.Caption>
        </Paper.TouchableRipple>
      </Wrapper>
    </Wrapper>
  }
}
@react.component
let make = (~name, ~tz1) => {
  <ReactNative.View>
    <Paper.Headline> {React.string(name)} </Paper.Headline> <Tz1Display tz1 />
  </ReactNative.View>
}
