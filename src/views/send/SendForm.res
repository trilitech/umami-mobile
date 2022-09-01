open SendInputs
open SendTypes
open Paper

open Belt

let validTrans = (trans: SendTypes.formState) =>
  trans.recipient->Option.isSome &&
    trans.prettyAmount->SendInputs.parsePrettyAmountStr->Option.mapWithDefault(false, a => a > 0.)

let vMargin = StyleUtils.makeVMargin()

let useTz1RecipientFromRoute = () => {
  let route = ReactNavigation.Native.useRoute()
  route->Js.Nullable.toOption->Option.flatMap(NavUtils.getTz1ForSendRecipient)
}

let useUpdateRecipient = setTrans => {
  let recipientTz1 = useTz1RecipientFromRoute()

  React.useEffect2(() => {
    setTrans(prev => {...prev, recipient: recipientTz1})
    None
  }, (setTrans, recipientTz1))
}

@react.component
let make = (~trans: SendTypes.formState, ~setTrans, ~loading, ~onSubmit) => {
  let disabled = !validTrans(trans) || loading
  let navigate = NavUtils.useNavigate()
  useUpdateRecipient(setTrans)

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
      // {<Caption> {React.string("editions")} </Caption>}
      <EditionsInput prettyAmount={prettyAmount} onChange=handleChangeAmount />
    </ReactNative.View>
  }

  let resetRecipient = () => setTrans(prev => {...prev, recipient: None})

  let handleSenderPress = () => navigate("Accounts")
  let handleSelectRecipient = () => navigate("SelectRecipient")

  <>
    {amountInput}
    <Sender onPress=handleSenderPress disabled={SendTypes.isNft(trans.assetType)} />
    <Recipient
      onPressSelectRecipient=handleSelectRecipient
      onPressDelete={resetRecipient}
      recipient={trans.recipient}
    />
    <Button disabled loading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("review")}
    </Button>
  </>
}
