open Paper
open CommonComponents

module Base = {
  @react.component
  let make = (~onPressGoBack=?, ~title=?, ~right=?) => {
    <TopBarPlain
      left={<>
        {onPressGoBack->Helpers.reactFold(onPressGoBack =>
          <PressableIcon onPress={_ => onPressGoBack()} name="chevron-left" />
        )}
      </>}
      center={title->Helpers.reactFold(title => <Text> {React.string(title)} </Text>)}
      ?right
    />
  }
}

module WithRightIcon = {
  @react.component
  let make = (~title, ~logoName, ~onPressLogo, ~disabled=false) => {
    let goBack = NavUtils.useGoBack()
    <Base onPressGoBack=goBack title right={<RightLogoForTopBar disabled logoName onPressLogo />} />
  }
}

@react.component
let make = (~title, ~right=?) => {
  let goBack = NavUtils.useGoBack()
  <Base onPressGoBack={goBack} title ?right />
}
