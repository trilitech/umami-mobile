open CommonComponents
open ReactNative.Style

module Tz1Display = {
  @react.component
  let make = (~tz1) => {
    let color = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.disabled

    let formatted = TezHelpers.formatTz1(tz1)
    let copy = ClipboardCopy.useCopy()

    <Wrapper>
      <Wrapper
        style={style(
          ~backgroundColor=color,
          ~borderRadius=4.,
          ~paddingHorizontal=10.->dp,
          ~marginTop=12.->dp,
          (),
        )}>
        <Paper.TouchableRipple onPress={_ => copy(tz1)}>
          <Paper.Caption testID="tez-display"> {React.string(formatted)} </Paper.Caption>
        </Paper.TouchableRipple>
      </Wrapper>
    </Wrapper>
  }
}

module TransactionIcon = {
  @react.component
  let make = (~iconName, ~label, ~onPress=_ => ()) => {
    <Wrapper
      style={style(~alignSelf=#center, ~marginTop=16.->dp, ~marginRight=16.->dp, ())}
      flexDirection=#column>
      <Paper.FAB onPress small=true icon={Paper.Icon.name(iconName)} />
      <Paper.Caption> {React.string(label)} </Paper.Caption>
    </Wrapper>
  }
}

open Paper
module PureProfile = {
  @react.component
  let make = (
    ~account: Account.t,
    ~onPressToggle=_ => (),
    ~onPressSend=_ => (),
    ~onPressReceive=_ => (),
  ) => {
    let {tz1, name} = account
    <Surface>
      <Wrapper style={style(~marginVertical=16.->dp, ())}>
        <Wrapper
          justifyContent=#center
          alignItems=#flexStart
          style={style(~flex=1., ~alignSelf=#stretch, ())}>
          <Wrapper style={style(~marginVertical=10.->dp, ())}>
            <UmamiLogoMulti size=60. tz1 />
          </Wrapper>
        </Wrapper>
        <Wrapper flexDirection=#column style={style(~flex=3., ())}>
          <Wrapper style={style(~alignSelf=#stretch, ())}>
            <Wrapper flexDirection=#column alignItems=#flexStart>
              <Headline> {React.string(name)} </Headline> <Tz1Display tz1 />
            </Wrapper>
            <IconButton
              style={style(~top=0.->dp, ~right=8.->dp, ~position=#absolute, ())}
              onPress={_ => onPressToggle()}
              icon={Paper.Icon.name("swap-horizontal")}
              size={20}
            />
          </Wrapper>
          <Wrapper justifyContent=#flexStart style={style(~alignSelf=#stretch, ())}>
            <TransactionIcon iconName="storefront-outline" label="Buy tez" />
            <TransactionIcon
              onPress={_ => onPressSend()} iconName="arrow-top-right-thin" label="Send"
            />
            <TransactionIcon
              onPress={_ => onPressReceive()} iconName="arrow-bottom-left-thin" label="Receive"
            />
          </Wrapper>
        </Wrapper>
      </Wrapper>
    </Surface>
  }
}

@react.component
let make = () => {
  let navigate = NavUtils.useNavigate()

  let onPressSend = () => {
    navigate("Send")->ignore
  }

  let onPressToggle = () => {
    navigate("Accounts")->ignore
  }

  let onPressReceive = () => {
    navigate("Receive")->ignore
  }

  Store.useWithAccount(account => <PureProfile onPressSend onPressToggle onPressReceive account />)
}
