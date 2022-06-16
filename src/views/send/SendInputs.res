open Paper
open Store
open CommonComponents
open ReactNative.Style
open Belt
open SendTypes
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

let fa1Symbol = "FA1.2"
let tezSymbol = "tez"

let _getCurrencies = (tokens: array<Token.t>): array<(currencyData, decimals)> => {
  open Belt.Array
  tokens->reduce([], (acc, curr) => {
    switch curr {
    | FA1(b) =>
      concat(
        acc,
        [
          (
            {symbol: fa1Symbol, contract: b.contract, tokenId: b.tokenId},
            Constants.fa1CurrencyDecimal,
          ),
        ],
      )
    | FA2(b, m) =>
      concat(acc, [({symbol: m.symbol, contract: b.contract, tokenId: b.tokenId}, m.decimals)])
    | _ => acc
    }
  })
}

let getLabel = c =>
  switch c {
  | CurrencyTez => tezSymbol
  | CurrencyToken(d, _) => d.symbol
  }

let makeSelectItem = (symbol: string) =>
  {
    "label": symbol,
    "value": symbol,
  }
module CurrencyPicker = {
  @react.component
  let make = (~value: currency, ~onChange: currency => unit) => {
    let tokens = Store.useTokens()

    let tokenCurrencies = tokens->_getCurrencies

    let items =
      tokenCurrencies
      ->Array.map(((data, _)) => makeSelectItem(data.symbol))
      ->Array.concat([
        {
          makeSelectItem(tezSymbol)
        },
      ])

    <StyledPicker
      items
      value={getLabel(value)}
      onChange={symbol => {
        if symbol == tezSymbol {
          onChange(CurrencyTez)
        } else {
          tokenCurrencies
          ->Array.getBy(((i, _)) => i.symbol == symbol)
          ->Option.map(((data, decimals)) => {
            onChange(CurrencyToken(data, decimals))
          })
          ->ignore
        }
      }}
    />
  }
}

module MultiCurrencyInput = {
  @react.component
  let make = (~amount, ~onChangeAmount, ~currency, ~onChangeSymbol) => {
    <Wrapper>
      <TextInput
        style={style(~flex=1., ())}
        keyboardType="number-pad"
        value={amount->Float.toString}
        onChangeText={t => {
          if t == "" {
            onChangeAmount(0.)
          } else {
            Float.fromString(t)->Option.map(v => onChangeAmount(v))->ignore
          }
        }}
        label="amount"
        mode=#flat
      />
      <CurrencyPicker value=currency onChange=onChangeSymbol />
    </Wrapper>
  }
}
