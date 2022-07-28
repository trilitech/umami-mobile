open ReactNative
open Style
open CommonComponents

type status = Done | Processing | Mempool

type tradeAmount = CurrencyTrade(string) | NFTTrade(string, string)

type diplayElement = {
  target: string,
  date: string,
  prettyAmountDisplay: tradeAmount,
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

let makeTradeAmount = (a: Asset.t, incoming: bool) => {
  let symbol = a->Asset.getSymbol
  let sign = incoming ? "+" : "-"
  let prettyStringWithSign = sign ++ a->Asset.getPrettyString

  switch symbol {
  | CurrencyName(_) => CurrencyTrade(prettyStringWithSign)
  | NFTname(_, url) => NFTTrade(prettyStringWithSign, url)
  }
}

let makeDisplayElement = (
  op: Operation.t,
  myAddress: string,
  indexorLevel: int,
  tokens: array<Token.t>,
) => {
  let status = getStatus(op, indexorLevel)
  let date = makePrettyDate(op.timestamp)
  let asset = operationAmountToAsset(op.amount, tokens)

  let incoming = op.destination == myAddress
  let outGoing = op.src == myAddress

  asset->Belt.Option.flatMap(asset => {
    if incoming || outGoing {
      let target = incoming ? op.src : op.destination

      {
        target: target,
        date: date,
        hash: op.hash,
        prettyAmountDisplay: makeTradeAmount(asset, incoming),
        status: status,
      }->Some
    } else {
      None
    }
  })
}

let useCurrentAccountOperations = () => {
  let account = Store.useActiveAccount()

  switch account {
  | Some(account) => account.transactions
  | None => []
  }
}

let makeKey = (t: Operation.t, i) => t.destination ++ t.timestamp ++ t.src ++ i->Belt.Int.toString

let matchAmount = (a: tradeAmount) =>
  switch a {
  | NFTTrade(a, _) => a
  | CurrencyTrade(a) => a
  }

let isCredit = (a: tradeAmount) => matchAmount(a) |> Js.Re.test_(%re("/^\+/i"))

let useLinkToTzkt = () => {
  let isTestNet = Store.useIsTestNet()
  let host = isTestNet ? Endpoints.tzkt.testNet : Endpoints.tzkt.mainNet
  hash => ReactNative.Linking.openURL(`https://${host}/${hash}`)->ignore
}

module Target = {
  open Paper
  @react.component
  let make = (~tz1) => {
    let getAlias = AliasDisplayer.useAliasDisplay(
      ~textRender=tz1 => <Caption> {React.string(tz1)} </Caption>,
      (),
    )
    getAlias(tz1)
  }
}

let makeTradeDisplay = (a: string, isCredit) => {
  open Paper
  open Colors.Light
  <Caption style={style(~color=isCredit ? positive : negative, ())}> {a->React.string} </Caption>
}

let makeTradeEl = (a: tradeAmount) => {
  let isCredit = isCredit(a)
  switch a {
  | NFTTrade(a, uri) =>
    <Wrapper>
      {makeTradeDisplay(a, isCredit)}
      <FastImage
        source={ReactNative.Image.uriSource(~uri, ())}
        resizeMode=#contain
        style={array([style(~height=20.->dp, ~width=20.->dp, ()), StyleUtils.makeLeftHMargin()])}
      />
    </Wrapper>
  | CurrencyTrade(a) => makeTradeDisplay(a, isCredit)
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

    let amountEl = makeTradeEl(transaction.prettyAmountDisplay)
    let arrowIcon =
      <Paper.Avatar.Icon
        style={style(~backgroundColor=isCredit ? positive : negative, ())}
        size={24}
        icon={Paper.Icon.name(isCredit ? "arrow-bottom-left-thin" : "arrow-top-right-thin")}
      />

    <CustomListItem
      left={arrowIcon}
      center={<ReactNative.View>
        <Target tz1={transaction.target} /> <Caption> {transaction.date->React.string} </Caption>
      </ReactNative.View>}
      right={<Wrapper>
        {amountEl}
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

module AssetBalanceDisplay = {
  open Paper
  @react.component
  let make = (~assetBalance) => {
    let prettyAmount = assetBalance->Asset.getPrettyString
    let icon = assetBalance->Asset.isToken->AssetLogo.getLogo

    <Card>
      <Wrapper
        flexDirection=#column
        justifyContent=#spaceBetween
        style={StyleUtils.makeVMargin(~size=2, ())}>
        {icon} <Title> {prettyAmount->React.string} </Title>
      </Wrapper>
    </Card>
  }
}

let filterOperations = (operations: array<Operation.t>, tokens, selectedAsset: Asset.t) => {
  operations->Belt.Array.keep(o => {
    let asset = o.amount->operationAmountToAsset(tokens)

    switch selectedAsset {
    | Tez(_) =>
      // Display Tez and NFTs if we select tez
      asset->Belt.Option.mapWithDefault(false, asset => asset->Asset.isTez || asset->Asset.isNft)
    | Token(t) =>
      switch t {
      | NFT(_) => false // NFTs displayed under tez
      | FA1(b)
      | FA2((b, _)) =>
        asset
        ->Belt.Option.flatMap(Asset.getTokenBase)
        ->Belt.Option.mapWithDefault(false, base =>
          // Keep asset in list only if it matches the identity of the selected asset
          b.contract == base.contract && b.tokenId == base.tokenId
        )
      }
    }
  })
}

@react.component
let make = (~route, ~navigation as _) => {
  let operations = useCurrentAccountOperations()
  let tokens = Store.useTokens()
  let notify = SnackBar.useNotification()
  let assetBalance = NavUtils.getAssetBalance(route)
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

  switch (account, indexerLastBlock, assetBalance) {
  | (Some(account), Some(indexerLastBlock), Some(assetBalance)) => {
      let operations = filterOperations(operations, tokens, assetBalance)
      <>
        <AssetBalanceDisplay assetBalance />
        <HistoryDisplay tz1=account.tz1 operations indexerLastBlock tokens />
      </>
    }
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
