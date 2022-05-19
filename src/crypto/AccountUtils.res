let generateAccount = (~mnemonic, ~passphrase, ~derivationPathIndex=0, ~name=?, ()) => {
  CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ~derivationPathIndex, ())->Promise.then(sk => {
    TaquitoUtils.getTz1(~sk, ~passphrase)->Promise.thenResolve(tz1 => {
      let account: Account.t = {
        name: name->Belt.Option.getWithDefault("Account " ++ Js.Int.toString(derivationPathIndex)),
        tz1: tz1,
        sk: sk,
        derivationPathIndex: derivationPathIndex,
        balance: None,
        tokens: [],
      }

      account
    })
  })
}

let checkExists = tz1 => {
  let url = `https://ithacanet.umamiwallet.com/accounts/${tz1}/exists`
  Fetch.fetch(url)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeBoolean)
  ->Promise.thenResolve(Belt.Option.getExn)
}

let backupPhraseIsValid = s => s->Js.String2.splitByRe(%re("/\s+/"))->Array.length == 24

let rec _restoreAccounts = (~mnemonic, ~passphrase, ~accounts=[], ~onDone, ()) => {
  let derivationPathIndex = accounts->Array.length

  generateAccount(~mnemonic, ~passphrase, ~derivationPathIndex, ())
  ->Promise.then(account => {
    checkExists(account.tz1)->Promise.thenResolve(exists => {
      if exists {
        _restoreAccounts(
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

let restoreAccounts = (~mnemonic, ~passphrase, ~accounts=[], ~onDone, ()) => {
  assert backupPhraseIsValid(mnemonic)
  _restoreAccounts(~mnemonic, ~passphrase, ~accounts, ~onDone, ())
}

let restore = (~mnemonic, ~passphrase) => {
  Promise.make((resolve, reject) => {
    restoreAccounts(
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
