@react.component
let make = (~navigation as _, ~route as _) =>
  <Container> <Paper.Text> {j`Hello From Modal`->React.string} </Paper.Text> </Container>
