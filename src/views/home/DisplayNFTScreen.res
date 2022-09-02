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
    <Container>
      <Wrapper flexDirection=#column justifyContent=#flexStart alignItems=#center>
        <Title style=vMargin> {React.string(name)} </Title>
        <FastImage
          source resizeMode=#contain style={style(~height=300.->dp, ~width=300.->dp, ())} key=url
        />
        <Text style=vMargin> {description->React.string} </Text>
        <Text style=vMargin> {("Editions: " ++ b.balance->Js.Int.toString)->React.string} </Text>
        <Wrapper>
          <Paper.FAB
            style={StyleUtils.makeHMargin()}
            onPress={_ => onSign()}
            icon={Paper.Icon.name("certificate")}
          />
          <Paper.FAB
            style={StyleUtils.makeHMargin()}
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
                },
              )->ignore}
            icon={Paper.Icon.name("arrow-top-right-thin")}
          />
        </Wrapper>
      </Wrapper>
    </Container>
  }
}

let makePayload = (token: Token.tokenNFT): TimestampedData.t<Token.nftInfo> => {
  date: Js.Date.make()->Js.Date.toISOString,
  data: token->Token.getNftInfo,
}

module SignableNFT = {
  @react.component
  let make = (~token) => {
    let sign = SignUtils.useSign()
    let notify = SnackBar.useNotification()

    sign->Helpers.reactFold(sign =>
      <ContentSigner
        sign
        notify
        renderForm={onSubmit =>
          <DisplayNFT token onSign={() => token->makePayload->JSONparse.stringify->onSubmit} />}
      />
    )
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let token = NavUtils.getNft(route)

  token->Belt.Option.mapWithDefault(React.null, token => <SignableNFT token />)
}
