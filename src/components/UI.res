open Paper
// open ReactNative.Style
open ReactNative
module Input = {
  @react.component
  let make = (
    ~error=false,
    ~placeholder,
    ~value,
    ~label,
    ~onChangeText,
    ~keyboardType=?,
    ~style=?,
  ) => {
    <View ?style>
      //   <Caption style={ReactNative.Style.style(~marginBottom=-4.->dp, ())}>
      <Caption style={ReactNative.Style.style()}> {label->React.string} </Caption>
      <Paper.TextInput ?keyboardType error placeholder value label="" mode=#outlined onChangeText />
    </View>
  }
}
