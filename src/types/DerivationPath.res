type t = string

let build = (str: string): result<t, string> => {
  if Js.Re.test_(%re("/m\/\d+'\/\d+'\/\?'\/\d+'/"), str) {
    Ok(str)
  } else {
    Error(`Invalid derivation path! ${str}`)
  }
}

let toString = (d: t): string => d

let unsafeBuild = (str: string): t => str

let getByIndex = (d: t, i: int) => d->toString->Js.String2.replace("?", i->Js.Int.toString)

let default = unsafeBuild("m/44'/1729'/?'/0'")

let save = t => Storage.set("derivationPath", t)

let load = () =>
  Storage.get("derivationPath")->Promise.thenResolve(d => d->Belt.Option.getWithDefault(default))

let erase = () => Storage.remove("derivationPath")
