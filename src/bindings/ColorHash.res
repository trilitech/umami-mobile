type t

@module("color-hash") @new
external create: unit => t = "default"
let colorHash = create()

@send
external hex: (t, string) => string = "hex"

let instance = create()
let generateColor = (str: string) => instance->hex(str)
