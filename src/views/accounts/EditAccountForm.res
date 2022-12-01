open Paper
open Belt

open FormValidators.NameValidator

@react.component
let make = (~name, ~onSubmit, ~submitWithPassword=false, ~loading=false) => {
  let (name, setName) = React.useState(_ => name)
  let pristine = name === ""
  let error = pristine ? None : getError(name)
  let disabled = error->Option.isSome

  let style = StyleUtils.makeVMargin()
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
    <UI.Input
      error={error->Option.isSome}
      style
      value=name
      placeholder="Enter account name"
      label="Name"
      onChangeText={t => setName(_ => t)}
    />
    {<HelperText _type=#error visible={error->Option.isSome}>
      {error->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>}
    {submiBtn}
  </>
}
