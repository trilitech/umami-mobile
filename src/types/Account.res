type t = {
  name: string,
  tz1: Pkh.t,
  pk: Pk.t,
  sk: string,
  derivationPathIndex: int,
}

let changeName = (a, name) => {...a, name: name}

let make = (~tz1, ~pk, ~sk, ~derivationPathIndex, ~name=?, ()) => {
  derivationPathIndex: derivationPathIndex,
  pk: pk,
  sk: sk,
  tz1: tz1,
  name: name->Belt.Option.getWithDefault("Account " ++ Js.Int.toString(derivationPathIndex)),
}
