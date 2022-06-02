open SendScreen
open SendAmount
@react.component
let make = (~navigation as _, ~route as _) => {
  let trans = {recipient: "bar", amount: Tez(33)}
  <SendScreen.Recap fee={1232} trans onSubmit={_ => ()} onCancel={_ => ()} />
}
