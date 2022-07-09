open ReactNative.Style
open Belt

let useBottomSheet = (~element, ~isOpen=false, ~setIsOpen, ~snapPoint="45%", ()) => {
  let backgroundColor = ThemeProvider.useSurfaceColor()
  let ref = React.useRef(None)

  let close = () => ref.current->Option.map(bs => bs["close"]())->ignore

  (
    <BottomSheetComponent
      ref
      backgroundStyle={style(~backgroundColor, ())}
      onChange={i => setIsOpen(_ => i == 0)}
      index={isOpen ? 0 : -1}
      snapPoints=[snapPoint]
      enablePanDownToClose=true>
      {element}
    </BottomSheetComponent>,
    close,
  )
}
