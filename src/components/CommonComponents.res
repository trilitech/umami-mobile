open ReactNative.Style
module type StyleModule = {
  let style: ReactNative.Style.t
}
module MakeWrapper = (Style: StyleModule) => {
  @react.component
  let make = (~children) => {
    <ReactNative.View style={Style.style}> {children} </ReactNative.View>
  }
}

let useCustomBorder = () => {
  let borderColor = UmamiThemeProvider.useDisabledColor()
  style(~borderColor, ~borderWidth=2., ~borderRadius=4., ())
}
module Wrapper = {
  open ReactNative
  @react.component
  let make = (
    ~children,
    ~flexDirection=#row,
    ~alignItems=#center,
    ~justifyContent=#flexStart,
    ~style as extraStyle=style(),
    ~testID=?,
  ) => {
    <View
      ?testID
      style={array([
        style(~display=#flex, ~alignItems, ~flexDirection, ~justifyContent, ()),
        extraStyle,
      ])}>
      children
    </View>
  }
}

module Icon = {
  @react.component
  let make = (~name, ~color=?, ~size=30, ~style as extraStyle=ReactNative.Style.style()) => {
    let theme = Paper.ThemeProvider.useTheme()

    open Paper
    open ThemeProvider
    open Theme
    let defaultIconColor = theme->colors->Colors.text
    <Paper.Avatar.Icon
      size
      color={color->Belt.Option.getWithDefault(defaultIconColor)}
      style={array([style(~backgroundColor="transparent", ()), extraStyle])}
      icon={Paper.Icon.name(name)}
    />
  }
}

module ChevronRight = {
  @react.component
  let make = () => <Icon name="chevron-right" />
}

module ChevronDown = {
  @react.component
  let make = () => <Icon name="chevron-down" />
}

module PressableIcon = {
  @react.component
  let make = (~name, ~color=?, ~size=30, ~style=ReactNative.Style.style(), ~onPress=() => ()) =>
    <Paper.IconButton style ?color onPress={_ => onPress()} icon={Paper.Icon.name(name)} size />
}

module CrossRight = {
  @react.component
  let make = (~onPress) => <PressableIcon size=16 name="window-close" onPress />
}

module ThreeDotsRight = {
  @react.component
  let make = (~onPress) => <PressableIcon size=16 name="dots-vertical" onPress />
}

module ListItemBase = {
  open Paper
  @react.component
  let make = (~height, ~left, ~center, ~right, ~transparent=false, ~backgroundColor, ~testID=?) => {
    let el =
      <Wrapper ?testID alignItems=#center style={style(~minHeight=height->dp, ())}>
        <ReactNative.View style={StyleUtils.makeHMargin()}> {left} </ReactNative.View>
        <ReactNative.View style={StyleUtils.makeHMargin()}> {center} </ReactNative.View>
        <ReactNative.View style={style(~position=#absolute, ~right=StyleUtils.u->dp, ())}>
          {right}
        </ReactNative.View>
      </Wrapper>

    let wrapped = transparent
      ? <ReactNative.View> {el} </ReactNative.View>
      : <Card style={style(~borderRadius=4., ~backgroundColor, ())}> {el} </Card>

    wrapped
  }
}

module CustomListItem = {
  open Paper
  open Paper.ThemeProvider
  @react.component
  let make = (
    ~left=React.null,
    ~center=React.null,
    ~right=React.null,
    ~height=#medium,
    ~selected=false,
    ~onPress=?,
    ~disabled=false,
    ~transparent=false,
    ~style as extraStyle=style(),
    ~showBorder=false,
    ~testID=?,
  ) => {
    let height = switch height {
    | #large => 96.
    | #medium => 72.
    | #small => 56.
    | #custom(height) => height->Belt.Int.toFloat
    }

    let theme = useTheme()

    let borderStyle = useCustomBorder()

    let backgroundColor = selected ? Colors.Light.scrim : theme->Theme.colors->Theme.Colors.surface
    <TouchableRipple
      disabled
      rippleColor="red"
      style={array([
        style(~alignSelf=#stretch, ()),
        StyleUtils.makeBottomMargin(),
        extraStyle,
        showBorder ? borderStyle : style(),
      ])}
      ?onPress>
      <ListItemBase
        ?testID height left center right={disabled ? React.null : right} transparent backgroundColor
      />
    </TouchableRipple>
  }
}

module ListItem = {
  @react.component
  let make = (~onPress=_ => (), ~title, ~iconName=?, ~iconColor=?, ~selected=false, ~testID=?) => {
    let icon = iconName->Belt.Option.mapWithDefault(React.null, n => {
      <Icon name=n color=?iconColor />
    })

    open Paper
    <CustomListItem
      ?testID height=#small left=icon selected onPress center={<Text> {title->React.string} </Text>}
    />
  }
}
module NicerIconBtn = {
  @react.component
  let make = (~onPress, ~small=true, ~iconName, ~style as extraStyle=style()) => {
    let textColor = UmamiThemeProvider.useTextColor()
    <Paper.FAB
      style={array([extraStyle, style(~backgroundColor="transparent", ())])}
      color={textColor}
      small
      onPress
      icon={Paper.Icon.name(iconName)}
    />
  }
}

module LabeledRadio = {
  @react.component
  let make = (~status, ~value, ~label, ~onPress=_ => ()) =>
    <CustomListItem
      selected={status == #checked}
      onPress={_ => onPress()}
      left={<Wrapper>
        <Paper.RadioButton.Android status value onPress={_ => onPress()} />
        <Paper.Caption> {label->React.string} </Paper.Caption>
      </Wrapper>}
    />
}

module CheckBoxAndText = {
  @react.component
  let make = (~status, ~setStatus, ~text) => {
    open Paper
    <Wrapper style={StyleUtils.makeVMargin(~size=2, ())}>
      <Checkbox.Android
        status onPress={_ => setStatus(s => s == #unchecked ? #checked : #unchecked)}
      />
      <Text style={ReactNative.Style.style(~flex=1., ())}> {text->React.string} </Text>
    </Wrapper>
  }
}

module Badge = {
  @react.component
  let make = (~children, ~style as extraStyle=style()) => {
    let borderColor = UmamiThemeProvider.useDisabledColor()
    <ReactNative.View
      style={array([style(~borderWidth=2., ~borderRadius=4., ~borderColor, ()), extraStyle])}>
      {children}
    </ReactNative.View>
  }
}

module RoundImage = {
  @react.component
  let make = (~url, ~size) => {
    let source = ReactNative.Image.uriSource(~uri=url, ())
    <FastImage
      source
      resizeMode=#cover
      style={style(
        ~borderRadius=75.,
        ~height=size->Js.Int.toFloat->dp,
        ~width=size->Js.Int.toFloat->dp,
        (),
      )}
    />
  }
}

module CenteredSpinner = {
  @react.component
  let make = () => {
    <Wrapper style={StyleUtils.makeTopMargin(~size=3, ())} justifyContent=#center>
      <Paper.ActivityIndicator />
    </Wrapper>
  }
}
