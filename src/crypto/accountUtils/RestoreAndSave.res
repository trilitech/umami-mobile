open Belt

let restoreAndSave = (~seedPhrase, ~password, ~notify, ~onAccountsReady, ~derivationPath, ()) => {
  DerivationPath.save(derivationPath)->Promise.then(() =>
    BackupPhraseStorage.save(seedPhrase, password)
    ->Promise.then(_ => AccountUtils.restoreKeysPromise(~mnemonic=seedPhrase, ~password))
    ->Promise.thenResolve(keys => {
      let accounts: array<Account.t> = keys->Array.map(AccountUtils.keysToAccount)
      if accounts == [] {
        Js.Exn.raiseError("No accounts revealed for this secret...")
      } else {
        AESCrypto.encrypt(seedPhrase, password)->Promise.thenResolve(_ => onAccountsReady(accounts))
      }
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
  restoreAndSave(~onAccountsReady=accounts => ReplaceAll(accounts)->dispatch, ~notify)
}
