open Paper
open ReBeacon

let safeParse = (payload: string) =>
  try {
    Taquito.unpackDataBytes({"bytes": payload})["string"]->Ok
  } catch {
  | e => {
      let msg = e->Helpers.getMessage
      if msg->Js.String2.includes("can't parse bytes") {
        payload->Ok
      } else {
        payload->Error
      }
    }
  }
module DisplayRequest = {
  @react.component
  let make = (~appMetadata, ~unpackedPayload: string, ~onSign, ~onDecline, ~loading) => {
    <Container>
      <MetadataDisplay.Header title="Sign payload request" appMetadata />
      <CommonComponents.CustomListItem
        style={StyleUtils.makeVMargin()}
        center={<Text style={StyleUtils.makeVPadding()}> {unpackedPayload->React.string} </Text>}
      />
      <PasswordSubmit onSubmit={onSign} loading />
      <Button style={StyleUtils.makeVMargin()} onPress={_ => onDecline()} mode=#outlined>
        {"decline"->React.string}
      </Button>
    </Container>
  }
}

@react.component
let make = (
  ~request: Message.Request.signPayloadRequest,
  ~goBack,
  ~notify,
  ~sign: (~encodedContent: string, ~password: string) => Promise.t<Taquito.signed>,
  ~respond,
) => {
  let (loading, setLoading) = React.useState(_ => false)
  let payload = safeParse(request.payload)

  let handleSubmitPassword = (password: string) => {
    setLoading(_ => true)
    sign(~encodedContent=request.payload, ~password)
    ->Promise.thenResolve(signed => {
      let response: Message.ResponseInput.signPayloadResponse = {
        type_: #sign_payload_response,
        id: request.id,
        signingType: request.signingType,
        signature: signed.prefixSig,
      }

      respond(#SignPayloadResponse(response))
    })
    ->Promise.thenResolve(_ => {
      notify("Beacon signature response sent!")
      goBack()
      setLoading(_ => false)
    })
    ->Promise.catch(_ => {
      notify("Failed to send beacon response!")
      setLoading(_ => false)
      Promise.resolve()
    })
    ->ignore
  }

  switch payload {
  | Ok(p) =>
    <DisplayRequest
      onDecline={_ => goBack()}
      appMetadata=request.appMetadata
      loading
      onSign={handleSubmitPassword}
      unpackedPayload={p}
    />

  | Error(error) => <BeaconErrorMsg message={"Failed to parse Beacon payload. Reason: " ++ error} />
  }
}
