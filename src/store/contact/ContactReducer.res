type actions = Upsert(Contact.t) | Delete(Pkh.t)

let reducer = (contacts: Contact.contactsMap, action: actions) =>
  switch action {
  | Upsert(contact) => contacts->Belt.Map.String.set(contact.tz1->Pkh.toString, contact)

  | Delete(tz1) => contacts->Belt.Map.String.remove(tz1->Pkh.toString)
  }
