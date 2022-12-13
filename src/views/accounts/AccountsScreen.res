@react.component
let make = (~navigation, ~route as _) => {
  let (accounts, _) = Store.useAccountsDispatcher()
  let (selectedAccount, setSelectedAccount) = Store.useSelectedAccount()

  <>
    <TopBarAllScreens.WithRightIcon
      title="Accounts"
      logoName="plus"
      onPressLogo={() => navigation->NavStacks.OnBoard.Navigation.navigate("CreateAccount")}
    />
    <ReactNative.ScrollView>
      <Container>
        {accounts
        ->Belt.Array.map(a => {
          let selected =
            selectedAccount->Belt.Option.mapWithDefault(false, selectedAccount =>
              a.derivationPathIndex == selectedAccount.derivationPathIndex
            )
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
                  beaconRequest: None,
                  browserUrl: None,
                },
              )
            }}
          />
        })
        ->React.array}
      </Container>
    </ReactNative.ScrollView>
  </>
}
