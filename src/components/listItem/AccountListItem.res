open Paper
@react.component
let make = (
  ~account: Account.t,
  ~selected=false,
  ~onPress=_ => (),
  ~onPressEdit=?,
  ~right=?,
  ~disabled=false,
  ~showBorder=?,
) => {
  let {tz1, name, balance} = account
  open Asset
  <GenericListItem
    ?showBorder
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
