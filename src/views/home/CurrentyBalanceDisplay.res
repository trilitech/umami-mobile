open CommonComponents
open ReactNative.Style

let tezLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tezos.png"),
)

let tokenLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tzbtc.png"),
)

open Belt
module CurrencyIem = {
  @react.component
  let make = (~balance: int, ~symbol=?, ~onPress) => {
    let prettyCurrency = Js.Int.toString(balance) ++ " " ++ symbol->Option.getWithDefault("tez")
    <CustomListItem
      height=70.
      left={<CustomImage
        size=40. source={Option.isSome(symbol) ? tokenLogoImagePath : tezLogoImagePath}
      />}
      center={<Paper.Title style={style()}> {React.string(prettyCurrency)} </Paper.Title>}
      onPress
      right={<Icon name="chevron-right" size=40 />}
    />
  }
}

open Token
@react.component
let make = (~balance, ~onPress, ~tokens) => {
  let balance = balance->Belt.Option.mapWithDefault("", TezHelpers.formatBalance)
  let tokens = tokens->Belt.Array.map(parseToken)->Helpers.filterNone
  <>
    <CurrencyIem onPress balance={Belt.Int.fromString(balance)->Option.getWithDefault(0)} />
    {tokens
    ->Belt.Array.map(t =>
      switch t {
      | FA2((base, metadata)) =>
        <CurrencyIem
          key={metadata.symbol} onPress balance={base.balance} symbol={metadata.symbol}
        />
      | FA1(base) =>
        <CurrencyIem key={base.contract} onPress balance={base.balance} symbol={"fa1.2"} />
      | NFT(_) => React.null
      }
    )
    ->React.array}
  </>
}
