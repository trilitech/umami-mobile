@module("./sendNft")
external sendNftBinding: (
  Taquito.Toolkit.toolkit,
  string,
  string,
  int,
  string,
  string,
) => Promise.t<'a> = "default"

let sendNft = (~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1) => {
  sendNftBinding(tezos, contractAddress, tokenId, amount, senderTz1, recipientTz1)
}

let tezNodeURL = "https://ithacanet.smartpy.io/"

let tezos = Taquito.create(tezNodeURL)

let getBalance = tz1 => {
  let res = tezos.tz->Taquito.Toolkit.getBalance(tz1)
  res->Promise.thenResolve(val => Js.Json.stringify(val)->Js.String2.slice(~from=1, ~to_=-1))
}

external unsafeParse: Js.Json.t => Token.t = "%identity"

let getTokens = tz1 => {
  Fetch.fetch("https://api.ithacanet.tzkt.io/v1/tokens/balances/?account=" ++ tz1)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeParse))
}

let safeGetBalance = tz1 =>
  getBalance(tz1)
  ->Promise.thenResolve(b => Belt.Int.fromString(b))
  ->Promise.then(b => {
    Promise.make((resolve, reject) => {
      switch b {
      | Some(b) => resolve(. b)
      | None => reject(. "Failed to parse balance")
      }
    })
  })

let send = (~recipient, ~amount, ~passphrase, ~sk) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    // TODO clear provider ?
    tezos.contract->Taquito.Toolkit.transfer({"to": recipient, "amount": amount})
  })
}

let signAndSendToken = (
  ~passphrase,
  ~sk,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1,
  ~recipientTz1,
) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})

    // TODO clear provider ?
    sendNft(~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1)
  })
}

let getTz1 = (~sk, ~passphrase) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => signer->Taquito.publicKeyHash())
}
