open Paper
open Belt
@react.component
let make = (~navigation as _, ~route as _) => {
  let navigateWithParams = NavUtils.useNavigateWithParams()
  let addressExists = Store.useAddressExists()
  let (tz1, setTz1) = React.useState(_ => None)

  let tz1IsNoneOrAlreadyExists = tz1->Option.mapWithDefault(true, addressExists)

  let handleTz1 = () => {
    navigateWithParams(
      "Send",
      {
        tz1ForContact: None,
        derivationIndex: None,
        nft: None,
        assetBalance: None,
        tz1ForSendRecipient: tz1,
        injectedAdress: None,
      },
    )
  }

  let addContact = () =>
    navigateWithParams(
      "EditContact",
      {
        tz1ForContact: tz1,
        derivationIndex: None,
        nft: None,
        assetBalance: None,
        tz1ForSendRecipient: None,
        injectedAdress: None,
      },
    )

  <>
    <InstructionsPanel
      instructions="You can transfer assets to a tz adress or tezos domain. Please enter the address or domain you want to make a transfer to. "
    />
    <Container>
      <AddressImporter
        onChange={tz1 => {
          setTz1(_ => tz1)
          ()
        }}
      />
      <Button
        disabled={tz1IsNoneOrAlreadyExists}
        style={StyleUtils.makeVMargin()}
        onPress={_ => addContact()}
        mode={#outlined}>
        {React.string("Add contact to address book")}
      </Button>
      <Button
        disabled={tz1->Option.isNone}
        style={StyleUtils.makeVMargin()}
        onPress={_ => handleTz1()}
        mode={#contained}>
        {React.string("Confirm recipient")}
      </Button>
    </Container>
  </>
}
