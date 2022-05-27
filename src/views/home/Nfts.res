module NftCard = {
  open Paper

  open ReactNative

  open ReactNative.Style
  @react.component
  let make = (~url, ~name, ~onPress) => {
    let url = Token.getNftUrl(url)
    let source = Image.uriSource(~uri=url, ())
    <TouchableRipple style={array([unsafeStyle({"width": "45%"})])} onPress>
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

let positiveBalance = (s: string) => {
  switch Belt.Int.fromString(s) {
  | Some(b) => b > 0
  | None => false
  }
}

let tokenToElement = (navigate, t: Token.t) => {
  open NavStacks.OnboardParams

  switch Token.matchNftData(t.token.metadata) {
  | Some((displayUri, _, _, name)) =>
    <NftCard
      onPress={_ => {
        navigate(
          "NFT",
          {
            derivationIndex: None,
            token: Some(t),
            tz1FromQr: None,
          },
        )->ignore
      }}
      key=displayUri
      url=displayUri
      name
    />

  | None => React.null
  }
}

let tokenNameContainsStr = (token: Token.t, str: string) => {
  open Js.String2
  switch Token.matchNftData(token.token.metadata) {
  | Some((_, _, _, name)) => name->toLowerCase->includes(str->toLowerCase)
  | None => false
  }
}
module NftGallery = {
  @react.component
  let make = (~tokens: array<Token.t>) => {
    let navigate = NavUtils.useNavigateWithParams()
    let (search, setSearch) = React.useState(_ => "")

    <>
      <Paper.Searchbar
        placeholder="Search NFT"
        onChangeText={t => setSearch(_ => t)}
        value=search
        style={FormStyles.styles["verticalMargin"]}
        onIconPress={t => setSearch(_ => "")}
      />
      <ScrollView>
        <Wrapper style={style(~flexWrap=#wrap, ~justifyContent=#spaceBetween, ())}>
          {tokens
          ->Belt.Array.keep(token => search == "" || tokenNameContainsStr(token, search))
          ->Belt.Array.map(tokenToElement(navigate))
          ->React.array}
        </Wrapper>
      </ScrollView>
    </>
  }
}

module PureNfts = {
  @react.component
  let make = (~account: Store.account) => {
    let nfts =
      account.tokens->Belt.Array.keep(Token.isNft)->Belt.Array.keep(t => positiveBalance(t.balance))

    if nfts == [] {
      <DefaultView
        icon="diamond-stone"
        title="Your NFTs will appear here"
        subTitle="Umami will automatically discover any NFT you possess"
      />
    } else {
      <NftGallery tokens=nfts />
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
