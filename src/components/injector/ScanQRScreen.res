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
        })
      )
      ->ignore
    })
  }
}