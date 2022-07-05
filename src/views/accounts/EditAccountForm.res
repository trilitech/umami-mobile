open Paper
@react.component
let make = (~name, ~onSubmit) => {
  let (name, setName) = React.useState(_ => name)
  let style = StyleUtils.makeVMargin()
  <>
    <TextInput style value=name label="name" mode=#flat onChangeText={t => setName(_ => t)} />
    <Button
      disabled={name->Js.String2.length < 4} style mode=#contained onPress={_ => onSubmit(name)}>
      {React.string("save")}
    </Button>
  </>
}
