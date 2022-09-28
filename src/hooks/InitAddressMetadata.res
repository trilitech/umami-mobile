open Belt
open AddressMetadata

let getMetadatas = (tz1: string) => {
  let domain = TezosDomainsAPI.getDomain(tz1)
  let profile = TezosProfilesAPI.getProfile(tz1)
  Promise.all2((domain, profile))->Promise.thenResolve(((d, p)) => {
    {tz1: tz1, tzProfile: p, tzDomain: d}
  })
}

let useGetAddressMetataData = () => {
  let (metatDatas, _) = Store.useAddressMetadatas()
  tz1 => metatDatas->Belt.Map.String.get(tz1)
}

let useRefresh = () => {
  let cards = Store.useAccountsAndContacts()
  let (metaDatas, setMetaDatas) = Store.useAddressMetadatas()

  let toUpdate =
    cards
    ->Array.map(AccountOrContact.getAddress)
    ->Array.keep(tz1 => {
      switch metaDatas->Belt.Map.String.get(tz1->Pkh.toString) {
      | None => true
      | Some(_) => false
      }
    })

  React.useEffect1(() => {
    Promise.all(toUpdate->Belt.Array.map(tz1 => getMetadatas(Pkh.toString(tz1))))
    ->Promise.thenResolve(d =>
      d->Array.forEach(d => setMetaDatas(_ => Map.String.set(metaDatas, d.tz1, d)))
    )
    ->ignore
    None
  }, [toUpdate])
}
