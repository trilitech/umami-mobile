open ReactNative.Style

// Use these functions to make the spacing in the app scale sanely

let makeVMargin = (~size=1, ()) => viewStyle(~marginVertical=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeHMargin = (~size=1, ()) => viewStyle(~marginHorizontal=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeLeftMargin = (~size=1, ()) => viewStyle(~marginLeft=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeRightMargin = (~size=1, ()) => viewStyle(~marginRight=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeBottomMargin = (~size=1, ()) =>
  viewStyle(~marginBottom=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeTopMargin = (~size=1, ()) => viewStyle(~marginTop=(size->Js.Int.toFloat *. 8.)->dp, ())

let makePadding = (~size=1, ()) => viewStyle(~padding=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeHPadding = (~size=1, ()) =>
  viewStyle(~paddingHorizontal=(size->Js.Int.toFloat *. 8.)->dp, ())
