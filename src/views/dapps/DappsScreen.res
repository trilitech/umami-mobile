open CommonComponents
open Paper

module PeerInfos = {
  @react.component
  let make = (~peerInfos: array<ReBeacon.peerInfo>, ~onRemove) => {
    let els =
      peerInfos->Belt.Array.map(p =>
        <CustomListItem
          left={<CommonComponents.Icon size=32 name="application-brackets" />}
          key=p.id
          center={<Text> {p.name->React.string} </Text>}
          right={<CrossRight onPress={_ => onRemove(p)} />}
        />
      )
    <> <Title> {"Peers"->React.string} </Title> {els->React.array} </>
  }
}

module Display = {
  @react.component
  let make = (~client: ReBeacon.WalletClient.t) => {
    let (peerInfos, remove, addPeer) = Beacon.usePeers(client)
    <Container>
      <InstructionsPanel
        title="Dapps"
        instructions="Manage your dApp connections here.\nScan or paste a beacon code to add a dApp."
      />
      <Wrapper justifyContent=#center>
        <NicerIconBtn onPress={_ => {()}} iconName="qrcode-scan" style={StyleUtils.makeVMargin()} />
        <NicerIconBtn
          onPress={_ => {
            Clipboard.getString()->Promise.then(addPeer)->ignore
          }}
          iconName="content-copy"
          style={StyleUtils.makeHMargin()}
        />
      </Wrapper>
      <PeerInfos peerInfos onRemove={p => p->remove->ignore} />
    </Container>
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let (client, _) = Beacon.useClient()
  client->Helpers.reactFold(client => <Display client />)
}
