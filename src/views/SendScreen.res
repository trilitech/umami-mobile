open Paper

open ReactNative.Style

type formState = {recipient: string, amount: int, passphrase: string}
let vMargin = FormStyles.styles["verticalMargin"]

let useSend = (~recipient: string, ~amount: int, ~passphrase, ~sk) => {
  ReactQuery.useQuery(ReactQuery.queryOptions(~queryFn=_ => {
      TaquitoUtils.send(~recipient, ~amount, ~passphrase, ~sk)
    }, ~queryKey="send", ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(
      #bool(false),
    ), ~enabled=false, ~retry=ReactQuery.retry(#number(0)), ()))
}

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

module SendForm = {
  @react.component
  let make = (~trans, ~setTrans, ~isLoading, ~onSubmit) => {
    let {recipient} = trans

    let disabled = trans.recipient->Js.String2.length < 10 || trans.amount == 0
    <>
      <TextInput
        keyboardType="number-pad"
        onChangeText={e => {
          e
          ->Belt.Int.fromString
          ->Belt.Option.map(amount => {
            setTrans(prev => {
              recipient: prev.recipient,
              amount: amount,
              passphrase: prev.passphrase,
            })
          })
          ->ignore
        }}
        style={vMargin}
        label="amount"
        mode=#flat
      />
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

module Confirm = {
  @react.component
  let make = (~passphrase, ~onChange, ~isLoading, ~onSubmit) => {
    <>
      <PasswordConfirm.PurePasswordConfirm value=passphrase onChange />
      <Button
        loading=isLoading
        style={style(~marginTop=10.->dp, ())}
        onPress={_ => onSubmit()}
        mode=#contained>
        {React.string("Confirm")}
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
    | #confirm =>
      <Confirm
        passphrase=trans.passphrase
        onChange={p => {
          setTrans(prev => {
            recipient: prev.recipient,
            amount: prev.amount,
            passphrase: p,
          })
        }}
        isLoading
        onSubmit
      />
    }
  }
}

module ConnectedSend = {
  @react.component
  let make = (~secret: Store.account) => {
    let (trans, setTrans) = React.useState(_ => {recipient: "", amount: 0, passphrase: ""})
    let notify = SnackBar.useNotification()
    let notifyAdvanced = SnackBar.useNotificationAdvanced()
    let navigate = NavUtils.useNavigate()

    let queryResult = useSend(
      ~recipient=trans.recipient,
      ~amount=trans.amount,
      ~passphrase=trans.passphrase,
      ~sk=secret.sk,
    )
    let {refetch} = queryResult
    let isError = queryResult.isError

    React.useEffect1(() => {
      if isError {
        notify("Failed to send")
      }
      None
    }, [isError])

    React.useEffect1(() => {
      {
        switch queryResult.data {
        | Some({hash}) => {
            let el =
              <CommonComponents.Wrapper alignItems=#center>
                <Paper.Text> {React.string("Transaction successful!")} </Paper.Text>
                <Paper.IconButton
                  onPress={_ =>
                    ReactNative.Linking.openURL("https://ithaca.tzstats.com/" ++ hash)->ignore}
                  icon={Paper.Icon.name("open-in-new")}
                  size={15}
                />
              </CommonComponents.Wrapper>

            notifyAdvanced(Some(el))

            queryResult.remove()
            navigate("Home")->ignore
          }
        | None => ()
        }
      }

      None
    }, [queryResult.data])

    let onSubmit = _ => {
      refetch({
        {
          throwOnError: false,
          cancelRefetch: false,
        }
      })->ignore
    }

    <Background>
      <SendAndConfirmForm isLoading=queryResult.isFetching trans setTrans onSubmit />
    </Background>
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let account = Store.useActiveAccount()

  switch account {
  | Some(account) => <ConnectedSend secret=account />
  | None => React.null
  }
}