export const decrypt = async (data, iv, salt, password) => {
  const buffer = Buffer.alloc(32, password);
  const key = await crypto.subtle.importKey('raw', buffer, 'PBKDF2', false, [
    'deriveBits',
    'deriveKey',
  ]);

  const derivedKey = await crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: Buffer.from(salt, 'hex'),
      iterations: 10000,
      hash: 'SHA-256',
    },
    key,
    {
      name: 'AES-GCM',
      length: 256,
    },
    true,
    ['encrypt', 'decrypt'],
  );

  const decrypted = await crypto.subtle.decrypt(
    {
      name: 'AES-GCM',
      iv: Buffer.from(iv, 'hex'),
    },
    derivedKey,
    Buffer.from(data, 'hex'),
  );

  return Buffer.from(decrypted).toString('utf8');
};
