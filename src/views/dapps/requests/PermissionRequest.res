open ReBeacon
open CommonComponents
open Paper

@react.component
let make = (~request: Message.Request.permissionRequest, ~pk: Pk.t, ~goBack, ~respond) => {
  let {appMetadata} = request

  let (loading, setLoading) = React.useState(_ => false)

  let acceptRequest = () => {
    let response: Message.ResponseInput.permissionResponse = {
      type_: #permission_response,
      id: request.id,
      network: request.network,
      scopes: request.scopes,
      publicKey: pk->Pk.toString,
    }

    setLoading(_ => true)
    respond(#PermissionResponse(response))->Promise.thenResolve(_ => {
      setLoading(_ => false)
      goBack()
    })
  }

  <Container>
    <Wrapper flexDirection=#column justifyContent=#center>
      <MetadataDisplay.Header
        title="Permission request" appMetadata network=request.network.type_
      />
      <Wrapper justifyContent=#center>
        {request.scopes
        ->Belt.Array.map(s => <Paper.Badge key={s}> {s->React.string} </Paper.Badge>)
        ->React.array}
      </Wrapper>
    </Wrapper>
    <Button
      loading
      disabled=loading
      style={StyleUtils.makeVMargin()}
      onPress={_ => {
        acceptRequest()->ignore
      }}
      mode=#contained>
      {"Accept"->React.string}
    </Button>
    <Button style={StyleUtils.makeVMargin()} onPress={_ => goBack()} mode=#outlined>
      {"Decline"->React.string}
    </Button>
  </Container>
}
