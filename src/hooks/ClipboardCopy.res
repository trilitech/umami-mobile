let useCopy = () => {
  let notify = SnackBar.useNotification()
  str => {
    Clipboard.setString(str)
    notify("Address copied to clipbloard")
  }
}
