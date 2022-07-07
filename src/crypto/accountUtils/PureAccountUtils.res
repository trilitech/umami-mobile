type keys = {
  derivationPathIndex: int,
  pk: string,
  sk: string,
  tz1: string,
}
module type Deps = {
  let generateKeys: (
    ~mnemonic: string,
    ~passphrase: string,
    ~derivationPathIndex: int=?,
    unit,
  ) => Promise.t<keys>

  let checkExists: (~tz1: string) => Promise.t<bool>
}
module Make = (M: Deps) => {
  let generateKeys = M.generateKeys
  let checkExists = M.checkExists

  let keysToAccount = k => {
    let {derivationPathIndex, pk, sk, tz1} = k
    Account.make(~derivationPathIndex, ~pk, ~sk, ~tz1, ())
  }

  let generateAccount = (
    ~mnemonic,
    ~passphrase,
    ~derivationPathIndex=0,
    ~name: option<string>=?,
    (),
  ) =>
    generateKeys(~mnemonic, ~passphrase, ~derivationPathIndex, ())->Promise.thenResolve(keys => {
      let nameXf =
        name->Belt.Option.mapWithDefault(
          i => i,
          (name, account) => Account.changeName(account, name),
        )

      keys->keysToAccount->nameXf
    })

  let backupPhraseIsValid = s => s->Js.String2.splitByRe(%re("/\s+/"))->Array.length == 24

  let rec _restoreKeys = (~mnemonic, ~passphrase, ~accounts=[], ~onDone, ()) => {
    let derivationPathIndex = accounts->Array.length

    generateKeys(~mnemonic, ~passphrase, ~derivationPathIndex, ())
    ->Promise.then(account => {
      checkExists(~tz1=account.tz1)->Promise.thenResolve(exists => {
        if exists {
          _restoreKeys(
            ~mnemonic,
            ~passphrase,
            ~accounts=Belt.Array.concat(accounts, [account]),
            ~onDone,
            (),
          )
          ()
        } else {
          onDone(Ok(accounts))
          ()
        }
      })
    })
    ->Promise.catch(error => {
      onDone(Error(error))->Promise.resolve
    })
    ->ignore
  }

  let restoreKeys = (~mnemonic, ~passphrase, ~accounts=[], ~onDone, ()) => {
    assert backupPhraseIsValid(mnemonic)
    // TODO investigate how to handle this error
    _restoreKeys(~mnemonic, ~passphrase, ~accounts, ~onDone, ())
  }

  let restore = (~mnemonic, ~passphrase) =>
    Promise.make((resolve, reject) => {
      restoreKeys(
        ~mnemonic,
        ~passphrase,
        ~onDone=res => {
          switch res {
          | Ok(accounts) => resolve(. accounts)
          | Error(error) => reject(. error)
          }
        },
        (),
      )
      ()
    })
}
