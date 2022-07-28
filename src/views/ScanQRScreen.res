module QRCodeScanner = {
  @react.component @module("react-native-qrcode-scanner")
  external make: (
    ~onRead: {"data": string} => unit,
    ~topContent: 'a,
    ~bottomContent: 'a,
  ) => React.element = "default"
}

open Paper
@react.component
let make = (~navigation as _, ~route as _) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  <QRCodeScanner
    onRead={e => {
      let tz1 = e["data"]

      if tz1->TaquitoUtils.tz1IsValid {
        navigateWithParams(
          "Send",
          {derivationIndex: None, token: None, tz1: Some(tz1), assetBalance: None},
        )
      }
    }}
    topContent={<Headline> {React.string("Scan TZ1")} </Headline>}
    bottomContent={<TouchableRipple>
      <Text> {React.string("Scan recipient address")} </Text>
    </TouchableRipple>}
  />
}
