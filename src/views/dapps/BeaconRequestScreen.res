open Paper

module Display = {
  @react.component
  let make = (~client, ~account: Account.t, ~beaconRequest: ReBeacon.Message.Request.t) => {
    let goBack = NavUtils.useGoBack()
    let notify = SnackBar.useNotification()
    let respond = Beacon.useRespond(client)
    let (accounts, _) = Store.useAccounts()

    switch beaconRequest {
    | PermissionRequest(r) => <PermissionRequest request={r} pk=account.pk goBack respond />
    | OperationRequest(r) => {
        let sender = accounts->Belt.Array.getBy(a => a.tz1->Pkh.toString === r.sourceAddress)
        sender->Belt.Option.mapWithDefault(React.null, sender =>
          <OperationRequest request={r} goBack respond sender />
        )
      }
    | SignPayloadRequest(r) =>
      <SignPayloadRequest
        respond request={r} goBack notify sign={SignUtils.signContentGeneric(~account)}
      />
    // TODO add nicer display
    | BroadcastRequest(_) => <Headline> {"Broadcast request not handled"->React.string} </Headline>
    }
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let beaconRequest = route->NavUtils.getBeaconRequest
  let account = Store.useActiveAccount()
  let (client, _) = Beacon.useClient()

  Helpers.three(beaconRequest, account, client)->Helpers.reactFold(((
    beaconRequest,
    account,
    client,
  )) => <Display client account beaconRequest />)
}
