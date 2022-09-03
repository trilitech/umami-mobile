let password = "totokoko"
let mnemonic = "neck damage distance eternal prison kit episode regular regret coyote summer loud page capable collect fall chase absorb clap output jazz news pink magnet"

let _mnemonicToSK = (~mnemonic, ~derivationPath, ~derivationPathIndex=0, ~password) => {
  let m = mnemonic
  let derivationPath = derivationPath->DerivationPath.getByIndex(derivationPathIndex)

  let seed = Bip39.seed(m)
  let seedHex = seed->Buffer.toString("hex")

  let secretKey = ED25519.derivePath(derivationPath, seedHex)["key"]

  EncryptSK.encryptSK(secretKey, password)
}
let mnemonicToSK = (~mnemonic, ~derivationPathIndex=0, ~password, ()) => {
  DerivationPath.load()->Promise.then(derivationPath =>
    _mnemonicToSK(~mnemonic, ~derivationPathIndex, ~password, ~derivationPath)
  )
}
