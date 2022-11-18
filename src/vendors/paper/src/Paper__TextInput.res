module Icon = {
  @module("react-native-paper") @scope("TextInput") @react.component
  external make: (~name: Paper__Icon.t, ~color: string=?) => React.element = "Icon"
}
module Affix = {
  @module("react-native-paper") @scope("TextInput") @react.component
  external make: (~text: string) => React.element = "Affix"
}

@module("react-native-paper") @react.component
external make: (
  ~mode: [#flat | #outlined],
  ~allowFontScaling: bool=?,
  ~autoCorrect: bool=?,
  ~autoFocus: bool=?,
  ~autoCapitalize: [#none | #sentences | #words | #characters]=?,
  ~autoGrow: bool=?,
  ~blurOnSubmit: bool=?,
  ~caretHidden: bool=?,
  ~contextMenuHidden: bool=?,
  ~dataDetectorTypes: string=?,
  ~enablesReturnKeyAutomatically: bool=?,
  ~error: bool=?,
  ~keyboardAppearance: string=?,
  ~defaultValue: string=?,
  ~disabled: bool=?,
  ~disableFullscreenUI: bool=?,
  ~editable: bool=?,
  ~keyboardType: string=?,
  ~inlineImageLeft: string=?,
  ~inlineImagePadding: string=?,
  ~maxHeight: float=?,
  ~maxLength: int=?,
  ~label: string=?,
  ~placeholder: string=?,
  ~placeholderTextColor: string=?,
  ~returnKeyType: string=?,
  ~returnKeyLabel: string=?,
  ~spellCheck: bool=?,
  ~textBreakStrategy: string=?,
  ~underlineColorAndroid: string=?,
  ~clearButtonMode: string=?,
  ~clearTextOnFocus: string=?,
  ~secureTextEntry: bool=?,
  ~selectTextOnFocus: bool=?,
  ~selection: {..}=?,
  ~selectionColor: string=?,
  ~underlineColor: string=?,
  ~multiline: bool=?,
  ~numberOfLines: int=?,
  ~value: string=?,
  ~theme: Paper__ThemeProvider.Theme.t=?,
  ~style: ReactNative.Style.t=?,
  ~onChange: unit => unit=?,
  ~onChangeText: string => unit=?,
  ~onContentSizeChange: unit => unit=?,
  ~onKeyPress: unit => unit=?,
  ~onEndEditing: unit => unit=?,
  ~onLayout: unit => unit=?,
  ~onScroll: unit => unit=?,
  ~onSelectionChange: unit => unit=?,
  ~onSubmitEditing: unit => unit=?,
  ~onFocus: unit => unit=?,
  ~onBlur: unit => unit=?,
  ~testID: string=?,
  ~ref: Js.Nullable.t<'a> => unit=?,
  ~right: React.element=?,
  ~left: React.element=?,
) => React.element = "TextInput"
