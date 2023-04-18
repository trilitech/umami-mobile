type contractData = {
  amount: int,
  tokenId: string,
  contract: string,
}

type amount = Tez(int) | Contract(contractData)

type t = {
  src: Pkh.t,
  hash: option<string>,
  destination: Pkh.t,
  level: int,
  timestamp: string,
  amount: amount,
  kind: string,
  blockHash: option<string>,
}

module JSON = {
  type addressData = {
    alias: option<string>,
    address: string,
  }

  module Tez = {
    type t = {
      hash: string,
      status: string,
      level: int,
      sender: addressData,
      target: addressData,
      block: option<string>,
      timestamp: string,
      bakerFee: int,
      gasLimit: int,
      storageLimit: int,
      amount: int,
    }
  }

  module Token = {
    type tokenData = {
      contract: addressData,
      tokenId: string,
      standard: string // fa1.2 or fa2
    }

    type t = {
      level: int,
      from: option<addressData>,
      token: tokenData,
      to: addressData,
      block: option<string>,
      timestamp: string,
      amount: string,
    }
  }
}

let parseTokenTransactionJSON = (transaction: JSON.Token.t): t => {
  let src = transaction.from->Belt.Option.getWithDefault(transaction.token.contract)
  {
    kind: "transaction",
    src: src.address->Pkh.unsafeBuild,
    destination: transaction.to.address->Pkh.unsafeBuild,
    level: transaction.level,
    timestamp: transaction.timestamp,
    amount: Contract({
        amount: transaction.amount->Belt.Int.fromString->Belt.Option.getExn,
        tokenId: transaction.token.tokenId,
        contract: transaction.token.contract.address,
    }),
    hash: None,
    blockHash: None
  }
}

let parseTezTransactionJSON = (transaction: JSON.Tez.t): t => {
  {
    kind: "transaction",
    src: transaction.sender.address->Pkh.unsafeBuild,
    destination: transaction.target.address->Pkh.unsafeBuild,
    level: transaction.level,
    timestamp: transaction.timestamp,
    amount: Tez(transaction.amount),
    hash: Some(transaction.hash),
    blockHash: transaction.block
  }
}
