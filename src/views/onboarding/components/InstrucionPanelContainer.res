@react.component
let make = (~body, ~instructions, ~title=?, ~step=?, ~danger=false) => {
  <> <InstructionsPanel instructions ?title ?step danger /> <Container> {body} </Container> </>
}
