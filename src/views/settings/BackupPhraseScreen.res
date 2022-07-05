@react.component
let make = (~navigation as _, ~route as _) => {
  let isFocused = ReactNavigation.Native.useIsFocused()
  let (dangerouseStorage, setDangerousStorage) = React.useState(_ => [])
  let goBack = NavUtils.useGoBack()

  React.useEffect1(() => {
    if !isFocused {
      setDangerousStorage(_ => [])
    }
    None
  }, [isFocused])

  <Container>
    {if dangerouseStorage == [] {
      <PasswordConfirm
        onSubmit={passord => {
          BackupPhraseStorage.load(passord)
          ->Promise.thenResolve(mnemonic =>
            setDangerousStorage(_ => mnemonic->Js.String2.split(" "))
          )
          ->ignore
          ()
        }}
      />
    } else {
      <>
        <InstructionsPanel title="This is your backup phrase" instructions="Write it down now!" />
        <Mnemonic mnemonic=dangerouseStorage />
        <ContinueBtn onPress={_ => {goBack()}} text="Close me fast!" />
      </>
    }}
  </Container>
}