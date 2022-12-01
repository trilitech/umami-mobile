let _useAsyncInit = (~init, ~errMsgPrefix=?, ~notify, ()) => {
  let (ready, setReady) = React.useState(_ => false)

  let initRef = React.useRef(init)
  let formatMsg = React.useCallback1(
    exn =>
      errMsgPrefix->Belt.Option.mapWithDefault(exn->Helpers.getMessage, msg =>
        msg ++ " " ++ exn->Helpers.getMessage
      ),
    [errMsgPrefix],
  )

  React.useEffect3(() => {
    initRef.current()
    ->Promise.thenResolve(_ => {
      setReady(_ => true)
    })
    ->Promise.catch(exn => {
      exn->formatMsg->notify

      Promise.resolve()
    })
    ->ignore
    None
  }, (notify, setReady, formatMsg))
  ready
}

let useAsyncInit = (~init, ~errMsgPrefix=?, ()) => {
  let notify = SnackBar.useNotification()
  _useAsyncInit(~init, ~errMsgPrefix?, ~notify, ())
}
