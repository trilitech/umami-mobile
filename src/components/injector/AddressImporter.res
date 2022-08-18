open CommonComponents
open Paper

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
  let (addressType, setAdressType) = React.useState(_ => Tz1Mode)

  let (drawer, _, openDrawer) = BottomSheet.useBottomSheet(~element=close =>
    <Pannel
      addressType
      onChange={t => {
        setAdressType(_ => t)
        onChange(None)
        close()
      }}
    />
  , ~snapPoint="30%", ())

  let label = switch addressType {
  | Tz1Mode => "Tz1 address"
  | TezosDomainMode => "Tezos domain"
  }

  // Stabilize onChange
  let onChange = React.useCallback1(a => onChange(a), [])

  <>
    <Caption> {"Address type"->React.string} </Caption>
    <CustomListItem
      center={<Text> {React.string(label)} </Text>}
      right={<ThreeDotsRight onPress={_ => openDrawer()} />}
    />
    {switch addressType {
    | Tz1Mode => <Tz1Recipient onChange />
    | TezosDomainMode => <TzDomainRecipient onChange />
    }}
    {drawer}
  </>
}
