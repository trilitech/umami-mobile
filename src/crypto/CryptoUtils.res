let passphrase = "totokoko"
let mnemonic = "neck damage distance eternal prison kit episode regular regret coyote summer loud page capable collect fall chase absorb clap output jazz news pink magnet"

let mnemonicToSK = (~mnemonic, ~derivationPathIndex=0, ~passphrase, ()) => {
  let m = mnemonic
  let index = derivationPathIndex->Belt.Int.toString
  let derivationPath = `m/44'/1729'/${index}'/0'`

  let seed = Bip39.seed(m)
  let seedHex = seed->Buffer.toString("hex")

  let secretKey = ED25519.derivePath(derivationPath, seedHex)["key"]

  // This is very slow
  EncryptSK.encryptSK(secretKey, passphrase)
}

let getTz1 = (~sk, ~passphrase) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => signer->Taquito.publicKeyHash())
}
