@module("./js/makeContract")
external makeFA1Contract: (
  ~toolkit: Taquito.Toolkit.toolkit,
  ~contractAddress: string,
  ~amount: int,
  ~senderTz1: string,
  ~recipientTz1: string,
) => Promise.t<Taquito.Contract.transfer> = "makeFA1Contract"

type methodArg

external buildMethodArg: 'a => methodArg = "%identity"

@module("./js/makeContract")
external makeContract: (
  ~toolkit: Taquito.Toolkit.toolkit,
  ~contractAddress: string,
  ~method: string,
  ~params: methodArg,
) => Promise.t<Taquito.Contract.transfer> = "makeContract"

@module("./js/getMetadata")
external _getMetadata: (
  ~toolkit: Taquito.Toolkit.toolkit,
  ~contractAddress: string,
  ~tokenId: string,
) => Promise.t<'a> = "getMetadata"

let makeContractTokenTransfer = (
  ~tezos,
  ~contractAddress,
  ~tokenId,
  ~amount,
  ~senderTz1: Pkh.t,
  ~recipientTz1: Pkh.t,
  ~isFa1=false,
  (),
) => {
  if isFa1 {
    makeFA1Contract(
      ~toolkit=tezos,
      ~contractAddress,
      ~amount,
      ~senderTz1=senderTz1->Pkh.toString,
      ~recipientTz1=recipientTz1->Pkh.toString,
    )
  } else {
    let transfer_params = [
      {
        "from_": senderTz1,
        "txs": [
          {
            "to_": recipientTz1,
            "token_id": tokenId,
            "amount": amount,
          },
        ],
      },
    ]->buildMethodArg

    makeContract(~toolkit=tezos, ~contractAddress, ~method="transfer", ~params=transfer_params)
  }
}

let _makeToolkit = (~network, ~nodeIndex) =>
  Taquito.create("https://" ++ Endpoints.getNodeUrl(network, nodeIndex))

let getMetadata = (~network, ~nodeIndex, ~contractAddress: string, ~tokenId: string) => {
  let toolkit = _makeToolkit(~network, ~nodeIndex)
  _getMetadata(~toolkit, ~contractAddress, ~tokenId)
}

let makeToolkitWithSigner = (~network, ~nodeIndex, ~sk, ~password) => {
  let tezos = _makeToolkit(~network, ~nodeIndex)

  Taquito.fromSecretKey(sk, password)->Promise.thenResolve(signer => {
    tezos->Taquito.Toolkit.setProvider({"signer": signer})
    tezos
  })
}

let makeToolkitWithDummySigner = (~network, ~nodeIndex, ~pk, ~pkh) => {
  let tezos = _makeToolkit(~network, ~nodeIndex)

  tezos->Taquito.Toolkit.setProvider({
    "signer": Taquito.createDummySigner(~pk=pk->Pk.toString, ~pkh=pkh->Pkh.toString),
  })
  tezos
}
exception BalanceFetchFailure(string)

let getBalance = (~tz1, ~network, ~nodeIndex) => {
  let _getBalance = (~tz1: Pkh.t, ~network, ~nodeIndex) => {
    open Taquito.Toolkit
    let tezos = _makeToolkit(~network, ~nodeIndex)
    tezos.tz
    ->Taquito.Toolkit.getBalance(Pkh.toString(tz1))
    ->Promise.thenResolve(val => Js.Json.stringify(val)->Js.String2.slice(~from=1, ~to_=-1))
  }

  _getBalance(~tz1, ~network, ~nodeIndex)
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
}

// Tez and Beacon requests that usually contain params

let estimateSendTez = (
  ~amount,
  ~recipient: Pkh.t,
  ~senderTz1: Pkh.t,
  ~senderPk: Pk.t,
  ~network: Network.t,
  ~nodeIndex: int,
  ~parameter=None,
  ~storagelimit=None,
  ~fee=None,
  ~mutez=false,
  (),
) => {
  let tezos = makeToolkitWithDummySigner(~network, ~nodeIndex, ~pk=senderPk, ~pkh=senderTz1)

  tezos.estimate->Taquito.Toolkit.estimateTransfer({
    "to": recipient,
    "amount": amount,
    "parameter": parameter,
    "storagelimit": storagelimit,
    "fee": fee,
    "mutez": mutez,
  })
}

let sendTez = (
  ~recipient,
  ~amount,
  ~password,
  ~sk,
  ~network,
  ~nodeIndex,
  ~parameter=None,
  ~storageLimit=None,
  ~fee=None,
  ~mutez=false,
  (),
) =>
  makeToolkitWithSigner(~network, ~nodeIndex, ~sk, ~password)->Promise.then(tezos =>
    tezos.contract->Taquito.Toolkit.transfer({
      "to": recipient,
      "amount": amount,
      "parameter": parameter,
      "storageLimit": storageLimit,
      "fee": fee,
      "mutez": mutez,
    })
  )

// Tokens

let estimateSendToken = (
  ~amount,
  ~contractAddress,
  ~tokenId,
  ~senderTz1: Pkh.t,
  ~senderPk: Pk.t,
  ~recipientTz1: Pkh.t,
  ~isFa1=false,
  ~network: Network.t,
  ~nodeIndex: int,
  (),
) => {
  let tezos = makeToolkitWithDummySigner(~network, ~nodeIndex, ~pk=senderPk, ~pkh=senderTz1)

  let transfer = makeContractTokenTransfer(
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
  ~nodeIndex: int,
  (),
) => {
  makeToolkitWithSigner(~network, ~nodeIndex, ~password, ~sk)->Promise.then(tezos =>
    makeContractTokenTransfer(
      ~tezos,
      ~contractAddress,
      ~tokenId,
      ~amount,
      ~senderTz1,
      ~recipientTz1,
      ~isFa1,
      (),
    )->Promise.then(t => t->Taquito.Contract.send())
  )
}

// Contracts
// Finally not used as we do Beacon requests with sendTez

// let estimateContractTransaction = (
//   ~contractAddress: string,
//   ~method: string,
//   ~params: methodArg,
//   ~network,
//   ~nodeIndex,
//   ~senderPk,
//   ~senderTz1,
//   (),
// ) => {
//   let tezos = makeToolkitWithDummySigner(~network, ~nodeIndex, ~pk=senderPk, ~pkh=senderTz1)

//   makeContract(~toolkit=tezos, ~contractAddress, ~method, ~params)->Promise.then(t => {
//     let params = t->Taquito.Contract.toTransferParams()

//     tezos.estimate->Taquito.Toolkit.estimateTransfer(params)
//   })
// }

// let executContractTransaction = (
//   ~contractAddress: string,
//   ~method: string,
//   ~params: methodArg,
//   ~network,
//   ~nodeIndex,
//   ~password,
//   ~sk,
// ) => {
//   makeToolkitWithSigner(~network, ~nodeIndex, ~password, ~sk)
//   ->Promise.then(tezos => makeContract(~toolkit=tezos, ~contractAddress, ~method, ~params))
//   ->Promise.then(t => t->Taquito.Contract.send())
// }

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
