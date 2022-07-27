open Paper
open ReactNative.Style
@react.component
let make = (
  ~contact: Contact.t,
  ~selected=false,
  ~onPress,
  ~right=?,
  ~onPressEdit=?,
  ~disabled=false,
) => {
  let {tz1, name} = contact
  <GenericListItem
    disabled
    selected
    onPress
    left={<CommonComponents.Icon
    // Hack on the margin to get same size as maki
      size=80 style={style(~margin=-20.->dp, ())} name="account-circle-outline"
    />}
    center={<>
      <Title> {React.string(name)} </Title>
      <Caption> {tz1->TezHelpers.formatTz1->React.string} </Caption>
    </>}
    ?right
    ?onPressEdit
  />
}
