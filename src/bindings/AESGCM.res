@module("./js/aesGCM")
external decrypt: (
  ~data: string,
  ~iv: string,
  ~salt: string,
  ~password: string,
) => Promise.t<string> = "decrypt"
