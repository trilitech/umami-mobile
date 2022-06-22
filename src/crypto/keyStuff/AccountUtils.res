let existsUrl = (server, tz1) => `https://${server}/accounts/${tz1}/exists`

let checkExists = tz1 => {
  let url = existsUrl(Endpoints.umamiWallet.testNet, tz1)
  Fetch.fetch(url)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeBoolean)
  ->Promise.thenResolve(Belt.Option.getExn)
}

let getKeys = (~sk, ~passphrase) =>
  Promise.all2((TaquitoUtils.getTz1(~sk, ~passphrase), TaquitoUtils.getPk(~sk, ~passphrase)))

let generateKeys = (~mnemonic, ~passphrase, ~derivationPathIndex=0, ()) =>
  CryptoUtils.mnemonicToSK(~mnemonic, ~passphrase, ~derivationPathIndex, ())->Promise.then(sk =>
    getKeys(~sk, ~passphrase)->Promise.thenResolve(((tz1, pk)) => {
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
  let checkExists = checkExists
})
