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
  let (metadatas, setMetadatas) = Store.useAddressMetadatas()

  let toUpdate =
    cards
    ->Array.map(AccountOrContact.getAddress)
    ->Array.keep(tz1 => {
      switch metadatas->Belt.Map.String.get(tz1->Pkh.toString) {
      | None => true
      | Some(_) => false
      }
    })
    ->React.useRef

  open TezosProfilesAPI
  open TezosDomainsAPI
  let stableRefresh = React.useMemo1(((), ()) => {
    Promise.all(toUpdate.current->Belt.Array.map(tz1 => getMetadatas(Pkh.toString(tz1))))
    ->Promise.thenResolve(d =>
      d->Array.forEach(d => setMetadatas(_ => Map.String.set(metadatas, d.tz1, d)))
    )
    ->Promise.catch(exn => {
      let message = switch exn {
      | FetchTzProfilError(message) => `Failed to fetch Tezos profile. Reason: ${message}`
      | FetchTezosDomainError(message) => `Failed to fetch Tezos profile. Reason: ${message}`
      | other => other->Helpers.getMessage
      }
      Logger.error(`Failed to fetch metatdatas. Reason: ${message}`)
      Promise.resolve()
    })
    ->ignore
  }, [setMetadatas])

  stableRefresh
}

let useSingleRefresh = () => {
  let refresh = useRefresh()
  let refresh = React.useRef(refresh)

  React.useEffect1(() => {
    refresh.current()
    None
  }, [])
}
