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
  let (nodeIndex, setNodeIndex) = Store.useNodeIndex()

  let setNetwork = cb => {
    setNodeIndex(_ => 0)
    setNetwork(cb)
  }

  let nodes = Endpoints.getNodes(network)
  <Container>
    <List.Section title="Selected network">
      {makeRadio(Mainnet, network, setNetwork)} {makeRadio(Ghostnet, network, setNetwork)}
    </List.Section>
    <List.Section title="Selected node">
      {nodes
      ->Belt.Array.mapWithIndex((i, host) => {
        <LabeledRadio
          key=host
          onPress={_ => setNodeIndex(_ => i)}
          status={i == nodeIndex ? #checked : #unchecked}
          label={host}
          value={host}
        />
      })
      ->React.array}
    </List.Section>
    <List.Section title="Mezos host">
      <CustomListItem
        selected={false}
        center={<Wrapper>
          <Paper.Caption> {Endpoints.getMezosUrl(network)->React.string} </Paper.Caption>
        </Wrapper>}
      />
    </List.Section>
    <List.Section title="Tzkt host">
      <CustomListItem
        selected={false}
        center={<Wrapper>
          <Paper.Caption> {Endpoints.getTzktUrl(network)->React.string} </Paper.Caption>
        </Wrapper>}
      />
    </List.Section>
  </Container>
}
