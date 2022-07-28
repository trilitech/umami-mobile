open CommonComponents

open Belt
open ReactNative
open ReactNative.Style

let vMargin = StyleUtils.makeVMargin()

module ContactBox = {
  @react.component
  let make = (~name, ~tz1, ~onPressControls) =>
    <CustomListItem
      left={<Icon size=80 name="account-circle-outline" />}
      center={<ContactDisplay name tz1 />}
      right={<PressableIcon name="dots-vertical" onPress={_ => onPressControls()} />}
    />
}

module Controls = {
  @react.component
  let make = (~onPressDelete, ~onPressEdit) => {
    <>
      <CustomListItem
        left={<Icon size=30 name="pencil-outline" />}
        center={<Paper.Text> {React.string("Edit contact")} </Paper.Text>}
        onPress=onPressEdit
      />
      <CustomListItem
        left={<Icon size=30 name="delete-outline" />}
        center={<Paper.Text> {React.string("Delete contact")} </Paper.Text>}
        onPress=onPressDelete
      />
    </>
  }
}

@react.component
let make = (~navigation as _, ~route: NavStacks.OnBoard.route) => {
  let getAlias = Alias.useGetAlias()
  let (isOpen, setIsOpen) = React.useState(_ => false)
  let tz1 = route.params->Option.flatMap(p => p.tz1)
  let dispatch = Store.useContactsDispatcher()
  let goBack = NavUtils.useGoBack()
  let navigateWithParams = NavUtils.useNavigateWithParams()

  let handlePressEdit = _ => {
    tz1
    ->Option.map(tz1 => {
      navigateWithParams(
        "EditContact",
        {
          tz1: tz1->Some,
          derivationIndex: None,
          nft: None,
          assetBalance: None,
        },
      )
    })
    ->ignore
    setIsOpen(_ => false)
  }

  let handlePressDelete = _ => {
    tz1->Option.map(tz1 => dispatch(Delete(tz1)))->ignore
    setIsOpen(_ => false)
    goBack()
  }

  let element = <Controls onPressDelete={handlePressDelete} onPressEdit={handlePressEdit} />

  let (drawer, close) = BottomSheet.useBottomSheet(
    ~element,
    ~isOpen,
    ~setIsOpen,
    ~snapPoint="30%",
    (),
  )

  React.useEffect1(() => {
    if !isOpen {
      close()
    }
    None
  }, [isOpen])

  <Container>
    {tz1
    ->Belt.Option.flatMap(getAlias)
    ->Option.mapWithDefault(React.null, alias => {
      <View style={style(~flex=1., ())}>
        <View>
          <ContactBox name=alias.name tz1=alias.tz1 onPressControls={_ => setIsOpen(_ => true)} />
          //   <Paper.Headline> {React.string("bar")} </Paper.Headline>
          //   <Qr value=alias.tz1 size=250 />
        </View>
        <View style={style(~flex=1., ~alignItems=#center, ~justifyContent=#center, ())}>
          <Qr value=alias.tz1 size=250 />
        </View>
      </View>
    })}
    {drawer}
  </Container>

  //   let dispatch = Store.useContactsDispatcher()

  //   tz1->Option.mapWithDefault(React.null, tz1 => {
  //       // <EditContactForm
  //       //   initialState={{name: None, tz1: tz1}}
  //       //   onSubmit={contact => {
  //       //     Upsert(contact)->dispatch
  //       //     navigation->NavStacks.OnBoard.Navigation.goBack()
  //       //   }}
  //       // />
  //   })
}
