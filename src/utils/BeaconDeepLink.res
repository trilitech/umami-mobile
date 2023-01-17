let useBeaconDeepLink = (~onDeepLink: PeerData.t => unit) => {
  let onDeepLink = React.useRef(onDeepLink)

  React.useEffect1(() => {
    let handleUri = str => str->PeerData.buildFromUri->Belt.Option.map(onDeepLink.current)->ignore

    ReactNative.Linking.getInitialURL()
    ->Promise.thenResolve(Helpers.nullToOption2)
    ->Promise.thenResolve(uri => uri->Belt.Option.map(handleUri))
    ->ignore

    ReactNative.Linking.addEventListener("url"->Obj.magic, data => data.url->handleUri)->ignore

    None
  }, [])
}

module Base = {
  @react.component
  let make = (~client: ReBeacon.WalletClient.t) => {
    let (_, _, addPeer, _) = BeaconHooks.usePeers(client, ())
    useBeaconDeepLink(~onDeepLink=d => addPeer(d)->ignore)

    React.null
  }
}

@react.component
let make = () => {
  let (client, _) = BeaconHooks.useClient()
  client->Helpers.reactFold(client => <Base client />)
}
