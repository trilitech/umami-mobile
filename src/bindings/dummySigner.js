class NoopSigner {
  constructor(pk, pkh) {
    this.pk = pk;
    this.pkh = pkh;
  }
  async publicKey() {
    return this.pk;
  }
  async publicKeyHash() {
    return this.pkh;
  }
}

let dummyPk = 'foo';
const dummyPkh = 'tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6';
export const create = () => new NoopSigner(dummyPk, dummyPkh);
