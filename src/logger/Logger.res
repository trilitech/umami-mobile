open Belt
@module("./js/logger")
external debug: string => unit = "debug"

@module("./js/logger")
external info: string => unit = "info"

@module("./js/logger")
external warn: string => unit = "warn"

@module("./js/logger")
external error: string => unit = "error"

@module("./js/logger")
external init: unit => Promise.t<unit> = "init"

@module("./js/logger")
external _readLogs: unit => Promise.t<array<LoggerFns.raw>> = "readLogs"

@module("./js/logger")
external deleteLogs: unit => Promise.t<unit> = "deleteLogs"

let readLogs = () => _readLogs()->Promise.thenResolve(LoggerFns.parseLogs)

let readLogsWithoutPaths = () =>
  readLogs()->Promise.thenResolve(logsWithPath =>
    logsWithPath->Array.reduce([], (acc, (_path, logData)) => Array.concat(acc, logData))
  )
