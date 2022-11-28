import * as Jest from '@glennsl/rescript-jest/src/jest.bs.js';

import {expect} from '@jest/globals';

const dummyAssertion = Jest.Expect.toEqual(Jest.Expect.expect(true), true);

export const toHaveTextContent = (el, str) => {
  expect(el).toHaveTextContent(str);
  return dummyAssertion;
};
export const toHaveProp = (el, prop, value) => {
  expect(el).toHaveProp(prop, value);
  return dummyAssertion;
};
