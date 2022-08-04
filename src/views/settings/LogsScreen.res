open Belt
open CommonComponents

let maxLogsToDisplay = 200

module LogCard = {
  open Paper
  @react.component
  let make = (~log: LoggerFns.logPayload) => {
    let prettyDate = Js.Date.fromString(log.date)->Js.Date.toUTCString
    <>
      <Caption> {prettyDate->React.string} </Caption>
      <CustomListItem center={<Text> {React.string(log.message)} </Text>} />
    </>
  }
}
module ClearLogs = {
  @react.component
  let make = (~onReset) => {
    open Paper
    let (loading, setIsLoading) = React.useState(_ => false)
    let notify = SnackBar.useNotification()
    let eraseLogs = () => {
      setIsLoading(_ => true)
      Logger.deleteLogs()
      ->Promise.then(_ => {
        onReset()
        Promise.resolve()
      })
      ->Promise.catch(exn => {
        notify("Failed to reset logs" ++ exn->Helpers.getMessage)
        Promise.resolve()
      })
      ->Promise.finally(() => {
        setIsLoading(_ => false)
      })
      ->ignore
    }
    <Button style={StyleUtils.makeVMargin()} loading disabled=loading onPress={_ => eraseLogs()}>
      {React.string("Erase logs")}
    </Button>
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let (logs, setLogs) = React.useState(_ => None)
  let notify = SnackBar.useNotification()

  let fetchLogs = React.useCallback2(() => {
    Logger.readLogsWithoutPaths()
    ->Promise.thenResolve(logs => {
      setLogs(_ => // truncate number of logs to avoid UI crash
      // reverse logs to get latest first
      Some(logs->Array.slice(~len=maxLogsToDisplay, ~offset=0)->Array.reverse))
    })
    ->Promise.catch(exn => {
      let message = "Failed to retrieve logs. " ++ exn->Helpers.getMessage
      notify(message)
      Promise.resolve()
    })
    ->ignore
  }, (notify, setLogs))

  React.useEffect2(() => {
    fetchLogs()
    None
  }, (notify, setLogs))

  <Container>
    <ReactNative.ScrollView>
      {logs->Helpers.reactFold(logs => {
        logs == []
          ? <DefaultView icon="script-outline" title="You have no logs yet..." />
          : <>
              <ClearLogs onReset={_ => {fetchLogs()}} />
              {logs
              ->Array.mapWithIndex((i, log) =>
                <LogCard log key={log.date ++ Belt.Int.toString(i)} />
              )
              ->React.array}
            </>
      })}
    </ReactNative.ScrollView>
  </Container>
}
