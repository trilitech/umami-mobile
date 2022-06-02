/**
 * @format
 */

// This is broken
// import {CATALOG} from '@env';

import Catalog from './Catalog';

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

const CATALOG = false;
AppRegistry.registerComponent(appName, () => (CATALOG ? Catalog : App));
