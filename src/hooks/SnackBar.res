open Paper
let useNotification = () => {
  let (_, setMessage) = Store.useSnackBar()
  s => setMessage(_ => Some(<Text> {React.string(s)} </Text>))
}

let useNotificationAdvanced = _ => {
  let (_, setMessage) = Store.useSnackBar()
  s => setMessage(_ => s)
}
