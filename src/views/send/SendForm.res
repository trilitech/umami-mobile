open SendInputs
open SendTypes
open CommonComponents
open Paper

open Belt

let validPrettyAmount = (amount: string) =>
  amount->Float.fromString->Option.mapWithDefault(false, a => a > 0.)

let validTrans = (trans: SendTypes.formState) =>
  trans.recipient->Option.mapWithDefault(false, t => t->TaquitoUtils.tz1IsValid) &&
    trans.prettyAmount->validPrettyAmount

let vMargin = FormStyles.styles["verticalMargin"]

@react.component
let make = (~trans: SendTypes.formState, ~setTrans, ~isLoading, ~onSubmit) => {
  let notify = SnackBar.useNotification()
  let disabled = !validTrans(trans) || isLoading
  let navigate = NavUtils.useNavigate()

  let handleChangeAmount = (a: string) =>
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
  | NftAsset(_, m) =>
    <ReactNative.View testID="nft-input">
      <NFTInput imageUrl={m.displayUri} name={m.name} />
      <EditionsInput prettyAmount={prettyAmount} onChange=handleChangeAmount />
    </ReactNative.View>
  }

  let handleSenderPress = _ => navigate("Accounts")->ignore
  let handleAddressBookPress = _ => navigate("Contacts")->ignore

  <>
    {amountInput}
    <Sender onPress=handleSenderPress disabled={SendTypes.isNft(trans.assetType)} />
    <Caption> {React.string("recipient")} </Caption>
    <CustomListItem
      onPress={handleAddressBookPress}
      center={<Recipient recipient=trans.recipient />}
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
            } else if recipient != "" {
              notify(`${recipient} is not a valid pkh`)
            }
          })
          ->ignore
        }}
        iconName="content-copy"
        style={FormStyles.styles["hMargin"]}
      />
    </Wrapper>
    <Button disabled loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("review")}
    </Button>
  </>
}
