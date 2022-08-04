// import {logger, fileAsyncTransport} from 'react-native-logs';
import RNFS from 'react-native-fs';

import {FileLogger} from 'react-native-file-logger';

const logsDirectory = RNFS.TemporaryDirectoryPath + '/logs';

export const init = () => {
  FileLogger.configure({
    captureConsole: false,
    dailyRolling: true,
    maximumFileSize: 1024 * 1024, //1M
    maximumNumberOfFiles: 50,
    logsDirectory,
  });
};

const escapeNewLines = str => str.replace(/\n/g, '\\n');
export const debug = msg => FileLogger.debug(escapeNewLines(msg));
export const info = msg => FileLogger.info(escapeNewLines(msg));
export const warn = msg => FileLogger.warn(escapeNewLines(msg));
export const error = msg => FileLogger.error(escapeNewLines(msg));

export const readLogs = () => {
  return RNFS.readDir(logsDirectory).then(res => {
    const paths = res.map(dirItem => dirItem.path);
    return Promise.all(paths.map(RNFS.readFile)).then(contents => {
      return contents.reduce((acc, curr, i) => {
        return [
          ...acc,
          {
            path: paths[i],
            content: curr,
          },
        ];
      }, []);
    });
  });
};
export const deleteLogs = () => FileLogger.deleteLogFiles();
