open ReactNative.Style

open CommonComponents
module QR = {
  @react.component @module("react-native-qrcode-svg")
  external make: (~value: string, ~size: int=?) => React.element = "default"
}

module PureReceiveModal = {
  @react.component
  let make = (~handleCopy, ~handleShare, ~onClose, ~tz1) => {
    <ReactNative.View
      style={style(~flex=1., ~display=#flex, ~flexDirection=#column, ~justifyContent=#flexEnd, ())}>
      <Paper.Surface
        style={style(
          ~height=380.->dp,
          ~flexDirection=#column,
          ~alignItems=#center,
          ~justifyContent=#spaceAround,
          ~borderTopLeftRadius=16.,
          ~borderTopRightRadius=16.,
          (),
        )}>
        // <Wrapper flexDirection=#column alignItems=#center style={FormStyles.makeVMargin(4.)}>
        <Paper.TouchableRipple onPress={_ => onClose()}>
          <QR value=tz1 size=250 />
        </Paper.TouchableRipple>
        <Wrapper justifyContent=#flexStart style={array([FormStyles.styles["verticalMargin"]])}>
          <NicerIconBtn
            onPress=handleCopy iconName="content-copy" style={FormStyles.styles["hMargin"]}
          />
          <NicerIconBtn
            onPress=handleShare iconName="share-variant" style={FormStyles.styles["hMargin"]}
          />
        </Wrapper>
        // </Wrapper>
      </Paper.Surface>
    </ReactNative.View>
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let goBack = NavUtils.useGoBack()
  let copy = ClipboardCopy.useCopy()

  let handleCopy = tz1 => {
    copy(tz1)
    goBack()->ignore
  }

  let handleShare = tz1 => {
    let content = ReactNative.Share.content(~message=`This is my Tezos Pkh: ${tz1}`, ())
    ReactNative.Share.share(content)->ignore
    goBack()->ignore
    ()
  }
  let account = Store.useActiveAccount()

  account->Helpers.reactFold(account =>
    <PureReceiveModal
      handleCopy={_ => handleCopy(account.tz1)}
      handleShare={_ => handleShare(account.tz1)}
      tz1=account.tz1
      onClose={() => goBack()->ignore}
    />
  )
}
