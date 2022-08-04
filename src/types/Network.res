type t = Ghostnet | Mainnet

let toString = s =>
  switch s {
  | Ghostnet => "ghostnet"
  | Mainnet => "mainnet"
  }
