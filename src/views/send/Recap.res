open CommonComponents
open SendTypes
open Paper
open SendInputs

let vMargin = StyleUtils.makeVMargin()

let makeRow = (title, content) =>
  <Wrapper justifyContent=#spaceBetween style=vMargin>
    <Caption> {title->React.string} </Caption> <Text> {content->React.string} </Text>
  </Wrapper>

@react.component
let make = (~trans, ~fee, ~loading=false, ~onSubmit, ~onCancel) => {
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
  <>
    <InstructionsPanel
      instructions="Please validate the details of the transaction and submit to confirm."
    />
    <Container>
      {amountDisplay}
      {makeRow("Fee", TezHelpers.formatBalance(fee))}
      <Sender disabled=true />
      {trans.recipient->Helpers.reactFold(recipient => <>
        {recipientLabel} <RecipientDisplayOnly disabled=true tz1=recipient />
      </>)}
      <Button disabled=loading loading onPress=onSubmit style={vMargin} mode=#contained>
        {React.string("Submit transaction")}
      </Button>
      <Button disabled=loading onPress=onCancel style={vMargin} mode=#contained>
        {React.string("Cancel")}
      </Button>
    </Container>
  </>
}
