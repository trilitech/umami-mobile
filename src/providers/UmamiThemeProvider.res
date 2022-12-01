// let useIsDarkMode = () => {
//   Appearance.useColorScheme()
//   ->Js.Null.toOption
//   ->Belt.Option.map(scheme => scheme === #dark)
//   ->Belt.Option.getWithDefault(false)
// }

let makeFonts = () => {
  open Paper.ThemeProvider.Theme.Fonts
  let regular = font(~fontFamily="SourceSansPro-Regular", ~fontWeight="normal")
  let medium = font(~fontFamily="SourceSansPro-Regular", ~fontWeight="normal")
  let light = font(~fontFamily="SourceSansPro-Light", ~fontWeight="normal")
  let thin = font(~fontFamily="SourceSansPro-ExtraLight", ~fontWeight="normal")

  let fonts = make(~regular, ~medium, ~light, ~thin)

  fontByOS(~ios=fonts, ~android=fonts, ~web=fonts, ())->configureFonts
}

let makeColors = (
  ~colors: Paper.ThemeProvider.Theme.Colors.t,
  ~primaryColor,
  ~surfaceColor=?,
  (),
) => {
  open Paper.ThemeProvider.Theme.Colors

  // Is there a less verbose way to do this ?
  make(
    ~accent=primaryColor,
    ~primary=primaryColor,
    // ~primary=primary(colors),
    ~backdrop=backdrop(colors),
    ~background=background(colors),
    ~disabled=disabled(colors),
    ~error=Colors.Light.error,
    ~placeholder=placeholder(colors),
    ~surface=surfaceColor->Belt.Option.getWithDefault(surface(colors)),
    ~text=text(colors),
  )
}

let customizeTheme = (~theme, ~colors) => {
  open Paper.ThemeProvider
  let fonts = makeFonts()
  // let fonts = Theme.fonts(theme)
  let animation = Theme.animation(theme)
  Theme.make(~colors, ~fonts, ~animation, ~roundness=4, ()) // have to pass fonts and animtion otherwise it explodes
}

let makeThemes = () => {
  open Paper.ThemeProvider
  let customPrimary = Colors.Light.primary
  let customDarkColor = makeColors(
    ~colors=Theme.colors(darkTheme),
    ~primaryColor=customPrimary,
    ~surfaceColor=Colors.Dark.elevatedBackground,
    (),
  )
  let customLightColor = makeColors(
    ~colors=Theme.colors(defaultTheme),
    ~primaryColor=customPrimary,
    (),
  )
  let newDark = customizeTheme(~theme=darkTheme, ~colors=customDarkColor)
  let newDefault = customizeTheme(~theme=defaultTheme, ~colors=customLightColor)
  (newDark, newDefault)
}

let useColors = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors
}

let useTextColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.text
}

let useDisabledColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.disabled
}

let usePlaceHolderColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.placeholder
}

let useBgColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.background
}

let usePrimaryColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.primary
}

let useSurfaceColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.surface
}

let useErrorColor = () => {
  open Paper.ThemeProvider
  useTheme()->Theme.colors->Theme.Colors.error
}

let (dark, default) = makeThemes()

let getSystemTheme = () =>
  ReactNative.Appearance.getColorScheme()->Js.nullToOption->Belt.Option.getWithDefault(#dark)

let useEffectiveTheme = () => {
  let (theme, _) = Store.useTheme()
  switch theme {
  | Dark => #dark
  | Light => #light
  | System => getSystemTheme()
  }
}

@react.component
let make = (~children) => {
  let effectiveTheme = useEffectiveTheme()

  <Paper.PaperProvider>
    <Paper.ThemeProvider theme={effectiveTheme == #dark ? dark : default}>
      {children}
    </Paper.ThemeProvider>
  </Paper.PaperProvider>
}
