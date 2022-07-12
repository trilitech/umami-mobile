type source = {uri: string}
@react.component @module("react-native-webview")
external make: (~source: source, ~style: ReactNative.Style.t=?) => React.element = "WebView"
