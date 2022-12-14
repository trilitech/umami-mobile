let withCache = (fn: 'a => Promise.t<'b>, serializer: 'a => string) => {
  let hashMap = Belt.HashMap.String.fromArray([])

  arg => {
    let args = serializer(arg)

    Promise.make((resolve, reject) => {
      switch hashMap->Belt.HashMap.String.get(args) {
      | Some(val) => resolve(. val)
      | None =>
        fn(arg)
        ->Promise.thenResolve(res => {
          hashMap->Belt.HashMap.String.set(args, res)
          resolve(. res)
        })
        ->Promise.catch(exn => {
          reject(. exn)
          Promise.resolve()
        })
        ->ignore
      }
    })
  }
}
