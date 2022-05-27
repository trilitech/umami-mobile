let usePrevious = val => {
  let ref = React.useRef(None)
  React.useEffect(() => {
    ref.current = Some(val)
    None
  })
  ref.current
}
