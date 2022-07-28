open Paper
open ContactFormTypes
open Belt

let style = StyleUtils.makeVMargin()

open FormValidators.NameValidator

@react.component
let make = (~initialState: ContactFormTypes.contactFormState, ~onSubmit) => {
  let (formState, setFormState) = React.useState(_ => initialState)
  let createMode = initialState.tz1->Option.isNone

  let nameError = formState.name->Option.flatMap(getError)

  let disabled =
    nameError->Option.isSome || formState.name->Option.isNone || formState.tz1->Option.isNone
  <>
    <TextInput
      error={nameError->Option.isSome}
      placeholder="Add contact name"
      style
      value={formState.name->Belt.Option.getWithDefault("")}
      label="contact name"
      mode=#flat
      onChangeText={t => setFormState(prev => {...prev, name: t->Some})}
    />
    <HelperText _type=#error visible={nameError->Option.isSome}>
      {nameError->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>
    <TextInput
      style
      disabled=true
      value={formState.tz1->Belt.Option.getWithDefault("")}
      placeholder="Enter tz1"
      label="tz1 address"
      mode=#flat
      onChangeText={t => {()}}
    />
    {createMode
      ? <AddressInjector
          onChange={tz1 => {
            setFormState(prev => {...prev, tz1: tz1->Some})
            ()
          }}
        />
      : React.null}
    <Button
      disabled
      style
      mode=#contained
      onPress={_ => {
        Helpers.both(formState.name, formState.tz1)
        ->Belt.Option.map(((n, a)) => {
          let res: Contact.t = {name: n, tz1: a}
          onSubmit(res)
        })
        ->ignore
      }}>
      {React.string("Save contact")}
    </Button>
  </>
}