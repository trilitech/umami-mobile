type keys = {
  derivationPathIndex: int,
  pk: string,
  sk: string,
  tz1: Pkh.t,
}
module type Deps = {
  let generateKeys: (
    ~mnemonic: string,
    ~password: string,
    ~derivationPathIndex: int=?,
    unit,
  ) => Promise.t<keys>

  let checkExists: (~tz1: Pkh.t) => Promise.t<bool>
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
    ~password,
    ~derivationPathIndex=0,
    ~name: option<string>=?,
    (),
  ) =>
    generateKeys(~mnemonic, ~password, ~derivationPathIndex, ())->Promise.thenResolve(keys => {
      let nameXf =
        name->Belt.Option.mapWithDefault(
          i => i,
          (name, account) => Account.changeName(account, name),
        )

      keys->keysToAccount->nameXf
    })

  let backupPhraseIsValid = s => s->Js.String2.splitByRe(%re("/\s+/"))->Array.length == 24

  %%private(
    let rec _restoreKeys = (~mnemonic, ~password, ~accounts=[], ~onDone, ()) => {
      let derivationPathIndex = accounts->Array.length

      generateKeys(~mnemonic, ~password, ~derivationPathIndex, ())
      ->Promise.then(account => {
        checkExists(~tz1=account.tz1)->Promise.thenResolve(exists => {
          if exists {
            _restoreKeys(
              ~mnemonic,
              ~password,
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
    let restoreKeys = (~mnemonic, ~password, ~accounts=[], ~onDone, ()) =>
      _restoreKeys(~mnemonic, ~password, ~accounts, ~onDone, ())
  )

  let restoreKeysPromise = (~mnemonic, ~password) =>
    Promise.make((resolve, reject) => {
      restoreKeys(
        ~mnemonic,
        ~password,
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
