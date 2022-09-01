open ReactNative.Style

open CommonComponents
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
        <Qr value={tz1->Pkh.toString} size=250 />
        <Wrapper justifyContent=#flexStart style={array([StyleUtils.makeVMargin()])}>
          <NicerIconBtn
            onPress=handleCopy iconName="content-copy" style={StyleUtils.makeHMargin()}
          />
          <NicerIconBtn
            onPress=handleShare iconName="share-variant" style={StyleUtils.makeHMargin()}
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
      handleCopy={_ => handleCopy(account.tz1->Pkh.toString)}
      handleShare={_ => handleShare(account.tz1->Pkh.toString)}
      tz1=account.tz1
    />
  })
}
