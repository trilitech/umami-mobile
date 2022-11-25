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
      <PasswordSubmit onSubmit={onAccept} loading disabled=loading />
      <Button style={StyleUtils.makeVMargin()} onPress={_ => goBack()} mode=#outlined>
        {"Decline"->React.string}
      </Button>
    </>)
  }
}

let unsafeToInt: string => int = %raw("str => Number(str)")

let simulateBeaconTrans = (
  ~transaction: ReBeacon.Message.Request.PartialOperation.transaction,
  ~senderTz1,
  ~senderPk,
  ~network,
  ~nodeIndex,
) => {
  TaquitoUtils.estimateSendTez(
    ~amount=transaction.amount,
    ~network,
    ~nodeIndex,
    ~recipient=transaction.destination->Pkh.unsafeBuild,
    ~senderPk,
    ~senderTz1,
    ~parameter=transaction.parameters,
    ~storagelimit=transaction.storage_limit,
    ~mutez=true,
    (),
  )
}
let executeBeaconTrans = (
  password,
  transaction: ReBeacon.Message.Request.PartialOperation.transaction,
  requestId,
  network,
  sender: Account.t,
  respond,
  nodeIndex: int,
) => {
  let promise =
    TaquitoUtils.sendTez(
      ~network,
      ~nodeIndex,
      ~amount=transaction.amount,
      ~recipient=transaction.destination,
      ~password,
      ~sk=sender.sk,
      ~parameter=transaction.parameters,
      ~storageLimit=transaction.storage_limit,
      ~mutez=true,
      (),
    )->Promise.thenResolve(r => r.hash)

  promise->Promise.then(hash => {
    let response: Message.ResponseInput.operationResponse = {
      type_: #operation_response,
      transactionHash: hash,
      id: requestId,
    }

    respond(#OperationResponse(response))->Promise.thenResolve(_ => hash)
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
    ~network,
    ~nodeIndex: int,
  ) => {
    let notify = SnackBar.useNotification()
    let (loading, setLoading) = React.useState(_ => false)
    let (fee, setFee) = React.useState(_ => None)

    // TODO handle nodeIndex
    React.useEffect5(() => {
      simulateBeaconTrans(
        ~senderTz1=sender.tz1,
        ~senderPk=sender.pk,
        ~network,
        ~nodeIndex,
        ~transaction,
      )
      ->Promise.thenResolve(fee => {
        setFee(_ => Some(fee->Ok))
      })
      ->Promise.catch(exn => {
        setFee(_ => Some(exn->Helpers.getMessage->Error))
        Promise.resolve()
      })
      ->ignore

      None
    }, (transaction, network, sender.tz1, sender.pk, nodeIndex))

    let handleAccept = (
      password,
      t,
      network: Network.t,
      sender: Account.t,
      requestId,
      nodeIndex,
    ) => {
      setLoading(_ => true)
      executeBeaconTrans(password, t, requestId, network, (sender: Account.t), respond, nodeIndex)
      ->Promise.thenResolve(hash => {
        setLoading(_ => false)
        notify("Transaction successfull! " ++ hash->Helpers.formatHash())
        goBack()
      })
      ->Promise.catch(exn => {
        setLoading(_ => false)
        notify("Failed to execute beacon transaction. " ++ exn->Helpers.getMessage)
        notify(exn->Helpers.getMessage)
        Promise.resolve()
      })
      ->ignore
    }

    fee->Helpers.reactFold(result => {
      open Taquito.Toolkit
      switch result {
      | Ok(fee) =>
        <SingleOpDisplay
          fee=fee.suggestedFeeMutez
          transaction
          onAccept={p =>
            handleAccept(p, transaction, network, sender, requestId, nodeIndex)->ignore}
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

// TODO refactor with store deserializer
let safeNetworkParse = (str: string) => {
  open Network
  switch str {
  | "mainnet" => Mainnet->Some
  | "ghostnet" => Ghostnet->Some
  | _ => None
  }
}
module Display = {
  @react.component
  let make = (~request: Message.Request.operationRequest, ~goBack, ~sender, ~respond) => {
    let network = safeNetworkParse(request.network.type_)
    let (nodeIndex, _) = Store.useNodeIndex()
    let (selectedNetwork, _) = Store.useNetwork()

    let el = switch matchSingleTransaction(request.operationDetails) {
    | #single(op) =>
      switch Message.Request.PartialOperation.classify(op) {
      | Transfer(t) =>
        network->Belt.Option.mapWithDefault(
          <BeaconErrorMsg message={"Unknown Network. " ++ request.network.type_} />,
          network =>
            <SingleOp
            // Default nodeIndex to 0 if request not on selected network
              nodeIndex={network == selectedNetwork ? nodeIndex : 0}
              network
              sender
              transaction=t
              goBack
              requestId=request.id
              respond
            />,
        )

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
