open ReactNative.Style

open Paper
@react.component
let make = (~navigation, ~route as _) => {
  let (accounts, _) = Store.useAccounts()
  let (selectedAccount, setSelectedAccount) = Store.useSelectedAccount()

  <Container>
    <CommonComponents.Wrapper flexDirection=#column alignItems=#center>
      {accounts
      ->Belt.Array.map(a => {
        let selected = switch selectedAccount {
        | Some(i) => i == a.derivationPathIndex
        | None => false
        }
        <AccountListItem
          key=a.tz1
          account=a
          selected
          onPress={_ => {
            navigation->NavStacks.OnBoard.Navigation.goBack()
            setSelectedAccount(a.derivationPathIndex)
          }}
          onPressEdit={_ => {
            navigation->NavStacks.OnBoard.Navigation.navigateWithParams(
              "EditAccount",
              {derivationIndex: a.derivationPathIndex},
            )
          }}
        />
      })
      ->React.array}
      <FAB
        style={style(~alignSelf=#center, ~marginVertical=20.->dp, ())}
        icon={Icon.name("plus")}
        onPress={_ => {
          navigation->NavStacks.OnBoard.Navigation.navigate("CreateAccount")
        }}
      />
    </CommonComponents.Wrapper>
  </Container>
}
