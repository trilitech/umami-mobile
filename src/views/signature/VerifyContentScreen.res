open Paper
open Belt
open ReactNative.Style

module NotOwned = {
  @react.component
  let make = () => {
    <Title> {"Nft not owned by signer!"->React.string} </Title>
  }
}

module SingedContentBase = {
  @react.component
  let make = (~signerAddress, ~prettySigDate, ~content, ~isValid) => {
    <Container>
      {isValid
        ? <CommonComponents.Icon
            size=100
            color=Colors.Light.positive
            name="certificate"
            style={style(~alignSelf=#center, ())}
          />
        : <CommonComponents.Icon
            size=100
            color=Colors.Light.negative
            name="alert-circle"
            style={style(~alignSelf=#center, ())}
          />}
      <Caption> {"Signer account"->React.string} </Caption>
      <SigListItem tz1=signerAddress prettySigDate />
      {content}
    </Container>
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
  let make = (~prettySigDate, ~signerAddress: Pkh.t, ~nftUrl: string, ~name, ~isValid) => {
    let source = ReactNative.Image.uriSource(~uri=nftUrl, ())
    <SingedContentBase
      isValid
      signerAddress
      prettySigDate
      content={<>
        <Title style={array([style(~alignSelf=#center, ()), StyleUtils.makeVMargin(~size=2, ())])}>
          {name->React.string}
        </Title>
        <FastImage
          source
          resizeMode=#contain
          style={style(~height=300.->dp, ~width=300.->dp, ~alignSelf=#center, ())}
        />
      </>}
    />
  }
}

module SignedNFTDisplay = {
  @react.component
  let make = (~signed: SignedData.t, ~signatureDate, ~nft: Token.tokenNFT) => {
    let (_, m) = nft
    let tz1 = signed.pk->Pkh.buildFromPk

    let date = signatureDate->Moment.getRelativeDate
    <SignedNFTDisplay2
      isValid={signed->SignUtils.checkIsValid}
      prettySigDate=date
      name=m.name
      nftUrl=m.displayUri
      signerAddress=tz1
    />
  }
}
module SignedNFT = {
  @react.component
  let make = (~timeStampedNft: TimestampedData.t<Token.nftInfo>, ~signed: SignedData.t) => {
    let {data, date} = timeStampedNft

    let tz1 = signed.pk->Pkh.buildFromPk

    let isTestNet = Store.useIsTestNet()

    let queryResult = ReactQuery.useQuery(
      ReactQuery.queryOptions(
        ~queryFn=_ => TzktAPI.getNft(~tz1, ~nftInfo=data, ~isTestNet),
        ~queryKey="nft",
        ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
        (),
      ),
    )

    let {data, isLoading, isError, error} = queryResult

    let el = if isLoading {
      <ActivityIndicator />
    } else if isError {
      Js.Console.warn(error)
      React.null
    } else {
      //Bad
      data->Belt.Option.mapWithDefault(<NotOwned />, nft => {
        nft->Belt.Option.mapWithDefault(<NotOwned />, nft => {
          <SignedNFTDisplay signed signatureDate=date nft />
        })
      })
    }

    <Container> {el} </Container>
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let signed = NavUtils.getSignedContent(route)
  signed->Helpers.reactFold(signed =>
    signed.content
    ->TimestampedNft.Decode.decode
    ->Helpers.resultToOption
    ->Option.mapWithDefault(<Generic signed />, timeStampedNft =>
      <SignedNFT timeStampedNft signed />
    )
  )
}
