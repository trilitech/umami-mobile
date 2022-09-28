open CommonComponents

open Belt
open ReactNative
open ReactNative.Style

let vMargin = StyleUtils.makeVMargin()

module ContactBox = {
  @react.component
  let make = (~name, ~tz1) =>
    <CustomListItem left={<AvatarDisplay tz1 />} center={<ContactDisplay name tz1 />} />
}

module Controls = {
  @react.component
  let make = (~onPressDelete, ~onPressEdit) => {
    let dangerColor = ThemeProvider.useErrorColor()
    <>
      <CustomListItem
        left={<Icon size=30 name="pencil-outline" />}
        center={<Paper.Text> {React.string("Edit contact")} </Paper.Text>}
        onPress=onPressEdit
        transparent=true
      />
      <CustomListItem
        left={<Icon color=dangerColor size=30 name="delete-outline" />}
        center={<Paper.Text style={style(~color=dangerColor, ())}>
          {React.string("Delete contact")}
        </Paper.Text>}
        onPress=onPressDelete
        transparent=true
      />
    </>
  }
}

@react.component
let make = (~navigation as _, ~route: NavStacks.OnBoard.route) => {
  let getContact = Alias.useGetContact()
  let tz1 = route.params->Option.flatMap(p => p.tz1ForContact)
  let dispatch = ContactReducer.useContactsDispatcher()
  let goBack = NavUtils.useGoBack()
  let navigateWithParams = NavUtils.useNavigateWithParams()

  let element = close => {
    let handlePressEdit = _ => {
      tz1
      ->Option.map(tz1 => {
        navigateWithParams(
          "EditContact",
          {
            tz1ForContact: tz1->Some,
            derivationIndex: None,
            nft: None,
            assetBalance: None,
            tz1ForSendRecipient: None,
            injectedAdress: None,
            signedContent: None,
          },
        )
      })
      ->ignore
      close()
    }

    let handlePressDelete = _ => {
      tz1->Option.map(tz1 => dispatch(Delete(tz1)))->ignore
      close()
      goBack()
    }

    <Controls onPressDelete={handlePressDelete} onPressEdit={handlePressEdit} />
  }

  let (drawer, _, open_) = BottomSheet.useBottomSheet(~element, ~snapPoint="30%", ())

  <>
    {tz1
    ->Belt.Option.flatMap(getContact)
    ->Option.mapWithDefault(React.null, alias => {
      <>
        <TopBarAllScreens.WithRightIcon
          title={"Contact"} logoName="dots-vertical" onPressLogo={_ => open_()}
        />
        <Container>
          <View style={style(~flex=1., ())}>
            <View> <ContactBox name=alias.name tz1=alias.tz1 /> </View>
            <View style={style(~flex=1., ~alignItems=#center, ~justifyContent=#center, ())}>
              <Qr value={alias.tz1->Pkh.toString} size=250 />
            </View>
          </View>
        </Container>
      </>
    })}
    {drawer}
  </>
}
