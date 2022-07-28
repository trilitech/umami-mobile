open Paper
open Belt
open CommonComponents
open ReactNative.Style

module Tz1WithAdd = {
  @react.component
  let make = (
    ~tz1,
    ~textRender=text => <Text> {text->React.string} </Text>,
    ~addUserIconSize=15,
  ) => {
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
              token: None,
              assetBalance: None,
            },
          )}
      />
    </Wrapper>
  }
}

let useAliasDisplay = (
  ~textRender=text => <Text> {text->React.string} </Text>,
  ~addUserIconSize=?,
  (),
) => {
  let getAlias = Alias.useGetAlias()

  tz1 => {
    getAlias(tz1)->Option.mapWithDefault(<Tz1WithAdd ?addUserIconSize tz1 textRender />, alias => {
      textRender(alias.name)
    })
  }
}
