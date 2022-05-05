open Paper
@react.component
let make = (~instructions, ~title, ~step) => {
  open ReactNative.Style
  <Card style={style(~padding=10.->dp, ())}>
    <Caption> {React.string(step)} </Caption>
    <Title> {React.string(title)} </Title>
    <Paragraph> {React.string(instructions)} </Paragraph>
  </Card>
}
