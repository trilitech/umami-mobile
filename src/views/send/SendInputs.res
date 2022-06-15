open Paper
open Store
open CommonComponents
open ReactNative.Style

module Sender = {
  @react.component
  let make = (~onPress, ~disabled) => {
    useWithAccount(account => <>
      <Caption> {React.string("sender")} </Caption> <AccountListItem account onPress disabled />
    </>)
  }
}

module TezInput = {
  @react.component
  let make = (~value, ~onChangeText, ~style) => {
    <TextInput keyboardType="number-pad" value onChangeText style label="amount" mode=#flat />
  }
}

module NFTInput = {
  @react.component
  let make = (~imageUrl, ~name) => {
    <CustomListItem
      left={<Image
        url=imageUrl resizeMode=#contain style={style(~height=40.->dp, ~width=40.->dp, ())}
      />}
      center={<Text> {React.string(name)} </Text>}
    />
  }
}

let _getCurrencies = (tokens: array<Token.t>) => {
  open Belt.Array
  tokens
  ->reduce([], (acc, curr) => {
    switch curr {
    | FA1(_) => concat(acc, ["FA1.2"])
    | FA2(_, m) => concat(acc, [m.symbol])
    | _ => acc
    }
  })
  ->concat(["tez"])
}
module CurrencyPicker = {
  @react.component
  let make = (~value, ~onChange) => {
    let tokens = Store.useTokens()

    let items =
      tokens->_getCurrencies->Belt.Array.map(currency => {"label": currency, "value": currency})

    <StyledPicker items value onChange />
  }
}

module MultiCurrencyInput = {
  @react.component
  let make = (~amount, ~onChangeAmount, ~symbol, ~onChangeSymbol) => {
    <Wrapper>
      <TextInput
        style={style(~flex=1., ())}
        keyboardType="number-pad"
        value={amount->Belt.Int.toString}
        onChangeText={t => {
          Belt.Int.fromString(t)->Belt.Option.map(v => onChangeAmount(v))->ignore
        }}
        label="amount"
        mode=#flat
      />
      <CurrencyPicker value=symbol onChange=onChangeSymbol />
    </Wrapper>
  }
}
