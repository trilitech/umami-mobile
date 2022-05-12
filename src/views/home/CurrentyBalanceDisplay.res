open CommonComponents
open ReactNative.Style

let tezLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tezos.png"),
)

@react.component
let make = (~balance) => {
  let balance = balance->Belt.Option.mapWithDefault("", TezHelpers.formatBalance)
  <CustomListItem
    height=60.
    left={<CustomImage size=40. source=tezLogoImagePath />}
    center={<Paper.Title style={style()}> {React.string(balance)} </Paper.Title>}
    right={<Icon name="chevron-right" size=40 />}
  />
}
