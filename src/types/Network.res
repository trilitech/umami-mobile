type t = Ithacanet | Mainnet

let toString = s =>
  switch s {
  | Ithacanet => "ithacanet"
  | Mainnet => "mainnet"
  }
