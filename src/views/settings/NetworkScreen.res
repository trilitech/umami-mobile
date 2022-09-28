open CommonComponents

open Network
open Paper

let makeRadio = (target, network, setNetwork) =>
  <LabeledRadio
    onPress={_ => setNetwork(_ => target)}
    status={network == target ? #checked : #unchecked}
    label={target->toString}
    value={target->toString}
  />

@react.component
let make = (~navigation as _, ~route as _) => {
  let (network, setNetwork) = Store.useNetwork()

  <Container>
    <List.Section title="Selected Network">
      {makeRadio(Mainnet, network, setNetwork)} {makeRadio(Ghostnet, network, setNetwork)}
    </List.Section>
  </Container>
}
