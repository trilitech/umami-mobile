import Analytics from '@react-native-firebase/analytics';

export async function logSend() {
  return Analytics().logEvent('send');
}
