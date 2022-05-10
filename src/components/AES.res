type aesEncrypted
type aesKey

@module("./aes")
external generateKey: (string, string, int, int) => Promise.t<aesKey> = "generateKey"

@module("./aes")
external encryptData: (string, aesKey) => Promise.t<aesEncrypted> = "encryptData"

@module("./aes")
external decryptData: (aesEncrypted, aesKey) => Promise.t<string> = "decryptData"
