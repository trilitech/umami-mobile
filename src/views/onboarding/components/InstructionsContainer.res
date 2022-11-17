@react.component
let make = (~children, ~instructions, ~title=?, ~step=?, ~danger=false) => {
  <> <InstructionsPanel instructions ?title ?step danger /> <Container> {children} </Container> </>
}
