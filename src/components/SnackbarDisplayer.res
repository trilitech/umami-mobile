@react.component
let make = (~children) => {
  let (message, setMessage) = Store.useSnackBar()

  let visible = Belt.Option.isSome(message)

  let message = switch message {
  | Some(el) => el
  | None => React.null
  }

  open ReactNative.Style
  let backgroundColor = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.surface

  open Paper
  <>
    {children}
    <Snackbar
      duration={Snackbar.Duration.value(5000)}
      style={style(~backgroundColor, ())}
      visible
      action={Snackbar.Action.make(~label="Dismiss", ~onPress=() => {
        setMessage(_ => None)
        ()
      })}
      onDismiss={() => {
        setMessage(_ => None)
        ()
      }}>
      {message}
    </Snackbar>
  </>
}
