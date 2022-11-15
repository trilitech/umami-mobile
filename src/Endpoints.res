let getNodeUrl = (n: Network.t, nodeIndex: int) => {
  switch n {
  | Mainnet => "mainnet.smartpy.io"
  | Ghostnet => "ghostnet.ecadinfra.com"
  }
}

let getMezosUrl = (n: Network.t) => {
  switch n {
  | Mainnet => "mainnet.umamiwallet.com"
  | Ghostnet => "ghostnet.umamiwallet.com"
  }
}

let getTzktUrl = (n: Network.t) => {
  switch n {
  | Mainnet => "api.mainnet.tzkt.io"
  | Ghostnet => "ghostnet.umamiwallet.com"
  }
}
