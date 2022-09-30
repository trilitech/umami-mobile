type actions = Upsert(Contact.t) | Delete(Pkh.t)

let reducer = (contacts: Contact.contactsMap, action: actions) =>
  switch action {
  | Upsert(contact) => contacts->Belt.Map.String.set(contact.tz1->Pkh.toString, contact)

  | Delete(tz1) => contacts->Belt.Map.String.remove(tz1->Pkh.toString)
  }

let useContactsDispatcher = () => {
  let (_, setContacts) = SavedStore.useContacts()

  let fn = action => setContacts(prev => reducer(prev, action))

  let dispatch = React.useCallback1(fn, [])
  dispatch
}
