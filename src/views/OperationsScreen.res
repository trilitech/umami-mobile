open ReactNative
open Style
open CommonComponents

type status = Done | Processing | Mempool

type tradeAmount = CurrencyTrade(string) | NFTTrade(string, string)

type diplayElement = {
  target: Pkh.t,
  date: string,
  prettyAmountDisplay: tradeAmount,
  hash: option<string>,
  status: status,
}

let makePrettyDate = (date: string) =>
  date->Js.Date.fromString->Js.Date.toLocaleDateString ++
  " " ++
  date->Js.Date.fromString->Js.Date.toLocaleTimeString

let minConfirmations = 2

let getStatus = (op: Operation.t, indexerLevel) => {
  let currentConfirmations = indexerLevel - op.level
  if (Operation.isToken(op)) {
    if currentConfirmations > 2 {
      Done
    } else {
      Processing
    }
  } else {
    if {op.blockHash->Belt.Option.isNone} {
      Mempool
    } else if currentConfirmations > 2 {
      Done
    } else {
      Processing
    }
  }
}

let getTokenByAddressAndId = (tokens: array<Token.t>, address, tokenId) => {
  tokens->Belt.Array.getBy(t =>
    switch t {
    | FA2(b, _)
    | NFT(b, _) =>
      b.contract == address && b.tokenId == tokenId
    // If we match an FA1 token, we must have provided no tokenId
    | FA1(b) => b.contract == address
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
  myAddress: Pkh.t,
  indexerLevel: int,
  tokens: array<Token.t>,
) => {
  let status = getStatus(op, indexerLevel)
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

let useSelectedAccountOperations = () => {
  let (account, _) = Store.useSelectedAccount()
  let (operations, _) = Store.useOperations()

  account
  ->Belt.Option.flatMap(account => operations->Belt.Map.String.get(account.tz1->Pkh.toString))
  ->Belt.Option.getWithDefault([])
}

let makeKey = (t: Operation.t, i) =>
  t.destination->Pkh.toString ++ t.timestamp ++ t.src->Pkh.toString ++ i->Belt.Int.toString

let matchAmount = (a: tradeAmount) =>
  switch a {
  | NFTTrade(a, _) => a
  | CurrencyTrade(a) => a
  }

let isCredit = (a: tradeAmount) => matchAmount(a) |> Js.Re.test_(%re("/^\+/i"))

let useAliasDisplay = (
  ~textRender=text => <Text> {text->React.string} </Text>,
  ~addUserIconSize=?,
  (),
) => {
  let getContactOrAccount = Alias.useGetContactOrAccount()

  tz1 => {
    switch getContactOrAccount(tz1) {
    | (Some(contact), None) => textRender(contact.name)
    | (None, Some(account)) => textRender(account.name)
    | (Some(_), Some(account)) => textRender(account.name)
    | (None, None) => <Tz1WithAdd ?addUserIconSize tz1 textRender />
    }
  }
}
module Target = {
  open Paper
  @react.component
  let make = (~tz1: Pkh.t) => {
    let getAlias = useAliasDisplay(~textRender=tz1 => <Caption> {React.string(tz1)} </Caption>, ())
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
        style={array([style(~height=20.->dp, ~width=20.->dp, ()), StyleUtils.makeLeftMargin()])}
      />
    </Wrapper>
  | CurrencyTrade(a) => makeTradeDisplay(a, isCredit)
  }
}

let useNavToTzkt = () => {
  let (network, _) = Store.useNetwork()
  let host = Endpoints.getTzktUrl(network)

  let navigate = NavUtils.useNavigateWithParams()

  hash => {
    let url = `https://${host}/${hash}`

    navigate(
      "Browser",
      {
        tz1ForContact: None,
        derivationIndex: None,
        nft: None,
        assetBalance: None,
        tz1ForSendRecipient: None,
        injectedAdress: None,
        signedContent: None,
        beaconRequest: None,
        browserUrl: url->Some,
      },
    )
  }
}

module TransactionItem = {
  open Paper
  @react.component
  let make = (~transaction,~myAddress) => {
    open Colors.Light

    // let goToTzktTransaction = useLinkToTzkt()
    let navToTzkt = useNavToTzkt()

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
      height=#small
      left={arrowIcon}
      center={<ReactNative.View>
        <Target tz1={transaction.target} /> <Caption> {transaction.date->React.string} </Caption>
      </ReactNative.View>}
      right={<Wrapper>
        {amountEl}
        <Paper.IconButton icon={Paper.Icon.name(statusIcon)} size={15} />
        <Paper.IconButton
          onPress={_ => navToTzkt(transaction.hash->Belt.Option.getWithDefault(myAddress->Pkh.toString))}
          // goToTzktTransaction(transaction.hash)

          icon={Paper.Icon.name("open-in-new")}
          size={15}
        />
      </Wrapper>}
    />
  }
}

module HistoryDisplay = {
  @react.component
  let make = (~tz1, ~operations: array<Operation.t>, ~indexerLastBlock: int, ~tokens) => {
    let operationEls =
      operations
      ->Belt.Array.map(el => makeDisplayElement(el, tz1, indexerLastBlock, tokens))
      ->Helpers.filterNone
      ->Belt.Array.mapWithIndex((i, t) =>
        <TransactionItem key={t.hash->Belt.Option.getWithDefault("") ++ t.date ++ Js.Int.toString(i)} transaction=t myAddress=tz1 />
      )

    if operationEls == [] {
      <DefaultView title="No Operations yet" subTitle="Your operations will appear here..." />
    } else {
      <ScrollView>
        <Container noVPadding=false> {operationEls->React.array} </Container>
      </ScrollView>
    }
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
        style={array([StyleUtils.makeVMargin(~size=2, ()), StyleUtils.makeTopMargin(~size=4, ())])}>
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

module Display = {
  @react.component
  let make = (~assetBalance, ~account: Account.t) => {
    let operations = useSelectedAccountOperations()
    let tokens = Store.useTokens()
    let (network, _) = Store.useNetwork()

    let query =
      ReactQuery.queryOptions(
        ~queryFn=_ => TzktAPI.getIndexerLastBlock(~network),
        ~queryKey="lastBlock",
        ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
        ~enabled=false,
        (),
      )->ReactQuery.useQuery

    let indexerLastBlock = query.data

    React.useEffect3(() => {
      query.refetch({
        throwOnError: false,
        cancelRefetch: false,
      })->ignore

      None
    }, (operations, network, query.refetch))

    let el = switch indexerLastBlock {
    | Some(indexerLastBlock) => {
        let operations = filterOperations(operations, tokens, assetBalance)
        <>
          <AssetBalanceDisplay assetBalance />
          <HistoryDisplay tz1=account.tz1 operations indexerLastBlock tokens />
        </>
      }
    | _ => React.null
    }

    query.isLoading ? <CenteredSpinner /> : el
  }
}

@react.component
let make = (~route, ~navigation as _) => {
  let assetBalance = NavUtils.getAssetBalance(route)
  let (account, _) = Store.useSelectedAccount()

  Helpers.both(assetBalance, account)->Helpers.reactFold(((assetBalance, account)) => {
    <Display account assetBalance />
  })
}
