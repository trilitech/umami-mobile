open Paper
@react.component
let make = (
  ~account: Account.t,
  ~selected=false,
  ~onPress,
  ~onPressEdit=?,
  ~right=?,
  ~disabled=false,
) => {
  let {tz1, name, balance} = account
  <GenericListItem
    disabled
    selected
    onPress
    left={<AvatarDisplay tz1 isAccount=true />}
    center={<>
      <Title> {React.string(name)} </Title>
      <Text>
        {balance->Belt.Option.mapWithDefault("", TezHelpers.formatBalance)->React.string}
      </Text>
      <Caption> {tz1->TezHelpers.formatTz1->React.string} </Caption>
    </>}
    ?right
    ?onPressEdit
  />
}
