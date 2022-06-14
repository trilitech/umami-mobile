open ReactNative.Style
@react.component
let make = (~openReceive, ~onChange) => {
  let snapPoints = ["45%"]
  let backgroundColor = ThemeProvider.useSurfaceColor()
  <BottomSheet
    backgroundStyle={style(~backgroundColor, ())}
    onChange={i => onChange(i == 0)}
    index={openReceive ? 0 : -1}
    snapPoints
    enablePanDownToClose=true>
    <ReceiveAssetsPanel />
  </BottomSheet>
}
