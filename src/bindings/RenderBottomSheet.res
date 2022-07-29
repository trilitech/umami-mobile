type bottomSheetRenderer

// We have to import the js with spread props because:
// - component doesn't work without spread props
// - can't spread props with rescript
// - docs don't tell what props are vital within the spreaded props and I don't feel like reading their source code
@module("./js/renderBottomSheet")
external makeBottomSheetRenderer: (int, int) => bottomSheetRenderer = "default"
