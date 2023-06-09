open CommonComponents
open ReactNative.Style

module TransactionIcon = {
  @react.component
  let make = (~iconName, ~label, ~onPress=_ => ()) => {
    <Wrapper
      style={array([
        style(~alignSelf=#center, ()),
        StyleUtils.makeTopMargin(~size=2, ()),
        StyleUtils.makeRightMargin(~size=4, ()),
      ])}
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
            <AvatarDisplay size=120 tz1 isAccount=true />
          </Wrapper>
        </Wrapper>
        <Wrapper flexDirection=#column style={style(~flex=3., ())}>
          <Wrapper style={style(~alignSelf=#stretch, ())}>
            <ContactDisplay name tz1 />
            <PressableIcon
              style={style(~top=0.->dp, ~right=8.->dp, ~position=#absolute, ())}
              onPress={_ => onPressToggle()}
              name="swap-horizontal"
              size={20}
            />
          </Wrapper>
          <Wrapper justifyContent=#flexStart style={style(~alignSelf=#stretch, ())}>
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
let make = (~onPressReceive) => {
  let navigate = NavUtils.useNavigate()

  let onPressSend = () => {
    navigate("Send")->ignore
  }

  let onPressToggle = () => {
    navigate("Accounts")->ignore
  }

  Store.useWithAccount(account =>
    <PureProfile onPressSend onPressToggle onPressReceive account />
  )
}
