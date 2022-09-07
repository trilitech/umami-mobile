open Paper
open Belt
open ReactNative.Style

open CommonComponents

let valid = (~tz1: Pkh.t) => {
  <>
    <Text> {("Signed by " ++ tz1->Pkh.toString)->React.string} </Text>
    <CommonComponents.Icon color=Colors.Light.positive name="check" />
  </>
}

let invalid =
  <>
    <Text> {"Invalid"->React.string} </Text>
    <CommonComponents.Icon color=Colors.Light.negative name="alert-circle" />
  </>

let renderStatus = (signed: SignedData.t) =>
  <Wrapper>
    {signed->SignUtils.checkIsValid ? valid(~tz1=signed.pk->Pkh.buildFromPk) : invalid}
  </Wrapper>

module Generic = {
  @react.component
  let make = (~signed: SignedData.t) => {
    <Wrapper flexDirection=#column alignItems=#center>
      <Headline> {React.string("Signed data")} </Headline>
      <Title> {React.string("Content:")} </Title>
      <Text style={StyleUtils.makeVMargin()}> {signed.content->React.string} </Text>
      {renderStatus(signed)}
    </Wrapper>
  }
}

let getMillisecondsFromSig = (dateStr: string) => {
  let dateObj = Js.Date.fromString(dateStr)

  let then = dateObj->Js.Date.getTime
  let now = Js.Date.now()
  let diff = (now -. then) /. 1000.
  diff
}

module NotOwned = {
  @react.component
  let make = () => {
    <Title> {"Nft not owned by signer!"->React.string} </Title>
  }
}

module SignedNFTDisplay2 = {
  @react.component
  let make = (~prettySigDate, ~signerAddress: string, ~nftUrl: string, ~name) => {
    let source = ReactNative.Image.uriSource(~uri=nftUrl, ())
    <Wrapper flexDirection=#column alignItems=#center>
      <Headline> {React.string("Signed by" ++ signerAddress)} </Headline>
      <Title> {React.string({prettySigDate})} </Title>
      <CommonComponents.Icon size=100 color=Colors.Light.positive name="certificate" />
      <Title> {name->React.string} </Title>
      <FastImage source resizeMode=#contain style={style(~height=300.->dp, ~width=300.->dp, ())} />
    </Wrapper>
  }
}

module SignedNFTDisplay = {
  @react.component
  let make = (~signed: SignedData.t, ~signatureDate, ~nft: Token.tokenNFT) => {
    let (_, m) = nft
    let tz1 = signed.pk->Pkh.buildFromPk->Pkh.toPretty

    let date = signatureDate->Moment.getRelativeDate

    <SignedNFTDisplay2 prettySigDate=date name=m.name nftUrl=m.displayUri signerAddress=tz1 />
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
module Display = {
  @react.component
  let make = (~signed: SignedData.t) => {
    let timeStampedNft = signed.content->TimestampedNft.Decode.decode->Helpers.resultToOption

    timeStampedNft->Option.mapWithDefault(<Generic signed />, timeStampedNft =>
      <SignedNFT timeStampedNft signed />
    )
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let signed = NavUtils.getSignedContent(route)

  signed->Helpers.reactFold(signed => {
    <Display signed />
  })
}
