open SendTypes

let simulate = (~trans, ~senderTz1, ~senderPk) => {
  let {recipient, prettyAmount, assetType} = trans

  let estimate = TaquitoUtils.estimateSendToken(
    ~recipientTz1=trans.recipient,
    ~senderTz1,
    ~senderPk,
  )
  switch assetType {
  | CurrencyAsset(currency) =>
    switch currency {
    | CurrencyTez =>
      TaquitoUtils.estimateSendTez(~amount=prettyAmount, ~recipient, ~senderTz1, ~senderPk)
    | CurrencyToken(b, decimals) =>
      estimate(
        ~contractAddress=b.contract,
        ~tokenId=b.tokenId,
        ~amount=Token.toRaw(prettyAmount, decimals),
        ~isFa1=b.symbol == SendInputs.fa1Symbol, // :(
        (),
      )
    }
  | NftAsset(b, _) =>
    estimate(
      ~contractAddress=b.contract,
      ~tokenId=b.tokenId,
      ~amount=Token.toRaw(prettyAmount, 0),
      (),
    )
  }
}

let send = (~trans, ~senderTz1, ~sk, ~passphrase) => {
  let {recipient, prettyAmount, assetType} = trans

  let sendToken = TaquitoUtils.sendToken(~passphrase, ~sk, ~senderTz1, ~recipientTz1=recipient)

  switch assetType {
  | CurrencyAsset(currency) =>
    switch currency {
    | CurrencyTez => TaquitoUtils.sendTez(~recipient, ~amount=prettyAmount, ~passphrase, ~sk)
    | CurrencyToken(b, decimals) =>
      sendToken(
        ~contractAddress=b.contract,
        ~tokenId=b.tokenId,
        ~amount=Token.toRaw(prettyAmount, decimals),
        (),
      )
    }
  | NftAsset(b, _) =>
    sendToken(
      ~contractAddress=b.contract,
      ~tokenId=b.tokenId,
      ~amount=Token.toRaw(prettyAmount, 0),
      (),
    )
  }
}
