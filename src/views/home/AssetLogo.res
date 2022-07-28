open CommonComponents
let tezLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tezos.png"),
)

let getLogo = isToken =>
  isToken
    ? <Icon size=40 name="stop-circle-outline" />
    : <SquareImage size=40. source={tezLogoImagePath} />
