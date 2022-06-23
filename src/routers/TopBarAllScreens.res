open Paper
open CommonComponents

@react.component
let make = (~onPressGoBack, ~title) => {
  <TopBarPlain
    left={<>
      <PressableIcon onPress={_ => onPressGoBack()} name="chevron-left" />
      <Text> {React.string(title)} </Text>
    </>}
  />
}
