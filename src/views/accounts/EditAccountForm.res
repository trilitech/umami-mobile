open Paper
open Belt

open FormValidators.NameValidator

@react.component
let make = (~name, ~onSubmit, ~submitWithPassword=false, ~loading=false) => {
  let (name, setName) = React.useState(_ => name)
  let style = StyleUtils.makeVMargin()
  let error = getError(name)
  let disabled = error->Option.isSome

  let submiBtn = submitWithPassword
    ? <PasswordSubmit
        disabled
        loading
        onSubmit={password => {
          onSubmit(name, password->Some)
        }}
      />
    : <Button disabled loading style mode=#contained onPress={_ => onSubmit(name, None)}>
        {React.string("save")}
      </Button>

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
    {submiBtn}
  </>
}
