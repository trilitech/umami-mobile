open SendInputs
open SendTypes
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
      // {<Caption> {React.string("editions")} </Caption>}
      <EditionsInput prettyAmount={prettyAmount} onChange=handleChangeAmount />
    </ReactNative.View>
  }

  let handleSenderPress = () => navigate("Accounts")
  let handleSelectRecipientPress = () => navigate("SelectRecipient")

  <>
    {amountInput}
    <Sender onPress=handleSenderPress disabled={SendTypes.isNft(trans.assetType)} />
    <Recipient onPress={handleSelectRecipientPress} recipient={trans.recipient} />
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
