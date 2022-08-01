let useGetContact = () => {
  let (contacts, _) = SavedStore.useContacts()
  (tz1: string) => contacts->Belt.Array.getBy(c => c.tz1 == tz1)
}

%%private(
  let useGetAccount = () => {
    let (accounts, _) = Store.useAccounts()
    (tz1: string) => accounts->Belt.Array.getBy(a => a.tz1 == tz1)
  }
)

let useGetContactOrAccount = () => {
  let getContact = useGetContact()
  let getAccount = useGetAccount()

  (tz1: string) => (getContact(tz1), getAccount(tz1))
}
