// Shim needed for WalletClient to work on RN
%raw(`
require('react-native-get-random-values')
`)

let hydrateBeaconStorage: unit => Promise.t<
  unit,
> = %raw(`require('./rnLocalStoragePolyfill').hydrateLocalStorage`)

let beaconAtom: Jotai.Atom.t<option<ReBeacon.WalletClient.t>, _, _> = Jotai.Atom.make(None)
let peerInfosAtom: Jotai.Atom.t<array<ReBeacon.peerInfo>, _, _> = Jotai.Atom.make([])
let permissionInfosAtom: Jotai.Atom.t<array<ReBeacon.permissionInfo>, _, _> = Jotai.Atom.make([])

let makePeerInfo = (encodedPeerInfo: string) => {
  ReBeacon.Serializer.make()->ReBeacon.Serializer.deserializeRaw(encodedPeerInfo)
}
let useClient = () => {
  let (client, setClient) = Jotai.Atom.use(beaconAtom)

  (client, setClient)
}

let useInit = () => {
  let navigate = NavUtils.useNavigateWithParams()
  let (client, setClient) = useClient()

  React.useEffect3(() => {
    switch client {
    | Some(client) =>
      client->ReBeacon.WalletClient.initRaw()->ignore
      client
      ->ReBeacon.WalletClient.connectRaw(m => {
        navigate(
          "BeaconRequest",
          {
            tz1ForContact: None,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: None,
            beaconRequest: ReBeacon.Message.Request.classify(m)->Some,
          },
        )
      })
      ->Promise.thenResolve(_ => Js.Console.log("Beacon successfully started"))
      ->ignore
    | None => setClient(_ => ReBeacon.WalletClient.make({name: "Umami mobile"})->Some)
    }

    None
  }, (navigate, client, setClient))
}

let usePermissionInfos = client => {
  let (permisionInfos, setPermissionInfos) = Jotai.Atom.use(permissionInfosAtom)

  let refresh = React.useMemo2(() => {
    () => {
      client
      ->ReBeacon.WalletClient.getPermissionsRaw()
      ->Promise.thenResolve(p => setPermissionInfos(_ => p))
    }
  }, (setPermissionInfos, client))

  React.useEffect1(() => {
    refresh()->ignore
    None
  }, [refresh])

  let removePermissionInfo = React.useMemo2(() => {
    id => client->ReBeacon.WalletClient.removePermissionRaw(id)->Promise.then(refresh)
  }, (client, refresh))

  (permisionInfos, refresh, removePermissionInfo)
}

let getExisting = (p: ReBeacon.peerInfo, ps: array<ReBeacon.peerInfo>) =>
  ps->Belt.Array.getBy(peerInfo => peerInfo.name === p.name)

// let removeIfExists = (client, p: ReBeacon.peerInfo) => {
//   client
//   ->ReBeacon.WalletClient.getPeersRaw()
//   ->Promise.thenResolve(peerInfos => {
//     Js.Console.log(peerInfos)
//     Js.Console.log(p)
//     peerInfos->Belt.Array.getBy(peerInfo => peerInfo.name === p.name)->Belt.Option.isSome
//   })
//   ->Promise.then(exists => {
//     Js.Console.log(exists)
//     if exists {
//       client->ReBeacon.WalletClient.removePeerRaw(p)
//     } else {
//       Promise.resolve()
//     }
//   })
// }

let usePeers = client => {
  let (peerInfos, setPeerInfos) = Jotai.Atom.use(peerInfosAtom)
  let (_, refreshPermissions, _) = usePermissionInfos(client)
  // let (permisionInfos, setPermissionInfos) = Jotai.Atom.use(permissionInfosAtom)

  let refresh = React.useMemo2(() => {
    () => {
      client
      ->ReBeacon.WalletClient.getPeersRaw()
      ->Promise.thenResolve(peerInfos => {
        setPeerInfos(_ => peerInfos)
      })
      // ->Promise.then(refreshPermissions)
    }
  }, (setPeerInfos, client))

  React.useEffect1(() => {
    refresh()->ignore
    None
  }, [refresh])

  React.useEffect2(() => {
    refreshPermissions()->ignore
    None
  }, (peerInfos, refreshPermissions))

  let removePeer = React.useMemo2(() => {
    p => client->ReBeacon.WalletClient.removePeerRaw(p)->Promise.then(refresh)
  }, (client, refresh))

  // let addPeer = React.useMemo2(() => {
  //   (encodedPeerInfo: string) => {
  //     makePeerInfo(encodedPeerInfo)
  //     ->Promise.then(p => client->ReBeacon.WalletClient.addPeerRaw(p))
  //     ->Promise.then(refresh)
  //   }
  // }, (client, refresh))

  let addPeer2 = p => client->ReBeacon.WalletClient.addPeerRaw(p)->Promise.then(refresh)

  let _safeAddPeer = (p: ReBeacon.peerInfo) => {
    switch getExisting(p, peerInfos) {
    | Some(p) => removePeer(p)->Promise.then(() => addPeer2(p))
    | None => addPeer2(p)
    }
  }

  let safeAddPeer = (encodedPeerInfo: string) => {
    makePeerInfo(encodedPeerInfo)->Promise.then(_safeAddPeer)
  }

  (peerInfos, removePeer, safeAddPeer)
}

let useRespond = client => {
  let respond = React.useMemo1(() => {
    r => client->ReBeacon.WalletClient.respondRaw(r)
  }, [client])
  respond
}
