open Paper
open SendAmount

open CommonComponents
type formState = {recipient: string, amount: SendAmount.t, passphrase: string}
let vMargin = FormStyles.styles["verticalMargin"]
open ReactNative.Style

// let useSend = (~recipient: string, ~amount: int, ~passphrase, ~sk) => {
//   ReactQuery.useQuery(ReactQuery.queryOptions(~queryFn=_ => {
//       TaquitoUtils.send(~recipient, ~amount, ~passphrase, ~sk)
//     }, ~queryKey="send", ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(
//       #bool(false),
//     ), ~enabled=false, ~retry=ReactQuery.retry(#number(0)), ()))
// }

module Sender = {
  @react.component
  let make = (~onPress, ~disabled) => {
    let account = Store.useActiveAccount()

    switch account {
    | Some(account) => <>
        <Caption> {React.string("sender")} </Caption> <AccountListItem account onPress disabled />
      </>
    | None => React.null
    }
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
  let make = (~value, ~onChangeText) => {
    <TextInput
      keyboardType="number-pad" value onChangeText style={vMargin} label="amount" mode=#flat
    />
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

module SendForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let {recipient} = trans

    let disabled = !validTrans(trans)
    let navigate = NavUtils.useNavigate()

    let amountInput = switch trans.amount {
    | Tez(amount) =>
      <TezInput
        value={Js.Int.toString(amount)}
        onChangeText={t => {
          t
          ->Belt.Int.fromString
          ->Belt.Option.map(amount => {
            setTrans(prev => {
              recipient: prev.recipient,
              amount: Tez(amount),
              passphrase: prev.passphrase,
            })
          })
          ->ignore
        }}
      />
    | Token(token) =>
      switch Token.matchNftData(token) {
      | Some((displayUri, _, _, name)) => <NFTInput imageUrl={Token.getNftUrl(displayUri)} name />
      | None => React.null
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
  let make = (~sender: Store.account, ~token: option<Token.t>, ~tz1FromQr: option<string>) => {
    let amount = switch token {
    | Some(token) => Token(token)
    | _ => Tez(0)
    }

    let (trans, setTrans) = React.useState(_ => {recipient: "", amount: amount, passphrase: ""})
    let notify = SnackBar.useNotification()
    let notifyAdvanced = SnackBar.useNotificationAdvanced()
    let navigate = NavUtils.useNavigate()
    let (loading, setLoading) = React.useState(_ => false)

    // let tz1FromQr = NavUtils.useT

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
    // let queryResult = useSend(
    //   ~recipient=trans.recipient,
    //   ~amount=trans.amount,
    //   ~passphrase=trans.passphrase,
    //   ~sk=secret.sk,
    // )
    // let {refetch} = queryResult
    // let isError = queryResult.isError

    // React.useEffect1(() => {
    //   if isError {
    //     notify("Failed to send")
    //   }
    //   None
    // }, [isError])

    // React.useEffect1(() => {
    //   {
    //     switch queryResult.data {
    //     | Some({hash}) => {
    //         let el = makeNotif(hash)

    //         notifyAdvanced(Some(el))

    //         queryResult.remove()
    //         navigate("Home")->ignore
    //       }
    //     | None => ()
    //     }
    //   }

    //   None
    // }, [queryResult.data])

    let onSubmit = (passphrase: string) => {
      let {recipient, amount} = trans
      setLoading(_ => true)

      let send = switch amount {
      | Tez(amount) => TaquitoUtils.send(~recipient, ~amount, ~passphrase, ~sk=sender.sk)
      | Token(token) =>
        TaquitoUtils.signAndSendToken(
          ~passphrase,
          ~sk=sender.sk,
          ~contractAddress=token.token.contract.address,
          ~amount=1,
          ~recipientTz1=recipient,
          ~tokenId=token.token.tokenId,
          ~senderTz1=sender.tz1,
        )
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
  let account = Store.useActiveAccount()
  let token = NavUtils.getToken(route)
  let tz1FromQr = NavUtils.getTz1FromQr(route)

  switch account {
  | Some(account) => <ConnectedSend tz1FromQr sender=account token />
  | None => React.null
  }
}
