open Paper
open Store
open CommonComponents
open ReactNative.Style
open Belt
open SendTypes
module Sender = {
  @react.component
  let make = (~onPress=() => (), ~disabled) => {
    useWithAccount(account => <>
      <Caption> {React.string("sender")} </Caption>
      <AccountListItem account onPress={_ => onPress()} right={<ChevronRight />} disabled />
    </>)
  }
}

let update = (p, xf, onChange) =>
  p
  ->Int.fromString
  ->Option.map(xf)
  ->Option.flatMap(i => i > 0 ? Some(i) : None)
  ->Option.map(Int.toString)
  ->Option.map(onChange)
  ->ignore

module EditionsInput = {
  @react.component
  let make = (~prettyAmount: string, ~onChange) => {
    <Wrapper>
      <TextInput
        testID="nft-editions"
        style={style(~flex=1., ())}
        mode=#flat
        placeholder="editions"
        value=prettyAmount
      />
      <NicerIconBtn iconName="minus" onPress={_ => prettyAmount->update(a => a - 1, onChange)} />
      <NicerIconBtn iconName="plus" onPress={_ => prettyAmount->update(a => a + 1, onChange)} />
    </Wrapper>
  }
}
module NFTInput = {
  @react.component
  let make = (~imageUrl, ~name, ~editions=?) => {
    let source = ReactNative.Image.uriSource(~uri=imageUrl, ())
    <CustomListItem
      left={<FastImage
        source resizeMode=#contain style={style(~height=40.->dp, ~width=40.->dp, ())}
      />}
      center={<Text> {React.string(name)} </Text>}
      right={editions->Helpers.reactFold(editions =>
        <Paper.Chip mode=#outlined> {React.string("Editions: " ++ editions)} </Paper.Chip>
      )}
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

    <ReactNative.Text testID="currency-picker">
      <StyledPicker
        items
        value={getLabel(value)}
        onChange={symbol => symbol->symbolToCurrencyData(tokens)->Option.map(onChange)->ignore}
      />
    </ReactNative.Text>
  }
}

let re = %re("/^\d+\.?\d*$/")
let representsPositiveFloat = s => re->Js.Re.test_(s)

module MultiCurrencyInput = {
  @react.component
  let make = (~amount, ~onChangeAmount, ~currency, ~onChangeSymbol) => {
    <Wrapper>
      <TextInput
        placeholder="Enter amount"
        style={style(~flex=1., ())}
        keyboardType="decimal-pad"
        value=amount
        onChangeText={t => {
          if t == "" {
            onChangeAmount("")
          } else if representsPositiveFloat(t) {
            onChangeAmount(t)
          }
        }}
        label="amount"
        mode=#flat
      />
      <CurrencyPicker value=currency onChange=onChangeSymbol />
    </Wrapper>
  }
}

let recipientLabel = <Caption> {React.string("recipient")} </Caption>
module RecipientDisplayOnly = {
  @react.component
  let make = (~tz1, ~onPress=() => (), ~disabled=false) => {
    let getAlias = Alias.useGetAlias()

    let el = switch getAlias(tz1) {
    | Some(contact) =>
      <ContactListItem disabled contact onPress={_ => onPress()} right={<ChevronRight />} />
    | None =>
      <CustomListItem
        disabled
        onPress={_ => onPress()}
        // center={disabled
        //   ? <Paper.Text> {tz1->TezHelpers.formatTz1->React.string} </Paper.Text>
        //   : <AliasDisplayer.Tz1WithAdd tz1 />}
        center={<AliasDisplayer.Tz1WithAdd tz1 />}
        right={<ChevronRight />}
      />
    }
    <> {recipientLabel} {el} </>
  }
}

module Recipient = {
  @react.component
  let make = (~recipient: option<string>, ~onPress) => {
    switch recipient {
    | None => <>
        {recipientLabel}
        <CustomListItem
          onPress={_ => onPress()}
          center={<Text> {"Add recipient..."->React.string} </Text>}
          right={<ChevronRight />}
        />
      </>

    | Some(tz1) => <RecipientDisplayOnly tz1 onPress />
    }
  }
}
