open ReactNative.Style
@react.component
let make = () =>
  <Paper.Title
    style={array([
      StyleUtils.makeLeftMargin(~size=2, ()),
      style(~fontFamily="Montserrat-Bold", ()),
    ])}>
    {React.string("umami")}
  </Paper.Title>
