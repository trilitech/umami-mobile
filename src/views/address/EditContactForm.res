open Paper
open ContactFormTypes

let style = StyleUtils.makeVMargin()

@react.component
let make = (~initialState: ContactFormTypes.contactFormState, ~onSubmit) => {
  let (formState, setFormState) = React.useState(_ => initialState)
  <>
    <TextInput
      placeholder="Add contact name"
      style
      value={formState.name->Belt.Option.getWithDefault("")}
      label="contact name"
      mode=#flat
      onChangeText={t => setFormState(prev => {...prev, name: t->Some})}
    />
    <TextInput
      style
      disabled=true
      value={formState.tz1->Belt.Option.getWithDefault("")}
      label="tz1 address"
      mode=#flat
      onChangeText={t => {()}}
    />
    <Button
    // disabled={name->Js.String2.length < 4}
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
