open Paper
open CommonComponents

module TopBarPlain = {
  open ReactNative.Style
  open UmamiThemeProvider
  @react.component
  let make = (~left=React.null, ~right=React.null, ~center=React.null, ~hideNetwork=false) => {
    let (network, _) = Store.useNetwork()
    let surfaceColor = useSurfaceColor()
    let errorColor = useErrorColor()
    let isTestNet = !(network == Mainnet)

    <Appbar.Header
      style={array([
        style(~backgroundColor=isTestNet ? errorColor : surfaceColor, ~justifyContent=#center, ()),
      ])}>
      <Wrapper style={style(~left=0.->dp, ~position=#absolute, ())}> {left} </Wrapper>
      {<Wrapper flexDirection=#column alignItems=#center>
        {center}
        {hideNetwork ? React.null : <Caption> {network->Network.toString->React.string} </Caption>}
      </Wrapper>}
      <Wrapper style={style(~right=0.->dp, ~position=#absolute, ())}> {right} </Wrapper>
    </Appbar.Header>
  }
}

module Base = {
  @react.component
  let make = (~onPressGoBack=?, ~title=?, ~right=?, ~hideNetwork=?, ~showLogo=false) => {
    <TopBarPlain
      ?hideNetwork
      left={<>
        {showLogo
          ? <UmamiBarTitle />
          : onPressGoBack->Helpers.reactFold(onPressGoBack =>
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
