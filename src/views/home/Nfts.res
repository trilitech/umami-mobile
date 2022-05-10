let getNftUrl = (ipfsUrl: string) => ipfsUrl->Js.String2.replace("ipfs://", "https://ipfs.io/ipfs/")

let hasNfts = (tokens: array<Token.t>) => tokens->Belt.Array.length != 0

module NftCard = {
  open Paper

  open ReactNative

  open ReactNative.Style
  @react.component
  let make = (~url, ~name) => {
    let url = getNftUrl(url)
    let source = Image.uriSource(~uri=url, ())
    <Surface style={array([unsafeStyle({"width": "45%"}), style(~height=200.->dp, ())])}>
      {<Image
        resizeMode=#contain
        style={style(~flex=1., ~height=200.->dp, ())}
        key=url
        source={source->ReactNative.Image.Source.fromUriSource}
      />}
      <Title> {name->React.string} </Title>
    </Surface>
  }
}

open ReactNative
open Style
open CommonComponents
module NftGallery = {
  @react.component
  let make = (~tokens: array<Token.t>) => {
    <>
      <Paper.Searchbar value="search" style={FormStyles.styles["verticalMargin"]} />
      <Wrapper style={style(~flexWrap=#wrap, ~justifyContent=#spaceBetween, ())}>
        {tokens
        ->Belt.Array.map(d => {
          let metadata = d.token.metadata
          switch (metadata.thumbnailUri, metadata.description) {
          | (Some(url), Some(_description)) => <NftCard key=url url name=metadata.name />
          | _ => React.null
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
    if hasNfts(account.tokens) {
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
