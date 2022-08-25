type t = ContactCard(Contact.t) | AccountCard(Account.t)

let getAddress = c => {
  switch c {
  | ContactCard(c) => c.tz1
  | AccountCard(c) => c.tz1
  }
}
