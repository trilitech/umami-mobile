open Belt
open CommonComponents

open Paper

module FilteredContacts = {
  @react.component
  let make = (~contacts: array<Contact.t>, ~search) => {
    let navigateWithParams = NavUtils.useNavigateWithParams()
    let contacts = contacts->FormUtils.filterBySearch(c => c.name, search)

    <Container noVPadding=true>
      <ReactNative.ScrollView>
        {contacts == []
          ? <NoResult search />
          : contacts
            ->Array.map(c =>
              <CustomListItem
                key=c.name
                center={<Text> {React.string(c.name)} </Text>}
                right={<ChevronRight />}
                onPress={_ =>
                  navigateWithParams(
                    "ShowContact",
                    {
                      tz1ForContact: c.tz1->Some,
                      derivationIndex: None,
                      nft: None,
                      assetBalance: None,
                      tz1ForSendRecipient: None,
                      injectedAdress: None,
                    },
                  )}
              />
            )
            ->React.array}
      </ReactNative.ScrollView>
    </Container>
  }
}

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  let (search, setSearch) = React.useState(_ => "")

  let contacts = Store.useContacts()

  let navigateWithParams = NavUtils.useNavigateWithParams()
  let gotToAddContact = () =>
    navigateWithParams(
      "EditContact",
      {
        tz1ForContact: None,
        derivationIndex: None,
        nft: None,
        assetBalance: None,
        tz1ForSendRecipient: None,
        injectedAdress: None,
      },
    )

  <>
    <TopBarAllScreens.WithRightIcon
      title="Address book" logoName="plus" onPressLogo={gotToAddContact}
    />
    {if contacts == [] {
      <DefaultView
        title="No contact" subTitle="Your contacts will appear here" icon="account-box"
      />
    } else {
      <>
        <Paper.Searchbar
          placeholder="Search contact"
          onChangeText={t => setSearch(_ => t)}
          value=search
          onIconPress={t => setSearch(_ => "")}
          style={StyleUtils.makeVMargin()}
        />
        {<FilteredContacts contacts search />}
      </>
    }}
  </>
}
