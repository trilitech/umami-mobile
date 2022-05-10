@module("../../../package.json")
external version: string = "version"

open Paper
open ReactNative.Style
@react.component
let make = () => {
  <Caption style={style(~textAlign=#center, ())}> {React.string("v" ++ version)} </Caption>
}
