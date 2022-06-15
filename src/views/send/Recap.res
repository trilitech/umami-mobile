open CommonComponents
open ReactNative.Style
open SendTypes
open Paper

let vMargin = FormStyles.styles["verticalMargin"]

let makeRow = (title, content) =>
  <Wrapper justifyContent=#spaceBetween style=vMargin>
    <Caption> {title->React.string} </Caption> <Text> {content->React.string} </Text>
  </Wrapper>

@react.component
let make = (~trans, ~fee, ~isLoading=false, ~onSubmit, ~onCancel) => {
  let symbol = Asset.getSymbol(trans.asset)
  let formatAmount = t => Token.getBalance(t)->Belt.Int.toString ++ " " ++ symbol
  let amountDisplay = switch trans.asset {
  | Tez(amount) => makeRow("Subtotal", amount->Belt.Int.toString ++ " " ++ symbol)
  | Token(t) =>
    switch t {
    | NFT((_, metadata)) =>
      let {name, displayUri} = metadata

      <SendInputs.NFTInput imageUrl={displayUri} name />
    | _ => makeRow("Subtotal", formatAmount(t))
    }
  }
  <>
    <Headline style={style(~textAlign=#center, ())}> {"Recap"->React.string} </Headline>
    {amountDisplay}
    {makeRow("Fee", TezHelpers.formatBalance(fee))}
    {makeRow("Recipient", trans.recipient)}
    <Button disabled=isLoading loading=isLoading onPress=onSubmit style={vMargin} mode=#contained>
      {React.string("Submit transaction")}
    </Button>
    <Button disabled=isLoading onPress=onCancel style={vMargin} mode=#contained>
      {React.string("Cancel")}
    </Button>
  </>
}
