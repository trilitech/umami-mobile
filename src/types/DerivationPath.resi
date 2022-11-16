type t
let build: string => result<t, string>
let unsafeBuild: string => t
let getByIndex: (t, int) => string
let default: t
let save: t => Promise.t<unit>
let load: unit => Promise.t<t>
let erase: unit => Promise.t<unit>
