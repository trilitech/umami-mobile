open Belt
open Paper
open AddressImporterTypes
module QRCodeScanner = {
  @react.component @module("react-native-qrcode-scanner")
  external make: (
    ~onRead: {"data": string} => unit,
    ~topContent: 'a,
    ~bottomContent: 'a,
  ) => React.element = "default"
}

%%private(
  let makeScanner = (~title: string, ~subTitle: string, ~onRead) => {
    <QRCodeScanner
      onRead={e => {
        let scannedString = e["data"]
        onRead(scannedString)
      }}
      topContent={<Headline> {React.string(title)} </Headline>}
      bottomContent={<TouchableRipple> <Text> {React.string(subTitle)} </Text> </TouchableRipple>}
    />
  }
)

module ScanTezosDomain = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let title = "Tz address or Tezos domain"
    let subTitle = "Scan Tz Address or Tezos domain"

    let getBackWithparams = NavUtils.useGoBackWithParams()

    makeScanner(~subTitle, ~title, ~onRead=str => {
      str
      ->makeInjectedAddress
      ->Belt.Option.map(a =>
        getBackWithparams({
          tz1ForContact: None,
          derivationIndex: None,
          nft: None,
          assetBalance: None,
          tz1ForSendRecipient: None,
          injectedAdress: a->Some,
          signedContent: None,
          beaconRequest: None,
        })
      )
      ->ignore
    })
  }
}

module ScanDesktopSeedPhrase = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let title = "Umami Desktop secret QR code"
    let subTitle = "Scan Umami Desktop secret QR code"

    let navigateWithParams = NavUtils.useOffboardNavigateWithParams()

    makeScanner(~subTitle, ~title, ~onRead=str => {
      switch SecretQRPayload.fromString(str) {
      | Ok(qrPayload) =>
        navigateWithParams(
          "RestoreDesktopSeedPhrase",
          {
            desktopSeedPhrase: qrPayload->Some,
          },
        )
      | Error(_) => ()
      }
    })
  }
}

module ScanSignedContent = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let title = "Scan signed content"
    let subTitle = "Scan signed content"

    let navigateWithParams = NavUtils.useNavigateWithParams()

    makeScanner(~subTitle, ~title, ~onRead=str => {
      str
      // TODO catch exception bevause library crashes if base form is unvalid
      ->SignedData.Decode.decode
      ->Helpers.resultToOption
      ->Option.map(signed => {
        navigateWithParams(
          "VerifySignedContent",
          {
            tz1ForContact: None,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: signed->Some,
            beaconRequest: None,
          },
        )
      })
      ->ignore
    })
  }
}

module ScanBeacon_ = {
  @react.component
  let make = (~client) => {
    let (_, _, addPeer) = Beacon.usePeers(client)
    let goBack = NavUtils.useGoBack()

    let title = "Scan beacon permission request"
    let subTitle = "Scan beacon permission request"

    makeScanner(~subTitle, ~title, ~onRead=str =>
      addPeer(str)->Promise.thenResolve(_ => goBack())->ignore
    )
  }
}
module ScanBeacon = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let (client, _) = Beacon.useClient()

    client->Helpers.reactFold(client => <ScanBeacon_ client />)
  }
}
