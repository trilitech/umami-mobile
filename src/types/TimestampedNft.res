open TimestampedData
module Decode = {
  open JsonCombinators.Json.Decode

  open Token
  let nftData = object(field => {
    tokenId: field.required(. "tokenId", string),
    contract: field.required(. "contract", string),
    balance: field.required(. "balance", int),
  })

  let timeStampedNftData = object(field => {
    date: field.required(. "date", string),
    data: field.required(. "data", nftData),
  })

  let decode = (data: string) =>
    try {
      let json = data->JsonCombinators.Json.parseExn
      json->JsonCombinators.Json.decode(timeStampedNftData)
    } catch {
    | _ => Error("Failed to parse timeStampedNft")
    }
}
