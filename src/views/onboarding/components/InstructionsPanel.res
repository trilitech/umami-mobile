open Helpers

open ReactNative.Style
@react.component
let make = (~instructions=?, ~title=?, ~step=?, ~danger=false) => {
  let dangerColor = UmamiThemeProvider.useErrorColor()
  open Paper
  let dangerStyle = style(~color=dangerColor, ())
  let disabledColor = UmamiThemeProvider.useDisabledColor()
  let textStyle = danger ? dangerStyle : style()
  <Card style={StyleUtils.makePadding()}>
    {step->reactFold(step =>
      <Caption style={array([style(~color=disabledColor, ()), textStyle])}>
        {React.string(step)}
      </Caption>
    )}
    {title->reactFold(title =>
      <Title style={array([style(~color=disabledColor, ()), textStyle])}>
        {React.string(title)}
      </Title>
    )}
    {instructions->reactFold(instructions =>
      <Paragraph style=textStyle> {React.string(instructions)} </Paragraph>
    )}
  </Card>
}
