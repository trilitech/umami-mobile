// open Paper
open ReactNative.Style
open CommonComponents
open Paper

let vMargin = FormStyles.styles["verticalMargin"]
module DisplayNFT = {
  @react.component
  let make = (~token: Token.t) => {
    let navigate = NavUtils.useNavigateWithParams()
    let metadata = token.token.metadata
    let {displayUri, description} = metadata

    switch (displayUri, description) {
    | (Some(url), Some(description)) => {
        let url = Token.getNftUrl(url)

        <Container>
          <Wrapper flexDirection=#column justifyContent=#flexStart alignItems=#center>
            <Title style=vMargin> {React.string(metadata.name)} </Title>
            <Image
              url resizeMode=#contain style={style(~height=300.->dp, ~width=300.->dp, ())} key=url
            />
            <Text style=vMargin> {description->React.string} </Text>
            <Paper.FAB
              onPress={_ => navigate("Send", {token: Some(token), derivationIndex: 0})->ignore}
              icon={Paper.Icon.name("arrow-top-right-thin")}
            />
          </Wrapper>
        </Container>
      }
    | _ => React.null
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
