open ReactNative.Style

let useBottomSheet = (~element, ~isOpen=false, ~setIsOpen, ~snapPoint="45%", ()) => {
  let backgroundColor = ThemeProvider.useSurfaceColor()
  <BottomSheet
    backgroundStyle={style(~backgroundColor, ())}
    onChange={i => setIsOpen(_ => i == 0)}
    index={isOpen ? 0 : -1}
    snapPoints=[snapPoint]
    enablePanDownToClose=true>
    {element}
  </BottomSheet>
}
