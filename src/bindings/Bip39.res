@module("bip39") external generate: int => string = "generateMnemonic"
@module("bip39") external entropyToMnemonic: 'a => string = "entropyToMnemonic"

@module("bip39") @scope("wordlists")
external wordlistsEnglish: array<string> = "english"

@module("bip39")
external seed: string => Buffer.t = "mnemonicToSeedSync"
