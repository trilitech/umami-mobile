open Belt

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()

  let contacts = Store.useContacts()
  <Container>
    {contacts
    ->Array.map(c =>
      <ContactListItem
        key={c.tz1}
        contact=c
        onPress={_ =>
          navigateWithParams(
            "Send",
            {
              tz1: c.tz1->Some,
              derivationIndex: None,
              nft: None,
              assetBalance: None,
            },
          )}
      />
    )
    ->React.array}
  </Container>
}
