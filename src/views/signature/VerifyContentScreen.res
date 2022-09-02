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

module SignedNFTDisplay = {
  @react.component
  let make = (~signed: SignedData.t, ~age, ~nft: Token.tokenNFT) => {
    let (_, m) = nft
    let tz1 = signed.pk->Pkh.buildFromPk

    let source = ReactNative.Image.uriSource(~uri=m.displayUri, ())
    <Wrapper flexDirection=#column alignItems=#center>
      <Headline> {React.string("Signed " ++ age->Js.Float.toString ++ " Seconds ago")} </Headline>
      <Headline> {React.string("By " ++ tz1->Pkh.toString)} </Headline>
      <FastImage source resizeMode=#contain style={style(~height=300.->dp, ~width=300.->dp, ())} />
      <Text style={StyleUtils.makeVMargin()}> {signed.content->React.string} </Text>
      {renderStatus(signed)}
    </Wrapper>
  }
}

module SignedNFT = {
  @react.component
  let make = (~timeStampedNft: TimestampedData.t<Token.nftInfo>, ~signed: SignedData.t) => {
    let {data, date} = timeStampedNft

    let tz1 = signed.pk->Pkh.buildFromPk

    let age = React.useMemo1(() => getMillisecondsFromSig(date), [date])

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
          <SignedNFTDisplay signed age nft />
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
