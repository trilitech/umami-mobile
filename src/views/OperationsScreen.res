open ReactNative
open Style
open CommonComponents

type status = Done | Processing | Mempool

type diplayElement = {
  target: string,
  date: string,
  prettyAmountDisplay: string,
  hash: string,
  status: status,
}

let makePrettyDate = (date: string) =>
  date->Js.Date.fromString->Js.Date.toLocaleDateString ++
    date->Js.Date.fromString->Js.Date.toLocaleTimeString

let minConfirmations = 2

let makeDisplayElement = (op: Operation.t, myAddress: string, indexorLevel: int) => {
  let currentConfirmations = indexorLevel - op.level

  let status = if {op.blockHash->Belt.Option.isNone} {
    Mempool
  } else if currentConfirmations > 2 {
    Done
  } else {
    Processing
  }

  let date = makePrettyDate(op.timestamp)

  let printAmount = (amount: Operation.amount) =>
    switch amount {
    | Tez(amount) => {
        let amount = Token.fromRaw(amount, 6)
        `${Belt.Int.toString(amount)} tez`
      }
    | FA2({amount}) => `${Belt.Int.toString(Token.fromRaw(amount, 5))} token`
    }

  if op.destination == myAddress {
    let sign = "+"

    {
      target: op.src->TezHelpers.formatTz1,
      date: date,
      hash: op.hash,
      prettyAmountDisplay: sign ++ printAmount(op.amount),
      status: status,
    }->Some
  } else if op.src == myAddress {
    let sign = "-"

    {
      target: op.destination->TezHelpers.formatTz1,
      date: date,
      hash: op.hash,
      prettyAmountDisplay: sign ++ printAmount(op.amount),
      status: status,
    }->Some
  } else {
    None
  }
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

module TransactionItem = {
  open Paper
  @react.component
  let make = (~transaction) => {
    open Colors.Light

    let statusIcon = switch transaction.status {
    | Done => "check"
    | Mempool => "timer-sand-empty"
    | Processing => "timer-sand"
    }

    let isCredit = transaction.prettyAmountDisplay |> Js.Re.test_(%re("/^\+/i"))
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
        <Caption> {transaction.target->React.string} </Caption>
        <Caption> {transaction.date->React.string} </Caption>
      </ReactNative.View>}
      right={<Wrapper>
        <Caption style={style(~color=isCredit ? positive : negative, ())}>
          {transaction.prettyAmountDisplay->React.string}
        </Caption>
        <Paper.IconButton
        // onPress={_ =>
          icon={Paper.Icon.name(statusIcon)} size={15}
        />
        <Paper.IconButton
          onPress={_ =>
            ReactNative.Linking.openURL("https://ithacanet.tzkt.io/" ++ transaction.hash)->ignore}
          icon={Paper.Icon.name("open-in-new")}
          size={15}
        />
      </Wrapper>}
    />
  }
}
module HistoryDisplay = {
  @react.component
  let make = (~tz1, ~operations: array<Operation.t>, ~indexerLastBlock: int) => {
    let els =
      operations
      ->Belt.Array.map(el => makeDisplayElement(el, tz1, indexerLastBlock))
      ->Helpers.filterNone

    <Container>
      <ScrollView>
        {els
        // ->Belt.Array.mapWithIndex((i, t) => <ListItem key={makeKey(t, i)} title=t.destination />)
        ->Belt.Array.mapWithIndex((i, t) =>
          <TransactionItem key={t.hash ++ t.date ++ Js.Int.toString(i)} transaction=t />
        )
        ->React.array}
      </ScrollView>
    </Container>
  }
}

@react.component
let make = (~route as _, ~navigation as _) => {
  let operations = useCurrentAccountOperations()
  let (indexerLastBlock, setIndexerLastBlock) = React.useState(_ => None)

  React.useEffect1(() => {
    MezosAPI.getIndexerLastBlock()
    ->Promise.thenResolve(lastBlock => {
      setIndexerLastBlock(_ => Some(lastBlock))
    })
    ->ignore
    None
  }, [operations])
  let account = Store.useActiveAccount()

  switch (account, indexerLastBlock) {
  | (Some(account), Some(indexerLastBlock)) =>
    <HistoryDisplay tz1=account.tz1 operations indexerLastBlock />
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
