@react.component
let make = (~onChange) => {
  open AddressImporterInputs

  // Stabilize onChange
  let onChange = React.useCallback1(a => onChange(a), [])

  <TzDomainRecipient onChange />
}
