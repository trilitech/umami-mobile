open Paper
open Store
open CommonComponents
open ReactNative.Style
open Belt
open SendTypes

let standardInputHeight = 54.

module SenderDisplay = {
  @react.component
  let make = (~account, ~onPress=_ => (), ~disabled) => {
    <>
      <Caption> {React.string("Sending account")} </Caption>
      <AccountListItem
        showBorder=true account onPress={_ => onPress()} right={<ChevronRight />} disabled
      />
    </>
  }
}

module Sender = {
  @react.component
  let make = (~onPress=() => (), ~disabled) => {
    useWithAccount(account => <SenderDisplay account disabled onPress />)
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
      <UI.Input
        testID="nft-editions"
        style={style(~flex=1., ())}
        label="Editions"
        placeholder="Enter editions"
        value=prettyAmount
      />
      <Wrapper style={array([StyleUtils.makeLeftMargin(), StyleUtils.makeTopMargin(~size=2, ())])}>
        <NicerIconBtn iconName="minus" onPress={_ => prettyAmount->update(a => a - 1, onChange)} />
        <NicerIconBtn iconName="plus" onPress={_ => prettyAmount->update(a => a + 1, onChange)} />
      </Wrapper>
    </Wrapper>
  }
}
module NFTInput = {
  @react.component
  let make = (~imageUrl, ~name, ~editions=?) => {
    let source = ReactNative.Image.uriSource(~uri=imageUrl, ())

    {
      <ReactNative.View>
        <Caption> {"NFT"->React.string} </Caption>
        <CustomListItem
          showBorder=true
          height=standardInputHeight
          left={<FastImage
            source resizeMode=#contain style={style(~height=40.->dp, ~width=40.->dp, ())}
          />}
          center={<Text> {React.string(name)} </Text>}
          right={editions->Helpers.reactFold(editions =>
            <Paper.Chip mode=#outlined> {React.string("Editions: " ++ editions)} </Paper.Chip>
          )}
        />
      </ReactNative.View>
    }
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

    <ReactNative.View
    // style={array([StyleUtils.makeLeftMargin(), StyleUtils.makeTopMargin()])}
      testID="currency-picker">
      <CustomListItem
        showBorder=true
        height=standardInputHeight // same height at RN Paper input outlined
        center={<Picker
          icon={_ => <ChevronDown />}
          items
          value={getLabel(value)}
          onChange={symbol => symbol->symbolToCurrencyData(tokens)->Option.map(onChange)->ignore}
        />}
      />
    </ReactNative.View>
  }
}

let parsePrettyAmountStr = amount => {
  let re = %re("/^\d+(\.|\,)?\d*$/")
  let representsPositiveFloat = s => re->Js.Re.test_(s)

  if representsPositiveFloat(amount) {
    (amount |> Js.String.replace(",", "."))->Float.fromString
  } else {
    None
  }
}

module MultiCurrencyInput = {
  @react.component
  let make = (~amount, ~onChangeAmount, ~currency, ~onChangeSymbol) => {
    <Wrapper alignItems=#flexStart>
      <UI.Input
        placeholder="Enter amount"
        keyboardType="decimal-pad"
        value=amount
        style={style(~flex=1., ())}
        onChangeText={t => {
          if t == "" {
            onChangeAmount("")
          } else if parsePrettyAmountStr(t)->Option.isSome {
            onChangeAmount(t)
          }
        }}
        label="Amount"
      />
      {<ReactNative.View style={StyleUtils.makeLeftMargin()}>
        <Caption> {"Currency"->React.string} </Caption>
        <CurrencyPicker value=currency onChange=onChangeSymbol />
      </ReactNative.View>}
    </Wrapper>
  }
}

let recipientLabel = <Caption> {React.string("Recipient")} </Caption>
module RecipientDisplayOnly = {
  @react.component
  let make = (~tz1, ~onPressDelete=() => (), ~disabled=false) => {
    let getContactOrAccount = Alias.useGetContactOrAccount()
    let deleteIcon = <CrossRight onPress={_ => onPressDelete()} />

    let el = switch getContactOrAccount(tz1) {
    | (Some(contact), None) =>
      <ContactListItem showBorder=true disabled contact onPress={_ => ()} right={deleteIcon} />
    | (Some(_), Some(account))
    | (None, Some(account)) =>
      <AccountListItem showBorder=true disabled account onPress={_ => ()} right={deleteIcon} />
    | (None, None) =>
      <CustomListItem
        showBorder=true
        disabled
        onPress={_ => ()}
        // center={disabled
        //   ? <Paper.Text> {tz1->TezHelpers.formatTz1->React.string} </Paper.Text>
        //   : <AliasDisplayer.Tz1WithAdd tz1 />}
        center={<Tz1WithAdd tz1 />}
        right={deleteIcon}
      />
    }
    el
  }
}

module Recipient = {
  @react.component
  let make = (~recipient: option<Pkh.t>, ~onPressDelete, ~onPressSelectRecipient) => {
    let style = useCustomBorder()
    <>
      {recipientLabel}
      {switch recipient {
      | None =>
        <CustomListItem
          style
          height=standardInputHeight
          onPress={_ => onPressSelectRecipient()}
          center={<Text> {"Select from address book..."->React.string} </Text>}
          right={<ChevronRight />}
        />

      | Some(tz1) => <RecipientDisplayOnly tz1 onPressDelete />
      }}
    </>
  }
}
