@react.component
let make = (~children, ~instructions, ~title=?, ~step=?, ~danger=false, ~scrollView=false) => {
  <>
    <InstructionsPanel instructions ?title ?step danger />
    {scrollView
      ? <ReactNative.ScrollView> <Container> {children} </Container> </ReactNative.ScrollView>
      : <Container> {children} </Container>}
  </>
}
