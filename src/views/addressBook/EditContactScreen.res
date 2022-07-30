open Paper
open ContactFormTypes

open Belt

@react.component
let make = (~navigation, ~route: NavStacks.OnBoard.route) => {
  let tz1 = route.params->Option.flatMap(p => p.tz1)
  let dispatch = Store.useContactsDispatcher()
  let getAlias = Alias.useGetAlias()

  let editMode = tz1->Option.isSome
  let name = tz1->Option.flatMap(getAlias)->Option.map(a => a.name)
  <Container>
    <Headline> {React.string(`${editMode ? "Edit" : "Create"} contact`)} </Headline>
    <EditContactForm
      initialState={{name: name, tz1: tz1}}
      onSubmit={contact => {
        Upsert(contact)->dispatch
        navigation->NavStacks.OnBoard.Navigation.goBack()
      }}
    />
  </Container>
}
