open Paper
open Belt
open ReactNative.Style
open CommonComponents
open SendInputs
open SendTypes

let vMargin = FormStyles.styles["verticalMargin"]

let validTrans = (trans: SendTypes.formState) =>
  trans.recipient->TaquitoUtils.tz1IsValid && trans.prettyAmount > 0.

module SendForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let notify = SnackBar.useNotification()

    let {recipient} = trans

    let disabled = !validTrans(trans) || isLoading
    let navigate = NavUtils.useNavigate()

    let handleChangeAmount = (a: float) => {
      setTrans(t => {
        {...t, prettyAmount: a}
      })
    }

    let handleChangeSymbol = (c: SendTypes.currency) => {
      setTrans(t => {
        {...t, assetType: CurrencyAsset(c)}
      })
    }

    let prettyAmount = trans.prettyAmount

    let amountInput = switch trans.assetType {
    | CurrencyAsset(currency) =>
      <MultiCurrencyInput
        amount=prettyAmount
        onChangeAmount={handleChangeAmount}
        currency={currency}
        onChangeSymbol=handleChangeSymbol
      />
    | NftAsset(_, m) => <NFTInput imageUrl={m.displayUri} name={m.name} />
    }

    let handleSenderPress = _ => navigate("Accounts")->ignore

    <>
      {amountInput}
      // Only allow sender change when sending Tez
      <Sender onPress=handleSenderPress disabled={SendTypes.isNft(trans.assetType)} />
      <Wrapper>
        <TextInput
          value={recipient == "" ? "" : TezHelpers.formatTz1(recipient)}
          disabled=true
          style={array([vMargin, style(~flex=1., ())])}
          label="recipient"
          mode=#flat
        />
        <NicerIconBtn
          onPress={_ => {
            navigate("ScanQR")->ignore
            ()
          }}
          iconName="qrcode-scan"
          style={FormStyles.styles["hMargin"]}
        />
        <NicerIconBtn
          onPress={_ => {
            Clipboard.getString()
            ->Promise.thenResolve(recipient => {
              if TaquitoUtils.tz1IsValid(recipient) {
                setTrans(prev => {
                  ...prev,
                  recipient: recipient,
                })
              } else {
                notify(`${recipient} is not a valid pkh`)
              }
            })
            ->ignore
          }}
          iconName="content-copy"
          style={FormStyles.styles["hMargin"]}
        />
      </Wrapper>
      <Button disabled loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
        {React.string("review")}
      </Button>
    </>
  }
}

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

module ConnectedSend = {
  @react.component
  let make = (
    ~sender: Account.t,
    ~nft: option<Token.tokenNFT>,
    ~tz1FromQr: option<string>,
    ~notify,
    ~notifyAdvanced,
    ~navigate,
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
      recipient: "",
      prettyAmount: initialPrettyAmount,
      assetType: initialAssetType,
    })

    let (fee, setFee) = React.useState(_ => None)
    let (loading, setLoading) = React.useState(_ => false)

    let send = SendAPI.send(~trans, ~senderTz1=sender.tz1, ~sk=sender.sk)
    let simulate = () => SendAPI.simulate(~trans, ~senderTz1=sender.tz1, ~senderPk=sender.pk)

    // if present, load QRCode tz1 in transaction
    React.useEffect2(() => {
      tz1FromQr
      ->Option.map(tz1 =>
        setTrans(prev => {
          ...prev,
          recipient: tz1,
        })
      )
      ->ignore

      None
    }, (tz1FromQr, setTrans))

    let handleSubmit = (passphrase: string) => {
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
      ->ignore
    }

    let handleSimulate = () => {
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
      ->ignore
    }

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
  Store.useWithAccount(account =>
    <ConnectedSend tz1FromQr sender=account nft notify notifyAdvanced navigate />
  )
}
