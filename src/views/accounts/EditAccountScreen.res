open Paper

let getAccount = (route: NavStacks.OnBoard.route, accounts: array<Account.t>) => {
  route.params
  ->Belt.Option.map(p => p.derivationIndex)
  ->Belt.Option.flatMap(i => {
    accounts->Belt.Array.getBy(a => a.derivationPathIndex == i)
  })
}

@react.component
let make = (~navigation, ~route: NavStacks.OnBoard.route) => {
  let (accounts, _) = Store.useAccounts()
  let updateAccount = Store.useUpdateAccount()

  getAccount(route, accounts)->Belt.Option.mapWithDefault(React.null, a =>
    <Container>
      <Headline> {React.string("Edit account")} </Headline>
      <EditAccountForm
        name=a.name
        onSubmit={name => {
          updateAccount({...a, name: name})
          navigation->NavStacks.OnBoard.Navigation.goBack()
        }}
      />
    </Container>
  )
}
