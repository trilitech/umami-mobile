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
  ~showBorder=?,
  ~height=#medium,
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

  <CustomListItem
    ?showBorder disabled selected onPress height left center={center} right=rightElement
  />
}
