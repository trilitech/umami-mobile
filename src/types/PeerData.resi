type t

let toString: t => string

let unsafeBuild: string => t

let buildFromUri: string => option<t>
