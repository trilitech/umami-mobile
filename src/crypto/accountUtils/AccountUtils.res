let getTz1AndPk = (~sk, ~passphrase) =>
  Promise.all2((TaquitoUtils.getTz1(~sk, ~passphrase), TaquitoUtils.getPk(~sk, ~passphrase)))

let generateKeys = (~mnemonic, ~passphrase, ~derivationPathIndex=0, ()) =>
  CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ~derivationPathIndex, ())->Promise.then(sk =>
    getTz1AndPk(~sk, ~passphrase)->Promise.thenResolve(((tz1, pk)) => {
      let result: PureAccountUtils.keys = {
        derivationPathIndex: derivationPathIndex,
        pk: pk,
        sk: sk,
        tz1: tz1,
      }
      result
    })
  )

include PureAccountUtils.Make({
  let generateKeys = generateKeys
  let checkExists = MezosAPI.checkExistsAllNetworks
})
