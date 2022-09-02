type t

let toString: t => string

let unsafeBuild: string => t

let build: string => result<t, string>
let buildOption: string => option<t>
let buildFromPk: string => t

let toPretty: t => string

let notKt: t => bool
