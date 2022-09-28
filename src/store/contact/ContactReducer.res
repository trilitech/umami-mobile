open Belt
type actions = Upsert(Contact.t) | Delete(Pkh.t)

let reducer = (contacts: array<Contact.t>, action: actions) =>
  switch action {
  | Upsert(account) => {
      let existing = contacts->Array.getIndexBy(c => c.tz1 === account.tz1)
      switch existing {
      | Some(i) => contacts->Helpers.update(i, account)
      | None => contacts->Array.concat([account])
      }
    }
  | Delete(tz1) => contacts->Array.keep(c => c.tz1 != tz1)
  }

let useContactsDispatcher = () => {
  let (_, setContacts) = SavedStore.useContacts()

  let fn = action => setContacts(prev => reducer(prev, action))

  let dispatch = React.useCallback1(fn, [])
  dispatch
}
