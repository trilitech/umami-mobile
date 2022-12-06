open CommonComponents
open ReactNative.Style
open Paper

let useGetAccountName = () => {
  let (account, _) = Store.useAccountsDispatcher()

  (pkh: Pkh.t) => account->Belt.Array.getBy(a => a.tz1 === pkh)->Belt.Option.map(a => a.name)
}

module PeerInfos = {
  @react.component
  let make = (
    ~peerInfos: array<ReBeacon.peerInfo>,
    ~onRemove,
    ~permissionInfos: array<ReBeacon.permissionInfo>,
  ) => {
    let getAccountName = useGetAccountName()
    let disabledColor = UmamiThemeProvider.useDisabledColor()
    let els = peerInfos->Belt.Array.map(p => {
      let permissionInfo =
        permissionInfos->Belt.Array.getBy(permissionInfo =>
          permissionInfo.appMetadata.senderId == p.senderId
        )
      let accountName =
        permissionInfo
        ->Belt.Option.flatMap(permissionInfo =>
          getAccountName(permissionInfo.address->Pkh.unsafeBuild)
        )
        ->Belt.Option.getWithDefault("")

      <CustomListItem
        height=80.
        left={p.icon->Belt.Option.mapWithDefault(
          <CommonComponents.Icon size=40 name="application-brackets" />,
          url => <RoundImage url size=40 />,
        )}
        key=p.id
        center={<ReactNative.View>
          <Title> {p.name->React.string} </Title>
          <Text style={style(~color=disabledColor, ())}> {accountName->React.string} </Text>
        </ReactNative.View>}
        right={<CrossRight onPress={_ => onRemove(p)} />}
      />
    })

    {
      els == []
        ? <DefaultView
            title="No dApps connected"
            subTitle="Your dApps will appear here"
            icon="application-cog-outline"
          />
        : <> <Title> {"Peers"->React.string} </Title> {<> {els->React.array} </>} </>
    }
  }
}

module Display = {
  @react.component
  let make = (~client: ReBeacon.WalletClient.t) => {
    let (peerInfos, remove, addPeer, permissionInfos) = Beacon.usePeers(client, ())
    let navigate = NavUtils.useNavigate()
    <InstructionsContainer
      title="Dapps"
      instructions="Manage your dApp connections here.\nScan or paste a beacon code to add a dApp.">
      <Wrapper justifyContent=#center>
        <NicerIconBtn
          onPress={_ => navigate("ScanBeacon")}
          iconName="qrcode-scan"
          style={StyleUtils.makeVMargin()}
        />
        <NicerIconBtn
          onPress={_ => {
            Clipboard.getString()->Promise.then(addPeer)->ignore
          }}
          iconName="content-copy"
          style={StyleUtils.makeHMargin()}
        />
      </Wrapper>
      <PeerInfos peerInfos permissionInfos onRemove={p => p->remove->ignore} />
    </InstructionsContainer>
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let (client, _) = Beacon.useClient()
  client->Helpers.reactFold(client => <Display client />)
}
