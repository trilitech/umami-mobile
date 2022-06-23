open SendTypes

let simulate = (~recipientTz1, ~prettyAmount, ~assetType, ~senderTz1, ~senderPk, ~isTestNet) => {
  let estimate = TaquitoUtils.estimateSendToken(~recipientTz1, ~senderTz1, ~senderPk)
  switch assetType {
  | CurrencyAsset(currency) =>
    switch currency {
    | CurrencyTez =>
      TaquitoUtils.estimateSendTez(
        ~amount=prettyAmount,
        ~recipient=recipientTz1,
        ~senderTz1,
        ~senderPk,
        ~isTestNet,
      )
    | CurrencyToken(b, decimals) =>
      estimate(
        ~contractAddress=b.contract,
        ~tokenId=b.tokenId,
        ~amount=Token.toRaw(prettyAmount, decimals),
        ~isFa1=b.symbol == SendInputs.fa1Symbol, // :(
        ~isTestNet,
        (),
      )
    }
  | NftAsset(b, _) =>
    estimate(
      ~contractAddress=b.contract,
      ~tokenId=b.tokenId,
      ~amount=Token.toRaw(prettyAmount, 0),
      ~isTestNet,
      (),
    )
  }
}

let send = (~prettyAmount, ~recipientTz1, ~assetType, ~senderTz1, ~sk, ~passphrase, ~isTestNet) => {
  let sendToken = TaquitoUtils.sendToken(~passphrase, ~sk, ~senderTz1, ~recipientTz1)

  switch assetType {
  | CurrencyAsset(currency) =>
    switch currency {
    | CurrencyTez =>
      TaquitoUtils.sendTez(
        ~recipient=recipientTz1,
        ~amount=prettyAmount,
        ~passphrase,
        ~sk,
        ~isTestNet,
      )
    | CurrencyToken(b, decimals) =>
      sendToken(
        ~contractAddress=b.contract,
        ~tokenId=b.tokenId,
        ~amount=Token.toRaw(prettyAmount, decimals),
        ~isTestNet,
        (),
      )
    }
  | NftAsset(b, _) =>
    sendToken(
      ~contractAddress=b.contract,
      ~tokenId=b.tokenId,
      ~amount=Token.toRaw(prettyAmount, 0),
      ~isTestNet,
      (),
    )
  }
}