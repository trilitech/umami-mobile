module NftCard = {
  open Paper

  open ReactNative

  open ReactNative.Style
  @react.component
  let make = (~url, ~name, ~onPress) => {
    let url = Token.getNftUrl(url)
    let source = Image.uriSource(~uri=url, ())
    <TouchableRipple
      style={array([unsafeStyle({"width": "45%"}), style(~height=200.->dp, ())])} onPress>
      <Surface style={array([unsafeStyle({"width": "100%"}), style(~height=240.->dp, ())])}>
        {<Image
          resizeMode=#contain
          style={style(~flex=1., ())}
          key=url
          source={source->ReactNative.Image.Source.fromUriSource}
        />}
        <Title> {name->React.string} </Title>
      </Surface>
    </TouchableRipple>
  }
}

open ReactNative
open Style
open CommonComponents
module NftGallery = {
  @react.component
  let make = (~tokens: array<Token.t>) => {
    let navigate = NavUtils.useNavigateWithParams()

    <>
      <Paper.Searchbar value="search" style={FormStyles.styles["verticalMargin"]} />
      <Wrapper style={style(~flexWrap=#wrap, ~justifyContent=#spaceBetween, ())}>
        {tokens
        ->Belt.Array.map(t => {
          switch Token.matchNftData(t) {
          | Some((displayUri, _, _, name)) =>
            <NftCard
              onPress={_ => {
                navigate("NFT", {derivationIndex: 0, token: Some(t)})->ignore
              }}
              key=displayUri
              url=displayUri
              name
            />

          | None => React.null
          }
        })
        ->React.array}
      </Wrapper>
    </>
  }
}

module PureNfts = {
  @react.component
  let make = (~account: Store.account) => {
    if Token.hasNfts(account.tokens) {
      <NftGallery tokens=account.tokens />
    } else {
      <DefaultView icon="diamond-stone" title="NFT" subTitle="You have no nfts yet..." />
    }
  }
}

@react.component
let make = () => {
  let account = Store.useActiveAccount()
  switch account {
  | Some(account) => <PureNfts account />
  | None => React.null
  }
}
