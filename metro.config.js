/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const path = require('path');
// If you ever want to import files from outside the project
// const watchFolders = [path.resolve(__dirname + '/../common')];

module.exports = {
  // watchFolders,
  resolver: {
    extraNodeModules: new Proxy(
      {
        stream: path.resolve(__dirname, './node_modules/readable-stream'),
      },
      {
        get: (target, name) => {
          if (target.hasOwnProperty(name)) {
            return target[name];
          }
          return path.join(process.cwd(), `node_modules/${name}`);
        },
      },
    ),
  },
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
};
