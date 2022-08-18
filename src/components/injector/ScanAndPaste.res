open CommonComponents
open AddressImporterTypes
open Belt

let useNavigateToQr = mode => {
  let navigate = NavUtils.useNavigate()
  let route = switch mode {
  | Tz1Mode => "ScanTz1"
  | TezosDomainMode => "ScanTezosDomain"
  }
  () => navigate(route)->ignore
}

let useOnScannedAddress = onChange => {
  let route = ReactNavigation.Native.useRoute()

  let tz1OrDomain =
    route
    ->Js.Nullable.toOption
    ->Option.flatMap(NavUtils.getInjectedAddress)
    ->Option.map(add =>
      switch add {
      | Tz1(tz1) => tz1
      | TezosDomain(domain) => domain
      }
    )

  React.useEffect2(() => {
    tz1OrDomain->Option.map(onChange)->ignore
    None
  }, (tz1OrDomain, onChange))
}

let getValidator = mode => {
  switch mode {
  | Tz1Mode => TaquitoUtils.tz1IsValid
  | TezosDomainMode => TezosDomains.isTezosDomain
  }
}

@react.component
let make = (~onChange, ~mode) => {
  let notify = SnackBar.useNotification()
  let navToQRScan = useNavigateToQr(mode)
  let validator = getValidator(mode)

  // Listen for successfull scans
  useOnScannedAddress(onChange)

  <Wrapper justifyContent=#center>
    <NicerIconBtn
      onPress={_ => navToQRScan()} iconName="qrcode-scan" style={StyleUtils.makeVMargin()}
    />
    <NicerIconBtn
      onPress={_ => {
        Clipboard.getString()
        ->Promise.thenResolve(recipient => {
          if validator(recipient) {
            onChange(recipient)
          } else if recipient != "" {
            notify(
              `${recipient} is not a valid ${switch mode {
                | Tz1Mode => "Tz1 address"
                | TezosDomainMode => "Tezos domain"
                }}!`,
            )
          }
        })
        ->ignore
      }}
      iconName="content-copy"
      style={StyleUtils.makeHMargin()}
    />
  </Wrapper>
}
