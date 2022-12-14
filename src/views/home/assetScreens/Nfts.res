module NftCard = {
  open Paper

  open ReactNative
  open ReactNative.Style
  @react.component
  let make = (~url, ~name, ~onPress, ~editions: int) => {
    <TouchableRipple style={array([unsafeStyle({"width": "48%"})])} onPress>
      <Surface
        style={array([
          StyleUtils.makeBottomMargin(),
          unsafeStyle({"width": "100%"}),
          style(~height=240.->dp, ~borderRadius=4., ()),
        ])}>
        {<FastImage
          resizeMode=#cover
          style={array([style(~flex=1., ~borderRadius=4., ())])}
          source={ReactNative.Image.uriSource(~uri=url, ())}
        />}
        <View style={StyleUtils.makeHMargin()}>
          <Title numberOfLines=1 style={array([style(~fontSize=16., ())])}>
            {name->React.string}
          </Title>
          <Caption> {`Editions: ${editions->Belt.Int.toString}`->React.string} </Caption>
        </View>
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
  let (base, metadata) = tokenNFT

  let {name, displayUri} = metadata
  <NftCard
    editions=base.balance
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
          browserUrl: None,
        },
      )->ignore
    }}
    key={base.contract ++ base.tokenId}
    url=displayUri
    name
  />
}

module NftGallery = {
  @react.component
  let make = (~tokens: array<Token.tokenNFT>) => {
    let navigate = NavUtils.useNavigateWithParams()
    let (search, setSearch) = React.useState(_ => "")

    let border = CommonComponents.useCustomBorder()
    let nftEls =
      tokens
      ->FormUtils.filterBySearch(((_, metadata)) => metadata.name, search)
      ->Belt.Array.map(tokenToElement(navigate))

    <>
      <Paper.Searchbar
        placeholder="Search NFT"
        onChangeText={t => setSearch(_ => t)}
        value=search
        style={array([border, StyleUtils.makeMargin()])}
        onIconPress={t => setSearch(_ => "")}
      />
      <ScrollView>
        <Container noVPadding=true>
          <Wrapper style={style(~flexWrap=#wrap, ~justifyContent=#spaceBetween, ())}>
            {if nftEls == [] {
              <NoResult search />
            } else {
              nftEls->React.array
            }}
          </Wrapper>
        </Container>
      </ScrollView>
    </>
  }
}

@react.component
let make = (~tokens) => {
  let nfts = tokens->Token.filterNFTs

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
