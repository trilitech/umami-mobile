(function (global, factory) {
  typeof exports === "object" && typeof module !== "undefined"
    ? factory(
        exports,
        require("@stablelib/nacl"),
        require("@stablelib/blake2b"),
        require("@taquito/utils"),
        require("typedarray-to-buffer"),
        require("@stablelib/ed25519"),
        require("elliptic"),
        require("pbkdf2"),
      )
    : typeof define === "function" && define.amd
    ? define(
        [
          "exports",
          "@stablelib/nacl",
          "@stablelib/blake2b",
          "@taquito/utils",
          "typedarray-to-buffer",
          "@stablelib/ed25519",
          "elliptic",
          "pbkdf2",
        ],
        factory,
      )
    : ((global =
        typeof globalThis !== "undefined" ? globalThis : global || self),
      factory(
        (global.taquitoSigner = {}),
        global.nacl,
        global.blake2b,
        global.utils,
        global.toBuffer,
        global.ed25519,
        global.elliptic,
        global.pbkdf2,
      ));
})(
  this,
  function (
    exports,
    nacl,
    blake2b,
    utils,
    toBuffer,
    ed25519,
    elliptic,
    pbkdf2,
  ) {
    "use strict";

    function _interopDefaultLegacy(e) {
      return e && typeof e === "object" && "default" in e ? e : { default: e };
    }

    var toBuffer__default = /*#__PURE__*/ _interopDefaultLegacy(toBuffer);
    var elliptic__default = /*#__PURE__*/ _interopDefaultLegacy(elliptic);
    var pbkdf2__default = /*#__PURE__*/ _interopDefaultLegacy(pbkdf2);

    /*! *****************************************************************************
    Copyright (c) Microsoft Corporation.

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    ***************************************************************************** */

    function __awaiter(thisArg, _arguments, P, generator) {
      function adopt(value) {
        return value instanceof P
          ? value
          : new P(function (resolve) {
              resolve(value);
            });
      }
      return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) {
          try {
            step(generator.next(value));
          } catch (e) {
            reject(e);
          }
        }
        function rejected(value) {
          try {
            step(generator["throw"](value));
          } catch (e) {
            reject(e);
          }
        }
        function step(result) {
          result.done
            ? resolve(result.value)
            : adopt(result.value).then(fulfilled, rejected);
        }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
      });
    }

    /**
     * @description Provide signing logic for ed25519 curve based key (tz1)
     */
    class Tz1 {
      /**
       *
       * @param key Encoded private key
       * @param encrypted Is the private key encrypted
       * @param decrypt Decrypt function
       */
      constructor(key, encrypted, decrypt) {
        this.key = key;
        const keyPrefix = key.substr(0, encrypted ? 5 : 4);
        if (!utils.isValidPrefix(keyPrefix)) {
          throw new utils.InvalidKeyError(key, "Key contains invalid prefix");
        }
        this._key = decrypt(
          utils.b58cdecode(this.key, utils.prefix[keyPrefix]),
        );
        this._publicKey = this._key.slice(32);
        if (!this._key) {
          throw new utils.InvalidKeyError(key, "Unable to decode");
        }
        this.isInit = this.init();
      }
      init() {
        return __awaiter(this, void 0, void 0, function* () {
          if (this._key.length !== 64) {
            const { publicKey, secretKey } = ed25519.generateKeyPairFromSeed(
              new Uint8Array(this._key),
            );
            this._publicKey = publicKey;
            this._key = secretKey;
          }
          return true;
        });
      }
      /**
       *
       * @param bytes Bytes to sign
       * @param bytesHash Blake2b hash of the bytes to sign
       */
      sign(bytes, bytesHash) {
        return __awaiter(this, void 0, void 0, function* () {
          yield this.isInit;
          const signature = ed25519.sign(
            new Uint8Array(this._key),
            new Uint8Array(bytesHash),
          );
          const signatureBuffer = toBuffer__default["default"](signature);
          const sbytes = bytes + utils.buf2hex(signatureBuffer);
          return {
            bytes,
            sig: utils.b58cencode(signature, utils.prefix.sig),
            prefixSig: utils.b58cencode(signature, utils.prefix.edsig),
            sbytes,
          };
        });
      }
      /**
       * @returns Encoded public key
       */
      publicKey() {
        return __awaiter(this, void 0, void 0, function* () {
          yield this.isInit;
          return utils.b58cencode(this._publicKey, utils.prefix["edpk"]);
        });
      }
      /**
       * @returns Encoded public key hash
       */
      publicKeyHash() {
        return __awaiter(this, void 0, void 0, function* () {
          yield this.isInit;
          return utils.b58cencode(
            blake2b.hash(new Uint8Array(this._publicKey), 20),
            utils.prefix.tz1,
          );
        });
      }
      /**
       * @returns Encoded private key
       */
      secretKey() {
        return __awaiter(this, void 0, void 0, function* () {
          yield this.isInit;
          let key = this._key;
          const { secretKey } = ed25519.generateKeyPairFromSeed(
            new Uint8Array(key).slice(0, 32),
          );
          key = toBuffer__default["default"](secretKey);
          return utils.b58cencode(key, utils.prefix[`edsk`]);
        });
      }
    }

    const pref = {
      p256: {
        pk: utils.prefix["p2pk"],
        sk: utils.prefix["p2sk"],
        pkh: utils.prefix.tz3,
        sig: utils.prefix.p2sig,
      },
      secp256k1: {
        pk: utils.prefix["sppk"],
        sk: utils.prefix["spsk"],
        pkh: utils.prefix.tz2,
        sig: utils.prefix.spsig,
      },
    };
    /**
     * @description Provide signing logic for elliptic curve based key (tz2, tz3)
     */
    class ECKey {
      /**
       *
       * @param curve Curve to use with the key
       * @param key Encoded private key
       * @param encrypted Is the private key encrypted
       * @param decrypt Decrypt function
       */
      constructor(curve, key, encrypted, decrypt) {
        this.curve = curve;
        this.key = key;
        const keyPrefix = key.substr(0, encrypted ? 5 : 4);
        if (!utils.isValidPrefix(keyPrefix)) {
          throw new utils.InvalidKeyError(key, "Key contains invalid prefix");
        }
        this._key = decrypt(
          utils.b58cdecode(this.key, utils.prefix[keyPrefix]),
        );
        const keyPair = new elliptic__default["default"].ec(
          this.curve,
        ).keyFromPrivate(this._key);
        const keyPairY = keyPair.getPublic().getY().toArray();
        const parityByte =
          keyPairY.length < 32 ? keyPairY[keyPairY.length - 1] : keyPairY[31];
        const pref = parityByte % 2 ? 3 : 2;
        const pad = new Array(32).fill(0);
        this._publicKey = toBuffer__default["default"](
          new Uint8Array(
            [pref].concat(
              pad.concat(keyPair.getPublic().getX().toArray()).slice(-32),
            ),
          ),
        );
      }
      /**
       *
       * @param bytes Bytes to sign
       * @param bytesHash Blake2b hash of the bytes to sign
       */
      sign(bytes, bytesHash) {
        return __awaiter(this, void 0, void 0, function* () {
          const key = new elliptic__default["default"].ec(
            this.curve,
          ).keyFromPrivate(this._key);
          const sig = key.sign(bytesHash, { canonical: true });
          const signature =
            sig.r.toString("hex", 64) + sig.s.toString("hex", 64);
          const sbytes = bytes + signature;
          return {
            bytes,
            sig: utils.b58cencode(signature, utils.prefix.sig),
            prefixSig: utils.b58cencode(signature, pref[this.curve].sig),
            sbytes,
          };
        });
      }
      /**
       * @returns Encoded public key
       */
      publicKey() {
        return __awaiter(this, void 0, void 0, function* () {
          return utils.b58cencode(this._publicKey, pref[this.curve].pk);
        });
      }
      /**
       * @returns Encoded public key hash
       */
      publicKeyHash() {
        return __awaiter(this, void 0, void 0, function* () {
          return utils.b58cencode(
            blake2b.hash(new Uint8Array(this._publicKey), 20),
            pref[this.curve].pkh,
          );
        });
      }
      /**
       * @returns Encoded private key
       */
      secretKey() {
        return __awaiter(this, void 0, void 0, function* () {
          const key = this._key;
          return utils.b58cencode(key, pref[this.curve].sk);
        });
      }
    }
    /**
     * @description Tz3 key class using the p256 curve
     */
    const Tz3 = ECKey.bind(null, "p256");
    /**
     * @description Tz3 key class using the secp256k1 curve
     */
    const Tz2 = ECKey.bind(null, "secp256k1");

    /* Copyright (c) 2014, Wei Lu <luwei.here@gmail.com> and Daniel Cousens <email@dcousens.com>

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted, provided that the above
    copyright notice and this permission notice appear in all copies. */
    function mnemonicToSeedSync(mnemonic, password) {
      const mnemonicBuffer = Buffer.from(normalize(mnemonic), "utf8");
      const saltBuffer = Buffer.from(salt(normalize(password)), "utf8");
      return pbkdf2__default["default"].pbkdf2Sync(
        mnemonicBuffer,
        saltBuffer,
        2048,
        64,
        "sha512",
      );
    }
    function normalize(str) {
      return (str || "").normalize("NFKD");
    }
    function salt(password) {
      return "mnemonic" + (password || "");
    }

    /**
     *
     * @description Import a key to sign operation with the side-effect of setting the Tezos instance to use the InMemorySigner provider
     *
     * @param toolkit The toolkit instance to attach a signer
     * @param privateKeyOrEmail Key to load in memory
     * @param passphrase If the key is encrypted passphrase to decrypt it
     * @param mnemonic Faucet mnemonic
     * @param secret Faucet secret
     */
    function importKey(
      toolkit,
      privateKeyOrEmail,
      passphrase,
      mnemonic,
      secret,
    ) {
      return __awaiter(this, void 0, void 0, function* () {
        if (privateKeyOrEmail && passphrase && mnemonic && secret) {
          const signer = InMemorySigner.fromFundraiser(
            privateKeyOrEmail,
            passphrase,
            mnemonic,
          );
          toolkit.setProvider({ signer });
          const pkh = yield signer.publicKeyHash();
          let op;
          try {
            op = yield toolkit.tz.activate(pkh, secret);
          } catch (ex) {
            const isInvalidActivationError =
              ex && ex.body && /Invalid activation/.test(ex.body);
            if (!isInvalidActivationError) {
              throw ex;
            }
          }
          if (op) {
            yield op.confirmation();
          }
        } else {
          // Fallback to regular import
          const signer = yield InMemorySigner.fromSecretKey(
            privateKeyOrEmail,
            passphrase,
          );
          toolkit.setProvider({ signer });
        }
      });
    }

    // IMPORTANT: THIS FILE IS AUTO GENERATED! DO NOT MANUALLY EDIT OR CHECKIN!
    const VERSION = {
      commitHash: "cbdd0af87e400489076259d065e2d328feb8e1b4",
      version: "12.1.0",
    };

    /**
     *  @category Error
     *  @description Error that indicates an invalid passphrase being passed or used
     */
    class InvalidPassphraseError extends Error {
      constructor(message) {
        super(message);
        this.message = message;
        this.name = "InvalidPassphraseError";
      }
    }
    /**
     * @description A local implementation of the signer. Will represent a Tezos account and be able to produce signature in its behalf
     *
     * @warn If running in production and dealing with tokens that have real value, it is strongly recommended to use a HSM backed signer so that private key material is not stored in memory or on disk
     *
     */
    class InMemorySigner {
      /**
       *
       * @param key Encoded private key
       * @param passphrase Passphrase to decrypt the private key if it is encrypted
       *
       */
      constructor(key, passphrase) {
        const encrypted = key.substring(2, 3) === "e";
        let decrypt = (k) => k;
        if (encrypted) {
          if (!passphrase) {
            throw new InvalidPassphraseError(
              "Encrypted key provided without a passphrase.",
            );
          }
          decrypt = (constructedKey) => {
            const salt = toBuffer__default["default"](
              constructedKey.slice(0, 8),
            );
            const encryptedSk = constructedKey.slice(8);
            const encryptionKey = pbkdf2__default["default"].pbkdf2Sync(
              passphrase,
              salt,
              32768,
              32,
              "sha512",
            );
            return nacl.openSecretBox(
              new Uint8Array(encryptionKey),
              new Uint8Array(24),
              new Uint8Array(encryptedSk),
            );
          };
        }
        switch (key.substr(0, 4)) {
          case "edes":
          case "edsk":
            this._key = new Tz1(key, encrypted, decrypt);
            break;
          case "spsk":
          case "spes":
            this._key = new Tz2(key, encrypted, decrypt);
            break;
          case "p2sk":
          case "p2es":
            this._key = new Tz3(key, encrypted, decrypt);
            break;
          default:
            throw new utils.InvalidKeyError(key, "Unsupported key type");
        }
      }
      static fromFundraiser(email, password, mnemonic) {
        const seed = mnemonicToSeedSync(mnemonic, `${email}${password}`);
        const key = utils.b58cencode(seed.slice(0, 32), utils.prefix.edsk2);
        return new InMemorySigner(key);
      }
      static fromSecretKey(key, passphrase) {
        return __awaiter(this, void 0, void 0, function* () {
          return new InMemorySigner(key, passphrase);
        });
      }
      /**
       *
       * @param bytes Bytes to sign
       * @param watermark Watermark to append to the bytes
       */
      sign(bytes, watermark) {
        return __awaiter(this, void 0, void 0, function* () {
          let bb = utils.hex2buf(bytes);
          if (typeof watermark !== "undefined") {
            bb = utils.mergebuf(watermark, bb);
          }
          const bytesHash = blake2b.hash(bb, 32);
          return this._key.sign(bytes, bytesHash);
        });
      }
      /**
       * @returns Encoded public key
       */
      publicKey() {
        return __awaiter(this, void 0, void 0, function* () {
          return this._key.publicKey();
        });
      }
      /**
       * @returns Encoded public key hash
       */
      publicKeyHash() {
        return __awaiter(this, void 0, void 0, function* () {
          return this._key.publicKeyHash();
        });
      }
      /**
       * @returns Encoded private key
       */
      secretKey() {
        return __awaiter(this, void 0, void 0, function* () {
          return this._key.secretKey();
        });
      }
    }

    exports.InMemorySigner = InMemorySigner;
    exports.InvalidPassphraseError = InvalidPassphraseError;
    exports.VERSION = VERSION;
    exports.importKey = importKey;

    Object.defineProperty(exports, "__esModule", { value: true });
  },
);
//# sourceMappingURL=taquito-signer.umd.js.map