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
  ) => {
    open SendTypes
    open Asset
    transaction.amount
    ->Belt.Int.fromString
    ->Helpers.reactFold(amount => <>
      <Recap.TransactionAmounts
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

module Display = {
  @react.component
  let make = (
    ~request: Message.Request.operationRequest,
    ~goBack,
    ~handleAccept,
    ~loading,
    ~sender,
  ) => {
    let el = switch matchSingleTransaction(request.operationDetails) {
    | #single(op) =>
      switch Message.Request.PartialOperation.classify(op) {
      | Transfer(t) =>
        <SingleOpDisplay sender onAccept={p => handleAccept(p, t)} transaction=t goBack loading />
      | _ => <Text> {"unsupported"->React.string} </Text>
      }
    | #empty => <Text> {"empty"->React.string} </Text>
    | #batch => <Text> {"batch"->React.string} </Text>
    }
    <> {el} </>
  }
}
@react.component
let make = (~request: Message.Request.operationRequest, ~goBack, ~respond, ~sender: Account.t) => {
  let notify = SnackBar.useNotification()
  let (loading, setLoading) = React.useState(_ => false)

  let handleAccept = (password, t: ReBeacon.Message.Request.PartialOperation.transaction) => {
    setLoading(_ => true)
    TaquitoUtils.sendTez(
      ~password,
      ~amount=t.amount,
      ~recipient=t.destination,
      ~isTestNet=true,
      ~sk=sender.sk,
    )
    ->Promise.then(r => {
      notify("Tez sent!")
      let response: Message.ResponseInput.operationResponse = {
        type_: #operation_response,
        transactionHash: r.hash,
        id: request.id,
      }

      respond(#OperationResponse(response))
    })
    ->Promise.thenResolve(_ => {
      setLoading(_ => false)
      goBack()
      ()
    })
    ->Promise.catch(exn => {
      setLoading(_ => false)
      notify("Failed to send. " ++ exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore
  }

  let {appMetadata} = request
  <Container>
    <MetadataDisplay.Header title="Operation request" appMetadata network=request.network.type_ />
    <Display sender request goBack handleAccept loading />
  </Container>
}
