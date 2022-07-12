open StyleUtils
@react.component
let make = (~route as _, ~navigation as _) => {
  let dangerColor = ThemeProvider.useErrorColor()

  open Paper
  <Container>
    <Headline> {"Buy tez for"->React.string} </Headline>
    <Title>
      {"In order to purchase tez, you will be redirected to wert, which is an external service to Umami."->React.string}
    </Title>
    <Button style={makeVMargin()} mode=#contained> {"confirm"->React.string} </Button>
    <Button color=dangerColor style={makeVMargin()} mode=#contained>
      {"cancel"->React.string}
    </Button>
  </Container>
}
