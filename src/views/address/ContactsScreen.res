open Belt
open CommonComponents

open Paper

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()

  let contacts = Store.useContacts()
  <Container>
    {if contacts == [] {
      <DefaultView
        title="No contact" subTitle="Your contacts will appear here" icon="account-box"
      />
    } else {
      <>
        {contacts
        ->Array.map(c =>
          <CustomListItem
            key=c.name
            center={<Text> {React.string(c.name)} </Text>}
            right={<PressableIcon
              onPress={_ =>
                navigateWithParams(
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
              navigateWithParams(
                "Send",
                {
                  tz1: c.tz1->Some,
                  derivationIndex: None,
                  token: None,
                },
              )}
          />
        )
        ->React.array}
        <BigPlusBtn
          onPress={() => {
            navigateWithParams(
              "EditContact",
              {
                tz1: None,
                derivationIndex: None,
                token: None,
              },
            )
          }}
        />
      </>
    }}
  </Container>
}
