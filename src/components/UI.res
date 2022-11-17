open Paper
// open ReactNative.Style
open ReactNative
open ReactNative.Style
module Input = {
  @react.component
  let make = (
    ~error=false,
    ~placeholder="",
    ~value,
    ~label="",
    ~onChangeText=?,
    ~keyboardType=?,
    ~style=?,
    ~autoCapitalize=?,
    ~right=?,
    ~multiline=?,
    ~testID=?,
    ~disabled=?,
    ~secureTextEntry=?,
  ) => {
    <View ?style>
      <Caption style={ReactNative.Style.style(~marginBottom=-4.->dp, ())}>
        {label->React.string}
      </Caption>
      <Paper.TextInput
        ?secureTextEntry
        ?disabled
        ?testID
        ?multiline
        ?right
        ?autoCapitalize
        ?keyboardType
        error
        placeholder
        value
        label=""
        mode=#outlined
        ?onChangeText
      />
    </View>
  }
}
