type aesEncrypted
type aesKey

@module("./js/aes")
external generateKey: (string, string, int, int) => Promise.t<aesKey> = "generateKey"

@module("./js/aes")
external encryptData: (string, aesKey) => Promise.t<aesEncrypted> = "encryptData"

@module("./js/aes")
external decryptData: (aesEncrypted, aesKey) => Promise.t<string> = "decryptData"
