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

export const create = (pk, pkh) => new NoopSigner(pk, pkh);
