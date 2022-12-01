let useGetContact = () => {
  let (contacts, _) = Store.useContacts()
  (tz1: Pkh.t) => contacts->Belt.Map.String.get(tz1->Pkh.toString)
}

%%private(
  let useGetAccount = () => {
    let (accounts, _) = Store.useAccountsDispatcher()
    (tz1: Pkh.t) => accounts->Belt.Array.getBy(a => a.tz1 == tz1)
  }
)

let useGetContactOrAccount = () => {
  let getContact = useGetContact()
  let getAccount = useGetAccount()

  (tz1: Pkh.t) => (getContact(tz1), getAccount(tz1))
}
