open CommonComponents
open ReactNative.Style
open SendTypes
open Paper

let vMargin = StyleUtils.makeVMargin()

let makeRow = (title, content) =>
  <Wrapper justifyContent=#spaceBetween style=vMargin>
    <Caption> {title->React.string} </Caption> <Text> {content->React.string} </Text>
  </Wrapper>

@react.component
let make = (~trans, ~fee, ~isLoading=false, ~onSubmit, ~onCancel) => {
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
    <Headline style={style(~textAlign=#center, ())}> {"Recap"->React.string} </Headline>
    {amountDisplay}
    {makeRow("Fee", TezHelpers.formatBalance(fee))}
    {makeRow("Recipient", trans.recipient->Belt.Option.getWithDefault("")->TezHelpers.formatTz1)}
    <Button disabled=isLoading loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("Submit transaction")}
    </Button>
    <Button disabled=isLoading onPress=onCancel style={vMargin} mode=#contained>
      {React.string("Cancel")}
    </Button>
  </>
}
