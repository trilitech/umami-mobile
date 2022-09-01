open SendTypes
@react.component
let make = (~navigation as _, ~route as _) => {
  let trans = {
    recipient: "bar"->Pkh.unsafeBuild->Some,
    prettyAmount: "3",
    assetType: CurrencyAsset(CurrencyTez),
  }
  <Recap fee={1232} trans onSubmit={_ => ()} onCancel={_ => ()} />
}
