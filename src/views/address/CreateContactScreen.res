open Paper

@react.component
let make = (~navigation as _, ~route as _: NavStacks.OnBoard.route) => {
  <Container> <Headline> {React.string("Create account")} </Headline> </Container>
}
