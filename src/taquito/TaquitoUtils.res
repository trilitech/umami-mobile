let tezNodeURL = "https://ithacanet.smartpy.io/"

// let tezAddress = "tz1Mqnm1ekENKNwTSqPfz3FVUYGggoZaQJv1"

// let pk = "edesk1tgmm4Zyqv8mUCSf7SicgoQhqDRqd9DDK7nBmTuqgiqK6FYUdQLiytS78FeFnkRtiTJK1T4Mepbbu1Egk9z"
// let passphrase = "12345678"

let tezos = Taquito.create(tezNodeURL)

let getBalance = tz1 => {
  let res = tezos.tz->Taquito.Toolkit.getBalance(tz1)
  res->Promise.thenResolve(val => Js.Json.stringify(val)->Js.String2.slice(~from=1, ~to_=-1))
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
    tezos.contract->Taquito.Toolkit.transfer({"to": recipient, "amount": amount})
  })
}
