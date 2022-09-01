export const parse = require('./encryptSK').parse;

export const toUnitArrayStringRep = str => parse(str).toString();
