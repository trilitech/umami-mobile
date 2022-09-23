open CommonComponents

@react.component
let make = (
  ~left,
  ~center,
  ~right=?,
  ~selected=false,
  ~onPress=_ => (),
  ~onPressEdit=?,
  ~disabled=false,
) => {
  // passing element in the right prop overrides onPressEdit
  let editElement = switch onPressEdit {
  | Some(onPressEdit) => <PressableIcon name={"pencil"} onPress={_ => onPressEdit()} size={20} />
  | None => React.null
  }

  let rightElement = switch right {
  | Some(el) => el
  | None => editElement
  }

  <CustomListItem disabled selected onPress height=90. left center={center} right=rightElement />
}
