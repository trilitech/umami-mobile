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
    | FA1({contract, tokenId}) =>
      concat(
        acc,
        [({symbol: fa1Symbol, contract: contract, tokenId: tokenId}, Constants.fa1CurrencyDecimal)],
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

let tokensToSelectItems = tokens =>
  tokens
  ->_getCurrencies
  ->Array.map(((data, _)) => makeSelectItem(data.symbol))
  ->Array.concat([
    {
      makeSelectItem(tezSymbol)
    },
  ])

let symbolToCurrencyData = (symbol: string, tokens) => {
  if symbol == tezSymbol {
    Some(CurrencyTez)
  } else {
    tokens
    ->_getCurrencies
    ->Array.getBy(((i, _)) => i.symbol == symbol)
    ->Option.map(((data, decimals)) => CurrencyToken(data, decimals))
  }
}

module CurrencyPicker = {
  @react.component
  let make = (~value: currency, ~onChange: currency => unit) => {
    let tokens = Store.useTokens()

    let items = tokensToSelectItems(tokens)

    <StyledPicker
      items
      value={getLabel(value)}
      onChange={symbol => symbol->symbolToCurrencyData(tokens)->Option.map(onChange)->ignore}
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