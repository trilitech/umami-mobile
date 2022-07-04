open ReactNative.Style
open CommonComponents

@react.component
let make = (~left=React.null, ~right=React.null, ~center=React.null) => {
  let isTestNet = Store.useIsTestNet()
  let surfaceColor = ThemeProvider.useSurfaceColor()
  let borderBottomColor = ThemeProvider.useBgColor()

  let backgroundColor = isTestNet ? Colors.Light.error : surfaceColor

  open Paper
  <Appbar.Header
    style={array([
      style(
        ~backgroundColor,
        ~borderBottomColor,
        ~borderBottomWidth=1.,
        ~justifyContent=#center,
        (),
      ),
    ])}>
    <Wrapper style={style(~left=0.->dp, ~position=#absolute, ())}> {left} </Wrapper>
    {<Wrapper flexDirection=#column alignItems=#center>
      {center} <Caption> {(isTestNet ? "Ithacanet" : "Mainnet")->React.string} </Caption>
    </Wrapper>}
    <Wrapper style={style(~right=0.->dp, ~position=#absolute, ())}> {right} </Wrapper>
  </Appbar.Header>
}
