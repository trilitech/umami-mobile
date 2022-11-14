open Belt

let restoreAndSave = (
  ~notify,
  ~updateKeychain,
  ~seedPhrase,
  ~password,
  ~onAccountsReady,
  ~derivationPath,
  ~saveInKeychain=false,
  (),
) => {
  DerivationPath.save(derivationPath)->Promise.then(() =>
    BackupPhraseStorage.save(seedPhrase, password)
    ->Promise.then(_ => AccountUtils.restoreKeysPromise(~mnemonic=seedPhrase, ~password))
    ->Promise.thenResolve(keys => {
      let accounts: array<Account.t> = keys->Array.map(AccountUtils.keysToAccount)
      AESCrypto.encrypt(seedPhrase, password)->Promise.thenResolve(_ => onAccountsReady(accounts))
    })
    ->Promise.then(_ => {
      saveInKeychain ? updateKeychain(Some(password)) : Promise.resolve()
    })
    ->Promise.thenResolve(_ => notify("Successfully restored accounts!"))
    ->Promise.catch(exn => {
      notify("Failed to restore accounts. " ++ exn->Helpers.getMessage)
      Promise.resolve()
    })
  )
}

let useRestoreAndSave = () => {
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()
  let notify = SnackBar.useNotification()
  let updateKeychain = Biometrics.useKeychainStorage()
  restoreAndSave(
    ~onAccountsReady=accounts => ReplaceAll(accounts)->dispatch,
    ~notify,
    ~updateKeychain,
  )
}
