open Paper
open Belt
open ReactNative.Style

module SingedContentBase = {
  @react.component
  let make = (~signerAddress, ~prettySigDate, ~content, ~isValid) => {
    let goBack = NavUtils.useGoBack()

    <ReactNative.ScrollView>
      <Container>
        {isValid
          ? <CommonComponents.Icon
              size=100
              color=Colors.Light.positive
              name="certificate"
              style={style(~alignSelf=#center, ())}
            />
          : <ErrorMsg message="Invalid signature!" />}
        <Caption> {"Signer account"->React.string} </Caption>
        <SigListItem tz1=signerAddress prettySigDate />
        {content}
        <Button
          style={StyleUtils.makeTopMargin(~size=2, ())} mode=#outlined onPress={_ => goBack()}>
          {"Dismiss"->React.string}
        </Button>
      </Container>
    </ReactNative.ScrollView>
  }
}

module Generic = {
  @react.component
  let make = (~signed: SignedData.t) => {
    let signerAddress = signed.pk->Pkh.buildFromPk

    let backgroundColor = UmamiThemeProvider.useSurfaceColor()
    <SingedContentBase
      isValid={signed->SignUtils.checkIsValid}
      signerAddress
      prettySigDate=""
      content={<>
        <Caption> {"Content"->React.string} </Caption>
        <Card style={style(~borderRadius=4., ~backgroundColor, ~padding=8.->dp, ())}>
          <Text> {signed.content->React.string} </Text>
        </Card>
      </>}
    />
  }
}

module SignedNFTDisplay2 = {
  @react.component
  let make = (~prettySigDate, ~signerAddress: Pkh.t, ~nft: Token.tokenNFT, ~isValid) => {
    let (b, m) = nft
    let source = ReactNative.Image.uriSource(~uri=m.displayUri, ())
    open CommonComponents
    <SingedContentBase
      isValid
      signerAddress
      prettySigDate
      content={<>
        <DataInRow title="Contract" content={b.contract->Helpers.formatHash()} />
        <DataInRow title="Token ID" content={b.tokenId} />
        <DataInRow title="Editions" content={b.balance->Belt.Int.toString} />
        <Title style={array([style(~alignSelf=#center, ()), StyleUtils.makeVMargin(~size=2, ())])}>
          {m.name->React.string}
        </Title>
        <FastImage
          source
          resizeMode=#contain
          style={style(~height=250.->dp, ~width=250.->dp, ~alignSelf=#center, ())}
        />
      </>}
    />
  }
}

module SignedNFTDisplay = {
  @react.component
  let make = (~signed: SignedData.t, ~signatureDate, ~nft: Token.tokenNFT) => {
    let tz1 = signed.pk->Pkh.buildFromPk

    let date = signatureDate->Moment.getRelativeDate
    <SignedNFTDisplay2
      isValid={signed->SignUtils.checkIsValid} prettySigDate=date nft signerAddress=tz1
    />
  }
}
module SignedNFT = {
  @react.component
  let make = (~timeStampedNft: TimestampedData.t<Token.nftInfo>, ~signed: SignedData.t) => {
    let {data, date} = timeStampedNft

    let tz1 = signed.pk->Pkh.buildFromPk

    let (network, _) = Store.useNetwork()
    let (nodeIndex, _) = Store.useNodeIndex()

    let opts = {
      "queryFn": _ => TzktAPI.getNft(~tz1, ~nftInfo=data, ~network, ~nodeIndex),
      "queryKey": "nft certificate " ++ data.tokenId,
      "cacheTime": 0,
    }

    // need to use Obj.magic since cacheTime not supported yet in binding
    let queryResult = ReactQuery.useQuery(opts->Obj.magic)

    let {data, isLoading, isError, error} = queryResult

    if isLoading {
      <ActivityIndicator />
    } else if isError {
      error
      ->Helpers.nullToOption
      ->Helpers.reactFold(error =>
        <ErrorMsg message={`Failed to fetch nft. Reason ${error->Helpers.getMessage}`} />
      )
    } else {
      data->Helpers.reactFold(nft =>
        switch nft {
        | Some(nft) => <SignedNFTDisplay signed signatureDate=date nft />
        | None => <ErrorMsg message={"Nft not owned by signer!"} />
        }
      )
    }
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  route
  ->NavUtils.getSignedContent
  ->Helpers.reactFold(signed =>
    signed.content
    ->TimestampedNft.Decode.decode
    ->Helpers.resultToOption
    ->Option.mapWithDefault(<Generic signed />, timeStampedNft =>
      <SignedNFT timeStampedNft signed />
    )
  )
}
