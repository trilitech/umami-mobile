open CommonComponents
open SendTypes
open Paper
open SendInputs

let vMargin = StyleUtils.makeVMargin()

let makeRow = (title, content) =>
  <Wrapper justifyContent=#spaceBetween style=vMargin>
    <Caption> {title->React.string} </Caption> <Text> {content->React.string} </Text>
  </Wrapper>

module TransactionAmounts = {
  @react.component
  let make = (~trans, ~fee, ~sender: Account.t) => {
    let prettyAmount = trans.prettyAmount
    let amountDisplay = switch trans.assetType {
    | CurrencyAsset(currency) =>
      switch currency {
      | CurrencyTez => makeRow("Subtotal", prettyAmount ++ " " ++ SendInputs.tezSymbol)
      | CurrencyToken(b, _) => makeRow("Subtotal", prettyAmount ++ " " ++ b.symbol)
      }
    | NftAsset(_, m) =>
      <SendInputs.NFTInput imageUrl={m.displayUri} name=m.name editions=prettyAmount />
    }
    open Asset
    <>
      {amountDisplay}
      {makeRow("Fee", Tez(fee)->Asset.getPrettyString)}
      <SenderDisplay account=sender disabled=true />
      {trans.recipient->Helpers.reactFold(recipient => <>
        {recipientLabel} <RecipientDisplayOnly disabled=true tz1=recipient />
      </>)}
    </>
  }
}

@react.component
let make = (~trans, ~fee, ~loading, ~onSubmit, ~onCancel, ~account) => {
  <InstructionsContainer
    instructions="Please validate the details of the transaction and submit to confirm.">
    <TransactionAmounts trans fee sender=account />
    <PasswordSubmit onSubmit loading />
    <Button disabled=loading onPress=onCancel style={vMargin} mode=#outlined>
      {React.string("Cancel")}
    </Button>
  </InstructionsContainer>
}
