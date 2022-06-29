/*
Encrypt the backup phrase in AES.
Store the backup phrase in the Filestem.
*/

exception BackupPhraseError(string)

let save = (backupPhrase: string, passphrase: string) => {
  AESCrypto.encrypt(backupPhrase, passphrase)->Promise.then(encrypted => {
    switch Js.Json.stringifyAny(encrypted) {
    | Some(d) => Storage.set("backupPhrase", d)
    | None => Promise.reject(BackupPhraseError("Failed to parse backup phrase"))
    }
  })
}

@scope("JSON") @val
external parseBackupPhrase: string => AES.aesEncrypted = "parse"

let load = passphrase => {
  Storage.get("backupPhrase")->Promise.then(encrypted =>
    switch encrypted {
    | Some(s) => {
        let encrypted = parseBackupPhrase(s)
        AESCrypto.decrypt(encrypted, passphrase)
      }
    | None => Promise.reject(BackupPhraseError("Failed to load backup phrase"))
    }
  )
}
