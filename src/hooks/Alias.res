let useGetAlias = () => {
  let (contacts, _) = SavedStore.useContacts()
  (tz1: string) => contacts->Belt.Array.getBy(c => c.tz1 == tz1)
}

let useGetAccount = () => {
  let (accounts, _) = Store.useAccounts()
  (tz1: string) => accounts->Belt.Array.getBy(a => a.tz1 == tz1)
}
