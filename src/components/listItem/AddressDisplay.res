open Paper

@react.component
let make = (~tz1: Pkh.t) => {
  let getTezosDomain = Store.useGetTezosDomain()
  let tezosDomain = getTezosDomain(tz1->Pkh.toString)
  let domainDisplay =
    tezosDomain->Helpers.reactFold(domain => <>
      <TzDomainBadge domain /> <Caption> {React.string(" / ")} </Caption>
    </>)

  {
    <CommonComponents.Wrapper justifyContent=#flexStart>
      {domainDisplay} <Caption> {tz1->Pkh.toPretty->React.string} </Caption>
    </CommonComponents.Wrapper>
  }
}
