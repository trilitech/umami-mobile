open Paper
open SendAmount

open CommonComponents
type formState = {recipient: string, amount: SendAmount.t}
let vMargin = FormStyles.styles["verticalMargin"]
open ReactNative.Style

open Store
module Sender = {
  @react.component
  let make = (~onPress, ~disabled) => {
    useWithAccount(account => <>
      <Caption> {React.string("sender")} </Caption> <AccountListItem account onPress disabled />
    </>)
  }
}

let validTrans = trans => {
  trans.recipient->Js.String2.length > 10 &&
    switch trans.amount {
    | Tez(amount) => amount > 0
    | _ => true
    }
}

module TezInput = {
  @react.component
  let make = (~value, ~onChangeText, ~style) => {
    <TextInput keyboardType="number-pad" value onChangeText style label="amount" mode=#flat />
  }
}

module NFTInput = {
  @react.component
  let make = (~imageUrl, ~name) => {
    <CustomListItem
      left={<Image
        url=imageUrl resizeMode=#contain style={style(~height=40.->dp, ~width=40.->dp, ())}
      />}
      center={<Text> {React.string(name)} </Text>}
    />
  }
}

let isTez = amount =>
  switch amount {
  | Tez(_) => true
  | _ => false
  }

let getCurrencies = (tokens: array<Token.t>) => {
  open Belt.Array
  tokens
  ->reduce([], (acc, curr) => {
    switch curr {
    | FA1(_) => concat(acc, ["FA1.2"])
    | FA2(_, m) => concat(acc, [m.symbol])
    | _ => acc
    }
  })
  ->concat(["tez"])
}
module CurrencyPicker = {
  @react.component
  let make = (~value, ~onChange) => {
    let tokens = Store.useTokens()
    let currencies = getCurrencies(tokens)

    let items = currencies->Belt.Array.map(currency => {"label": currency, "value": currency})

    <StyledPicker items value onChange />
  }
}

module MultiCurrencyInput = {
  @react.component
  let make = (~amount, ~onChangeAmount, ~symbol, ~onChangeSymbol) => {
    <Wrapper>
      <TextInput
        style={style(~flex=1., ())}
        keyboardType="number-pad"
        value={amount->Belt.Int.toString}
        onChangeText={t => {
          Belt.Int.fromString(t)->Belt.Option.map(v => onChangeAmount(v))->ignore
        }}
        label="amount"
        mode=#flat
      />
      <CurrencyPicker value=symbol onChange=onChangeSymbol />
    </Wrapper>
  }
}

let getSymbol = (t: SendAmount.t) => {
  switch t {
  | Tez(_) => "tez"
  | Token(t) =>
    switch t {
    | FA1(_) => "FA1.2"
    | FA2(_, m) => m.symbol
    | NFT(_, m) => m.symbol
    }
  }
}

let getAmount = (t: SendAmount.t) => {
  switch t {
  | Tez(amount) => amount
  | Token(t) => Token.getBalance(t)
  }
}

