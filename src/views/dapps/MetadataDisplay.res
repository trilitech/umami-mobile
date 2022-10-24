open CommonComponents
open ReBeacon
open Paper
open ReactNative.Style

module Metadata = {
  @react.component
  let make = (~appMetadata: appMetadata) => {
    <>
      <Title> {appMetadata.name->React.string} </Title>
      <Caption> {appMetadata.senderId->React.string} </Caption>
      {appMetadata.icon->Helpers.reactFold(icon => {
        <FastImage
          source={ReactNative.Image.uriSource(~uri=icon, ())}
          resizeMode=#contain
          style={array([
            StyleUtils.makeVMargin(),
            style(~height=60.->dp, ~width=60.->dp, ()),
            StyleUtils.makeLeftMargin(),
          ])}
        />
      })}
    </>
  }
}

module Header = {
  @react.component
  let make = (~title, ~appMetadata, ~network=?) => {
    <Wrapper flexDirection=#column justifyContent=#center style={StyleUtils.makeBottomMargin()}>
      <Headline> {title->React.string} </Headline>
      {network->Helpers.reactFold(network => {
        <Caption> {network->React.string} </Caption>
      })}
      <Metadata appMetadata />
    </Wrapper>
  }
}
