open CommonComponents
open ReactNative.Style

module Tz1Display = {
  @react.component
  let make = (~tz1) => {
    let color = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.disabled

    let formatted = TezHelpers.formatTz1(tz1)

    let notify = SnackBar.useNotification()

    <Wrapper>
      <Wrapper
        style={style(
          ~backgroundColor=color,
          ~borderRadius=4.,
          ~paddingHorizontal=10.->dp,
          ~marginTop=12.->dp,
          (),
        )}>
        <Paper.TouchableRipple
          onPress={_ => {
            Clipboard.setString(tz1)
            notify("Address copied to clipbloard")
          }}>
          <Paper.Caption> {React.string(formatted)} </Paper.Caption>
        </Paper.TouchableRipple>
      </Wrapper>
    </Wrapper>
  }
}

module TransactionIcon = {
  @react.component
  let make = (~iconName, ~label, ~onPress=_ => ()) => {
    <Wrapper flexDirection=#column>
      <Paper.FAB
        onPress
        small=true
        style={style(~alignSelf=#center, ~marginTop=20.->dp, ~marginHorizontal=10.->dp, ())}
        icon={Paper.Icon.name(iconName)}
      />
      <Paper.Caption> {React.string(label)} </Paper.Caption>
    </Wrapper>
  }
}

open Paper
module PureProfile = {
  @react.component
  let make = (
    ~account: Store.account,
    ~onPressToggle=_ => (),
    ~onPressSend=_ => (),
    ~onPressReceive=_ => (),
    ~hideButtons=false,
  ) => {
    let {tz1, name, derivationPathIndex} = account
    <Surface>
      <Wrapper flexDirection=#column justifyContent=#center style={style(~height=280.->dp, ())}>
        <IconButton
          style={style(~alignSelf=#flexEnd, ~top=0.->dp, ~right=8.->dp, ~position=#absolute, ())}
          onPress={_ => onPressToggle()}
          icon={Paper.Icon.name("swap-horizontal")}
          size={20}
        />
        <UmamiLogoMulti size=60. colorIndex=derivationPathIndex />
        <Headline> {React.string(name)} </Headline>
        <Tz1Display tz1 />
        {hideButtons
          ? React.null
          : <Wrapper>
              <TransactionIcon iconName="storefront-outline" label="Buy tez" />
              <TransactionIcon
                onPress={_ => onPressSend()} iconName="arrow-top-right-thin" label="Send"
              />
              <TransactionIcon
                onPress={_ => onPressReceive()} iconName="arrow-bottom-left-thin" label="Receive"
              />
            </Wrapper>}
      </Wrapper>
    </Surface>
  }
}

@react.component
let make = (~hideButtons=false) => {
  let account = Store.useActiveAccount()
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

  switch account {
  | Some(account) => <PureProfile hideButtons onPressSend onPressToggle onPressReceive account />
  | None => React.null
  }
}
