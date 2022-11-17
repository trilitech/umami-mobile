open CommonComponents
open SignedData

let useAccountByPk = () => {
  let (accounts, _) = Store.useAccounts()
  pk => accounts->Belt.Array.getBy(a => a.pk === pk)
}

@react.component
let make = (~signed) => {
  let accountByPk = useAccountByPk()
  let account = accountByPk(signed.pk->Pk.unsafeBuild)

  account->Helpers.reactFold(account => {
    <InstructionsContainer
      instructions="Have the QR code scanned with Umami mobile in order to read your signature.">
      <Container>
        <Paper.Caption style={ReactNative.Style.style(~alignSelf=#flexStart, ())}>
          {"Signer account"->React.string}
        </Paper.Caption>
        <AccountListItem account disabled=true />
        <Wrapper justifyContent=#center style={StyleUtils.makeVMargin(~size=3, ())}>
          <Qr value={signed->SignedData.serialise} size=260 />
        </Wrapper>
      </Container>
    </InstructionsContainer>
  })
}
