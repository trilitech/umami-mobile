open CommonComponents

open AddressImporterTypes
module Pannel = {
  @react.component
  let make = (~addressType, ~onChange) => {
    <>
      <LabeledRadio
        onPress={_ => onChange(Tz1Mode)}
        label="Tez address"
        status={addressType == Tz1Mode ? #checked : #unchecked}
        value="irrelevant"
      />
      <LabeledRadio
        onPress={_ => onChange(TezosDomainMode)}
        label="Tezos domain"
        status={addressType == TezosDomainMode ? #checked : #unchecked}
        value="irrelevant"
      />
    </>
  }
}

@react.component
let make = (~onChange) => {
  open AddressImporterInputs

  // Stabilize onChange
  let onChange = React.useCallback1(a => onChange(a), [])

  <TzDomainRecipient onChange />
}
