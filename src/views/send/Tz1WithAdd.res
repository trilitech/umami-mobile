open Paper
open CommonComponents
open ReactNative.Style

@react.component
let make = (
  ~tz1: Pkh.t,
  ~textRender=text => <Text> {text->React.string} </Text>,
  ~addUserIconSize=15,
) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  <Wrapper>
    {textRender(tz1->Pkh.toPretty)}
    <PressableIcon
      name="account-plus"
      style={style(~marginLeft=8.->dp, ~marginVertical=-8.->dp, ())}
      size=addUserIconSize
      onPress={_ =>
        navigateWithParams(
          "EditContact",
          {
            tz1ForContact: tz1->Some,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
          },
        )}
    />
  </Wrapper>
}
