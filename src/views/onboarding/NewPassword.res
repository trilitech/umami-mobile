@react.component
let make = (~navigation as _, ~route as _) => {
  let (_, setSecret) = Store.useAccounts()
  let (_, setSelectedAccount) = Store.useSelectedAccount()

  let (mnemonic, _) = OnboardingMnemonicState.useMnemonic()

  let (loading, setLoading) = React.useState(_ => false)

  let handlePasswordSubmit = password => {
    setLoading(_ => true)
    let mnemonic = mnemonic->Js.Array2.joinWith(" ")
    BackupPhraseStorage.save(mnemonic, password)
    ->Promise.then(() =>
      AccountUtils.generateAccount(
        ~mnemonic,
        ~passphrase=password,
        ~derivationPathIndex=0,
        (),
      )->Promise.thenResolve(account => {
        setSecret(_ => [account])
        setSelectedAccount(_ => 0->Some)
      })
    )
    ->Promise.catch(err => {
      Js.Console.error(err)
      Promise.resolve()
    })
    ->Promise.finally(() => {
      setLoading(_ => false)
      ()
    })
    ->ignore
  }

  <>
    <OnboardingIntructions
      step="Step 3 of 4"
      title="Set a passcode to secure your wallet"
      instructions="Please note that this password is not recorded anywhere and only applies to this machine. "
    />
    <Container> <PasswordCreate loading onSubmit={handlePasswordSubmit} /> </Container>
  </>
}
