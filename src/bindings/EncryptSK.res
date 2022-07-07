@module("./js/encryptSK") external encryptSK: (Buffer.t, string) => Promise.t<'a> = "encryptSK"

@module("./js/encryptSK")
external encryptEasy: (string, string) => Promise.t<string> = "encryptEasy"
@module("./js/encryptSK")
external decryptEasy: (string, string) => Promise.t<string> = "decryptEasy"
