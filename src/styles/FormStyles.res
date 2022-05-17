open ReactNative

open Style
let styles = {
  StyleSheet.create({
    "verticalMargin": viewStyle(~marginVertical=10.->dp, ()),
    "hMargin": viewStyle(~marginHorizontal=10.->dp, ()),
  })
}

let makeVMargin = n => viewStyle(~marginVertical=(n *. 8.)->dp, ())
