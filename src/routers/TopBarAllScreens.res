open Paper
open CommonComponents

@react.component
let make = (~onPressGoBack=?, ~title=?) => {
  <TopBarPlain
    left={<>
      {onPressGoBack->Helpers.reactFold(onPressGoBack =>
        <PressableIcon onPress={_ => onPressGoBack()} name="chevron-left" />
      )}
    </>}
    center={title->Helpers.reactFold(title => <Text> {React.string(title)} </Text>)}
  />
}
