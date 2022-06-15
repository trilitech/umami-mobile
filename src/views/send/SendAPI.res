open SendTypes

let _makeTokenEstimate = (~base: Token.tokenBase, ~senderTz1, ~recipientTz1, ~isFa1=false, ()) => {
  TaquitoUtils.estimateSendToken(
    ~contractAddress=base.contract,
    ~tokenId=base.tokenId,
    ~amount=base.balance,
    ~senderTz1,
    ~recipientTz1,
    ~isFa1,
  )
}

let simulate = (~trans, ~senderTz1, ~senderPk) =>
  switch trans.asset {
  | Tez(amount) =>
    TaquitoUtils.estimateSendTez(~amount, ~recipient=trans.recipient, ~senderTz1, ~senderPk)
  | Token(t) =>
    let estimate = _makeTokenEstimate(~recipientTz1=trans.recipient, ~senderTz1, ~senderPk)
    switch t {
    | NFT((base, _))
    | FA2(base, _) =>
      estimate(~base, ())
    | FA1(base) => estimate(~base, ~isFa1=true, ())
    }
  }

let _makeSendToken = (
  ~base: Token.tokenBase,
  ~amount,
  ~isFa1=false,
  ~passphrase,
  ~sk,
  ~senderTz1,
  ~recipientTz1,
  (),
) => {
  TaquitoUtils.sendToken(
    ~passphrase,
    ~sk,
    ~contractAddress=base.contract,
    ~amount,
    ~recipientTz1,
    ~tokenId=base.tokenId,
    ~senderTz1,
    ~isFa1,
    (),
  )
}

let send = (~trans, ~senderTz1, ~sk, ~passphrase) => {
  let {recipient, asset} = trans
  let send = switch asset {
  // No need to ajust tez amount
  | Tez(amount) => TaquitoUtils.sendTez(~recipient, ~amount, ~passphrase, ~sk)
  | Token(t) =>
    let sendToken = _makeSendToken(~passphrase, ~sk, ~senderTz1, ~recipientTz1=recipient)
    switch t {
    | NFT((base, _)) => sendToken(~base, ~amount=1, ())
    | FA1(base) =>
      sendToken(
        ~base,
        ~amount=Token.toRaw(base.balance, Constants.fa1CurrencyDecimal),
        ~isFa1=true,
        (),
      )
    | FA2(base, m) => sendToken(~base, ~amount=Token.toRaw(base.balance, m.decimals), ())
    }
  }
  send
}
