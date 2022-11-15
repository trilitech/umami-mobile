open ReactNative.Style
open CommonComponents

open UmamiThemeProvider
@react.component
let make = (~left=React.null, ~right=React.null, ~center=React.null) => {
  let (network, _) = Store.useNetwork()
  let surfaceColor = useSurfaceColor()
  let errorColor = useErrorColor()
  let isTestNet = !(network == Mainnet)

  open Paper
  <Appbar.Header
    style={array([
      style(~backgroundColor=isTestNet ? errorColor : surfaceColor, ~justifyContent=#center, ()),
    ])}>
    <Wrapper style={style(~left=0.->dp, ~position=#absolute, ())}> {left} </Wrapper>
    {<Wrapper flexDirection=#column alignItems=#center>
      {center} <Caption> {(isTestNet ? "Ghostnet" : "Mainnet")->React.string} </Caption>
    </Wrapper>}
    <Wrapper style={style(~right=0.->dp, ~position=#absolute, ())}> {right} </Wrapper>
  </Appbar.Header>
}
