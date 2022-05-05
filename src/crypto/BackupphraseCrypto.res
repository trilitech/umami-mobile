open AES
let encrypt = (phrase: string, key: string) =>
  generateKey(key, "salt", 5000, 256)->Promise.then(key => encryptData(phrase, key))

let decrypt = (encrypted, key) => {
  generateKey(key, "salt", 5000, 256)->Promise.then(key => decryptData(encrypted, key))
}
