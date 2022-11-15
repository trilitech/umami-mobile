open Belt
open SendTypes

module SendAndConfirmForm = {
  @react.component
  let make = (~trans, ~setTrans, ~loading, ~onSimulate, ~onSubmit, ~fee, ~onCancel, ~sender) => {
    switch fee {
    | Some(fee) => <Recap loading account=sender fee trans onSubmit onCancel />
    | None => <SendForm trans setTrans loading onSubmit={_ => onSimulate()} />
    }
  }
}

let makeNotif = _hash => {
  <CommonComponents.Wrapper alignItems=#center>
    <Paper.Text> {React.string("Transaction successful!")} </Paper.Text>
    // <Paper.IconButton
    //   onPress={_ => ReactNative.Linking.openURL("https://ithaca.tzstats.com/" ++ hash)->ignore}
    //   icon={Paper.Icon.name("open-in-new")}
    //   size={15}
    // />
  </CommonComponents.Wrapper>
}

let getFriendlyMsg = (msg: string) => {
  if msg |> Js.Re.test_(%re("/^undefined is not an object \(evaluating/i")) {
    ErrorMsgs.wrongPassword
  } else {
    msg
  }
}
module PureSendScreen = {
  @react.component
  let make = (
    ~sender: Account.t,
    ~nft: option<Token.tokenNFT>,
    ~notify,
    ~notifyAdvanced,
    ~navigate,
    ~network,
    ~send: SendAPI.send,
    ~simulate: SendAPI.simulate,
  ) => {
    let initialPrettyAmount = switch nft {
    | Some((_, _)) => "1"
    | _ => ""
    }

    let initialAssetType = switch nft {
    | Some((b, m)) => NftAsset({tokenId: b.tokenId, contract: b.contract, symbol: m.symbol}, m)
    | _ => CurrencyAsset(CurrencyTez)
    }

    let (trans, setTrans) = React.useState(_ => {
      recipient: None,
      prettyAmount: initialPrettyAmount,
      assetType: initialAssetType,
    })

    let (fee, setFee) = React.useState(_ => None)
    let (loading, setLoading) = React.useState(_ => false)

    let send =
      Helpers.both(
        SendInputs.parsePrettyAmountStr(trans.prettyAmount),
        trans.recipient,
      )->Option.map(((prettyAmount, recipientTz1)) =>
        send(
          ~recipientTz1,
          ~prettyAmount,
          ~assetType=trans.assetType,
          ~senderTz1=sender.tz1,
          ~sk=sender.sk,
          ~network,
        )
      )

    let simulate =
      Helpers.both(
        SendInputs.parsePrettyAmountStr(trans.prettyAmount),
        trans.recipient,
      )->Option.map(((prettyAmount, recipientTz1), ()) =>
        simulate(
          ~recipientTz1,
          ~prettyAmount,
          ~assetType=trans.assetType,
          ~senderTz1=sender.tz1,
          ~senderPk=sender.pk,
          ~network,
        )
      )

    let handleSubmit = (password: string) =>
      send
      ->Option.map(send => {
        setLoading(_ => true)

        send(~password)
        ->Promise.thenResolve(({hash}) => {
          hash->makeNotif->Some->notifyAdvanced
          navigate("Home")->ignore
        })
        ->Promise.catch(e => {
          let message = "Failed to send. " ++ e->Helpers.getMessage->getFriendlyMsg
          notify(message)
          Logger.error(message)
          Promise.resolve()
        })
        ->Promise.finally(_ => setLoading(_ => false))
      })
      ->ignore

    let handleSimulate = () =>
      simulate
      ->Belt.Option.map(simulate => {
        setLoading(_ => true)

        simulate()
        ->Promise.thenResolve(res => {
          setFee(_ => res.suggestedFeeMutez->Some)
        })
        ->Promise.catch(e => {
          let message = "Invalid transaction: " ++ Helpers.getMessage(e)
          notify(message)
          Logger.error(message)
          Promise.resolve()
        })
        ->Promise.finally(_ => {
          setLoading(_ => false)
        })
      })
      ->ignore

    <SendAndConfirmForm
      sender
      fee
      loading
      trans
      setTrans
      onSubmit=handleSubmit
      onSimulate=handleSimulate
      onCancel={_ => setFee(_ => None)}
    />
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let nft = NavUtils.getNft(route)

  let notify = SnackBar.useNotification()
  let notifyAdvanced = SnackBar.useNotificationAdvanced()
  let navigate = NavUtils.useNavigate()
  let (network, _) = Store.useNetwork()
  Store.useWithAccount(account =>
    <PureSendScreen
      sender=account
      nft
      notify
      notifyAdvanced
      navigate
      network
      send=SendAPI.send
      simulate=SendAPI.simulate
    />
  )
}
