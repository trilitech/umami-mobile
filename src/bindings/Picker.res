@react.component
let make = (~items, ~value, ~onChange, ~icon) => {
  let color = ThemeProvider.useTextColor()
  <RNPicker
    \"Icon"=icon
    value
    onValueChange=onChange
    style={{
      "inputIOS": {
        "color": color,
        "width": 50,
      },
      // Icon misaligned by default
      "iconContainer": {
        "top": -5,
        "alignItems": "center",
      },
    }}
    items
  />
}
