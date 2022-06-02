import {LogBox} from 'react-native';

LogBox.ignoreLogs([
  'ViewPropTypes will be removed',
  'ColorPropType will be removed',
  'Sending `onAnimatedValueUpdate` with no listeners registered',
]);
