open ReactNative
open Style
open CommonComponents

type status = Done | Processing | Mempool

type displayAmount = Currency(string) | NFT(string, string)
type diplayElement = {
  target: string,
  date: string,
  prettyAmountDisplay: displayAmount,
  hash: string,
  status: status,
}

let makePrettyDate = (date: string) =>
  date->Js.Date.fromString->Js.Date.toLocaleDateString ++
  " " ++
  date->Js.Date.fromString->Js.Date.toLocaleTimeString

let minConfirmations = 2

let getStatus = (op: Operation.t, indexorLevel) => {
  let currentConfirmations = indexorLevel - op.level
  if {op.blockHash->Belt.Option.isNone} {
    Mempool
  } else if currentConfirmations > 2 {
    Done
  } else {
    Processing
  }
}

type tokenName = CurrencyName(string) | NFTname(string, string)

let getTokenByAddressAndId = (tokens: array<Token.t>, address, tokenId) => {
  tokens->Belt.Array.getBy(t =>
    switch (t, tokenId) {
    | (FA2(b, _), Some(tokenId))
    | (NFT(b, _), Some(tokenId)) =>
      b.contract == address && b.tokenId == tokenId
    // If we match an FA1 token, we must have provided no tokenId
    | (FA1(b), None) => b.contract == address
    | _ => false
    }
  )
}

let getName = (a: Operation.amount, tokens: array<Token.t>) => {
  open Belt
  switch a {
  | Tez(_) => CurrencyName("tez")
  | Contract(data) =>
    tokens
    ->getTokenByAddressAndId(data.contract, data.tokenId)
    ->Option.map(t =>
      switch t {
      | FA2(_, m) => CurrencyName(m.symbol)
      | NFT(_, m) => NFTname(m.symbol, m.thumbnailUri)
      | FA1(_) => CurrencyName("KLD")
      }
    )
    ->Option.getWithDefault(CurrencyName("Token"))
  }
}

let operationAmountToAsset = (amount: Operation.amount, tokens: array<Token.t>) => {
  open Asset
  switch amount {
  | Tez(amount) => Tez(amount)->Some
  | Contract(data) =>
    tokens
    ->getTokenByAddressAndId(data.contract, data.tokenId)
    ->Belt.Option.map(t => {
      switch t {
      | FA2(d, m) => FA2({...d, balance: data.amount}, m)
      | NFT(d, m) => NFT({...d, balance: data.amount}, m)
      | FA1(d) => FA1({...d, balance: data.amount})
      }->Token
    })
  }
}

let getAdjustedAmount = (amount: Operation.amount, tokens: array<Token.t>) =>
  operationAmountToAsset(amount, tokens)->Belt.Option.map(Asset.toPretty)

let makeDisplayElement = (
  op: Operation.t,
  myAddress: string,
  indexorLevel: int,
  tokens: array<Token.t>,
) => {
  let status = getStatus(op, indexorLevel)
  let date = makePrettyDate(op.timestamp)
  let adjustedAmount =
    getAdjustedAmount(op.amount, tokens)->Belt.Option.map(a => Js.Float.toString(a))

  let symbol = switch getName(op.amount, tokens) {
  | NFTname(n, _) => n
  | CurrencyName(n) => n
  }

  adjustedAmount->Belt.Option.flatMap(adjustedAmount =>
    if op.destination == myAddress {
      let sign = "+"

      {
        target: op.src,
        date: date,
        hash: op.hash,
        prettyAmountDisplay: Currency(sign ++ adjustedAmount ++ " " ++ symbol),
        status: status,
      }->Some
    } else if op.src == myAddress {
      let sign = "-"

      {
        target: op.destination,
        date: date,
        hash: op.hash,
        prettyAmountDisplay: Currency(sign ++ adjustedAmount ++ " " ++ symbol),
        status: status,
      }->Some
    } else {
      None
    }
  )
}

let useCurrentAccountOperations = () => {
  let account = Store.useActiveAccount()

  switch account {
  | Some(account) => account.transactions
  | None => []
  }
}

let makeKey = (t: Operation.t, i) => {
  t.destination ++ t.timestamp ++ t.src ++ i->Belt.Int.toString
}

let matchAmount = (a: displayAmount) => {
  switch a {
  | NFT(a, _) => a
  | Currency(a) => a
  }
}
let isCredit = (a: displayAmount) => matchAmount(a) |> Js.Re.test_(%re("/^\+/i"))

let useLinkToTzkt = () => {
  let isTestNet = Store.useIsTestNet()
  let host = isTestNet ? "ithacanet" : "mainnet"
  hash => ReactNative.Linking.openURL(`https://${host}.tzkt.io/${hash}`)->ignore
}

