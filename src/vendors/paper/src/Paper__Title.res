@module("react-native-paper") @react.component
external make: (
  ~style: ReactNative.Style.t=?,
  ~children: React.element,
  ~numberOfLines: int=?,
) => React.element = "Title"
