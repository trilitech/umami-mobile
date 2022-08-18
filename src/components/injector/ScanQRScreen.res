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
  let makeScanner = (~isValid, ~makeInjectedAddress, ~title: string, ~subTitle: string) => {
    let getBackWithparams = NavUtils.useGoBackWithParams()
    <QRCodeScanner
      onRead={e => {
        let scannedString = e["data"]
        if isValid(scannedString) {
          getBackWithparams({
            tz1ForContact: None,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: makeInjectedAddress(scannedString),
          })
        }
      }}
      topContent={<Headline> {React.string(title)} </Headline>}
      bottomContent={<TouchableRipple> <Text> {React.string(subTitle)} </Text> </TouchableRipple>}
    />
  }
)

module ScanTz1 = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let isValid = str => TaquitoUtils.tz1IsValid(str)
    let title = "Tz1"
    let subTitle = "Scan tz1 address"
    let makeInjectedAddress = str => Tz1(str)->Some
    makeScanner(~isValid, ~makeInjectedAddress, ~subTitle, ~title)
  }
}

module ScanTezosDomain = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let isValid = str => TezosDomains.isTezosDomain(str)
    let title = "Tezos domain"
    let subTitle = "Scan Tezos domain"
    let makeInjectedAddress = str => TezosDomain(str)->Some
    makeScanner(~isValid, ~makeInjectedAddress, ~subTitle, ~title)
  }
}