module Target = {
  open Paper
  @react.component
  let make = (~tz1) => {
    let getAlias = AliasDisplayer.useAliasDisplay(
      ~textRender=tz1 => <Caption> {React.string(tz1)} </Caption>,
      ~addUserIconSize=20,
      (),
    )
    getAlias(tz1)
  }
}
module TransactionItem = {
  open Paper
  @react.component
  let make = (~transaction) => {
    open Colors.Light

    let goToTzktTransaction = useLinkToTzkt()

    let statusIcon = switch transaction.status {
    | Done => "check"
    | Mempool => "timer-sand-empty"
    | Processing => "timer-sand"
    }

    let isCredit = isCredit(transaction.prettyAmountDisplay)
    let arrowIcon = isCredit
      ? <Paper.Avatar.Icon
          style={style(~backgroundColor=positive, ())}
          size={24}
          icon={Paper.Icon.name("arrow-bottom-left-thin")}
        />
      : <Paper.Avatar.Icon
          style={style(~backgroundColor=negative, ())}
          size={24}
          icon={Paper.Icon.name("arrow-top-right-thin")}
        />

    <CustomListItem
      left={arrowIcon}
      center={<ReactNative.View>
        <Target tz1={transaction.target} /> <Caption> {transaction.date->React.string} </Caption>
      </ReactNative.View>}
      right={<Wrapper>
        <Caption style={style(~color=isCredit ? positive : negative, ())}>
          {matchAmount(transaction.prettyAmountDisplay)->React.string}
        </Caption>
        <Paper.IconButton icon={Paper.Icon.name(statusIcon)} size={15} />
        <Paper.IconButton
          onPress={_ => goToTzktTransaction(transaction.hash)}
          icon={Paper.Icon.name("open-in-new")}
          size={15}
        />
      </Wrapper>}
    />
  }
}

let makePrettyOperations = (~myTz1, ~operations, ~tokens, ~indexerLastBlock) => {
  operations
  ->Belt.Array.map(el => makeDisplayElement(el, myTz1, indexerLastBlock, tokens))
  ->Helpers.filterNone
}
module HistoryDisplay = {
  @react.component
  let make = (~tz1, ~operations: array<Operation.t>, ~indexerLastBlock: int, ~tokens) => {
    let operationEls =
      operations
      ->Belt.Array.map(el => makeDisplayElement(el, tz1, indexerLastBlock, tokens))
      ->Helpers.filterNone
      ->Belt.Array.mapWithIndex((i, t) =>
        <TransactionItem key={t.hash ++ t.date ++ Js.Int.toString(i)} transaction=t />
      )

    <Container>
      <ScrollView>
        {if operationEls == [] {
          <DefaultView title="No Operations yet" subTitle="Your operations will appear here..." />
        } else {
          operationEls->React.array
        }}
      </ScrollView>
    </Container>
  }
}

@react.component
let make = (~route as _, ~navigation as _) => {
  let operations = useCurrentAccountOperations()
  let tokens = Store.useTokens()
  let notify = SnackBar.useNotification()
  let (indexerLastBlock, setIndexerLastBlock) = React.useState(_ => None)
  let isTestNet = Store.useIsTestNet()

  React.useEffect1(() => {
    MezosAPI.getIndexerLastBlock(~isTestNet)
    ->Promise.thenResolve(lastBlock => setIndexerLastBlock(_ => Some(lastBlock)))
    ->Promise.catch(err => {
      notify("Failed fetchting index last block. Reaston: " ++ Helpers.getMessage(err))
      Promise.reject(err)
    })
    ->ignore
    None
  }, [operations])

  let account = Store.useActiveAccount()

  switch (account, indexerLastBlock) {
  | (Some(account), Some(indexerLastBlock)) =>
    <HistoryDisplay tz1=account.tz1 operations indexerLastBlock tokens />
  | _ => React.null
  }
}

// UMAMI DESKTOP SNIPET
// let status = (operation: Operation.t, currentLevel, config: ConfigContext.env) => {
//   let (txt, colorStyle) =
//     switch (operation.status) {
//     | Mempool => (I18n.state_mempool, Some(`negative))
//     | Chain =>
//       let minConfirmations = config.confirmations;
//       let currentConfirmations = currentLevel - operation.level;
//       currentConfirmations > minConfirmations
//         ? (I18n.state_confirmed, None)
//         : (
//           I18n.state_levels(currentConfirmations, minConfirmations),
//           Some(`negative),
//         );
//     };

//   <Typography.Body1 ?colorStyle> txt->React.string </Typography.Body1>;
// };
