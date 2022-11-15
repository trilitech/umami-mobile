let getTezosNode = (n: Network.t) => {
  switch n {
  | Mainnet => "mainnet.smartpy.io"
  | Ghostnet => "ghostnet.ecadinfra.com"
  }
}

let getUmamiWalletHost = (n: Network.t) => {
  switch n {
  | Mainnet => "mainnet.umamiwallet.com"
  | Ghostnet => "ghostnet.umamiwallet.com"
  }
}

let getTzktEndpoint = (n: Network.t) => {
  switch n {
  | Mainnet => "api.mainnet.tzkt.io"
  | Ghostnet => "ghostnet.umamiwallet.com"
  }
}
