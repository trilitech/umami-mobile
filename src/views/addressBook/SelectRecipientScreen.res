open Belt

let getCardName = c => {
  open AccountOrContact
  switch c {
  | ContactCard(c) => c.name
  | AccountCard(c) => c.name
  }
}

module SelectedRecipients = {
  @react.component
  let make = (~contacts: array<AccountOrContact.t>, ~search) => {
    let navigateWithParams = NavUtils.useNavigateWithParams()

    let cards = contacts->FormUtils.filterBySearch(getCardName, search)

    let handleTz1 = tz1 => {
      navigateWithParams(
        "Send",
        {
          tz1ForContact: None,
          derivationIndex: None,
          nft: None,
          assetBalance: None,
          tz1ForSendRecipient: tz1->Some,
          injectedAdress: None,
          signedContent: None,
        },
      )
    }
    <Container noVPadding=true>
      <ReactNative.ScrollView>
        {cards == []
          ? <NoResult search />
          : cards
            ->Array.map(c =>
              switch c {
              | ContactCard(c) =>
                <ContactListItem
                  key={c.tz1->Pkh.toString} contact=c onPress={_ => handleTz1(c.tz1)}
                />
              | AccountCard(a) =>
                <AccountListItem
                  key={a.tz1->Pkh.toString} account=a onPress={_ => handleTz1(a.tz1)}
                />
              }
            )
            ->React.array}
      </ReactNative.ScrollView>
    </Container>
  }
}

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  let (search, setSearch) = React.useState(_ => "")
  let allContacts = Store.useAccountsAndContacts()

  let navigateWithParams = NavUtils.useNavigateWithParams()

  <>
    <TopBarAllScreens.WithRightIcon
      title="Recipients"
      logoName="plus"
      onPressLogo={() =>
        navigateWithParams(
          "NewRecipient",
          {
            tz1ForContact: None,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: None,
          },
        )}
    />
    <Paper.Searchbar
      placeholder="Search recipient"
      onChangeText={t => setSearch(_ => t)}
      value=search
      onIconPress={t => setSearch(_ => "")}
      style={StyleUtils.makeVMargin()}
    />
    <SelectedRecipients contacts=allContacts search />
  </>
}
