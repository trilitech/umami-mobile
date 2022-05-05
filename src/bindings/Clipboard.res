@module("@react-native-clipboard/clipboard") @scope("default")
external getString: unit => Promise.t<string> = "getString"

@module("@react-native-clipboard/clipboard") @scope("default")
external setString: string => unit = "setString"
