@react.component
let make = (~title="", ~subTitle="", ~icon=?) => {
  open Paper
  open ReactNative.Style
  <ReactNative.View style={style(~display=#flex, ~alignItems=#center, ~padding=30.->dp, ())}>
    {icon->Helpers.reactFold(icon =>
      <Avatar.Icon
        size=140 icon={Icon.name(icon)} style={style(~backgroundColor="transparent", ())}
      />
    )}
    <Headline style={style(~textAlign=#center, ~marginVertical=30.->dp, ())}>
      {React.string(title)}
    </Headline>
    <Caption style={style(~textAlign=#center, ())}> {React.string(subTitle)} </Caption>
  </ReactNative.View>
}
