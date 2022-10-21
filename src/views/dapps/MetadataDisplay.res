open CommonComponents
open ReBeacon
open Paper
open ReactNative.Style
@react.component
let make = (~appMetadata: appMetadata) => {
  <Wrapper flexDirection=#column justifyContent=#center>
    <Title> {appMetadata.name->React.string} </Title>
    <Title> {appMetadata.senderId->React.string} </Title>
    {appMetadata.icon->Helpers.reactFold(icon => {
      <FastImage
        source={ReactNative.Image.uriSource(~uri=icon, ())}
        resizeMode=#contain
        style={array([style(~height=40.->dp, ~width=40.->dp, ()), StyleUtils.makeLeftMargin()])}
      />
    })}
  </Wrapper>
}
