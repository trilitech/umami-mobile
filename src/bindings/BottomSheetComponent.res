@module("@gorhom/bottom-sheet") @react.component
external make: (
  ~ref: 'a,
  ~index: int,
  ~enablePanDownToClose: bool,
  ~snapPoints: 'b,
  ~onChange: 'c,
  ~children: React.element,
  ~backgroundStyle: ReactNative.Style.t,
  ~backdropComponent: RenderBottomSheet.bottomSheetRenderer,
) => React.element = "default"
