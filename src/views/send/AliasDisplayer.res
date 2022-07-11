open Paper
open Belt
open CommonComponents
open ReactNative.Style

let useAliasDisplay = (
  ~textRender=text => <Text> {text->React.string} </Text>,
  ~addUserIconSize=30,
  (),
) => {
  let getAlias = Alias.useGetAlias()
  let navigateWithParams = NavUtils.useNavigateWithParams()

  tz1 => {
    getAlias(tz1)->Option.mapWithDefault(
      <Wrapper>
        {textRender(TezHelpers.formatTz1(tz1))}
        <PressableIcon
          name="account-plus"
          style={style(~marginLeft=8.->dp, ())}
          size=addUserIconSize
          onPress={_ =>
            navigateWithParams(
              "EditContact",
              {
                tz1: tz1->Some,
                derivationIndex: None,
                token: None,
              },
            )}
        />
      </Wrapper>,
      alias => {
        textRender(alias.name)
      },
    )
  }
}
