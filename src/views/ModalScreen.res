@react.component
let make = (~navigation as _, ~route as _) =>
  <Background> <Paper.Text> {j`Hello From Modal`->React.string} </Paper.Text> </Background>
