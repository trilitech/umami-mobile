open CommonComponents

@react.component
let make = (~onChange) => {
  let navigate = NavUtils.useNavigate()
  let notify = SnackBar.useNotification()
  <Wrapper justifyContent=#center>
    <NicerIconBtn
      onPress={_ => {
        navigate("ScanQR")->ignore
        ()
      }}
      iconName="qrcode-scan"
      style={StyleUtils.makeVMargin()}
    />
    <NicerIconBtn
      onPress={_ => {
        Clipboard.getString()
        ->Promise.thenResolve(recipient => {
          if TaquitoUtils.tz1IsValid(recipient) {
            onChange(recipient)
          } else if recipient != "" {
            notify(`${recipient} is not a valid pkh`)
          }
        })
        ->ignore
      }}
      iconName="content-copy"
      style={StyleUtils.makeHMargin()}
    />
  </Wrapper>
}
