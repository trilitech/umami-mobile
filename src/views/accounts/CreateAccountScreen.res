open Paper

let addNewAccount = (~name, ~passphrase, ~derivationIndex) => {
  BackupPhraseStorage.load(passphrase)->Promise.then(b => {
    AccountUtils.generateAccount(
      ~name,
      ~mnemonic=b,
      ~passphrase,
      ~derivationPathIndex=derivationIndex,
      (),
    )
  })
}

let useLastDerivationIndex = () => {
  let (secrets, _) = Store.useAccounts()
  secrets->Belt.Array.length
}
@react.component
let make = (~navigation, ~route as _: NavStacks.OnBoard.route) => {
  let (step, setStep) = React.useState(_ => #edit)
  let (accountName, setAccountName) = React.useState(_ => "")
  let (accounts, setAccounts) = Store.useAccounts()

  let notify = SnackBar.useNotification()
  let derivationIndex = useLastDerivationIndex()
  let (loading, setLooading) = React.useState(_ => false)

  <Background>
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
          addNewAccount(~name=accountName, ~passphrase=p, ~derivationIndex)
          ->Promise.thenResolve(a => {
            setAccounts(_ => Belt.Array.concat(accounts, [a]))

            notify(`Accounts successfully created: ${accountName}`)
            navigation->NavStacks.OnBoard.Navigation.navigate("Accounts")
            ()
          })
          ->Promise.catch(_ => {
            notify("Failed to create account")
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
  </Background>
}
