open Paper

@react.component
let make = (
  ~contact: Contact.t,
  ~selected=false,
  ~onPress,
  ~right=?,
  ~onPressEdit=?,
  ~disabled=false,
  ~showBorder=?,
) => {
  let {tz1, name} = contact

  <ListItemEditable
    height=#large
    disabled
    selected
    onPress
    left={<AvatarDisplay tz1 />}
    center={<> <Title> {React.string(name)} </Title> <AddressDisplay tz1 /> </>}
    ?right
    ?onPressEdit
    ?showBorder
  />
}
