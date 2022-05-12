open Paper
open SendAmount

type formState = {recipient: string, amount: SendAmount.t, passphrase: string}
let vMargin = FormStyles.styles["verticalMargin"]

// let useSend = (~recipient: string, ~amount: int, ~passphrase, ~sk) => {
//   ReactQuery.useQuery(ReactQuery.queryOptions(~queryFn=_ => {
//       TaquitoUtils.send(~recipient, ~amount, ~passphrase, ~sk)
//     }, ~queryKey="send", ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(
//       #bool(false),
//     ), ~enabled=false, ~retry=ReactQuery.retry(#number(0)), ()))
// }

module Sender = {
  @react.component
  let make = () => {
    let account = Store.useActiveAccount()

    let navigate = NavUtils.useNavigate()
    switch account {
    | Some(account) => <>
        <Caption> {React.string("sender")} </Caption>
        <AccountListItem account onPress={_ => {navigate("Accounts")->ignore}} />
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
  open CommonComponents
  open ReactNative.Style
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

let matchNftData = (token: Token.t) => {
  let {displayUri, thumbnailUri, description} = token.token.metadata
  switch (displayUri, thumbnailUri, description) {
  | (Some(displayUri), Some(thumbnailUri), Some(description)) =>
    Some((displayUri, thumbnailUri, description))
  | _ => None
  }
}
module SendForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let {recipient} = trans

    let disabled = !validTrans(trans)

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
      switch matchNftData(token) {
      | Some((displayUri, _, _)) =>
        <NFTInput imageUrl={Token.getNftUrl(displayUri)} name=token.token.metadata.name />
      | None => React.null
      }
    }

    <>
      {amountInput}
      <Sender />
      <TextInput
        value=recipient
        onChangeText={e => {
          setTrans(prev => {
            recipient: e,
            amount: prev.amount,
            passphrase: prev.passphrase,
          })
        }}
        style={vMargin}
        label="recipient"
        mode=#flat
      />
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
  let make = (~sender: Store.account, ~token: option<Token.t>) => {
    let amount = switch token {
    | Some(token) => Token(token)
    | _ => Tez(0)
    }

    let (trans, setTrans) = React.useState(_ => {recipient: "", amount: amount, passphrase: ""})
    let notify = SnackBar.useNotification()
    let notifyAdvanced = SnackBar.useNotificationAdvanced()
    let navigate = NavUtils.useNavigate()
    let (loading, setLoading) = React.useState(_ => false)

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

  switch account {
  | Some(account) => <ConnectedSend sender=account token />
  | None => React.null
  }
}
