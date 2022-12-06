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

let makePeerInfo = (encodedPeerInfo: string) =>
  ReBeacon.Serializer.make()->ReBeacon.Serializer.deserializeRaw(encodedPeerInfo)

let useClient = () => Jotai.Atom.use(beaconAtom)

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

%%private(
  let usePermissionInfos = client => {
    let (permisionInfos, setPermissionInfos) = Jotai.Atom.use(permissionInfosAtom)

    let refresh = React.useMemo2(() => {
      () =>
        client
        ->ReBeacon.WalletClient.getPermissionsRaw()
        ->Promise.thenResolve(p => setPermissionInfos(_ => p))
    }, (setPermissionInfos, client))

    // React.useEffect1(() => {
    //   refresh()->ignore
    //   None
    // }, [refresh])

    // Not needed at the moment
    // let removePermissionInfo = React.useMemo2(() => {
    //   id => client->ReBeacon.WalletClient.removePermissionRaw(id)->Promise.then(refresh)
    // }, (client, refresh))

    (permisionInfos, refresh)
  }
)

let useRespond = client => {
  let (_, refreshPermissions) = usePermissionInfos(client)
  let respond = React.useMemo1(() => {
    r => {
      client
      ->ReBeacon.WalletClient.respondRaw(r)
      ->Promise.then(() =>
        switch r {
        | #PermissionResponse(_) => refreshPermissions()
        | _ => Promise.resolve()
        }
      )
    }
  }, [client])
  respond
}

let _getExisting = (p: ReBeacon.peerInfo, ps: array<ReBeacon.peerInfo>) =>
  ps->Belt.Array.getBy(peerInfo => peerInfo.name === p.name)

let usePeers = (client, ~onError=_ => (), ()) => {
  let (peerInfos, setPeerInfos) = Jotai.Atom.use(peerInfosAtom)
  let (permisionInfos, refreshPermissions) = usePermissionInfos(client)

  let refresh = React.useMemo2(() => {
    () => {
      client
      ->ReBeacon.WalletClient.getPeersRaw()
      ->Promise.thenResolve(peerInfos => setPeerInfos(_ => peerInfos))
    }
  }, (setPeerInfos, client))

  React.useEffect2(() => {
    refreshPermissions()->ignore
    None
  }, (peerInfos, refreshPermissions))

  React.useEffect1(() => {
    refresh()->ignore
    None
  }, [refresh])

  let removePeer = React.useMemo2(() => {
    p => {
      client
      ->ReBeacon.WalletClient.removePeerRaw(p)
      ->Promise.then(refresh)
      ->Promise.catch(exn => {
        `Failed to remove peer. Reason: ${exn->Helpers.getMessage}`->onError
        Promise.resolve()
      })
    }
  }, (client, refresh))

  let addPeer = p => client->ReBeacon.WalletClient.addPeerRaw(p)->Promise.then(refresh)

  let _safeAddPeer = (p: ReBeacon.peerInfo) => {
    switch _getExisting(p, peerInfos) {
    | Some(p) => removePeer(p)->Promise.then(() => addPeer(p))
    | None => addPeer(p)
    }
  }

  let safeAddPeer = (encodedPeerInfo: string) => {
    makePeerInfo(encodedPeerInfo)
    ->Promise.then(_safeAddPeer)
    ->Promise.catch(exn => {
      `Failed to add peer. Reason: ${exn->Helpers.getMessage}`->onError
      Promise.resolve()
    })
  }

  (peerInfos, removePeer, safeAddPeer, permisionInfos)
}
