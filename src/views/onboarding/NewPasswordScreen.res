@react.component
let make = (~navigation as _, ~route as _) => {
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()
  let (_, setSelectedAccount) = Store.useSelectedAccount()
  let notify = SnackBar.useNotification()

  let (mnemonic, _) = DangerousMnemonicHooks.useMnemonic()

  let (loading, setLoading) = React.useState(_ => false)
  let savePassword = Biometrics.useKeychainStorage()

  let handlePasswordSubmit = data => {
    let password = data["password"]
    let saveInKeyChain = data["saveInKeyChain"]
    setLoading(_ => true)
    let mnemonic = mnemonic->Js.Array2.joinWith(" ")

    // TODO refactor this with same logic as ImportSecretScreen
    BackupPhraseStorage.save(mnemonic, password)
    ->Promise.then(() =>
      AccountUtils.generateAccount(
        ~mnemonic,
        ~password,
        ~derivationPathIndex=0,
        (),
      )->Promise.thenResolve(account => {
        setLoading(_ => false)
        dispatch(ReplaceAll([account]))
        setSelectedAccount(_ => 0)
      })
    )
    ->Promise.then(_ => saveInKeyChain ? savePassword(password->Some) : Promise.resolve())
    ->Promise.catch(exn => {
      setLoading(_ => false)
      notify("Failed to generate account. " ++ exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore
  }

  <>
    <InstructionsPanel
      step="Step 3 of 4"
      title="Set a password to secure your wallet"
      instructions="Please note that this password is not recorded anywhere and only applies to this machine."
    />
    <Container> <PasswordCreate loading onSubmit={handlePasswordSubmit} /> </Container>
  </>
}
