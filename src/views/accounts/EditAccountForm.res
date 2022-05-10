open Paper
@react.component
let make = (~name, ~onSubmit) => {
  let (name, setName) = React.useState(_ => name)
  let style = FormStyles.styles["verticalMargin"]
  <>
    // <CommonComponents.Wrapper flexDirection=#column>
    <TextInput style value=name label="name" mode=#flat onChangeText={t => setName(_ => t)} />
    <Button style mode=#contained onPress={_ => onSubmit(name)}> {React.string("save")} </Button>
    // </CommonComponents.Wrapper>
  </>
}
