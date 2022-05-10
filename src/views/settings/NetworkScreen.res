open CommonComponents

open Paper
@react.component
let make = (~navigation as _, ~route as _) => {
  let makeRadio = value => <LabeledRadio onPress={_ => ()} label=value status={#unchecked} value />
  <Background>
    <List.Section title="Selected Network">
      {makeRadio("mainnet")} {makeRadio("hanghzounet")}
    </List.Section>
  </Background>
}
