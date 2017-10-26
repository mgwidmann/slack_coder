import store from './store';
import { refreshToken, online, reconnecting, offline } from '../shared/actions/login';
import { NetInfo } from 'react-native';
import Config from 'react-native-config';

NetInfo.addEventListener('connectionChange', handleOffline);

export function connectionOnline() {
  store.dispatch(online());
}

export function reconnect() {
  let { token, offline } = store.getState().login;
  if (token && !offline) {
    store.dispatch(reconnecting());
    // Attempt to refresh the token
    const refreshUrl = `${Config.SLACK_CODER_HTTP_PROTOCOL}://${Config.SLACK_CODER_HOST}/api/token/${store.getState().login.token}/refresh`;
    store.dispatch(refreshToken(refreshUrl));
  }
}

export function connectionOffline() {
  store.dispatch(offline());
}

export function handleOffline({ type }) {
  if (type === 'none') {
    store.dispatch(offline());
  } else {
    store.dispatch(reconnecting());
    reconnect();
  }
}

export function token() {
  return store.getState().login.token;
}
