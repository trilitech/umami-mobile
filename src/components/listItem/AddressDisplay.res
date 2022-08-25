open Paper

@react.component
let make = (~tz1) => {
  let getTezosDomain = Store.useGetTezosDomain()
  let tezosDomain = getTezosDomain(tz1)
  let domainDisplay =
    tezosDomain->Helpers.reactFold(domain => <>
      <TzDomainBadge domain /> <Caption> {React.string(" / ")} </Caption>
    </>)

  {
    <CommonComponents.Wrapper justifyContent=#flexStart>
      {domainDisplay} <Caption> {tz1->TezHelpers.formatTz1->React.string} </Caption>
    </CommonComponents.Wrapper>
  }
}
