let _useAsyncInit = (~init, ~errMsgPrefix=?, ~notify, ()) => {
  let (ready, setReady) = React.useState(_ => false)

  let formatMsg = React.useCallback1(
    exn =>
      errMsgPrefix->Belt.Option.mapWithDefault(exn->Helpers.getMessage, msg =>
        msg ++ " " ++ exn->Helpers.getMessage
      ),
    [errMsgPrefix],
  )

  React.useEffect4(() => {
    init()
    ->Promise.thenResolve(_ => {
      setReady(_ => true)
    })
    ->Promise.catch(exn => {
      exn->formatMsg->notify

      Promise.resolve()
    })
    ->ignore
    None
  }, (notify, setReady, init, formatMsg))
  ready
}

let useAsyncInit = (~init, ~errMsgPrefix=?, ()) => {
  let notify = SnackBar.useNotification()
  _useAsyncInit(~init, ~errMsgPrefix?, ~notify, ())
}
