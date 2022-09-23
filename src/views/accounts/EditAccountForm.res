open Paper
open Belt

open FormValidators.NameValidator

@react.component
let make = (~name, ~onSubmit) => {
  let (name, setName) = React.useState(_ => name)
  let style = StyleUtils.makeVMargin()
  let error = getError(name)

  <>
    <TextInput
      error={error->Option.isSome}
      style
      value=name
      label="Name"
      mode=#outlined
      onChangeText={t => setName(_ => t)}
    />
    <HelperText _type=#error visible={error->Option.isSome}>
      {error->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>
    <Button disabled={error->Option.isSome} style mode=#contained onPress={_ => onSubmit(name)}>
      {React.string("save")}
    </Button>
  </>
}
