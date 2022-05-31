@module("./sendToken")
external sendTokenBinding: (
  Taquito.Toolkit.toolkit,
  string,
  string,
  int,
  string,
  string,
) => Promise.t<'a> = "default"

let sendToken = (~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1) => {
  sendTokenBinding(tezos, contractAddress, tokenId, amount, senderTz1, recipientTz1)
}

let tezNodeURL = "https://ithacanet.smartpy.io/"

let _getBalance = tz1 => {
  let tezos = Taquito.create(tezNodeURL)
  let res = tezos.tz->Taquito.Toolkit.getBalance(tz1)
  res->Promise.thenResolve(val => Js.Json.stringify(val)->Js.String2.slice(~from=1, ~to_=-1))
}

let getBalance = tz1 =>
  _getBalance(tz1)
  ->Promise.thenResolve(b => Belt.Int.fromString(b))
  ->Promise.then(b => {
    Promise.make((resolve, reject) => {
      switch b {
      | Some(b) => resolve(. b)
      | None => reject(. "Failed to parse balance")
      }
    })
  })

let sendTez = (~recipient, ~amount, ~passphrase, ~sk) => {
  let tezos = Taquito.create(tezNodeURL)
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
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
  let tezos = Taquito.create(tezNodeURL)

  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    sendToken(~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1)
  })
}

let getTz1 = (~sk, ~passphrase) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => signer->Taquito.publicKeyHash())
}
