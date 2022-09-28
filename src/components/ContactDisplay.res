open CommonComponents
open ReactNative.Style

module Tz1Badge = {
  @react.component
  let make = (~tz1) => {
    let color = UmamiThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.disabled

    let formatted = tz1->Pkh.toPretty
    let copy = ClipboardCopy.useCopy()
    <Wrapper
      style={style(~backgroundColor=color, ~borderRadius=4., ~paddingHorizontal=10.->dp, ())}>
      <Paper.TouchableRipple onPress={_ => copy(tz1->Pkh.toString)}>
        <Paper.Caption testID="tez-display"> {React.string(formatted)} </Paper.Caption>
      </Paper.TouchableRipple>
    </Wrapper>
  }
}

module Tz1Display = {
  open Paper
  @react.component
  let make = (~tz1: Pkh.t) => {
    let getDomain = Store.useGetTezosDomain()
    let domain = getDomain(tz1->Pkh.toString)
    <Wrapper alignItems=#center>
      {domain->Helpers.reactFold(domain =>
        <Title style={StyleUtils.makeRightMargin()}> {domain->React.string} </Title>
      )}
      <Tz1Badge tz1 />
    </Wrapper>
  }
}
@react.component
let make = (~name, ~tz1) => {
  <ReactNative.View>
    <Paper.Headline style={StyleUtils.makeBottomMargin()}> {React.string(name)} </Paper.Headline>
    <Tz1Display tz1 />
  </ReactNative.View>
}
