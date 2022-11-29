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
  let getBalance = Store.useGetBalance()
  let {tz1, name} = account
  let balance = getBalance(tz1)->Belt.Option.flatMap(b => b.tez)
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
