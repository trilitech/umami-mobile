/*
Encrypt the backup phrase in AES.
Store the backup phrase in the Filestem.
*/

exception BackupPhraseError(string)
@scope("JSON") @val
external parseBackupPhrase: string => AES.aesEncrypted = "parse"

let save = (backupPhrase: string, password: string) => {
  AESCrypto.encrypt(backupPhrase, password)->Promise.then(encrypted => {
    switch Js.Json.stringifyAny(encrypted) {
    | Some(d) => Storage.set("backupPhrase", d)
    | None => Promise.reject(BackupPhraseError("Failed to parse backup phrase"))
    }
  })
}

let getFriendlyMsg = (msg: string) => {
  if msg |> Js.Re.test_(%re("/^decrypt failed/i")) {
    ErrorMsgs.wrongPassword
  } else {
    msg
  }
}
let load = password => {
  Storage.get("backupPhrase")
  ->Promise.then(encrypted =>
    switch encrypted {
    | Some(s) => {
        let encrypted = parseBackupPhrase(s)
        AESCrypto.decrypt(encrypted, password)
      }
    | None => Promise.reject(BackupPhraseError("Failed to load backup phrase"))
    }
  )
  ->Promise.catch(exn => exn->Helpers.getMessage->getFriendlyMsg->Js.Exn.raiseError)
}

let erase = () => Storage.remove("backupPhrase")

let validatePassword = (password: string) => load(password)->Promise.thenResolve(_ => true)
