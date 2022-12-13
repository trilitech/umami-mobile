open Belt
open CommonComponents

open Paper

module ContactTile = {
  @react.component
  let make = (~contact: Contact.t) => {
    let navigateWithParams = NavUtils.useNavigateWithParams()
    let getTezosDomain = Store.useGetTezosDomain()
    let domain = getTezosDomain(contact.tz1->Pkh.toString)
    <CustomListItem
      left={<AvatarDisplay tz1=contact.tz1 size=50 />}
      center={<Wrapper>
        <Text> {React.string(contact.name)} </Text>
        {domain->Helpers.reactFold(domain =>
          <TzDomainBadge domain style={StyleUtils.makeLeftMargin()} />
        )}
      </Wrapper>}
      right={<ChevronRight />}
      onPress={_ =>
        navigateWithParams(
          "ShowContact",
          {
            tz1ForContact: contact.tz1->Some,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: None,
            beaconRequest: None,
            browserUrl: None,
          },
        )}
    />
  }
}

module FilteredContacts = {
  @react.component
  let make = (~contacts: array<Contact.t>, ~search) => {
    let contacts = contacts->FormUtils.filterBySearch(c => c.name, search)

    <ReactNative.ScrollView>
      <Container noVPadding=true>
        {contacts == []
          ? <NoResult search />
          : contacts
            ->Array.map(c => <ContactTile key={c.tz1->Pkh.toString} contact=c />)
            ->React.array}
      </Container>
    </ReactNative.ScrollView>
  }
}

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  let (search, setSearch) = React.useState(_ => "")

  let (contacts, _) = Store.useContacts()
  let contacts = contacts->Contact.toArray

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
        signedContent: None,
        beaconRequest: None,
        browserUrl: None,
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
