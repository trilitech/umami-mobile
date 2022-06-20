let useGetAlias = () => {
  let (contacts, _) = SavedStore.useContacts()
  (tz1: string) => contacts->Belt.Array.getBy(c => c.tz1 == tz1)
}
