open ReactNative
@module("react-native-fast-image") @react.component
external make: (
  ~style: Style.t=?,
  ~source: Image.uriSource,
  ~resizeMode: Style.resizeMode=?,
) => React.element = "default"
