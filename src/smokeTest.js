import Aes from 'react-native-aes-crypto';

const encryptData = (text, key) => {
  return Aes.randomKey(16).then(iv => {
    return Aes.encrypt(text, key, iv, 'aes-256-cbc').then(cipher => ({
      cipher,
      iv,
    }));
  });
};

const decryptData = (encryptedData, key) =>
  Aes.decrypt(encryptedData.cipher, key, encryptedData.iv, 'aes-256-cbc');

encryptData('hello world', 'password').then(res => {
  console.log(res);

  decryptData(res.cipher, 'password').then(text => {
    console.log('Decrypted:', text);
  });
});

const generateKey = (password, salt, cost, length) =>
  Aes.pbkdf2(password, salt, cost, length);

generateKey('Arnold', 'salt', 5000, 256).then(key => {
  console.log('Key:', key);
  encryptData('These violent delights have violent ends', key)
    .then(({cipher, iv}) => {
      console.log('Encrypted:', cipher);

      decryptData({cipher, iv}, key)
        .then(text => {
          console.log('Decrypted:', text);
        })
        .catch(error => {
          console.log(error);
        });

      Aes.hmac256(cipher, key).then(hash => {
        console.log('HMAC', hash);
      });
    })
    .catch(error => {
      console.log(error);
    });
});
