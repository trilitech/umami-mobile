open Asset
open SendTypes
@react.component
let make = (~navigation as _, ~route as _) => {
  let trans = {recipient: "bar", asset: Tez(33)}
  <Recap fee={1232} trans onSubmit={_ => ()} onCancel={_ => ()} />
}
