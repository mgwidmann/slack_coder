import { refreshToken, setLoggedIn, setLoggedOut, setOffline } from '../shared/actions/login';
import { NetInfo } from 'react-native';
import Config from 'react-native-config';

export default function(client, store) {
  // Setup client interface
  const login = () => {
    store.dispatch(setLoggedIn());
  };
  const logout = () => {
    store.dispatch(setLoggedOut());
    let { token, offline } = store.getState().login;
    if (token && !offline) {
      // Attempt to refresh the token
      const refreshUrl = `${Config.SLACK_CODER_HTTP_PROTOCOL}://${Config.SLACK_CODER_HOST}/api/token/${store.getState().login.token}/refresh`;
      store.dispatch(refreshToken(refreshUrl));
    }
  };
  const handleOffline = ({ type }) => {
    if (type === 'none') {
      store.dispatch(setOffline());
    }
  };
  NetInfo.addEventListener('connectionChange', handleOffline);
  NetInfo.getConnectionInfo().then(handleOffline);

  // Set the token on the options so when the socket is created it has access
  client.networkInterface.use([{
    applyMiddleware({ request, options }, next) {
      options.token = store.getState().login.token;
      options.login = login;
      options.logout = logout;
      next()
    }
  }]);
}