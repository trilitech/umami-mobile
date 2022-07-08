import Base64 from 'base64-js';
import {pbkdf2} from 'react-native-fast-crypto';
import Sodium from 'react-native-sodium';
var bs58check = require('bs58check');

function b58cencode(data, prefix) {
  // eslint-disable-next-line no-bitwise
  var buffer = new Uint8Array((prefix.length + data.length) | 0);
  buffer.set(prefix);
  buffer.set(data, prefix.length);
  // eslint-disable-next-line no-undef
  return bs58check.encode(Buffer.from(buffer, 'hex'));
}

const parse = text => {
  const byteString = encodeURI(text);
  const out = new Uint8Array(byteString.length);

  // Treat each character as a byte, except for %XX escape sequences:
  let di = 0; // Destination index
  for (let i = 0; i < byteString.length; ++i) {
    const c = byteString.charCodeAt(i);
    if (c === 0x25) {
      out[di++] = parseInt(byteString.slice(i + 1, i + 3), 16);
      i += 2;
    } else {
      out[di++] = c;
    }
  }

  // Trim any over-allocated space (zero-copy):
  return out.subarray(0, di);
};

function mergebuf(b1, b2) {
  // eslint-disable-next-line no-bitwise
  var r = new Uint8Array((b1.length + b2.length) | 0);
  r.set(b1);
  r.set(b2, b1.length);
  return r;
}

export const encryptSK = (sk, password) => {
  return Sodium.randombytes_buf(8)
    .then(saltStr => {
      const salt = Base64.toByteArray(saltStr);
      return pbkdf2
        .deriveAsync(parse(password), salt, 32768, 32, 'sha512')
        .then(derivedPassphrase => {
          return Sodium.crypto_secretbox_easy(
            Base64.fromByteArray(sk),
            Base64.fromByteArray(new Uint8Array(24)),
            Base64.fromByteArray(derivedPassphrase),
          ).then(boxed => {
            const encryptedSK = b58cencode(
              mergebuf(salt, Base64.toByteArray(boxed)),
              [7, 90, 60, 179, 41],
            );

            return encryptedSK;
          });
        });
    })
    .catch(console.error);
};
