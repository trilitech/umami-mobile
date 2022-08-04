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
  let (accounts, _) = AccountsReducer.useAccountsDispatcher()
  accounts->Belt.Array.length
}

@react.component
let make = (~navigation, ~route as _: NavStacks.OnBoard.route) => {
  let (step, setStep) = React.useState(_ => #edit)
  let (accountName, setAccountName) = React.useState(_ => "")
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()

  let notify = SnackBar.useNotification()
  let derivationIndex = useLastDerivationIndex()
  let (loading, setLooading) = React.useState(_ => false)

  <>
    <TopBarAllScreens title="Create account" />
    <Container>
      {switch step {
      | #edit => <>
          <Headline> {React.string("Create account")} </Headline>
          <EditAccountForm
            name="New Account"
            onSubmit={n => {
              setAccountName(_ => n)
              setStep(_ => #confirm)
              ()
            }}
          />
        </>
      | #confirm =>
        <PasswordConfirm
          loading
          onSubmit={p => {
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
            ()
          }}
        />
      }}
    </Container>
  </>
}
