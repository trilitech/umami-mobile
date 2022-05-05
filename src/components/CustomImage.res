open ReactNative
open Style

@react.component
let make = (~size, ~source, ~style as extraStyles=style()) => {
  <Image source style={Style.array([style(~width=size->dp, ~height=size->dp, ()), extraStyles])} />
}