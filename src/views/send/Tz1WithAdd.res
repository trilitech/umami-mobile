open Paper
open CommonComponents
open ReactNative.Style

@react.component
let make = (~tz1, ~textRender=text => <Text> {text->React.string} </Text>, ~addUserIconSize=15) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  <Wrapper>
    {textRender(TezHelpers.formatTz1(tz1))}
    <PressableIcon
      name="account-plus"
      style={style(~marginLeft=8.->dp, ~marginVertical=-8.->dp, ())}
      size=addUserIconSize
      onPress={_ =>
        navigateWithParams(
          "EditContact",
          {
            tz1: tz1->Some,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
          },
        )}
    />
  </Wrapper>
}
