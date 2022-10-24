open Paper
@react.component
let make = (
  ~account: Account.t,
  ~selected=false,
  ~onPress=_ => (),
  ~onPressEdit=?,
  ~right=?,
  ~disabled=false,
) => {
  let {tz1, name, balance} = account
  open Asset
  <GenericListItem
    disabled
    selected
    onPress
    left={<AvatarDisplay tz1 isAccount=true />}
    center={<>
      <Title> {React.string(name)} </Title>
      {balance->Helpers.reactFold(balance => {
        <Text> {Tez(balance)->Asset.getPrettyString->React.string} </Text>
      })}
      <Caption> {tz1->Pkh.toPretty->React.string} </Caption>
    </>}
    ?right
    ?onPressEdit
  />
}
