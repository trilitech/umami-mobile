open SendInputs
open SendTypes
open CommonComponents
open Paper

open Belt
let validTrans = (trans: SendTypes.formState) =>
  trans.recipient->Option.mapWithDefault(false, t => t->TaquitoUtils.tz1IsValid) &&
    trans.prettyAmount > 0.

let vMargin = FormStyles.styles["verticalMargin"]

@react.component
let make = (~trans: SendTypes.formState, ~setTrans, ~isLoading, ~onSubmit) => {
  let notify = SnackBar.useNotification()
  let getAlias = Alias.useGetAlias()
  let navigateWithParams = NavUtils.useNavigateWithParams()

  let {recipient} = trans

  let disabled = !validTrans(trans) || isLoading
  let navigate = NavUtils.useNavigate()

  let handleChangeAmount = (a: float) =>
    setTrans(t => {
      {...t, prettyAmount: a}
    })

  let handleChangeSymbol = (c: SendTypes.currency) =>
    setTrans(t => {
      {...t, assetType: CurrencyAsset(c)}
    })

  let prettyAmount = trans.prettyAmount

  let amountInput = switch trans.assetType {
  | CurrencyAsset(currency) =>
    <MultiCurrencyInput
      amount=prettyAmount
      onChangeAmount={handleChangeAmount}
      currency={currency}
      onChangeSymbol=handleChangeSymbol
    />
  | NftAsset(_, m) => <NFTInput imageUrl={m.displayUri} name={m.name} />
  }

  let handleSenderPress = _ => navigate("Accounts")->ignore
  let handleAddressBookPress = _ => navigate("Contacts")->ignore

  let recipientEl = recipient->Option.mapWithDefault(
    <Text> {"Add recipient "->React.string} </Text>,
    tz1 => {
      open ReactNative.Style
      //   <Text> {"Add bar "->React.string} </Text>
      getAlias(tz1)->Option.mapWithDefault(
        <Wrapper>
          <Text> {TezHelpers.formatTz1(tz1)->React.string} </Text>
          <PressableIcon
            name="account-plus"
            style={style(~marginLeft=8.->dp, ())}
            size=30
            onPress={_ =>
              navigateWithParams(
                "EditContact",
                {
                  tz1: trans.recipient,
                  derivationIndex: None,
                  token: None,
                },
              )}
          />
        </Wrapper>,
        alias => {
          <Text> {alias.name->React.string} </Text>
        },
      )
    },
  )

  <>
    {amountInput}
    // Only allow sender change when sending Tez
    <Sender onPress=handleSenderPress disabled={SendTypes.isNft(trans.assetType)} />
    <Caption> {React.string("recipient")} </Caption>
    <CustomListItem
      onPress={handleAddressBookPress}
      center={recipientEl}
      right={<CommonComponents.Icon name="chevron-right" />}
    />
    <Wrapper justifyContent=#center>
      <NicerIconBtn
        onPress={_ => {
          navigate("ScanQR")->ignore
          ()
        }}
        iconName="qrcode-scan"
        style={FormStyles.styles["hMargin"]}
      />
      <NicerIconBtn
        onPress={_ => {
          Clipboard.getString()
          ->Promise.thenResolve(recipient => {
            if TaquitoUtils.tz1IsValid(recipient) {
              setTrans(prev => {
                ...prev,
                recipient: recipient->Some,
              })
            } else {
              notify(`${recipient} is not a valid pkh`)
            }
          })
          ->ignore
        }}
        iconName="content-copy"
        style={FormStyles.styles["hMargin"]}
      />
    </Wrapper>
    // </Wrapper>
    <Button disabled loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("review")}
    </Button>
  </>
}
