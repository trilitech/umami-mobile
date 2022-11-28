open Belt
open SignedData

let checkIsValid = (signed: SignedData.t) => {
  Taquito.verifySignature(
    ~content=UnitArrayUtils.toUnitArrayStringRep(signed.content),
    ~pk=signed.pk,
    ~sig=signed.sig,
  )
}

let verifyAndThrowExn = signed =>
  if checkIsValid(signed) {
    signed
  } else {
    Js.Exn.raiseError("Invalid signature")
  }

let signContentGeneric = (~encodedContent: string, ~password: string, ~account: Account.t) => {
  Taquito.fromSecretKey(account.sk, password)->Promise.then(signer =>
    signer->Taquito.sign(encodedContent)
  )
}

let signContent = (~content: string, ~password: string, ~account: Account.t) => {
  let encodedContent = UnitArrayUtils.toUnitArrayStringRep(content)
  signContentGeneric(~encodedContent, ~password, ~account)
  ->Promise.thenResolve(signed => {
    pk: account.pk->Pk.toString,
    content: content,
    sig: signed.sig,
  })
  ->Promise.thenResolve(verifyAndThrowExn)
}

let useSign = () => {
  let (account, _) = Store.useSelectedAccount()
  account->Option.map((account, ~content, ~password) => signContent(~content, ~password, ~account))
}
