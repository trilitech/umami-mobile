@react.component
let make = (~items, ~value, ~onChange) => {
  let color = ThemeProvider.useTextColor()
  <RNPicker
    value
    onValueChange=onChange
    style={{
      "inputIOS": {
        "color": color,
        "marginTop": 30.,
        "marginRight": 8,
        "marginLeft": 8,
      },
    }}
    items
  />
}
