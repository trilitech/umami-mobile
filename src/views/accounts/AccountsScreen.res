@react.component
let make = (~navigation, ~route as _) => {
  let (accounts, _) = AccountsReducer.useAccountsDispatcher()
  let (selectedAccount, setSelectedAccount) = Store.useSelectedAccount()

  <>
    <TopBarAllScreens.WithRightIcon
      title="Accounts"
      logoName="plus"
      onPressLogo={() => navigation->NavStacks.OnBoard.Navigation.navigate("CreateAccount")}
    />
    <Container>
      <CommonComponents.Wrapper flexDirection=#column alignItems=#center>
        {accounts
        ->Belt.Array.map(a => {
          let selected = a.derivationPathIndex == selectedAccount
          <AccountListItem
            key={a.tz1->Pkh.toString}
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
                  nft: None,
                  tz1ForContact: None,
                  assetBalance: None,
                  tz1ForSendRecipient: None,
                  injectedAdress: None,
                  signedContent: None,
                },
              )
            }}
          />
        })
        ->React.array}
      </CommonComponents.Wrapper>
    </Container>
  </>
}
