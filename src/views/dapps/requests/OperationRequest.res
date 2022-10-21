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
  ) => {
    <>
      <Text> {("amount " ++ transaction.amount)->React.string} </Text>
      <Text> {("destination" ++ transaction.destination)->React.string} </Text>
      <PasswordConfirm.Plain loading onSubmit={onAccept} />
      <Button style={StyleUtils.makeVMargin()} onPress={_ => goBack()} mode=#outlined>
        {"decline"->React.string}
      </Button>
    </>
  }
}

@react.component
let make = (~request: Message.Request.operationRequest, ~sk: string, ~goBack, ~respond) => {
  let notify = SnackBar.useNotification()
  let (loading, setLoading) = React.useState(_ => false)

  let handleAccept = (password, t: ReBeacon.Message.Request.PartialOperation.transaction) => {
    setLoading(_ => true)
    TaquitoUtils.sendTez(
      ~password,
      ~amount=t.amount,
      ~recipient=t.destination,
      ~isTestNet=true,
      ~sk,
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
  let el = switch matchSingleTransaction(request.operationDetails) {
  | #single(op) =>
    switch Message.Request.PartialOperation.classify(op) {
    | Transfer(t) =>
      <SingleOpDisplay
        onAccept={p => {
          handleAccept(p, t)
        }}
        transaction=t
        goBack
        loading
      />
    | _ => <Text> {"unsupported"->React.string} </Text>
    }
  | #empty => <Text> {"empty"->React.string} </Text>
  | #batch => <Text> {"batch"->React.string} </Text>
  }

  let {appMetadata} = request
  <Container>
    <Headline> {"Operation request"->React.string} </Headline>
    <MetadataDisplay appMetadata />
    <Title> {request.network.type_->React.string} </Title>
    <Text> {("source address " ++ request.sourceAddress)->React.string} </Text>
    {el}
  </Container>
}
