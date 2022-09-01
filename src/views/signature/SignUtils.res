type signedData = {
  pk: string,
  content: string,
  sig: string,
}

let checkIsValid = signed => {
  Taquito.verifySignature(
    ~content=UnitArrayUtils.toUnitArrayStringRep(signed.content),
    ~pk=signed.pk,
    ~sig=signed.sig,
  )
}

@scope("JSON") @val
external serialise: signedData => string = "stringify"

@scope("JSON") @val
external deSerialise: string => signedData = "parse"
