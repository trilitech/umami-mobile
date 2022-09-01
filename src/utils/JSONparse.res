@scope("JSON") @val
external unsafeJSONParse: string => 'a = "parse"

@scope("JSON") @val
external stringify: 'a => string = "stringify"
