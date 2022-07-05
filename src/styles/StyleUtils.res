open ReactNative.Style

let makeVMargin = (~size=1, ()) => viewStyle(~marginVertical=(size->Js.Int.toFloat *. 8.)->dp, ())
let makeHMargin = (~size=1, ()) => viewStyle(~marginHorizontal=(size->Js.Int.toFloat *. 8.)->dp, ())
