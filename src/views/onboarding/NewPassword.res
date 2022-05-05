open Paper

// let generateAccount = (~mnemonic, ~passphrase, ~derivationPathIndex) => {
//   CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ~derivationPathIndex=0, ())->Promise.then(sk => {
//     CryptoUtils.getTz1(~sk, ~passphrase)->Promise.thenResolve(tz1 => {
//       let account: Store.account = {
//         name: "Secret " ++ derivationPathIndex->Js.Int.toString,
//         tz1: tz1,
//         sk: sk,
//         derivationPathIndex: derivationPathIndex,
//       }

//       Js.Console.log2("generated account", account)
//       account
//     })
//   })
// }

@react.component
let make = (~navigation as _, ~route as _) => {
  let (_, setSecret) = Store.useAccounts()
  let (_, setSelectedAccount) = Store.useSelectedAccount()

  let (mnemonic, _) = OnboardingMnemonicState.useMnemonic()
  let handlePasswordSubmit = password => {
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
        setSelectedAccount(0)
      })
    )
    ->ignore
  }

  <>
    <OnboardingIntructions
      step="Step 3 of 4"
      title="Set a passcode to secure your wallet"
      instructions="Please note that this password is not recorded anywhere and only applies to this machine. "
    />
    <Background>
      <Caption> {React.string("Enter passcode")} </Caption>
      // <PasswordConfirm.PurePasswordConfirm value=password onChange={d => setPassword(_ => d)} />
      <PasswordCreate onSubmit={handlePasswordSubmit} />
      // <TextInput
      //   style={ReactNative.Style.style(~display=#none, ())}
      //   onChangeText={t => setPassword(_ => t)}
      //   maxLength=8
      //   mode=#flat
      //   autoFocus=true
      //   keyboardType="number-pad"
      // />
      // <ContinueBtn
      //   onPress={_ => {
      //     handlePasswordSubmit()
      //   }}
      //   text="Save"
      // />
    </Background>
  </>
}
