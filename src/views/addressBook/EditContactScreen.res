open Paper
open ContactFormTypes

open Belt

@react.component
let make = (~navigation, ~route: NavStacks.OnBoard.route) => {
  let tz1 = route.params->Option.flatMap(p => p.tz1ForContact)
  let dispatch = ContactReducer.useContactsDispatcher()
  let getContact = Alias.useGetContact()

  let editMode = tz1->Option.isSome
  let name = tz1->Option.flatMap(getContact)->Option.map(a => a.name)
  let title = `${editMode ? "Edit" : "Create"} contact`

  <>
    <TopBarAllScreens title />
    <Container>
      <Headline> {React.string(title)} </Headline>
      <EditContactForm
        initialState={{name: name, tz1: tz1}}
        onSubmit={contact => {
          Upsert(contact)->dispatch
          navigation->NavStacks.OnBoard.Navigation.goBack()
        }}
      />
    </Container>
  </>
}
