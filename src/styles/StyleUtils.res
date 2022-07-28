open ReactNative.Style

let makeVMargin = (~size=1, ()) => viewStyle(~marginVertical=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeHMargin = (~size=1, ()) => viewStyle(~marginHorizontal=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeLeftHMargin = (~size=1, ()) => viewStyle(~marginLeft=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeRightMargin = (~size=1, ()) => viewStyle(~marginLeft=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeBottomMargin = (~size=1, ()) =>
  viewStyle(~marginBottom=(size->Js.Int.toFloat *. 8.)->dp, ())

let makeTopMargin = (~size=1, ()) => viewStyle(~marginTop=(size->Js.Int.toFloat *. 8.)->dp, ())
let makePadding = (~size=1, ()) => viewStyle(~padding=(size->Js.Int.toFloat *. 8.)->dp, ())
