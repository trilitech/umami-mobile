let get = key => ReactNativeAsyncStorage.getItem(key)->Promise.thenResolve(Js.Null.toOption)
let set = (key, value) => ReactNativeAsyncStorage.setItem(key, value)
let remove = ReactNativeAsyncStorage.removeItem
