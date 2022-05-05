let generateAccount = (~mnemonic, ~passphrase, ~derivationPathIndex=0, ~name=?, ()) => {
  CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ~derivationPathIndex, ())->Promise.then(sk => {
    CryptoUtils.getTz1(~sk, ~passphrase)->Promise.thenResolve(tz1 => {
      let account: Store.account = {
        name: name->Belt.Option.getWithDefault("Account " ++ Js.Int.toString(derivationPathIndex)),
        tz1: tz1,
        sk: sk,
        derivationPathIndex: derivationPathIndex,
        balance: None,
      }

      account
    })
  })
}
