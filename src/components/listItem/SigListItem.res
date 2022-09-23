open CommonComponents

@react.component
let make = (~tz1, ~prettySigDate: string) => {
  let backgroundColor = ThemeProvider.useSurfaceColor()
  open Paper
  <ListItemBase
    backgroundColor
    height=90.
    left={<AvatarDisplay tz1 />}
    center={<AddressDisplay tz1 />}
    right={<Text> {prettySigDate->React.string} </Text>}
  />
}
