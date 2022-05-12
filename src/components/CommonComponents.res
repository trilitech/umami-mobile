module type StyleModule = {
  let style: ReactNative.Style.t
}
module MakeWrapper = (Style: StyleModule) => {
  @react.component
  let make = (~children) => {
    <ReactNative.View style={Style.style}> {children} </ReactNative.View>
  }
}

module Wrapper = {
  open ReactNative
  open Style
  @react.component
  let make = (
    ~children,
    ~flexDirection=#row,
    ~alignItems=#center,
    ~justifyContent=#flexStart,
    ~style as extraStyle=style(),
  ) => {
    <View
      style={array([
        style(~display=#flex, ~alignItems, ~flexDirection, ~justifyContent, ()),
        extraStyle,
      ])}>
      children
    </View>
  }
}

module LabeledRadio = {
  @react.component
  let make = (~status, ~value, ~label, ~onPress=_ => ()) =>
    <Wrapper>
      <Paper.RadioButton.Android status value onPress />
      <Paper.Caption> {label->React.string} </Paper.Caption>
    </Wrapper>
}

let makeListItem = (
  ~theme,
  ~onPress,
  ~title,
  ~left=?,
  ~right=?,
  ~description=?,
  ~selected=false,
  ~height,
  (),
) => {
  let disabled = Colors.Light.scrim
  open Paper

  open ThemeProvider
  open Theme
  open ReactNative.Style
  <Surface
    key=title
    style={style(
      ~borderRadius=4.,
      ~elevation=1.,
      ~backgroundColor=selected ? disabled : theme->colors->Colors.surface,
      ~marginVertical=4.->dp,
      // ~alignItems=#center,
      // ~flexDirection=#row,
      // ~justifyContent=#flexStart,
      (),
    )}>
    <List.Item
      style={style(
        ~alignItems=#center,
        ~flexDirection=#row,
        ~justifyContent=#flexStart,
        ~height=height->dp,
        (),
      )}
      ?description
      onPress
      title
      ?left
      ?right
    />
  </Surface>
}

module Icon = {
  @react.component
  let make = (~name, ~color=?, ~size=30, ~style as extraStyle=ReactNative.Style.style()) => {
    let theme = Paper.ThemeProvider.useTheme()

    open Paper
    open ThemeProvider
    open Theme
    open ReactNative.Style
    let defaultIconColor = theme->colors->Colors.text
    <Paper.Avatar.Icon
      size
      color={color->Belt.Option.getWithDefault(defaultIconColor)}
      style={array([style(~backgroundColor="transparent", ()), extraStyle])}
      icon={Paper.Icon.name(name)}
    />
  }
}

module PressableIcon = {
  @react.component
  let make = (~name, ~color=?, ~size=30, ~style=ReactNative.Style.style(), ~onPress=?) => {
    <ReactNative.Pressable ?onPress> {_ => <Icon name ?color size style />} </ReactNative.Pressable>
  }
}

module ListItem = {
  @react.component
  let make = (~onPress=_ => (), ~title, ~iconName=?, ~iconColor=?, ~selected=false) => {
    let theme = Paper.ThemeProvider.useTheme()

    let icon = _ =>
      iconName->Belt.Option.mapWithDefault(React.null, n => {
        <Icon name=n color=?iconColor />
      })
    makeListItem(~theme, ~onPress, ~title, ~left=icon, ~selected, ~height=50., ())
  }
}

module ListItemCustomIcon = {
  @react.component
  let make = (
    ~onPress=_ => (),
    ~title,
    ~left,
    ~right=?,
    ~selected=false,
    ~height=50.,
    ~description=?,
  ) => {
    let theme = Paper.ThemeProvider.useTheme()
    makeListItem(~theme, ~onPress, ~title, ~left, ~right?, ~selected, ~height, ~description?, ())
  }
}

module CustomListItem = {
  open Paper
  open Paper.ThemeProvider
  open ReactNative.Style
  @react.component
  let make = (
    ~left=React.null,
    ~center=React.null,
    ~right=React.null,
    ~height=50.,
    ~selected=false,
    ~onPress=?,
  ) => {
    let theme = useTheme()

    let backgroundColor = selected ? Colors.Light.scrim : theme->Theme.colors->Theme.Colors.surface

    <TouchableRipple
      rippleColor="red" style={style(~alignSelf=#stretch, ~marginVertical=4.->dp, ())} ?onPress>
      <Surface style={style(~borderRadius=4., ~backgroundColor, ())}>
        <Wrapper alignItems=#center style={style(~height=height->dp, ())}>
          <ReactNative.View style={style(~margin=8.->dp, ())}> {left} </ReactNative.View>
          <ReactNative.View style={style(~margin=8.->dp, ())}> {center} </ReactNative.View>
          <ReactNative.View style={style(~position=#absolute, ~right=0.->dp, ())}>
            {right}
          </ReactNative.View>
        </Wrapper>
      </Surface>
    </TouchableRipple>
  }
}

module Image = {
  @react.component
  let make = (~url: string, ~style, ~resizeMode) => {
    let source = ReactNative.Image.uriSource(~uri=url, ())
    <ReactNative.Image
      resizeMode style key=url source={source->ReactNative.Image.Source.fromUriSource}
    />
  }
}
