open ReBeacon
open Paper

let matchSingleTransaction = operations =>
  if operations->Belt.Array.length > 1 {
    #batch
  } else if operations == [] {
    #empty
  } else {
    #single(operations[0])
  }

module SingleOpDisplay = {
  @react.component
  let make = (
    ~transaction: ReBeacon.Message.Request.PartialOperation.transaction,
    ~goBack,
    ~onAccept,
    ~loading,
    ~sender: Account.t,
    ~fee: int,
  ) => {
    open SendTypes
    open Asset
    transaction.amount
    ->Belt.Int.fromString
    ->Helpers.reactFold(amount => <>
      <Recap.TransactionAmounts
        fee
        sender
        trans={{
          recipient: transaction.destination->Pkh.unsafeBuild->Some,
          prettyAmount: Tez(amount)->toPrettyAmount->Belt.Float.toString,
          assetType: CurrencyAsset(CurrencyTez),
        }}
      />
      <PasswordConfirm.Plain loading onSubmit={onAccept} />
      <Button style={StyleUtils.makeVMargin()} onPress={_ => goBack()} mode=#outlined>
        {"Decline"->React.string}
      </Button>
    </>)
  }
}

let unsafeToInt: string => int = %raw("str => Number(str)")

let formatBeaconTezAmount = (a: string) =>
  Tez(unsafeToInt(a))->Asset.toPrettyAmount->Js.Float.toString

let simulateBeaconTrans = (
  t: ReBeacon.Message.Request.PartialOperation.transaction,
  sender: Account.t,
  isTestNet,
) =>
  TaquitoUtils.estimateSendTez(
    ~amount=t.amount->formatBeaconTezAmount,
    ~recipient=t.destination->Pkh.unsafeBuild,
    ~isTestNet,
    ~senderTz1=sender.tz1,
    ~senderPk=sender.pk,
  )

let executeBeaconTrans = (
  password,
  t: ReBeacon.Message.Request.PartialOperation.transaction,
  requestId,
  isTestNet,
  sender: Account.t,
  respond,
) => {
  TaquitoUtils.sendTez(
    ~password,
    ~amount=t.amount->formatBeaconTezAmount,
    ~recipient=t.destination,
    ~isTestNet,
    ~sk=sender.sk,
  )->Promise.then(r => {
    let response: Message.ResponseInput.operationResponse = {
      type_: #operation_response,
      transactionHash: r.hash,
      id: requestId,
    }

    respond(#OperationResponse(response))
  })
}

module SingleOp = {
  @react.component
  let make = (
    ~transaction: ReBeacon.Message.Request.PartialOperation.transaction,
    ~goBack,
    ~sender: Account.t,
    ~requestId: string,
    ~respond,
    ~isTestNet,
  ) => {
    let notify = SnackBar.useNotification()
    let (loading, setLoading) = React.useState(_ => false)
    let (estimationRes, setFee) = React.useState(_ => None)

    React.useEffect4(() => {
      simulateBeaconTrans(transaction, sender, isTestNet)
      ->Promise.thenResolve(fee => setFee(_ => Some(fee->Ok)))
      ->Promise.catch(exn => {
        setFee(_ => exn->Helpers.getMessage->Error->Some)
        Promise.resolve()
      })
      ->ignore
      None
    }, (setFee, transaction, isTestNet, sender))

    let handleAccept = (password, t, isTestNet, sender: Account.t, requestId) => {
      setLoading(_ => true)
      executeBeaconTrans(password, t, requestId, isTestNet, (sender: Account.t), respond)
      ->Promise.thenResolve(() => {
        setLoading(_ => false)
        notify("Tez sent!")
        goBack()
      })
      ->Promise.catch(exn => {
        setLoading(_ => false)
        notify("Failed to send. " ++ exn->Helpers.getMessage)
        Promise.resolve()
      })
    }

    estimationRes->Helpers.reactFold(result => {
      switch result {
      | Ok(fee) =>
        <SingleOpDisplay
          fee=fee.suggestedFeeMutez
          transaction
          onAccept={p => handleAccept(p, transaction, isTestNet, sender, requestId)->ignore}
          loading
          goBack
          sender
        />

      | Error(msg) => <>
          <BeaconErrorMsg message={msg} />
          <Button style={StyleUtils.makeVMargin()} onPress={_ => goBack()} mode=#outlined>
            {"Decline"->React.string}
          </Button>
        </>
      }
    })
  }
}

module Display = {
  @react.component
  let make = (~request: Message.Request.operationRequest, ~goBack, ~sender, ~respond) => {
    // TODO improve this flag
    let _isTestNet = request.network.type_ != "mainnet"
    let el = switch matchSingleTransaction(request.operationDetails) {
    | #single(op) =>
      switch Message.Request.PartialOperation.classify(op) {
      | Transfer(t) =>
        <SingleOp isTestNet=true sender transaction=t goBack requestId=request.id respond />
      | _ => <BeaconErrorMsg message="Unsupported operation" />
      }
    | #empty => <BeaconErrorMsg message="No transactions found in request" />
    | #batch => <BeaconErrorMsg message="Batch transactions are not supported" />
    }
    <> {el} </>
  }
}
@react.component
let make = (~request: Message.Request.operationRequest, ~goBack, ~respond, ~sender: Account.t) => {
  let {appMetadata} = request
  <Container>
    <MetadataDisplay.Header title="Operation request" appMetadata network=request.network.type_ />
    <Display sender request goBack respond />
  </Container>
}
