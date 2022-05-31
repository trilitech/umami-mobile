open Paper
open SendAmount

open CommonComponents
type formState = {recipient: string, amount: SendAmount.t, passphrase: string}
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

let getCurrencies = (tokens: array<Token.allTokens>) => {
  open Belt.Array
  tokens
  ->reduce([], (acc, curr) => {
    switch curr {
    | FA1(_) => concat(acc, ["FA1"])
    | FA2(_, m) => concat(acc, [m.symbol])
    | _ => acc
    }
  })
  ->concat(["TEZ"])
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
  | Tez(_) => "TEZ"
  | FA1(_) => "FA1"
  | FA2(_, m) => m.symbol
  | NFT(_, m) => m.symbol
  }
}

let getAmount = (t: SendAmount.t) => {
  switch t {
  | Tez(amount) => amount
  | FA1(b) => b.balance
  | FA2(b, _) => b.balance
  | NFT(b, _) => b.balance
  }
}

let updateAmount = (a: int, t: SendAmount.t) => {
  switch t {
  | Tez(_) => Tez(a)
  | FA1(b) => FA1({...b, balance: a})
  | FA2(b, m) => FA2({...b, balance: a}, m)
  | NFT(b, m) => NFT({...b, balance: a}, m)
  }
}

open Belt
let getFA1Data = (tokens: array<Token.allTokens>) =>
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

let getFA2Data = (symbol: string, tokens: array<Token.allTokens>) =>
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

let updateCurrency = (symbol: string, t: SendAmount.t, tokens: array<Token.allTokens>): option<
  SendAmount.t,
> => {
  let amount = getAmount(t)
  if symbol == "TEZ" {
    Tez(amount)->Some
  } else if symbol == "FA1" {
    getFA1Data(tokens)->Option.map(b => FA1({...b, balance: amount}))
  } else {
    getFA2Data(symbol, tokens)->Option.map(((b, m)) => {
      FA2({...b, balance: amount}, m)
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
    | NFT((_, metadata)) =>
      let {name, displayUri} = metadata

      <NFTInput imageUrl={Token.getNftUrl(displayUri)} name />
    | Tez(amount) =>
      <MultiCurrencyInput
        amount
        onChangeAmount={handleChangeAmount}
        symbol={getSymbol(trans.amount)}
        onChangeSymbol=handleChangeSymbol
      />
    | FA1(b) =>
      <MultiCurrencyInput
        amount=b.balance
        onChangeAmount={handleChangeAmount}
        symbol={getSymbol(trans.amount)}
        onChangeSymbol=handleChangeSymbol
      />
    | FA2((b, _)) =>
      <MultiCurrencyInput
        amount=b.balance
        onChangeAmount={handleChangeAmount}
        symbol={getSymbol(trans.amount)}
        onChangeSymbol=handleChangeSymbol
      />
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
          // onChangeText={e => {
          //   setTrans(prev => {
          //     recipient: e,
          //     amount: prev.amount,
          //     passphrase: prev.passphrase,
          //   })
          // }}
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
                passphrase: prev.passphrase,
              })
            })
            ->ignore
          }}
          iconName="content-copy"
          style={FormStyles.styles["hMargin"]}
        />
      </Wrapper>
      <Button disabled loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
        {React.string("send")}
      </Button>
    </>
  }
}

module SendAndConfirmForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let (step, setStep) = React.useState(_ => #fill)

    switch step {
    | #fill => <SendForm trans setTrans isLoading=false onSubmit={_ => {setStep(_ => #confirm)}} />
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
  let make = (~sender: Store.account, ~nft: option<Token.tokenNFT>, ~tz1FromQr: option<string>) => {
    let amount = switch nft {
    | Some(token) => NFT(token)
    | _ => Tez(0)
    }

    let (trans, setTrans) = React.useState(_ => {recipient: "", amount: amount, passphrase: ""})
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

    let onSubmit = (passphrase: string) => {
      let {recipient, amount} = trans
      setLoading(_ => true)

      let makeSendToken = (base: Token.tokenBase, ~amount=base.balance, ()) => {
        TaquitoUtils.estimateSendToken(
          ~contractAddress=base.contract,
          ~amount,
          ~recipientTz1=recipient,
          ~tokenId=base.tokenId,
          ~senderTz1=sender.tz1,
        )
        ->Promise.thenResolve(res => {
          Js.Console.log2("fee", res.suggestedFeeMutez)
        })
        ->ignore

        TaquitoUtils.sendToken(
          ~passphrase,
          ~sk=sender.sk,
          ~contractAddress=base.contract,
          ~amount,
          ~recipientTz1=recipient,
          ~tokenId=base.tokenId,
          ~senderTz1=sender.tz1,
        )
      }

      let send = switch amount {
      | Tez(amount) =>
        TaquitoUtils.estimateSendTez(~amount, ~recipient, ~senderTz1=sender.tz1)
        ->Promise.thenResolve(res => {
          Js.Console.log2("fee", res.suggestedFeeMutez)
        })
        ->ignore
        TaquitoUtils.sendTez(~recipient, ~amount, ~passphrase, ~sk=sender.sk)
      | NFT((base, _)) => makeSendToken(base, ~amount=1, ())
      | FA1(b) => makeSendToken(b, ())
      | FA2(b, m) => makeSendToken(b, ~amount=Token.toRaw(b.balance, m.decimals), ())
      }

      send
      ->Promise.thenResolve(({hash}) => {
        let el = makeNotif(hash)

        notifyAdvanced(Some(el))

        // queryResult.remove()
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

    <Container> <SendAndConfirmForm isLoading=loading trans setTrans onSubmit /> </Container>
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let nft = NavUtils.getToken(route)
  let tz1FromQr = NavUtils.getTz1FromQr(route)

  Store.useWithAccount(account => <ConnectedSend tz1FromQr sender=account nft />)
}
