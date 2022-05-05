@react.component
let make = (~title="", ~subTitle="", ~icon) => {
  open Paper
  open ReactNative.Style
  <ReactNative.View style={style(~display=#flex, ~alignItems=#center, ~padding=30.->dp, ())}>
    <Avatar.Icon size=120 icon={Icon.name(icon)} style={style(~backgroundColor="lightgray", ())} />
    <Headline style={style(~textAlign=#center, ~marginVertical=30.->dp, ())}>
      {React.string(title)}
    </Headline>
    <Subheading style={style(~textAlign=#center, ())}> {React.string(subTitle)} </Subheading>
  </ReactNative.View>
}
