import * as Jest from '@glennsl/rescript-jest/src/jest.bs.js';

import {expect} from '@jest/globals';

export const toHaveTextContent = (el, str) => {
  expect(el).toHaveTextContent(str);
};
export const toHaveProp = (el, prop, value) => {
  expect(el).toHaveProp(prop, value);
};

export const dummyAssertion = Jest.Expect.toEqual(
  Jest.Expect.expect(true),
  true,
);
