open ReactNative.Style

let useHeaderStyle = () => {
  open Paper.ThemeProvider.Theme
  let colors = ThemeProvider.useColors()

  let options = NavStacks.OnBoard.options(
    ~headerStyle=style(~backgroundColor=colors->Colors.background, ()),
    ~headerTitleStyle=style(~color=colors->Colors.text, ()),
    (),
  )
  _ => options
}
