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

let makePeerInfo = encodedPeerInfo =>
  ReBeacon.Serializer.make()->ReBeacon.Serializer.deserializeRaw(encodedPeerInfo->PeerData.toString)

let useClient = () => Jotai.Atom.use(beaconAtom)

let _useInit = (
  ~onDone=_ => (),
  ~onError=_ => (),
  ~makeClient: ReBeacon.WalletClient.options => ReBeacon.WalletClient.t,
  ~onBeaconRequest,
  (),
) => {
  let (client, setClient) = useClient()
  let onError = React.useRef(onError)
  let onDone = React.useRef(onDone)
  let onBeaconRequest = React.useRef(onBeaconRequest)
  let makeClient = React.useRef(makeClient)

  React.useEffect2(() => {
    switch client {
    | Some(client) =>
      client
      ->ReBeacon.WalletClient.initRaw()
      ->Promise.then(_ => {
        client->ReBeacon.WalletClient.connectRaw(m =>
          m->ReBeacon.Message.Request.classify->onBeaconRequest.current
        )
      })
      ->Promise.thenResolve(_ => onDone.current())
      ->Promise.catch(exn => {
        `Failed to remove peer. Reason: ${exn->Helpers.getMessage}`->onError.current
        Promise.resolve()
      })
      ->ignore

    | None => setClient(_ => makeClient.current({name: "Umami mobile"})->Some)
    }

    None
  }, (client, setClient))
}

let useInit = () => {
  let navigate = NavUtils.useNavigateWithParams()
  let handleBeaconRequest = r =>
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
        beaconRequest: r->Some,
        browserUrl: None,
      },
    )

  _useInit(
    ~makeClient=ReBeacon.WalletClient.make,
    ~onDone=_ => Js.Console.log("Beacon successfully started"),
    ~onError=Logger.error,
    ~onBeaconRequest=handleBeaconRequest,
    (),
  )
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

  let safeAddPeer = (encodedPeerInfo: PeerData.t) => {
    makePeerInfo(encodedPeerInfo)
    ->Promise.then(_safeAddPeer)
    ->Promise.catch(exn => {
      `Failed to add peer. Reason: ${exn->Helpers.getMessage}`->onError
      Promise.resolve()
    })
  }

  (peerInfos, removePeer, safeAddPeer, permisionInfos)
}
