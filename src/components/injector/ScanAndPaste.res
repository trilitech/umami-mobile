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
  | TezosDomainMode => TezosDomainsAPI.isTezosDomain
  }
}

@react.component
let make = (~onChange, ~style) => {
  let navigate = NavUtils.useNavigate()

  // Listen for successfull scans
  useOnScannedAddress(onChange)

  <Wrapper justifyContent=#center style>
    <NicerIconBtn
      onPress={_ => navigate("ScanAddressOrDomain")}
      iconName="qrcode-scan"
      style={StyleUtils.makeVMargin()}
    />
    <NicerIconBtn
      onPress={_ => {
        Clipboard.getString()
        ->Promise.thenResolve(recipient => {
          makeInjectedAddress(recipient)->Option.map(a => {
            switch a {
            | Tz1(val) => onChange(val)
            | TezosDomain(val) => onChange(val)
            }->ignore
          })
        })
        ->ignore
      }}
      iconName="content-copy"
      style={StyleUtils.makeHMargin()}
    />
  </Wrapper>
}
