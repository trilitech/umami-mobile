open ReactNative.Style
open Belt

let useBottomSheet = (~element, ~snapPoint="45%", ()) => {
  let backgroundColor = ThemeProvider.useSurfaceColor()
  let ref = React.useRef(None)
  let (isOpen, setIsOpen) = React.useState(_ => false)

  let close = () => ref.current->Option.map(bs => bs["close"]())->ignore
  let open_ = () => setIsOpen(_ => true)

  (
    <BottomSheetComponent
      backdropComponent={RenderBottomSheet.makeBottomSheetRenderer(0, -1)}
      ref
      backgroundStyle={style(~backgroundColor, ())}
      onChange={i => setIsOpen(_ => i == 0)}
      index={isOpen ? 0 : -1}
      snapPoints=[snapPoint]
      enablePanDownToClose=true>
      {element(close)}
    </BottomSheetComponent>,
    close,
    open_,
  )
}
