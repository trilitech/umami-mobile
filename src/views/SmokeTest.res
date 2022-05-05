let tezNodeURL = "https://ithacanet.smartpy.io/"

let tezos = Taquito.create(tezNodeURL)

let passphrase = "totokoko"
let mnemonic = "neck damage distance eternal prison kit episode regular regret coyote summer loud page capable collect fall chase absorb clap output jazz news pink magnet"

let exec2 = () => {
  CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ())->Promise.thenResolve(sk => {
    Js.Console.log2("sk", sk)

    Taquito.fromSecretKey(sk, passphrase)
    ->Promise.thenResolve(signer => {
      // tezos->Taquito.Toolkit.setProvider({"signer": signer})
      let _foo =
        signer
        ->Taquito.publicKeyHash()
        ->Promise.thenResolve(tz1 => {
          Js.Console.warn(tz1)
        })
    })
    ->ignore
    ()
  })
}

let exec = () => {
  let derivationPath = "m/44'/1729'/0'/0'"

  let seed = Bip39.seed(mnemonic)
  let seedHex = seed->Buffer.toString("hex")

  let secretKey = ED25519.derivePath(derivationPath, seedHex)

  let key = secretKey["key"]
  EncryptSK.encryptSK(key, passphrase)->Promise.thenResolve(sk => {
    Js.Console.log2("foo2", sk)
    Taquito.fromSecretKey(sk, passphrase)
    ->Promise.thenResolve(signer => {
      // tezos->Taquito.Toolkit.setProvider({"signer": signer})
      let _foo =
        signer
        ->Taquito.publicKeyHash()
        ->Promise.thenResolve(tz1 => {
          Js.Console.warn(tz1)
        })
    })
    ->ignore
  })
  // EncryptSK.encryptSK(key, passphrase, sk => {
  //   Taquito.fromSecretKey(sk, passphrase)
  //   ->Promise.thenResolve(signer => {
  //     tezos->Taquito.Toolkit.setProvider({"signer": signer})
  //     signer
  //     ->Taquito.publicKeyHash()
  //     ->Promise.thenResolve(tz1 => {
  //       Js.Console.warn(tz1)
  //     })
  //     ->ignore
  //     //   tezos.contract->Taquito.Toolkit.transfer({"to": tezAddress, "amount": 10})
  //   })
  //   ->ignore
  //   ()
  // })
}
