@module("./encryptSK") external encryptSK: (Buffer.t, string) => Promise.t<'a> = "encryptSK"

@module("./encryptSK") external encryptEasy: (string, string) => Promise.t<string> = "encryptEasy"
@module("./encryptSK") external decryptEasy: (string, string) => Promise.t<string> = "decryptEasy"
