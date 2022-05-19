open ReactNative
open Style

let source = Image.Source.fromRequired(Packager.require("../assets/maki-trans.png"))

module Base = {
  @react.component
  let make = (~size, ~makiColor) => {
    let offset = size /. 8.

    <View
      style={style(
        ~margin=(offset /. 2.)->dp,
        ~backgroundColor=makiColor,
        ~width=(size -. offset)->dp,
        ~height=(size -. offset)->dp,
        ~justifyContent=#center,
        ~alignItems=#center,
        (),
      )}>
      <CustomImage size source />
    </View>
  }
}

let colors = ["blue", "brown", "pink", "green", "purple"]
@react.component
let make = (~size, ~tz1) => {
  let makiColor = ColorHash.generateColor(tz1)
  <Base size makiColor />
}
