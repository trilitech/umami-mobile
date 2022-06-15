open Paper
open Belt
open Asset
open ReactNative.Style
open CommonComponents
open SendTypes
open SendInputs

let vMargin = FormStyles.styles["verticalMargin"]

let validTrans = trans => {
  trans.recipient->Js.String2.length > 10 &&
    switch trans.asset {
    | Tez(amount) => amount > 0
    | _ => true
    }
}

let updateAmount = (a: int, t: Asset.t) => {
  switch t {
  | Tez(_) => Tez(a)

  | Token(t) =>
    switch t {
    | FA1(b) => FA1({...b, balance: a})->Token
    | FA2(b, m) => FA2({...b, balance: a}, m)->Token
    | NFT(b, m) => NFT({...b, balance: a}, m)->Token
    }
  }
}

let getFA1base = (tokens: array<Token.t>) =>
  tokens
  ->Array.getBy(t =>
    switch t {
    | FA1(_) => true
    | _ => false
    }
  )
  ->Option.flatMap(t =>
    switch t {
    | FA1(d) => Some(d)
    | _ => None
    }
  )

let getFA2base = (symbol: string, tokens: array<Token.t>) =>
  tokens
  ->Array.getBy(t =>
    switch t {
    | FA2(_, meta) => meta.symbol === symbol
    | _ => false
    }
  )
  ->Option.flatMap(t =>
    switch t {
    | FA2(d) => Some(d)
    | _ => None
    }
  )

let changeCurrency = (symbol: string, t: Asset.t, tokens: array<Token.t>): option<Asset.t> => {
  let amount = getBalance(t)
  if symbol == "tez" {
    Tez(amount)->Some
  } else if symbol == "FA1.2" {
    getFA1base(tokens)->Option.map(b => FA1({...b, balance: amount})->Token)
  } else {
    getFA2base(symbol, tokens)->Option.map(((b, m)) => {
      FA2({...b, balance: amount}, m)->Token
    })
  }
}

module SendForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let {recipient} = trans

    let tokens = Store.useTokens()
    let disabled = !validTrans(trans) || isLoading
    let navigate = NavUtils.useNavigate()

    let handleChangeAmount = (a: int) => {
      setTrans(t => {
        let amount = updateAmount(a, t.asset)
        {...t, asset: amount}
      })
    }

    let handleChangeSymbol = (s: string) => {
      setTrans(t => {
        let amount = changeCurrency(s, t.asset, tokens)
        switch amount {
        | Some(amount) => {...t, asset: amount}
        | None => t
        }
      })
      ()
    }

    let amountInput = switch trans.asset {
    | Tez(amount) =>
      <MultiCurrencyInput
        amount
        onChangeAmount={handleChangeAmount}
        symbol={getSymbol(trans.asset)}
        onChangeSymbol=handleChangeSymbol
      />
    | Token(t) =>
      switch t {
      | NFT((_, metadata)) =>
        let {name, displayUri} = metadata

        <NFTInput imageUrl={displayUri} name />
      | _ =>
        <MultiCurrencyInput
          amount={getBalance(trans.asset)}
          onChangeAmount={handleChangeAmount}
          symbol={getSymbol(trans.asset)}
          onChangeSymbol=handleChangeSymbol
        />
      }
    }

    let handleSenderPress = _ => navigate("Accounts")->ignore

    <>
      {amountInput}
      // Only allow sender change when sending Tez
      <Sender onPress=handleSenderPress disabled={!isTez(trans.asset)} />
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
              setTrans(prev => {
                recipient: recipient,
                asset: prev.asset,
              })
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
    ~sender: Store.account,
    ~nft: option<Token.tokenNFT>,
    ~tz1FromQr: option<string>,
    ~notify,
    ~notifyAdvanced,
    ~navigate,
  ) => {
    let amount = switch nft {
    | Some(token) => NFT(token)->Token
    | _ => Tez(0)
    }

    let (trans, setTrans) = React.useState(_ => {recipient: "", asset: amount})
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
