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

let vMargin = StyleUtils.makeVMargin()

@react.component
let make = (~trans: SendTypes.formState, ~setTrans, ~loading, ~onSubmit) => {
  let disabled = !validTrans(trans) || loading
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
    <AddressInjector
      onChange={tz1 => {
        setTrans(prev => {
          ...prev,
          recipient: tz1->Some,
        })
      }}
    />
    <Button disabled loading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("review")}
    </Button>
  </>
}
