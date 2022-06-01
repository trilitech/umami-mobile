@module("./sendToken")
external _makeContractTransferBinding: (
  Taquito.Toolkit.toolkit,
  string,
  string,
  int,
  string,
  string,
  bool,
) => Promise.t<Taquito.Contract.transfer> = "default"

let makeContractTransfer = (
  ~tezos,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1,
  ~recipientTz1,
  ~isFa1=false,
  (),
) =>
  _makeContractTransferBinding(
    tezos,
    contractAddress,
    tokenId,
    amount,
    senderTz1,
    recipientTz1,
    isFa1,
  )

let _sendToken = (
  ~tezos,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1,
  ~recipientTz1,
  ~isFa1=false,
  (),
) => {
  makeContractTransfer(
    ~tezos,
    ~contractAddress,
    ~tokenId,
    ~amount,
    ~senderTz1,
    ~recipientTz1,
    ~isFa1,
    (),
  )->Promise.then(t => t->Taquito.Contract.send())
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

let estimateSendTez = (~recipient, ~amount, ~senderTz1) => {
  let tezos = Taquito.create(tezNodeURL)
  tezos->Taquito.Toolkit.setProvider({"signer": Taquito.createDummySigner(senderTz1)})

  tezos.estimate->Taquito.Toolkit.estimateTransfer({"to": recipient, "amount": amount})
}

let estimateSendToken = (
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1,
  ~recipientTz1,
  ~isFa1,
) => {
  let tezos = Taquito.create(tezNodeURL)
  tezos->Taquito.Toolkit.setProvider({"signer": Taquito.createDummySigner(senderTz1)})

  let transfer = makeContractTransfer(
    ~tezos,
    ~contractAddress,
    ~tokenId,
    ~amount,
    ~senderTz1,
    ~recipientTz1,
    ~isFa1,
    (),
  )

  transfer->Promise.then(t => {
    let params = t->Taquito.Contract.toTransferParams()

    tezos.estimate->Taquito.Toolkit.estimateTransfer(params)
  })
}

let sendToken = (
  ~passphrase,
  ~sk,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1,
  ~recipientTz1,
  ~isFa1=false,
  (),
) => {
  let tezos = Taquito.create(tezNodeURL)

  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    _sendToken(~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1, ~isFa1, ())
  })
}

let getTz1 = (~sk, ~passphrase) => {
  Taquito.fromSecretKey(sk, passphrase)->Promise.then(signer => signer->Taquito.publicKeyHash())
}
