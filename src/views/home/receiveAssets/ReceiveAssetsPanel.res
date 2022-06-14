open ReactNative.Style

open CommonComponents
module QR = {
  @react.component @module("react-native-qrcode-svg")
  external make: (~value: string, ~size: int=?) => React.element = "default"
}

module PureReceiveModal = {
  @react.component
  let make = (~handleCopy, ~handleShare, ~tz1) => {
    <ReactNative.View style={style(~flex=1., ())}>
      <ReactNative.View
        style={style(
          ~flexDirection=#column,
          ~alignItems=#center,
          ~justifyContent=#spaceAround,
          (),
        )}>
        <QR value=tz1 size=250 />
        <Wrapper justifyContent=#flexStart style={array([FormStyles.styles["verticalMargin"]])}>
          <NicerIconBtn
            onPress=handleCopy iconName="content-copy" style={FormStyles.styles["hMargin"]}
          />
          <NicerIconBtn
            onPress=handleShare iconName="share-variant" style={FormStyles.styles["hMargin"]}
          />
        </Wrapper>
      </ReactNative.View>
    </ReactNative.View>
  }
}

open Store
@react.component
let make = () => {
  let copy = ClipboardCopy.useCopy()

  let handleCopy = tz1 => {
    copy(tz1)
  }

  let handleShare = tz1 => {
    let content = ReactNative.Share.content(~message=`This is my Tezos Pkh: ${tz1}`, ())
    ReactNative.Share.share(content)->ignore
  }

  useWithAccount(account => {
    <PureReceiveModal
      handleCopy={_ => handleCopy(account.tz1)}
      handleShare={_ => handleShare(account.tz1)}
      tz1=account.tz1
    />
  })
}
