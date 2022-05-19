// open Paper
open ReactNative.Style
open CommonComponents
open Paper

let vMargin = FormStyles.styles["verticalMargin"]
module DisplayNFT = {
  @react.component
  let make = (~token: Token.t) => {
    let navigate = NavUtils.useNavigateWithParams()

    switch Token.matchNftData(token) {
    | Some((url, _, description, name)) => {
        let url = Token.getNftUrl(url)

        <Container>
          <Wrapper flexDirection=#column justifyContent=#flexStart alignItems=#center>
            <Title style=vMargin> {React.string(name)} </Title>
            <Image
              url resizeMode=#contain style={style(~height=300.->dp, ~width=300.->dp, ())} key=url
            />
            <Text style=vMargin> {description->React.string} </Text>
            <Paper.FAB
              onPress={_ =>
                navigate(
                  "Send",
                  {
                    token: Some(token),
                    derivationIndex: None,
                    tz1FromQr: None,
                  },
                )->ignore}
              icon={Paper.Icon.name("arrow-top-right-thin")}
            />
          </Wrapper>
        </Container>
      }
    | None => React.null
    }
    // let url = Token.getNftUrl(token.token.metadata.displayUri)
    // let source = Image.uriSource(~uri=url, ())

    // {
    //   <ReactNative.Image
    //     resizeMode=#contain
    //     style={style(~flex=1., ())}
    //     key=url
    //     source={source->ReactNative.Image.Source.fromUriSource}
    //   />
    // }
  }
}

@react.component
let make = (~navigation as _, ~route) => {
  let token = NavUtils.getToken(route)

  token->Belt.Option.mapWithDefault(React.null, token => <DisplayNFT token />)
}
