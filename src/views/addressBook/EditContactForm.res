open Paper
open Helpers
open ContactFormTypes
open Belt

let style = StyleUtils.makeVMargin()

open FormValidators.NameValidator

@react.component
let make = (~initialState: ContactFormTypes.contactFormState, ~onSubmit) => {
  let (formState, setFormState) = React.useState(_ => initialState)
  let createMode = initialState.tz1->Option.isNone

  let addressExists = Store.useAddressExists()
  let tz1IsNoneOrAlreadyExists = formState.tz1->Option.mapWithDefault(true, addressExists)

  let nameError = formState.name->Option.flatMap(getError)

  let disabled =
    nameError->Option.isSome ||
    both(formState.name, formState.tz1)->Option.isNone ||
    (createMode && tz1IsNoneOrAlreadyExists)

  <>
    <TextInput
      error={nameError->Option.isSome}
      placeholder="Add contact name"
      style
      value={formState.name->Belt.Option.getWithDefault("")}
      label="contact name"
      mode=#outlined
      onChangeText={t => setFormState(prev => {...prev, name: t->Some})}
    />
    <HelperText _type=#error visible={nameError->Option.isSome}>
      {nameError->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>
    {createMode
      ? <AddressImporter onChange={tz1 => setFormState(prev => {...prev, tz1: tz1})} />
      : formState.tz1->Helpers.reactFold(tz1 =>
          <CommonComponents.Wrapper justifyContent=#center style={StyleUtils.makeBottomMargin()}>
            <AddressDisplay tz1={tz1} />
          </CommonComponents.Wrapper>
        )}
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
