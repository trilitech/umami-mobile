open StyleUtils
@react.component
let make = (~route as _, ~navigation as _) => {
  let dangerColor = ThemeProvider.useErrorColor()
  let goBack = NavUtils.useGoBack()

  open Paper
  <Container>
    <Headline> {"Purchase tez for"->React.string} </Headline>
    <Title>
      {"In order to purchase tez, you will be redirected to wert, which is an external service to Umami."->React.string}
    </Title>
    <Button style={makeVMargin()} mode=#contained> {"confirm"->React.string} </Button>
    <Button onPress={_ => goBack()} color=dangerColor style={makeVMargin()} mode=#contained>
      {"cancel"->React.string}
    </Button>
  </Container>
}
