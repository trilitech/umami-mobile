open ReactNative
open Style

let getSource = makiColor => {
  switch makiColor {
  | #salmon => Image.Source.fromRequired(Packager.require("../assets/icon.png"))
  | #blue => Image.Source.fromRequired(Packager.require("../assets/maki-blue.png"))
  }
}

@react.component
let make = (~size, ~style as extraStyles=style(), ~makiColor=#salmon) => {
  let source = getSource(makiColor)

  <CustomImage size style=extraStyles source />
}
