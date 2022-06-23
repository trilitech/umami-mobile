open CommonComponents
open ReactNative.Style

let tezLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tezos.png"),
)

let tokenLogoImagePath = ReactNative.Image.Source.fromRequired(
  ReactNative.Packager.require("../../assets/icon_currency_tzbtc.png"),
)

module FAStandard = {
  @react.component
  let make = (~standard) => {
    let borderColor = ThemeProvider.useDisabledColor()
    <ReactNative.View
      style={style(
        ~borderWidth=1.,
        ~borderRadius=4.,
        ~paddingHorizontal=4.->dp,
        ~marginHorizontal=8.->dp,
        ~borderColor,
        (),
      )}>
      <Paper.Caption> {React.string(standard)} </Paper.Caption>
    </ReactNative.View>
  }
}
open Belt
module CurrencyIem = {
  @react.component
  let make = (~balance: float, ~symbol=?, ~standard=?, ~onPress) => {
    let prettyCurrency = Belt.Float.toString(balance) ++ " " ++ symbol->Option.getWithDefault("tez")
    let icon = Option.isSome(symbol)
      ? <Icon size=40 name="stop-circle-outline" />
      : <CustomImage
          size=40. source={Option.isSome(symbol) ? tokenLogoImagePath : tezLogoImagePath}
        />

    <CustomListItem
      height=70.
      left={icon}
      center={<Wrapper>
        <Paper.Title style={style()}> {React.string(prettyCurrency)} </Paper.Title>
        {standard->Option.mapWithDefault(React.null, standard => <FAStandard standard />)}
        // <Paper.Chip mode=#outlined> {React.string("fa1")} </Paper.Chip>
      </Wrapper>}
      onPress
      right={<Icon name="chevron-right" size=40 />}
    />
  }
}

open Token
@react.component
let make = (~balance: option<int>, ~onPress, ~tokens) => {
  <>
    {balance->Belt.Option.mapWithDefault(React.null, balance => {
      let balance = balance->TezHelpers.formatBalance
      <CurrencyIem onPress balance={Belt.Float.fromString(balance)->Option.getWithDefault(0.)} />
    })}
    {tokens
    ->Belt.Array.map(t =>
      switch t {
      | FA2((base, metadata)) =>
        <CurrencyIem
          key={metadata.symbol}
          onPress
          balance={fromRaw(base.balance, metadata.decimals)}
          symbol={metadata.symbol}
          standard="fa2"
        />
      | FA1(base) =>
        <CurrencyIem
          key={base.contract}
          onPress
          balance={fromRaw(base.balance, Constants.fa1CurrencyDecimal)}
          symbol={"KLD"}
          standard="fa1.2"
        />
      | NFT(_) => React.null
      }
    )
    ->React.array}
  </>
}
