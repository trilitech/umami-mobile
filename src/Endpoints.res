let mainnetNodes = [
  "mainnet.smartpy.io",
  "api.tez.ie/rpc/mainnet",
  "teznode.letzbake.com",
  "mainnet.tezrpc.me",
  "rpc.tzbeta.net",
]
let ghostNetNodes = ["ghostnet.ecadinfra.com", "ghostnet.smartpy.io"]

let getNodes = (n: Network.t) => {
  switch n {
  | Mainnet => mainnetNodes
  | Ghostnet => ghostNetNodes
  }
}

let getNodeUrl = (n: Network.t, nodeIndex: int) => {
  let nodes = getNodes(n)
  nodes[nodeIndex]
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
  | Ghostnet => "api.ghostnet.tzkt.io"
  }
}
