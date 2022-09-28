type payload = Tz1(string) | TezosDomain(string)

type mode = Tz1Mode | TezosDomainMode

let makeInjectedAddress = str => {
  if TezosDomainsAPI.isTezosDomain(str) {
    TezosDomain(str)->Some
  } else if TaquitoUtils.tz1IsValid(str) {
    Tz1(str)->Some
  } else {
    None
  }
}
