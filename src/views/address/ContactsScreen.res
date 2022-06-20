// open Paper
open Belt
// open ReactNative.Style
// open ReactNative.Style
open Paper
open CommonComponents

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  // let contacts: array<Contact.t> = []
  let navigate = NavUtils.useNavigateWithParams()
  let contacts = Store.useContacts()
  // account-plus
  <Container>
    {if contacts == [] {
      <DefaultView
        title="No contact" subTitle="Your contacts will appear here" icon="account-box"
      />
    } else {
      {
        contacts
        ->Array.map(c =>
          <CustomListItem
            key=c.name
            center={<Text> {React.string(c.name)} </Text>}
            right={<PressableIcon
              onPress={_ =>
                navigate(
                  "ShowContact",
                  {
                    tz1: c.tz1->Some,
                    derivationIndex: None,
                    token: None,
                  },
                )}
              name="chevron-right"
            />}
            onPress={_ =>
              navigate(
                "Send",
                {
                  tz1: c.tz1->Some,
                  derivationIndex: None,
                  token: None,
                },
              )}
          />
        )
        ->React.array
      }
    }}
  </Container>
}
