// Shim needed for WalletClient to work on RN
%raw(`
require('react-native-get-random-values')
`)

let hydrateBeaconStorage: unit => Promise.t<
  unit,
> = %raw(`require('./rnLocalStoragePolyfill').hydrateLocalStorage`)

let beaconAtom: Jotai.Atom.t<option<ReBeacon.WalletClient.t>, _, _> = Jotai.Atom.make(None)
let peerInfosAtom: Jotai.Atom.t<array<ReBeacon.peerInfo>, _, _> = Jotai.Atom.make([])

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

let usePeers = client => {
  let (peerInfos, setPeerInfos) = Jotai.Atom.use(peerInfosAtom)

  let refresh = React.useMemo2(() => {
    () =>
      client
      ->ReBeacon.WalletClient.getPeersRaw()
      ->Promise.thenResolve(peerInfos => {
        setPeerInfos(_ => peerInfos)
      })
  }, (setPeerInfos, client))

  React.useEffect1(() => {
    refresh()->ignore
    None
  }, [refresh])

  let removePeer = React.useMemo2(() => {
    p => client->ReBeacon.WalletClient.removePeerRaw(p)->Promise.then(refresh)
  }, (client, refresh))

  let addPeer = React.useMemo2(() => {
    (encodedPeerInfo: string) => {
      makePeerInfo(encodedPeerInfo)
      ->Promise.then(p => client->ReBeacon.WalletClient.addPeerRaw(p))
      ->Promise.then(refresh)
    }
  }, (client, refresh))

  (peerInfos, removePeer, addPeer)
}

let useRespond = client => React.useMemo1(() => {
    r => client->ReBeacon.WalletClient.respondRaw(r)
  }, [client])
