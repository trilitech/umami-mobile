@react.component
let make = (~navigation, ~route as _) => {
  let (accounts, _) = AccountsReducer.useAccountsDispatcher()
  let (selectedAccount, setSelectedAccount) = Store.useSelectedAccount()

  <Container>
    <CommonComponents.Wrapper flexDirection=#column alignItems=#center>
      {accounts
      ->Belt.Array.map(a => {
        let selected = a.derivationPathIndex == selectedAccount
        <AccountListItem
          key=a.tz1
          account=a
          selected
          onPress={_ => {
            navigation->NavStacks.OnBoard.Navigation.goBack()
            setSelectedAccount(_ => a.derivationPathIndex)
          }}
          onPressEdit={_ => {
            navigation->NavStacks.OnBoard.Navigation.navigateWithParams(
              "EditAccount",
              {
                derivationIndex: Some(a.derivationPathIndex),
                token: None,
                tz1: None,
              },
            )
          }}
        />
      })
      ->React.array}
      <BigPlusBtn
        onPress={() => navigation->NavStacks.OnBoard.Navigation.navigate("CreateAccount")}
      />
    </CommonComponents.Wrapper>
  </Container>
}
