open Belt
open SendTypes

module SendAndConfirmForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSimulate, ~onSubmit, ~fee, ~onCancel) => {
    let (step, setStep) = React.useState(_ => #fill)

    let el = switch fee {
    | Some(fee) => <Recap fee trans onSubmit={_ => {setStep(_ => #confirm)}} onCancel />
    | None => <SendForm trans setTrans isLoading onSubmit={_ => onSimulate()} />
    }

    switch step {
    // | #fill => <SendForm trans setTrans isLoading=false onSubmit={_ => {setStep(_ => #confirm)}} />
    | #fill => el
    | #confirm => <PasswordConfirm loading=isLoading onSubmit />
    }
  }
}

let makeNotif = hash => {
  <CommonComponents.Wrapper alignItems=#center>
    <Paper.Text> {React.string("Transaction successful!")} </Paper.Text>
    <Paper.IconButton
      onPress={_ => ReactNative.Linking.openURL("https://ithaca.tzstats.com/" ++ hash)->ignore}
      icon={Paper.Icon.name("open-in-new")}
      size={15}
    />
  </CommonComponents.Wrapper>
}

module PureSendScreen = {
  @react.component
  let make = (
    ~sender: Account.t,
    ~nft: option<Token.tokenNFT>,
    ~tz1FromQr: option<string>,
    ~notify,
    ~notifyAdvanced,
    ~navigate,
    ~isTestNet,
  ) => {
    let initialPrettyAmount = switch nft {
    | Some((b, _)) => b.balance->Js.Int.toFloat
    | _ => 0.
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
      trans.recipient->Option.map(recipientTz1 =>
        SendAPI.send(
          ~recipientTz1,
          ~prettyAmount=trans.prettyAmount,
          ~assetType=trans.assetType,
          ~senderTz1=sender.tz1,
          ~sk=sender.sk,
          ~isTestNet,
        )
      )
    let simulate =
      trans.recipient->Option.map((recipientTz1, ()) =>
        SendAPI.simulate(
          ~recipientTz1,
          ~prettyAmount=trans.prettyAmount,
          ~assetType=trans.assetType,
          ~senderTz1=sender.tz1,
          ~senderPk=sender.pk,
          ~isTestNet,
        )
      )

    // if present, load QRCode tz1 in transaction
    React.useEffect2(() => {
      tz1FromQr
      ->Option.map(tz1 =>
        setTrans(prev => {
          ...prev,
          recipient: tz1->Some,
        })
      )
      ->ignore

      None
    }, (tz1FromQr, setTrans))

    let handleSubmit = (passphrase: string) =>
      send
      ->Option.map(send => {
        setLoading(_ => true)

        send(~passphrase)
        ->Promise.thenResolve(({hash}) => {
          hash->makeNotif->Some->notifyAdvanced
          navigate("Home")->ignore
        })
        ->Promise.catch(e => {
          notify("Failed to send. Reason: " ++ Helpers.getMessage(e))->ignore
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
          notify("Invalid transaction: " ++ Helpers.getMessage(e))
          Promise.resolve()
        })
        ->Promise.finally(_ => {
          setLoading(_ => false)
        })
      })
      ->ignore

    <Container>
      <SendAndConfirmForm
        fee
        isLoading=loading
        trans
        setTrans
        onSubmit=handleSubmit
        onSimulate=handleSimulate
        onCancel={_ => setFee(_ => None)}
      />
    </Container>
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let nft = NavUtils.getToken(route)
  let tz1FromQr = NavUtils.getTz1FromQr(route)

  let notify = SnackBar.useNotification()
  let notifyAdvanced = SnackBar.useNotificationAdvanced()
  let navigate = NavUtils.useNavigate()
  let isTestNet = Store.useIsTestNet()
  Store.useWithAccount(account =>
    <PureSendScreen tz1FromQr sender=account nft notify notifyAdvanced navigate isTestNet />
  )
}
