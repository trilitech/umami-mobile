open ReactNative.Style
open CommonComponents
open Paper
let vMargin = StyleUtils.makeVMargin()

module DisplayNFT = {
  @react.component
  let make = (~token: Token.tokenNFT, ~onSign) => {
    let navigate = NavUtils.useNavigateWithParams()

    let (b, metadata) = token
    let {displayUri, name, description} = metadata

    let url = displayUri
    let source = ReactNative.Image.uriSource(~uri=url, ())
    let imageSize = ReactNative.Dimensions.get(#window).width
    let editionsTextColor = UmamiThemeProvider.usePlaceHolderColor()
    <ReactNative.ScrollView>
      <Container>
        <Wrapper flexDirection=#column justifyContent=#flexStart alignItems=#center>
          <Headline style=vMargin> {React.string(name)} </Headline>
          <FastImage
            source
            resizeMode=#contain
            style={style(~height=imageSize->dp, ~width=imageSize->dp, ())}
            key=url
          />
          <Text style=vMargin> {description->React.string} </Text>
          <Text
            style={array([
              StyleUtils.makeVMargin(~size=2, ()),
              style(~color=editionsTextColor, ()),
            ])}>
            {("Editions: " ++ b.balance->Js.Int.toString)->React.string}
          </Text>
          <Wrapper style={StyleUtils.makeVMargin(~size=1, ())}>
            <Paper.FAB
              style={StyleUtils.makeHMargin(~size=2, ())}
              onPress={_ => onSign()}
              icon={Paper.Icon.name("certificate")}
            />
            <Paper.FAB
              style={StyleUtils.makeHMargin(~size=2, ())}
              onPress={_ =>
                navigate(
                  "Send",
                  {
                    nft: Some(token),
                    derivationIndex: None,
                    tz1ForContact: None,
                    assetBalance: None,
                    tz1ForSendRecipient: None,
                    injectedAdress: None,
                    signedContent: None,
                    beaconRequest: None,
                  },
                )->ignore}
              icon={Paper.Icon.name("arrow-top-right-thin")}
            />
          </Wrapper>
        </Wrapper>
      </Container>
    </ReactNative.ScrollView>
  }
}

let makePayload = (token: Token.tokenNFT): TimestampedData.t<Token.nftInfo> => {
  date: Js.Date.make()->Js.Date.toISOString,
  data: token->Token.getNftInfo,
}

module SignableNFT = {
  @react.component
  let make = (~token) =>
    <ContentSigner
      renderForm={(~onSubmit) =>
        <DisplayNFT token onSign={() => token->makePayload->JSONparse.stringify->onSubmit} />}
    />
}

@react.component
let make = (~navigation as _, ~route) => {
  let token = NavUtils.getNft(route)

  token->Belt.Option.mapWithDefault(React.null, token => <SignableNFT token />)
}