let updateAmount = (a: int, t: SendAmount.t) => {
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

open Belt
let getFA1Data = (tokens: array<Token.t>) =>
  tokens
  ->Array.getBy(t =>
    switch t {
    | FA1(_) => true
    | _ => false
    }
  )
  ->Option.flatMap(t => {
    switch t {
    | FA1(d) => Some(d)
    | _ => None
    }
  })

let getFA2Data = (symbol: string, tokens: array<Token.t>) =>
  tokens
  ->Array.getBy(t =>
    switch t {
    | FA2(_, meta) => meta.symbol === symbol
    | _ => false
    }
  )
  ->Option.flatMap(t => {
    switch t {
    | FA2(d) => Some(d)
    | _ => None
    }
  })

let updateCurrency = (symbol: string, t: SendAmount.t, tokens: array<Token.t>): option<
  SendAmount.t,
> => {
  let amount = getAmount(t)
  if symbol == "tez" {
    Tez(amount)->Some
  } else if symbol == "FA1.2" {
    getFA1Data(tokens)->Option.map(b => FA1({...b, balance: amount})->Token)
  } else {
    getFA2Data(symbol, tokens)->Option.map(((b, m)) => {
      FA2({...b, balance: amount}, m)->Token
    })
  }
}

let makeRow = (title, content) =>
  <Wrapper justifyContent=#spaceBetween style=vMargin>
    <Caption> {title->React.string} </Caption> <Text> {content->React.string} </Text>
  </Wrapper>
module Recap = {
  @react.component
  let make = (~trans, ~fee, ~isLoading=false, ~onSubmit, ~onCancel) => {
    let symbol = getSymbol(trans.amount)
    let formatAmount = t => Token.getBalance(t)->Belt.Int.toString ++ " " ++ symbol
    let amountDisplay = switch trans.amount {
    | Tez(amount) => makeRow("Subtotal", amount->Belt.Int.toString ++ " " ++ symbol)
    | Token(t) =>
      switch t {
      | NFT((_, metadata)) =>
        let {name, displayUri} = metadata

        <NFTInput imageUrl={displayUri} name />
      | _ => makeRow("Subtotal", formatAmount(t))
      }
    }
    <>
      <Headline style={style(~textAlign=#center, ())}> {"Recap"->React.string} </Headline>
      {amountDisplay}
      {makeRow("Fee", TezHelpers.formatBalance(fee))}
      {makeRow("Recipient", trans.recipient)}
      <Button disabled=isLoading loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
        {React.string("Submit transaction")}
      </Button>
      <Button disabled=isLoading onPress=onCancel style={vMargin} mode=#contained>
        {React.string("Cancel")}
      </Button>
    </>
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
        let amount = updateAmount(a, t.amount)
        {...t, amount: amount}
      })
    }

    let handleChangeSymbol = (s: string) => {
      setTrans(t => {
        let amount = updateCurrency(s, t.amount, tokens)
        switch amount {
        | Some(amount) => {...t, amount: amount}
        | None => t
        }
      })
      ()
    }

    let amountInput = switch trans.amount {
    | Tez(amount) =>
      <MultiCurrencyInput
        amount
        onChangeAmount={handleChangeAmount}
        symbol={getSymbol(trans.amount)}
        onChangeSymbol=handleChangeSymbol
      />
    | Token(t) =>
      switch t {
      | NFT((_, metadata)) =>
        let {name, displayUri} = metadata

        <NFTInput imageUrl={displayUri} name />
      | _ =>
        <MultiCurrencyInput
          amount={getAmount(trans.amount)}
          onChangeAmount={handleChangeAmount}
          symbol={getSymbol(trans.amount)}
          onChangeSymbol=handleChangeSymbol
        />
      }
    }

    let handleSenderPress = _ => navigate("Accounts")->ignore

    <>
      {amountInput}
      // Only allow sender change when sending Tez
      <Sender onPress=handleSenderPress disabled={!isTez(trans.amount)} />
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
                amount: prev.amount,
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

let makeEstimate = (~base: Token.tokenBase, ~senderTz1, ~recipientTz1, ~isFa1=false, ()) => {
  TaquitoUtils.estimateSendToken(
    ~contractAddress=base.contract,
    ~tokenId=base.tokenId,
    ~amount=base.balance,
    ~senderTz1,
    ~recipientTz1,
    ~isFa1,
  )
}

let simulate = (trans, senderTz1) =>
  switch trans.amount {
  | Tez(amount) => TaquitoUtils.estimateSendTez(~amount, ~recipient=trans.recipient, ~senderTz1)
  | Token(t) =>
    let estimate = makeEstimate(~recipientTz1=trans.recipient, ~senderTz1)
    switch t {
    | NFT((base, _))
    | FA2(base, _) =>
      estimate(~base, ())
    | FA1(base) => estimate(~base, ~isFa1=true, ())
    }
  }

let makeSendToken = (
  ~base: Token.tokenBase,
  ~amount,
  ~isFa1=false,
  ~passphrase,
  ~sk,
  ~senderTz1,
  ~recipientTz1,
  (),
) => {
  TaquitoUtils.sendToken(
    ~passphrase,
    ~sk,
    ~contractAddress=base.contract,
    ~amount,
    ~recipientTz1,
    ~tokenId=base.tokenId,
    ~senderTz1,
    ~isFa1,
    (),
  )
}
module ConnectedSend = {
  @react.component
  let make = (~sender: Store.account, ~nft: option<Token.tokenNFT>, ~tz1FromQr: option<string>) => {
    let amount = switch nft {
    | Some(token) => NFT(token)->Token
    | _ => Tez(0)
    }

    let (trans, setTrans) = React.useState(_ => {recipient: "", amount: amount})
    let (fee, setFee) = React.useState(_ => None)
    let notify = SnackBar.useNotification()
    let notifyAdvanced = SnackBar.useNotificationAdvanced()
    let navigate = NavUtils.useNavigate()
    let (loading, setLoading) = React.useState(_ => false)

    React.useEffect1(() => {
      tz1FromQr
      ->Belt.Option.map(tz1 => {
        setTrans(prev => {
          ...prev,
          recipient: tz1,
        })
      })
      ->ignore

      None
    }, [tz1FromQr])

    let {recipient, amount} = trans
    let onSubmit = (passphrase: string) => {
      setLoading(_ => true)

      let send = switch amount {
      // No need to ajust tez amount
      | Tez(amount) => TaquitoUtils.sendTez(~recipient, ~amount, ~passphrase, ~sk=sender.sk)
      | Token(t) =>
        let sendToken = makeSendToken(
          ~passphrase,
          ~sk=sender.sk,
          ~senderTz1=sender.tz1,
          ~recipientTz1=recipient,
        )
        switch t {
        | NFT((base, _)) => sendToken(~base, ~amount=1, ())
        | FA1(base) =>
          sendToken(
            ~base,
            ~amount=Token.toRaw(base.balance, Constants.fa1CurrencyDecimal),
            ~isFa1=true,
            (),
          )
        | FA2(base, m) => sendToken(~base, ~amount=Token.toRaw(base.balance, m.decimals), ())
        }
      }

      send
      ->Promise.thenResolve(({hash}) => {
        let el = makeNotif(hash)

        notifyAdvanced(Some(el))

        navigate("Home")->ignore
        ()
      })
      ->Promise.catch(_ => {
        notify("Failed to send")->ignore
        Promise.resolve()
      })
      ->Promise.finally(_ => {
        setLoading(_ => false)
      })
      ->ignore
    }

    let onSimulate = () => {
      setLoading(_ => true)
      simulate(trans, sender.tz1)
      ->Promise.thenResolve(res => {
        setFee(_ => res.suggestedFeeMutez->Some)
      })
      ->Promise.catch(_ => {
        notify("Invalid transaction")
        Promise.resolve()
      })
      ->Promise.finally(_ => {
        setLoading(_ => false)
      })
      ->ignore
    }

    <Container>
      <SendAndConfirmForm
        fee isLoading=loading trans setTrans onSubmit onSimulate onCancel={_ => setFee(_ => None)}
      />
    </Container>
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let nft = NavUtils.getToken(route)
  let tz1FromQr = NavUtils.getTz1FromQr(route)

  Store.useWithAccount(account => <ConnectedSend tz1FromQr sender=account nft />)
}
