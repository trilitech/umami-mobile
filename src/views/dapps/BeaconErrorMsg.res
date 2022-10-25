open Paper
open CommonComponents
@react.component
let make = (~message) => {
  <Wrapper flexDirection=#column alignItems=#center>
    <CommonComponents.Icon
      style={StyleUtils.makeVMargin(~size=2, ())}
      name="alert-circle"
      color=Colors.Light.error
      size=60
    />
    <Title> {message->React.string} </Title>
  </Wrapper>
}
