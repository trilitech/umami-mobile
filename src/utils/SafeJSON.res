let parse = (data: string) => {
  try {
    let json = data->JsonCombinators.Json.parseExn
    json->Ok
  } catch {
  | e => Error("Unabled to parse string. Reason: " ++ e->Helpers.getMessage)
  }
}
