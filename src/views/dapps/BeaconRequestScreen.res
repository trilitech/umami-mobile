let unknownAccount = address => <BeaconErrorMsg message={"Unknown account " ++ address} />
module Display = {
  @react.component
  let make = (
    ~client,
    ~activeAccount: Account.t,
    ~beaconRequest: ReBeacon.Message.Request.t,
    ~accounts: array<Account.t>,
  ) => {
    let goBack = NavUtils.useGoBack()
    let notify = SnackBar.useNotification()
    let respond = Beacon.useRespond(client)

    let (_, refreshPermissions, _) = Beacon.usePermissionInfos(client)

    switch beaconRequest {
    | PermissionRequest(r) =>
      // Permission request specifies no account
      // Reply to permission request with selected account
      <PermissionRequest request={r} pk=activeAccount.pk goBack respond refreshPermissions />
    | OperationRequest(r) => {
        // Handle operations with account specified in request sourceAddress
        let accountInRequest =
          accounts->Belt.Array.getBy(a => a.tz1->Pkh.toString === r.sourceAddress)
        accountInRequest->Belt.Option.mapWithDefault(unknownAccount(r.sourceAddress), sender =>
          <OperationRequest request={r} goBack respond sender />
        )
      }
    | SignPayloadRequest(r) =>
      // Sign payloads with account specified in request sourceAddress
      let accountInRequest =
        accounts->Belt.Array.getBy(a => a.tz1->Pkh.toString === r.sourceAddress)
      accountInRequest->Belt.Option.mapWithDefault(unknownAccount(r.sourceAddress), account =>
        <SignPayloadRequest
          respond request={r} goBack notify sign={SignUtils.signContentGeneric(~account)}
        />
      )
    | BroadcastRequest(_) => <BeaconErrorMsg message="Broadcast request not handled" />
    }
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let beaconRequest = route->NavUtils.getBeaconRequest
  let (account, _) = Store.useSelectedAccount()
  let (client, _) = Beacon.useClient()
  let (accounts, _) = Store.useAccountsDispatcher()

  Helpers.three(beaconRequest, account, client)->Helpers.reactFold(((
    beaconRequest,
    activeAccount,
    client,
  )) => <Display client activeAccount beaconRequest accounts />)
}
