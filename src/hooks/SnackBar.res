open Paper
let useNotification = () => {
  let (_, setMessage) = Store.useSnackBar()
  let callBack = React.useCallback1(
    s => setMessage(_ => Some(<Text> {React.string(s)} </Text>)),
    [setMessage],
  )
  callBack
}

let useNotificationAdvanced = _ => {
  let (_, setMessage) = Store.useSnackBar()

  let callBack = React.useCallback1(s => setMessage(_ => s), [setMessage])
  callBack
}
