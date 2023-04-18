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

let getTzktUrl = (n: Network.t) => {
  switch n {
  | Mainnet => "mainnet.tzkt.io"
  | Ghostnet => "ghostnet.tzkt.io"
  }
}
