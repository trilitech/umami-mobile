type t

@module("moment")
external create: string => t = "default"

@send
external fromNow: (t, unit) => string = "fromNow"

let getRelativeDate = (dateStr: string) => create(dateStr)->fromNow()
