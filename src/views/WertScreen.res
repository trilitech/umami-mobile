open StyleUtils
open ReactNative.Style
@react.component
let make = (~route as _, ~navigation as _) => {
  let dangerColor = ThemeProvider.useErrorColor()
  let goBack = NavUtils.useGoBack()

  open Paper

  Store.useWithAccount(account => {
    <Container>
      <Title> {`Purchase tez for ${account.name}`->React.string} </Title>
      <Title> {`Address: ${TezHelpers.formatTz1(account.tz1)}`->React.string} </Title>
      <Title style={style(~color=dangerColor, ())}>
        {"In order to purchase tez, you will be redirected to wert, which is an external service to Umami."->React.string}
      </Title>
      <Button style={makeVMargin()} mode=#contained> {"confirm"->React.string} </Button>
      <Button onPress={_ => goBack()} color=dangerColor style={makeVMargin()} mode=#contained>
        {"cancel"->React.string}
      </Button>
    </Container>
  })
}
