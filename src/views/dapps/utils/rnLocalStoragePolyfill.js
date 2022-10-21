import 'localstorage-polyfill';
import AsyncStorage from '@react-native-async-storage/async-storage';

global.localStorage = new Proxy(global.localStorage, {
  get: function (target, name) {
    if (name === 'setItem') {
      return (key, val) => {
        AsyncStorage.setItem(key, val);
        return target[name](key, val);
      };
    }
    return target[name];
  },
});

const getBeaconKeys = () =>
  new Promise((res, rej) => {
    AsyncStorage.getAllKeys((_, keys) => {
      const bKeys = keys.filter(k => k.startsWith('beacon:'));
      res(bKeys);
    });
  });

const restoreKey = key =>
  AsyncStorage.getItem(key).then(val => global.localStorage.setItem(key, val));

export const hydrateLocalStorage = () =>
  getBeaconKeys().then(keys => Promise.all(keys.map(restoreKey)));
