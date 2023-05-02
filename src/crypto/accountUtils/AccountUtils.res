let getTz1AndPk = (~sk, ~password) =>
  Promise.all2((TaquitoUtils.getTz1(~sk, ~password), TaquitoUtils.getPk(~sk, ~password)))

let generateKeys = (~mnemonic, ~password, ~derivationPathIndex=0, ()) =>
  CryptoUtils.mnemonicToSK(~mnemonic, ~password, ~derivationPathIndex, ())->Promise.then(sk =>
    getTz1AndPk(~sk, ~password)->Promise.thenResolve(((tz1, pk)) => {
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
  let checkExists = TzktAPI.checkExistsAllNetworks
})
