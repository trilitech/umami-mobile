open CommonComponents
open Paper
@react.component
let make = (~account: Account.t, ~selected=false, ~onPress, ~onPressEdit=?, ~disabled=false) => {
  let {tz1, name, balance} = account
  <CustomListItem
    disabled
    selected
    onPress
    height=80.
    left={<UmamiLogoMulti size=40. tz1 />}
    center={<>
      <Title> {React.string(name)} </Title>
      <Text>
        {balance->Belt.Option.mapWithDefault("", TezHelpers.formatBalance)->React.string}
      </Text>
      <Caption> {tz1->TezHelpers.formatTz1->React.string} </Caption>

      //   right={_ =>
      //     switch onPressEdit {
      //     | Some(onPressEdit) =>
      //       <Paper.IconButton onPress={_ => onPressEdit()} icon={Paper.Icon.name("pencil")} size={20} />
      //     | None => React.null
      //     }}
    </>}
    right={switch onPressEdit {
    | Some(onPressEdit) =>
      <Paper.IconButton onPress={_ => onPressEdit()} icon={Paper.Icon.name("pencil")} size={20} />
    | None => React.null
    }}
  />
  // <ListItemCustomIcon
  //   ?onPress
  //   selected
  //   height=80.
  //   right={_ =>
  //     switch onPressEdit {
  //     | Some(onPressEdit) =>
  //       <Paper.IconButton onPress={_ => onPressEdit()} icon={Paper.Icon.name("pencil")} size={20} />
  //     | None => React.null
  //     }}
  //   left={_ => <UmamiLogoMulti size=40. colorIndex=derivationPathIndex />}
  //   description={TezHelpers.formatTz1(tz1)}
  //   title={name}
  // />
}
