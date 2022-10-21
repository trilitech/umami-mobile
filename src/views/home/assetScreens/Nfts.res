module NftCard = {
  open Paper

  open ReactNative.Style
  @react.component
  let make = (~url, ~name, ~onPress) => {
    <TouchableRipple style={array([unsafeStyle({"width": "45%"})])} onPress>
      <Surface style={array([unsafeStyle({"width": "100%"}), style(~height=240.->dp, ())])}>
        {<FastImage
        // resizeMode=#contain
          style={style(~flex=1., ())} key=url source={ReactNative.Image.uriSource(~uri=url, ())}
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

let tokenToElement = (navigate, tokenNFT: Token.tokenNFT) => {
  open NavStacks.OnboardParams
  let (_, metadata) = tokenNFT

  let {name, displayUri} = metadata
  <NftCard
    onPress={_ => {
      navigate(
        "NFT",
        {
          derivationIndex: None,
          nft: Some(tokenNFT),
          tz1ForContact: None,
          assetBalance: None,
          tz1ForSendRecipient: None,
          injectedAdress: None,
          signedContent: None,
          beaconRequest: None,
        },
      )->ignore
    }}
    key=displayUri
    url=displayUri
    name
  />
}

module NftGallery = {
  @react.component
  let make = (~tokens: array<Token.tokenNFT>) => {
    let navigate = NavUtils.useNavigateWithParams()
    let (search, setSearch) = React.useState(_ => "")

    let nftEls =
      tokens
      ->FormUtils.filterBySearch(((_, metadata)) => metadata.name, search)
      ->Belt.Array.map(tokenToElement(navigate))

    <>
      <Paper.Searchbar
        placeholder="Search NFT"
        onChangeText={t => setSearch(_ => t)}
        value=search
        style={StyleUtils.makeBottomMargin()}
        onIconPress={t => setSearch(_ => "")}
      />
      <ScrollView>
        <Wrapper style={style(~flexWrap=#wrap, ~justifyContent=#spaceBetween, ())}>
          {if nftEls == [] {
            <NoResult search />
          } else {
            nftEls->React.array
          }}
        </Wrapper>
      </ScrollView>
    </>
  }
}

module PureNfts = {
  @react.component
  let make = (~account: Account.t) => {
    let nfts = account.tokens->Token.filterNFTs

    if nfts == [] {
      <DefaultView
        icon="diamond-stone"
        title="Your NFTs will appear here"
        subTitle="Umami will automatically discover any NFT you possess"
      />
    } else {
      <Container> <NftGallery tokens=nfts /> </Container>
    }
  }
}

@react.component
let make = () => {
  Store.useWithAccount(account => <PureNfts account />)
}
