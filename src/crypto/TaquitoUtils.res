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
  ~senderTz1: Pkh.t,
  ~recipientTz1: Pkh.t,
  ~isFa1=false,
  (),
) =>
  _makeContractTransferBinding(
    tezos,
    contractAddress,
    tokenId,
    amount,
    senderTz1->Pkh.toString,
    recipientTz1->Pkh.toString,
    isFa1,
  )

let _sendToken = (
  ~tezos,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1: Pkh.t,
  ~recipientTz1: Pkh.t,
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

let _makeToolkit = (~network) => Taquito.create("https://" ++ Endpoints.getTezosNode(network))

let _getBalance = (~tz1: Pkh.t, ~network) => {
  let tezos = _makeToolkit(~network)
  let res = tezos.tz->Taquito.Toolkit.getBalance(Pkh.toString(tz1))
  res->Promise.thenResolve(val => Js.Json.stringify(val)->Js.String2.slice(~from=1, ~to_=-1))
}

exception BalanceFetchFailure(string)

let getBalance = (~tz1, ~network) =>
  _getBalance(~tz1, ~network)
  ->Promise.thenResolve(b => Belt.Int.fromString(b))
  ->Promise.then(b => {
    Promise.make((resolve, reject) => {
      switch b {
      | Some(b) => resolve(. b)
      | None => reject(. "Failed to parse balance")
      }
    })
  })
  ->Promise.catch(err => Promise.reject(BalanceFetchFailure(Helpers.getMessage(err))))

let sendTez = (~recipient, ~amount, ~password, ~sk, ~network) => {
  let tezos = _makeToolkit(~network)
  Taquito.fromSecretKey(sk, password)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    tezos.contract->Taquito.Toolkit.transfer({"to": recipient, "amount": amount})
  })
}

let estimateSendTez = (
  ~amount,
  ~recipient: Pkh.t,
  ~senderTz1: Pkh.t,
  ~senderPk: Pk.t,
  ~network: Network.t,
) => {
  let tezos = _makeToolkit(~network)
  tezos->Taquito.Toolkit.setProvider({
    "signer": Taquito.createDummySigner(~pk=senderPk->Pk.toString, ~pkh=senderTz1->Pkh.toString),
  })

  tezos.estimate->Taquito.Toolkit.estimateTransfer({"to": recipient, "amount": amount})
}

let estimateSendToken = (
  ~amount,
  ~contractAddress,
  ~tokenId,
  ~senderTz1: Pkh.t,
  ~senderPk: Pk.t,
  ~recipientTz1: Pkh.t,
  ~isFa1=false,
  ~network: Network.t,
  (),
) => {
  let tezos = _makeToolkit(~network)
  tezos->Taquito.Toolkit.setProvider({
    "signer": Taquito.createDummySigner(~pk=senderPk->Pk.toString, ~pkh=senderTz1->Pkh.toString),
  })

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
  ~password,
  ~sk,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1: Pkh.t,
  ~recipientTz1: Pkh.t,
  ~isFa1=false,
  ~network: Network.t,
  (),
) => {
  let tezos = _makeToolkit(~network)

  Taquito.fromSecretKey(sk, password)->Promise.then(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    _sendToken(~tezos, ~contractAddress, ~tokenId, ~amount, ~senderTz1, ~recipientTz1, ~isFa1, ())
  })
}

let getTz1 = (~sk, ~password) =>
  Taquito.fromSecretKey(sk, password)
  ->Promise.then(signer => signer->Taquito.publicKeyHash())
  ->Promise.then(pkhStr =>
    switch Pkh.build(pkhStr) {
    | Ok(pkh) => Promise.resolve(pkh)
    | Error(msg) => Js.Exn.raiseError(msg)
    }
  )

let getPk = (~sk, ~password) =>
  Taquito.fromSecretKey(sk, password)
  ->Promise.then(signer => signer->Taquito.publicKey())
  ->Promise.thenResolve(Pk.unsafeBuild)

let tz1IsValid = address => Taquito.validateAddress(address) == 3
