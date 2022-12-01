open Paper

let addNewAccount = (~name, ~password, ~derivationIndex) => {
  BackupPhraseStorage.load(password)->Promise.then(b => {
    AccountUtils.generateAccount(
      ~name,
      ~mnemonic=b,
      ~password,
      ~derivationPathIndex=derivationIndex,
      (),
    )
  })
}

let useLastDerivationIndex = () => {
  let (accounts, _) = Store.useAccountsDispatcher()
  accounts->Belt.Array.length
}

@react.component
let make = (~navigation, ~route as _: NavStacks.OnBoard.route) => {
  let (_, dispatch) = Store.useAccountsDispatcher()

  let notify = SnackBar.useNotification()
  let derivationIndex = useLastDerivationIndex()
  let (loading, setLooading) = React.useState(_ => false)

  let handleSubmit = (accountName, p) => {
    setLooading(_ => true)
    addNewAccount(~name=accountName, ~password=p, ~derivationIndex)
    ->Promise.thenResolve(a => {
      Add([a])->dispatch

      notify(`Accounts successfully created: ${accountName}`)
      navigation->NavStacks.OnBoard.Navigation.navigate("Accounts")
    })
    ->Promise.catch(e => {
      let message = "Failed to create account. " ++ e->Helpers.getMessage
      Logger.error(message)
      notify(message)
      Promise.resolve()
    })
    ->Promise.finally(() => {
      setLooading(_ => false)
    })
    ->ignore
  }

  <>
    <TopBarAllScreens title="Create account" />
    <Headline> {React.string("Create account")} </Headline>
    <EditAccountForm
      loading
      submitWithPassword=true
      name="New Account"
      onSubmit={(name, p) =>
        p
        ->Belt.Option.map(password => {
          handleSubmit(name, password)
        })
        ->ignore}
    />
  </>
}
