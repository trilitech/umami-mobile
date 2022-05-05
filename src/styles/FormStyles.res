open ReactNative

let styles = {
  open Style
  StyleSheet.create({
    "verticalMargin": viewStyle(~marginVertical=10.->dp, ()),
  })
}
