open Belt
type raw = {path: string, content: string}

type logLevel = Debug | Info | Warn | Error_

type logPayload = {
  level: logLevel,
  date: string,
  message: string,
}

type log = (string, array<logPayload>)

%%private(
  let parseLogLevel = (str: string) => {
    switch str {
    | "[INFO]" => Info->Some
    | "[DEBUG]" => Debug->Some
    | "[ERROR]" => Error_->Some
    | "[WARN]" => Warn->Some
    | _ => None
    }
  }

  let unescapeNewLines = (str: string) => str->Js.String2.replaceByRe(%re("/\\\\n/g"), "\n")

  let lineParseResultToLog = (result: array<option<string>>) => {
    switch (
      result->Array.get(1)->Option.getWithDefault(None),
      result->Array.get(2)->Option.getWithDefault(None),
      result->Array.get(3)->Option.getWithDefault(None),
    ) {
    | (Some(date), Some(level), Some(message)) => {
        let message = unescapeNewLines(message)
        parseLogLevel(level)->Option.map(level => {
          level: level,
          date: date,
          message: message,
        })
      }
    | _ => None
    }
  }

  let parseLine = (line: string) => {
    let regex = %re(`/(\d{4}-[01]\d-[0-3]\dT.*) (\[DEBUG\]|\[INFO\]|\[WARN\]|\[ERROR\]) (.*)/`)
    Js.Re.exec_(regex, line)
    ->Option.map(res => Js.Re.captures(res)->Array.map(Js.Nullable.toOption))
    ->Option.map(lineParseResultToLog)
  }
)

let parseLogContent = (fileContent: string) =>
  fileContent->Js.String2.split("\n")->Array.map(parseLine)->Helpers.filterNone->Helpers.filterNone

let parseLogs = (logs: array<raw>) => logs->Array.map(r => (r.path, parseLogContent(r.content)))
