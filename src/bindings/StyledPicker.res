@react.component
let make = (~items, ~value, ~onChange) => {
  let color = ThemeProvider.useTextColor()
  <RNPicker
    value
    onValueChange=onChange
    style={{
      "inputIOS": {
        "color": color,
        "width": 50,
      },
    }}
    items
  />
}
