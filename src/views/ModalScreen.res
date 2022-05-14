open Paper
open ReactNative.Style

open CommonComponents
module QR = {
  @react.component @module("react-native-qrcode-svg")
  external make: (~value: string, ~size: int=?) => React.element = "default"
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let goBack = NavUtils.useGoBack()
  let handleCopy = _ => {
    goBack()->ignore
    ()
  }
  let handleShare = _ => {
    goBack()->ignore
    ()
  }

  <ReactNative.View
    style={style(~flex=1., ~display=#flex, ~flexDirection=#column, ~justifyContent=#flexEnd, ())}>
    <Surface style={style(~height=350.->dp, ())}>
      <Wrapper flexDirection=#column alignItems=#center style={FormStyles.styles["verticalMargin"]}>
        <QR value="bar" size=250 />
        <Wrapper justifyContent=#flexStart style={array([FormStyles.styles["verticalMargin"]])}>
          <Paper.FAB
            style={FormStyles.styles["hMargin"]}
            small=true
            onPress=handleCopy
            icon={Paper.Icon.name("content-copy")}
          />
          <Paper.FAB
            style={FormStyles.styles["hMargin"]}
            small=true
            onPress=handleShare
            icon={Paper.Icon.name("share-variant")}
          />
        </Wrapper>
      </Wrapper>
    </Surface>
  </ReactNative.View>
}
